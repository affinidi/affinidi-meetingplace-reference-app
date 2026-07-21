import 'dart:async';

import 'package:meeting_place_core/meeting_place_core.dart' as core;
import 'package:meeting_place_matrix/meeting_place_matrix.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../application/services/contacts_service/contacts_service.dart';
import '../../../../application/services/contacts_service/contacts_service_state.dart';
import '../../../../application/services/incoming_call_service/incoming_call_notifier.dart';
import '../../../../domain/models/contact_card/contact_card.dart';
import '../../../../infrastructure/extensions/contact_card_extensions.dart';
import '../../../../infrastructure/providers/app_logger_provider.dart';
import '../../../../infrastructure/providers/meeting_place_sdk_provider.dart';
import '../../../../infrastructure/services/call_audio_session_service/call_audio_session_service.dart';
import '../../../../infrastructure/services/permission_service/permission_service.dart';
import '../../../widgets/banners/active_call/active_call_controller.dart';
import '../../../widgets/banners/active_call/active_call_state.dart';
import '../../../widgets/call_ended/call_ended_controller.dart';
import 'audio_video_call_screen_state.dart';
import 'audio_video_call_state_update.dart';
import 'call_lifecycle_update.dart';
import 'call_media_update.dart';
import 'handlers/call_lifecycle_handler.dart';
import 'handlers/call_media_toggle_handler.dart';
import 'handlers/call_session_handler.dart';
import 'rules/call_ui_rules.dart';

part 'audio_video_call_screen_controller.g.dart';

@riverpod
class AudioVideoCallScreenController extends _$AudioVideoCallScreenController {
  static const _logKey = 'AudioVideoCallScreenController';

  late final _logger = ref.read(appLoggerProvider);

  MeetingPlaceMatrixSDK? _sdk;
  AudioVideoCallSession? _session;
  CallSessionHandler? _sessionHandler;
  StreamSubscription<String>? _contactCardUpdatedSub;
  StreamSubscription<CallParticipantEvent>? _participantEventSub;
  StreamSubscription<CallSignal>? _signalSub;
  bool _isDisposed = false;
  bool _isMinimizing = false;
  AudioVideoCallStatus _lastStatus = AudioVideoCallStatus.idle;
  bool _isGroupContact = false;
  String? _groupOfferLink;

  // Resolved once in build() from the contact's channel DID (falling back to
  // contactId). Cached as a field so disposal-safe paths never read ref.
  String? _cachedChannelDid;
  // Peer display name resolved once in build(), used by the post-dispose banner
  // registration where reading contact state via ref is unsafe.
  String _cachedPeerName = '';

  // Captured on minimize-dispose so the session can still be forwarded to the
  // banner controller after this provider is torn down.
  ActiveCallController? _pendingBannerController;
  // Last-known values snapshotted for the post-dispose banner registration.
  bool _lastIsAudioOnly = false;

  // The device's call role, mirrored from the session's authoritative ownRole.
  // True once the SDK reports this device opened the call (CallRole.caller).
  // Drives end-status resolution; the chat item itself is gated by the emitter.
  bool _isCaller = false;
  Set<String> _groupMemberDids = const <String>{};

  late final CallLifecycleHandler _lifecycleHandler;
  late final CallMediaToggleHandler _mediaHandler;

  @override
  set state(AudioVideoCallScreenState value) {
    if (!ref.mounted) return;
    _lastStatus = value.status;
    _lastIsAudioOnly = value.isAudioOnly;
    super.state = value;
    _syncActiveCallBanner(value);
  }

  @override
  AudioVideoCallScreenState build(String contactId) {
    final contact = ref.read(contactsServiceProvider).getContactById(contactId);
    _isGroupContact = contact?.isGroup ?? false;
    _groupOfferLink = contact?.offerLink;
    _cachedChannelDid = contact?.channelDid ?? contactId;
    _cachedPeerName = contact?.displayName ?? contact?.card.displayName ?? '';
    final incomingEvent = ref.read(incomingCallProvider).eventOrNull;
    final expectedOtherPartyDid = contact?.channelDid ?? contactId;
    final isAcceptedIncomingForThisScreen =
        incomingEvent != null &&
        incomingEvent.otherPartyPermanentChannelDid == expectedOtherPartyDid;

    if (_isGroupContact && contact != null) {
      _subscribeToGroupMemberCardUpdates();
      unawaited(_loadGroupMemberNames(contact.offerLink));
    }

    final audioSessionService = ref.read(
      callAudioSessionServiceProvider.notifier,
    );

    _lifecycleHandler = CallLifecycleHandler(
      logger: _logger,
      channelDid: _channelDid,
      audioSessionService: audioSessionService,
      getState: () => state,
      getSDK: () => _sdk,
      getSession: () => _session,
      setSession: (session) => _session = session,
      onUpdate: _applyLifecycleUpdate,
    );

    _mediaHandler = CallMediaToggleHandler(
      logger: _logger,
      getSession: () => _session,
      getPermissionService: () => ref.read(permissionServiceProvider),
      onUpdate: _applyMediaUpdate,
    );

    final banner = ref.read(activeCallControllerProvider);
    final hasActiveBanner = banner != null && !isEndedCallStatus(banner.status);
    final pendingSession = hasActiveBanner
        ? ref.read(activeCallControllerProvider.notifier).session
        : null;
    final restoredBanner = pendingSession != null ? banner : null;
    if (pendingSession != null) {
      _session = pendingSession;
      _attachSession(
        pendingSession,
        fromBuild: true,
        skipBannerRegistration: true,
      );
    }

    // Keep callDurationSeconds in sync with the banner timer, which persists
    // through minimize/maximize.
    ref.listen(activeCallControllerProvider, (_, bannerState) {
      if (!_isDisposed && bannerState != null) {
        state = state.copyWith(
          callDurationSeconds: bannerState.callDurationSeconds,
        );
      }
    });

    ref.listen(incomingCallProvider, (_, incoming) {
      final event = incoming.eventOrNull;
      if (event == null) return;
      final channelDid = _channelDid;
      if (channelDid == null) return;
      if (event.otherPartyPermanentChannelDid != channelDid) return;
      if (_isDisposed) return;
      state = state.copyWith(peerIsCallingBack: true);
      ref.read(callEndedControllerProvider.notifier).dismiss();
    });

    ref.listen(meetingPlaceSdkProvider, (prev, next) {
      final sdk = next.value;
      _sdk = sdk;

      if (sdk == null || _isDisposed) return;

      _signalSub?.cancel();

      _signalSub = sdk.callSignals.listen((signal) {
        if (_isDisposed) return;

        if (signal is CallDeclineSignal && _isCaller) {
          _logger.info('Call declined by peer, ending call', name: _logKey);
          unawaited(onPeerDeclined());
        }
      });

      ref.onDispose(_signalSub!.cancel);
    }, fireImmediately: true);

    final activeCallController = ref.read(
      activeCallControllerProvider.notifier,
    );

    // Read the logger eagerly here (outside the dispose lifecycle) and close
    // over the self reference inside onDispose. Riverpod forbids ref.read while
    // a provider is being disposed, which is when the onDispose callback runs.
    final logger = _logger;

    ref.onDispose(() {
      _isDisposed = true;
      _sessionHandler?.dispose();
      _contactCardUpdatedSub?.cancel();
      _participantEventSub?.cancel();
      if (!_isMinimizing) {
        logger.info(
          'onDispose: Screen controller releasing session from banner',
          name: _logKey,
        );
        Future.microtask(() {
          if (!isEndedCallStatus(_lastStatus) &&
              _lastStatus != AudioVideoCallStatus.idle) {
            activeCallController.hangUpFromScreen(
              role: _isCaller ? CallRole.caller : CallRole.recipient,
            );
          } else {
            activeCallController.clearSession();
          }
        });
      } else {
        logger.info(
          'onDispose: minimized; banner retains session',
          name: _logKey,
        );
        _pendingBannerController = activeCallController;
      }
    });

    return AudioVideoCallScreenState(
      isGroupContact: _isGroupContact,
      peerName: _cachedPeerName,
      hasHadPeer: restoredBanner != null
          ? (restoredBanner.callDurationSeconds > 0)
          : isAcceptedIncomingForThisScreen || pendingSession != null,
      status: restoredBanner?.status ?? AudioVideoCallStatus.idle,
      callDurationSeconds: restoredBanner?.callDurationSeconds ?? 0,
      isMicEnabled: restoredBanner?.isMicEnabled ?? true,
      isAudioOnly: restoredBanner?.isAudioOnly ?? false,
      isCameraEnabled: restoredBanner != null
          ? restoredBanner.isCameraEnabled
          : true,
      session: pendingSession,
    );
  }

  /// Starts the call on screen entry: restores any minimized call still in
  /// progress, then places an outgoing call if none is active.
  Future<void> startCall({required bool isAudioOnly}) async {
    _logger.info('startCall: isAudioOnly=$isAudioOnly', name: _logKey);
    _isMinimizing = false;
    ref.read(activeCallControllerProvider.notifier).restore();
    final isRestoring = state.session != null;
    state = state.copyWith(
      isAudioOnly: isRestoring ? state.isAudioOnly : isAudioOnly,
      isCameraEnabled: isRestoring ? state.isCameraEnabled : !isAudioOnly,
    );
    await checkInitialPermissions();
    await joinCall();
  }

  /// Discards a finished call (missed or declined) and places a fresh
  /// outgoing call. Used by the "Call again" action on the end-call screen.
  Future<void> restartCall({required bool isAudioOnly}) async {
    _logger.info('restartCall: isAudioOnly=$isAudioOnly', name: _logKey);
    _isMinimizing = false;
    _session = null;
    _sessionHandler?.dispose();
    _sessionHandler = null;
    state = state.copyWith(
      status: AudioVideoCallStatus.idle,
      hasHadPeer: false,
      participants: [],
      session: null,
      isAudioOnly: isAudioOnly,
      isCameraEnabled: !isAudioOnly,
    );
    await checkInitialPermissions();
    await joinCall();
  }

  /// Accepts a peer recall while the call screen is still visible.
  ///
  /// Called by the incoming-call banner when the peer that disconnected
  /// (hot-restart, force-kill) is calling back and the screen is still open.
  /// Clears the peer-calling-back flag and restarts the call in-place so the
  /// screen reinitialises without any navigation, matching the WhatsApp UX.
  Future<void> acceptRecall({required bool isAudioOnly}) async {
    state = state.copyWith(peerIsCallingBack: false);
    _clearIncomingCallState();
    await restartCall(isAudioOnly: isAudioOnly);
  }

  /// Toggles top-bar and controls-bar visibility (tap-anywhere behaviour).
  void toggleControlsBar() {
    _logger.info(
      'toggleControlsBar: visible=${!state.showControlsBar}',
      name: _logKey,
    );
    state = state.copyWith(showControlsBar: !state.showControlsBar);
  }

  /// Directly sets controls-bar visibility (used by scroll-driven hiding).
  void setControlsBarVisible({required bool visible}) {
    if (state.showControlsBar == visible) return;
    _logger.info('setControlsBarVisible: visible=$visible', name: _logKey);
    state = state.copyWith(showControlsBar: visible);
  }

  /// Switches between front and rear camera.
  Future<void> switchCamera() {
    _logger.info('switchCamera: Toggling camera', name: _logKey);
    return _mediaHandler.switchCamera();
  }

  /// Sets the participant displayed full-screen in focused layout.
  /// Pass null to return to the grid layout.
  void setFocusedParticipant(String? participantId) {
    _logger.info(
      'setFocusedParticipant: participantId=$participantId',
      name: _logKey,
    );
    state = state.copyWith(focusedParticipantId: participantId);
  }

  /// Toggles the floating mini-grid between collapsed and expanded.
  void toggleMiniGridExpanded() {
    _logger.info(
      'toggleMiniGridExpanded: expanded=${!state.miniGridExpanded}',
      name: _logKey,
    );
    state = state.copyWith(miniGridExpanded: !state.miniGridExpanded);
  }

  /// Transitions the call to banner control and marks the screen as minimizing.
  /// The screen controller will remain alive but won't clean up the session
  /// when disposed, leaving it under banner ownership.
  void minimize() {
    _logger.info('minimize: Transitioning to banner control', name: _logKey);
    _isMinimizing = true;
    _clearIncomingCallState();
    final selfParticipant = state.participants
        .where((p) => p.isSelf)
        .firstOrNull;
    ref
        .read(activeCallControllerProvider.notifier)
        .minimize(
          contactId: contactId,
          status: state.status,
          peerName: state.peerName,
          isAudioOnly: state.isAudioOnly,
          isCameraEnabled: state.isCameraEnabled,
          isMicEnabled: state.isMicEnabled,
          selfParticipant: selfParticipant,
        );
  }

  /// Checks initial microphone and camera permission status and updates state.
  ///
  /// Only flags an error for `permanentlyDenied` permission status (user
  /// explicitly denied a previous prompt). Undetermined ("not yet asked") is
  /// not treated as an error — LiveKit requests the permission natively when
  /// it enables the mic/camera track, avoiding races with AVAudioSession setup.
  Future<void> checkInitialPermissions() {
    _logger.info('checkInitialPermissions', name: _logKey);
    return _mediaHandler.checkInitialPermissions();
  }

  /// Initiates a new outgoing call to the contact,
  /// acquiring the plugin session.
  Future<void> joinCall() {
    _logger.info('joinCall', name: _logKey);
    return _lifecycleHandler.joinCall();
  }

  /// Cancels an outgoing call that has not yet been answered.
  Future<void> cancelCall() {
    _logger.info('cancelCall', name: _logKey);
    return _lifecycleHandler.cancelCall();
  }

  /// Hangs up the call, dispatching either a cancel
  /// (if still ringing) or leave.
  Future<void> hangUp() {
    _logger.info('hangUp', name: _logKey);
    return _lifecycleHandler.hangUp();
  }

  /// Ends the call from the call screen: shows the call-ended overlay
  /// immediately when a peer was connected, then hangs up. Showing the overlay
  /// here (rather than from the widget's ended-state effect) keeps it
  /// deterministic even though the screen is popped before the hang-up
  /// completes.
  Future<void> endCallFromScreen() async {
    _logger.info('endCallFromScreen', name: _logKey);
    if (state.hasHadPeer) {
      ref
          .read(callEndedControllerProvider.notifier)
          .show(
            contactId: contactId,
            peerName: state.peerName,
            callDurationSeconds: state.callDurationSeconds,
            isAudioOnly: state.isAudioOnly,
          );
    }
    await hangUp();
  }

  /// Flushes the outgoing call chat item and transitions to declined state.
  /// The decline signal arrives off-stream, so the handler doesn't observe it.
  /// The flush must complete before state changes trigger the banner teardown.
  Future<void> onPeerDeclined() async {
    _logger.info('onPeerDeclined', name: _logKey);
    final sessionBeforeFlush = _session;
    await ref
        .read(activeCallControllerProvider.notifier)
        .endCallChatItem(role: CallRole.caller);

    if (_isDisposed || !identical(_session, sessionBeforeFlush)) {
      _logger.info(
        'onPeerDeclined: Skipping stale decline '
        '(disposed=$_isDisposed, '
        'sessionSwapped=${!identical(_session, sessionBeforeFlush)})',
        name: _logKey,
      );
      return;
    }

    state = state.copyWith(status: AudioVideoCallStatus.declined);
    return _lifecycleHandler.onPeerDeclined();
  }

  /// Ends the active call and transitions to ended state.
  Future<void> leaveCall() {
    _logger.info('leaveCall', name: _logKey);
    return _lifecycleHandler.leaveCall();
  }

  /// Toggles microphone on/off.
  ///
  /// Skips the permission check when the call is active — LiveKit already
  /// owns the AVAudioSession at that point and re-querying permission_handler
  /// can return a stale status. Only re-checks if a previous permission error
  /// was recorded.
  Future<void> toggleMic() {
    _logger.info('toggleMic: enabled=${!state.isMicEnabled}', name: _logKey);
    return _mediaHandler.toggleMic(
      currentValue: state.isMicEnabled,
      permissionError: state.micPermissionError,
    );
  }

  /// Toggles camera on/off.
  ///
  /// LiveKit owns the iOS audio session, so the app does not reconfigure it
  /// when switching to video. Reconfiguring it mid-call makes LiveKit treat the
  /// change as an audio interruption and drop the room. Output routing
  /// (earpiece/speaker) is driven through LiveKit instead.
  Future<void> toggleCamera() async {
    _logger.info(
      'toggleCamera: enabled=${!state.isCameraEnabled}',
      name: _logKey,
    );
    return _mediaHandler.toggleCamera(
      currentValue: state.isCameraEnabled,
      permissionError: state.cameraPermissionError,
    );
  }

  /// Toggles speakerphone on/off.
  Future<void> toggleSpeaker() {
    if (_isDisposed) return Future.value();
    _logger.info(
      'toggleSpeaker: enabled=${!state.isSpeakerEnabled}',
      name: _logKey,
    );
    return _mediaHandler.toggleSpeaker(currentValue: state.isSpeakerEnabled);
  }

  /// Attaches a new session, setting up the handler
  /// and optionally registering with the banner.
  ///
  /// [fromBuild] must be true when called from [build] — in that case the
  /// session is written into the returned initial state instead of via [state]
  /// (which is uninitialized during build).
  ///
  /// [skipBannerRegistration] skips the banner registration when the banner
  /// already owns the session (e.g., when restoring from a minimized call).
  void _attachSession(
    AudioVideoCallSession session, {
    bool fromBuild = false,
    bool skipBannerRegistration = false,
  }) {
    _sessionHandler?.dispose();
    _participantEventSub?.cancel();
    if (!fromBuild) state = state.copyWith(session: session);
    if (!skipBannerRegistration) {
      _logger.info(
        '_attachSession: registering session with banner',
        name: _logKey,
      );
      ref
          .read(activeCallControllerProvider.notifier)
          .registerSession(
            session,
            channelDid: _channelDid ?? contactId,
            isAudioOnly: state.isAudioOnly,
            initialStatus: state.status,
            peerName: state.peerName,
            isMicEnabled: state.isMicEnabled,
            isMinimized: _isMinimizing,
            isGroupContact: _isGroupContact,
          );
    }
    _participantEventSub = session.participantEvents.listen(
      _onParticipantEvent,
    );
    final handler = CallSessionHandler(
      logger: _logger,
      onUpdate: _applySessionUpdate,
    )..attach(session);
    _sessionHandler = handler;
  }

  /// Ends a 1-on-1 call immediately when the only peer leaves.
  void _onParticipantEvent(CallParticipantEvent event) {
    if (_isDisposed) return;
    if (event.type != CallParticipantEventType.left) return;
    if (_isGroupContact) {
      _logger.info(
        '_onParticipantEvent: Peer left group call, call continues',
        name: _logKey,
      );
      return;
    }
    if (!state.hasHadPeer) {
      _logger.warning(
        '_onParticipantEvent: Peer left but hasHadPeer=false, skipping',
        name: _logKey,
      );
      return;
    }
    _logger.info(
      '_onParticipantEvent: Peer left 1-on-1 call, ending call',
      name: _logKey,
    );
    unawaited(hangUp());
  }

  /// Applies handler-transformed session events to the screen
  /// state and syncs to banner.
  void _applySessionUpdate(AudioVideoCallStateUpdate update) {
    if (_isDisposed || !ref.mounted) {
      _logger.info(
        'applySessionUpdate: Skipping, controller disposed',
        name: _logKey,
      );
      return;
    }

    if (update.ownRole != null) {
      _isCaller = update.ownRole == CallRole.caller;
    }

    final nextParticipants = update.participants ?? state.participants;
    final nextMemberContactCards = _mergeMemberContactCards(
      update.participantContactCardsByDid,
    );
    final anyHasVideo = nextParticipants.any((p) => p.hasVideo);

    _groupMemberDids = {
      ..._groupMemberDids,
      ...nextParticipants
          .map((participant) => participant.did)
          .whereType<String>(),
      ...nextMemberContactCards.keys,
    };

    final nextStatus = isEndedCallStatus(state.status)
        ? state.status
        : update.status ?? state.status;

    state = state.copyWith(
      status: nextStatus,
      participants: nextParticipants,
      memberContactCards: nextMemberContactCards,
      errorCode: update.errorCode,
      isMicEnabled: update.isMicEnabled ?? state.isMicEnabled,
      isCameraEnabled: update.isCameraEnabled ?? state.isCameraEnabled,
      participantEvent: update.participantEvent,
      hasHadPeer: state.hasHadPeer || update.hasHadPeer,
      isAudioOnly: state.isAudioOnly && !anyHasVideo,
    );

    if (update.peerJustJoined) {
      _clearIncomingCallState();
      ref
          .read(activeCallControllerProvider.notifier)
          .startTimer(update.callStartedAt);
    }

    if (isEndedCallStatus(update.status ?? state.status)) {
      unawaited(ref.read(callAudioSessionServiceProvider.notifier).release());
      _clearIncomingCallState();
      ref.read(activeCallControllerProvider.notifier).stopTimer();
    }
  }

  /// The contact's channel DID, or contactId if not found.
  ///
  /// Resolved once in [build] and cached, so it is safe to read after the
  /// provider is disposed (e.g. in the post-minimize forwarding path).
  String? get _channelDid => _cachedChannelDid;

  /// Applies lifecycle transitions: attaches sessions, clears incoming state,
  /// updates status, records failures, and writes ended chat items.
  void _applyLifecycleUpdate(CallLifecycleUpdate update) {
    if (_isDisposed || !ref.mounted) {
      final pending = _pendingBannerController;
      if (pending != null && update.attachedSession != null) {
        _pendingBannerController = null;
        pending.registerSession(
          update.attachedSession!,
          channelDid: _channelDid ?? contactId,
          isAudioOnly: _lastIsAudioOnly,
          initialStatus: AudioVideoCallStatus.connecting,
          peerName: _cachedPeerName,
          isMicEnabled: true,
          isMinimized: true,
          isGroupContact: _isGroupContact,
        );
      }
      return;
    }
    if (update.attachedSession != null) {
      _attachSession(update.attachedSession!);
    }
    if (update.clearIncomingCall) {
      _clearIncomingCallState();
    }
    if (update.status != null || update.isSpeakerEnabled != null) {
      final staleEndedUpdate =
          update.status != null &&
          isEndedCallStatus(update.status!) &&
          state.status == AudioVideoCallStatus.idle;
      final newStatus = (isEndedCallStatus(state.status) || staleEndedUpdate)
          ? state.status
          : update.status ?? state.status;
      state = state.copyWith(
        status: newStatus,
        errorCode: update.errorCode ?? state.errorCode,
        isSpeakerEnabled: update.isSpeakerEnabled ?? state.isSpeakerEnabled,
      );
    }
    if (update.reportHangUpFailure) {
      state = state.copyWith(
        actionFailure: CallActionFailureEvent(CallActionFailure.hangUp),
      );
    }
    if (isEndedCallStatus(update.status ?? state.status)) {
      ref.read(activeCallControllerProvider.notifier).stopTimer();
    }
  }

  /// Clears the kept-alive incoming-call state once the call leaves the
  /// joiner-detection window (established, ended, cancelled, or minimized).
  /// Holding it until this point lets the joiner be detected even if this
  /// autoDispose controller rebuilds during navigation, while still hiding the
  /// dashboard incoming banner once the call is underway or over.
  void _clearIncomingCallState() {
    if (_isDisposed) return;
    ref.read(incomingCallProvider.notifier).clear();
  }

  /// Applies media toggle updates (mic, camera, speaker, permissions) to state.
  void _applyMediaUpdate(CallMediaUpdate update) {
    if (_isDisposed || !ref.mounted) return;

    final newIsCameraEnabled = update.isCameraEnabled ?? state.isCameraEnabled;
    // When enabling camera from audio-only call, switch to video mode.
    final shouldSwitchToVideo =
        update.isCameraEnabled == true && state.isAudioOnly;

    if (shouldSwitchToVideo) {
      ref.read(activeCallControllerProvider.notifier).switchToVideo();
    }

    state = state.copyWith(
      isMicEnabled: update.isMicEnabled ?? state.isMicEnabled,
      micPermissionError: update.micPermissionError ?? state.micPermissionError,
      isCameraEnabled: newIsCameraEnabled,
      isAudioOnly: shouldSwitchToVideo ? false : state.isAudioOnly,
      cameraPermissionError:
          update.cameraPermissionError ?? state.cameraPermissionError,
      isSpeakerEnabled: update.isSpeakerEnabled ?? state.isSpeakerEnabled,
      actionFailure: update.failure != null
          ? CallActionFailureEvent(update.failure!)
          : state.actionFailure,
    );
  }

  /// Loads the initial group member cards before the first SDK state update
  /// arrives.
  Future<void> _loadGroupMemberNames(String offerLink) async {
    try {
      final sdk = await ref.read(meetingPlaceSdkProvider.future);
      final group = await sdk.getGroupByOfferLink(offerLink);
      if (group == null || _isDisposed) return;
      final contactsState = ref.read(contactsServiceProvider);
      final cards = <String, ContactCard>{...state.memberContactCards};
      for (final member in group.members) {
        final resolvedCard = _resolveGroupMemberContactCard(
          memberDid: member.did,
          groupCard: ContactCardUtils.fromSdkContactCard(member.contactCard),
          contactsState: contactsState,
        );
        if (resolvedCard != null) {
          cards.putIfAbsent(member.did, () => resolvedCard);
        }
      }
      _groupMemberDids = {..._groupMemberDids, ...cards.keys};
      if (_isDisposed) return;
      state = state.copyWith(memberContactCards: cards);
    } catch (e, stackTrace) {
      _logger.error(
        'Failed to load group member names',
        error: e,
        stackTrace: stackTrace,
        name: _logKey,
      );
      if (!_isDisposed) {
        state = state.copyWith(
          actionFailure: CallActionFailureEvent(CallActionFailure.memberNames),
        );
      }
    }
  }

  /// Keeps the group member card cache in sync with contact-card updates.
  void _subscribeToGroupMemberCardUpdates() {
    _contactCardUpdatedSub?.cancel();
    _contactCardUpdatedSub = ref
        .read(contactsServiceProvider.notifier)
        .onContactCardUpdated
        .listen(_onGroupMemberContactCardUpdated);
  }

  /// Refreshes one group member card when the contacts store updates it.
  void _onGroupMemberContactCardUpdated(String did) {
    if (_isDisposed || !ref.mounted || !_groupMemberDids.contains(did)) return;
    final contactsState = ref.read(contactsServiceProvider);
    final liveContact =
        contactsState.getContactByChannelDid(did) ??
        contactsState.getContactByCardDid(did);
    if (liveContact == null) {
      unawaited(_refreshGroupMemberContactCard(did));
      return;
    }
    final updatedCard = _resolveGroupMemberContactCard(
      memberDid: did,
      groupCard: state.memberContactCards[did],
      contactsState: contactsState,
    );
    if (updatedCard == null) return;
    state = state.copyWith(
      memberContactCards: {...state.memberContactCards, did: updatedCard},
    );
  }

  /// Fetches and updates a group member's contact card from the SDK.
  Future<void> _refreshGroupMemberContactCard(String did) async {
    final offerLink = _groupOfferLink;
    if (offerLink == null || _isDisposed || !ref.mounted) return;

    final sdk = await ref.read(meetingPlaceSdkProvider.future);
    final group = await sdk.getGroupByOfferLink(offerLink);
    if (group == null || _isDisposed || !ref.mounted) return;

    final member = group.members
        .where((member) => member.did == did)
        .firstOrNull;
    if (member == null) return;

    state = state.copyWith(
      memberContactCards: {
        ...state.memberContactCards,
        did: ContactCardUtils.fromSdkContactCard(member.contactCard),
      },
    );
  }

  /// Resolves the best available contact card for a group member DID.
  ContactCard? _resolveGroupMemberContactCard({
    required String memberDid,
    required ContactsServiceState contactsState,
    ContactCard? groupCard,
  }) {
    final liveContact =
        contactsState.getContactByChannelDid(memberDid) ??
        contactsState.getContactByCardDid(memberDid);
    return liveContact?.card ?? groupCard;
  }

  /// Adds the initial SDK participant cards without overwriting newer live
  /// contact cards.
  Map<String, ContactCard> _mergeMemberContactCards(
    Map<String, core.ContactCard>? sdkCards,
  ) {
    if (sdkCards == null || sdkCards.isEmpty) return state.memberContactCards;
    final mergedCards = <String, ContactCard>{...state.memberContactCards};
    for (final entry in sdkCards.entries) {
      mergedCards.putIfAbsent(
        entry.key,
        () => ContactCardUtils.fromSdkContactCard(entry.value),
      );
    }
    return mergedCards;
  }

  /// Syncs screen state to the banner controller,
  /// clearing if call is not visible.
  void _syncActiveCallBanner(AudioVideoCallScreenState value) {
    if (_isMinimizing) {
      _logger.info(
        '_syncActiveCallBanner: Skipping, minimizing',
        name: _logKey,
      );
      return;
    }
    final activeCallController = ref.read(
      activeCallControllerProvider.notifier,
    );
    if (!value.isVisible) {
      activeCallController.clear();
      return;
    }
    final currentMinimized =
        ref.read(activeCallControllerProvider)?.isMinimized ?? false;
    activeCallController.update(
      ActiveCallState(
        contactId: contactId,
        peerName: value.peerName,
        status: value.status,
        callDurationSeconds: value.callDurationSeconds,
        isMicEnabled: value.isMicEnabled,
        isAudioOnly: value.isAudioOnly,
        hasHadPeer: value.hasHadPeer,
        isMinimized: currentMinimized,
        isCameraEnabled: value.isCameraEnabled,
        selfParticipant: value.participants.where((p) => p.isSelf).firstOrNull,
      ),
    );
  }
}
