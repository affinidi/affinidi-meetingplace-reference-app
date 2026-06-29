import 'dart:async';

import 'package:meeting_place_chat/meeting_place_chat.dart'
    show
        AudioVideoCallPlugin,
        AudioVideoCallSession,
        AudioVideoCallStatus,
        CallRole,
        CallStatus;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../application/services/chat_service/chat_session_service.dart';
import '../../../../application/services/contacts_service/contacts_service.dart';
import '../../../../domain/models/contact_card/contact_card.dart';
import '../../../../infrastructure/extensions/contact_card_extensions.dart';
import '../../../../infrastructure/providers/active_group_call_provider.dart';
import '../../../../infrastructure/providers/app_logger_provider.dart';
import '../../../../infrastructure/providers/audio_video_call_plugin_provider.dart';
import '../../../../infrastructure/providers/incoming_call_state_provider.dart';
import '../../../../infrastructure/providers/meeting_place_sdk_provider.dart';
import '../../../../infrastructure/providers/pending_call_session_provider.dart';
import '../../../../infrastructure/services/permission_service/permission_service.dart';
import '../../../widgets/banners/active_call/active_call_controller.dart';
import '../../../widgets/banners/active_call/active_call_state.dart';

import 'audio_video_call_screen_state.dart';
import 'audio_video_call_state_update.dart';
import 'call_lifecycle_update.dart';
import 'call_media_update.dart';
import 'handlers/call_chat_item_handler.dart';
import 'handlers/call_lifecycle_handler.dart';
import 'handlers/call_media_toggle_handler.dart';
import 'handlers/call_session_handler.dart';
import 'rules/call_chat_item_rules.dart';
import 'rules/call_ui_rules.dart';

part 'audio_video_call_screen_controller.g.dart';

@riverpod
class AudioVideoCallScreenController extends _$AudioVideoCallScreenController {
  static const _logKey = 'AudioVideoCallScreenController';

  late final _logger = ref.read(appLoggerProvider);

  AudioVideoCallPlugin? _plugin;
  AudioVideoCallSession? _session;
  CallSessionHandler? _sessionHandler;
  bool _isDisposed = false;
  bool _isMinimizing = false;
  AudioVideoCallStatus _lastStatus = AudioVideoCallStatus.idle;
  bool _isGroupContact = false;

  // The device's call role, mirrored from the session's authoritative ownRole.
  // True once the SDK reports this device opened the call (CallRole.caller).
  // Drives end-status resolution; the chat item itself is gated by the emitter.
  bool _isCaller = false;

  late final CallChatItemHandler _chatItemHandler;
  late final CallLifecycleHandler _lifecycleHandler;
  late final CallMediaToggleHandler _mediaHandler;

  @override
  set state(AudioVideoCallScreenState value) {
    _lastStatus = value.status;
    super.state = value;
    _syncActiveCallBanner(value);
  }

  @override
  AudioVideoCallScreenState build(String contactId) {
    final contact = ref.read(contactsServiceProvider).getContactById(contactId);
    _isGroupContact = contact?.isGroup ?? false;
    final incomingEvent = ref.read(incomingCallStateProvider);
    final expectedOtherPartyDid = contact?.channelDid ?? contactId;
    final isAcceptedIncomingForThisScreen =
        incomingEvent != null &&
        incomingEvent.otherPartyChannelDid == expectedOtherPartyDid;

    if (_isGroupContact && contact != null) {
      unawaited(_loadGroupMemberNames(contact.offerLink));
    }

    _chatItemHandler = CallChatItemHandler(
      resolveItemId: ({required bool isCaller}) async {
        final bannerItemId = ref
            .read(activeCallControllerProvider.notifier)
            .callChatItemId;
        if (bannerItemId != null) return bannerItemId;
        if (_isDisposed) return null;
        final channelDid = _channelDid;
        if (channelDid == null) return null;
        return ref
            .read(chatSessionServiceProvider(channelDid).notifier)
            .resolveIncomingCallChatItemId();
      },
      updateItem: (messageId, {required status, duration}) async {
        final channelDid = _channelDid;
        if (channelDid == null) return;
        await ref
            .read(chatSessionServiceProvider(channelDid).notifier)
            .updateCallChatItem(messageId, status: status, duration: duration);
      },
      isDisposed: () => _isDisposed,
      logger: _logger,
    );

    _lifecycleHandler = CallLifecycleHandler(
      logger: _logger,
      channelDid: _channelDid,
      isGroupContact: _isGroupContact,
      getState: () => state,
      getPlugin: () => _plugin,
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

    final rawPendingSession = ref.read(pendingCallSessionProvider);
    final banner = ref.read(activeCallControllerProvider);
    final hasActiveBanner = banner != null && !isEndedCallStatus(banner.status);
    final pendingSession = hasActiveBanner ? rawPendingSession : null;
    final restoredBanner = pendingSession != null ? banner : null;
    if (rawPendingSession != null) {
      Future.microtask(
        () => ref.read(pendingCallSessionProvider.notifier).state = null,
      );
    }
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

    ref.listen(audioVideoCallPluginProvider, (prev, next) {
      _plugin = next.value;
    }, fireImmediately: true);

    final activeCallController = ref.read(
      activeCallControllerProvider.notifier,
    );

    // Read the logger eagerly here (outside the dispose lifecycle) and close
    // over the local inside onDispose. Riverpod forbids ref.read while a
    // provider is being disposed, which is when the onDispose callback runs.
    final logger = _logger;

    ref.onDispose(() {
      _isDisposed = true;
      _sessionHandler?.dispose();
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
      }
    });

    return AudioVideoCallScreenState(
      isGroupContact: _isGroupContact,
      peerName: contact?.displayName ?? contact?.card.displayName ?? '',
      hasHadPeer: restoredBanner != null
          ? (restoredBanner.callDurationSeconds > 0)
          : isAcceptedIncomingForThisScreen || pendingSession != null,
      status: restoredBanner?.status ?? AudioVideoCallStatus.idle,
      callDurationSeconds: restoredBanner?.callDurationSeconds ?? 0,
      isMicEnabled: restoredBanner?.isMicEnabled ?? true,
      isAudioOnly: restoredBanner?.isAudioOnly ?? false,
      isCameraEnabled: restoredBanner == null || !restoredBanner.isAudioOnly,
      session: pendingSession,
    );
  }

  /// Starts the call on screen entry: restores any minimized call still in
  /// progress, then places an outgoing call if none is active.
  Future<void> startCall({required bool isAudioOnly}) async {
    _isMinimizing = false;
    ref.read(activeCallControllerProvider.notifier).restore();
    state = state.copyWith(isAudioOnly: isAudioOnly);
    await checkInitialPermissions();
    await joinCall();
  }

  /// Discards a finished call (missed or declined) and places a fresh
  /// outgoing call. Used by the "Call again" action on the end-call screen.
  Future<void> restartCall({required bool isAudioOnly}) async {
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
    );
    await checkInitialPermissions();
    await joinCall();
  }

  /// Toggles top-bar and controls-bar visibility (tap-anywhere behaviour).
  void toggleControlsBar() {
    state = state.copyWith(showControlsBar: !state.showControlsBar);
  }

  /// Directly sets controls-bar visibility (used by scroll-driven hiding).
  void setControlsBarVisible({required bool visible}) {
    if (state.showControlsBar == visible) return;
    state = state.copyWith(showControlsBar: visible);
  }

  /// Switches between front and rear camera.
  Future<void> switchCamera() => _mediaHandler.switchCamera();

  /// Sets the participant displayed full-screen in focused layout.
  /// Pass null to return to the grid layout.
  void setFocusedParticipant(int? index) {
    state = state.copyWith(focusedParticipantIndex: index);
  }

  /// Toggles the floating mini-grid between collapsed and expanded.
  void toggleMiniGridExpanded() {
    state = state.copyWith(miniGridExpanded: !state.miniGridExpanded);
  }

  /// Transitions the call to banner control and marks the screen as minimizing.
  /// The screen controller will remain alive but won't clean up the session
  /// when disposed, leaving it under banner ownership.
  void minimize() {
    _logger.info('minimize: Transitioning to banner control', name: _logKey);
    _isMinimizing = true;
    _clearIncomingCallState();
    ref.read(activeCallControllerProvider.notifier).minimize();
  }

  /// Checks initial microphone and camera permission status and updates state.
  ///
  /// Only flags an error for `permanentlyDenied` permission status (user
  /// explicitly denied a previous prompt). Undetermined ("not yet asked") is
  /// not treated as an error — LiveKit requests the permission natively when
  /// it enables the mic/camera track, avoiding races with AVAudioSession setup.
  Future<void> checkInitialPermissions() =>
      _mediaHandler.checkInitialPermissions();

  /// Initiates a new outgoing call to the contact,
  /// acquiring the plugin session.
  Future<void> joinCall() => _lifecycleHandler.joinCall();

  /// Cancels an outgoing call that has not yet been answered.
  Future<void> cancelCall() => _lifecycleHandler.cancelCall();

  /// Hangs up the call, dispatching either a cancel
  /// (if still ringing) or leave.
  Future<void> hangUp() => _lifecycleHandler.hangUp();

  /// Ends the active call and transitions to ended state.
  Future<void> leaveCall() => _lifecycleHandler.leaveCall();

  /// Toggles microphone on/off.
  ///
  /// Skips the permission check when the call is active — LiveKit already
  /// owns the AVAudioSession at that point and re-querying permission_handler
  /// can return a stale status. Only re-checks if a previous permission error
  /// was recorded.
  Future<void> toggleMic() => _mediaHandler.toggleMic(
    currentValue: state.isMicEnabled,
    permissionError: state.micPermissionError,
  );

  /// Toggles camera on/off.
  ///
  /// Same skip-if-active logic as [toggleMic].
  Future<void> toggleCamera() => _mediaHandler.toggleCamera(
    currentValue: state.isCameraEnabled,
    permissionError: state.cameraPermissionError,
  );

  /// Toggles speakerphone on/off.
  Future<void> toggleSpeaker() {
    if (_isDisposed) return Future.value();
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
          );
    }
    final handler = CallSessionHandler(
      logger: _logger,
      onUpdate: _applySessionUpdate,
    )..attach(session);
    _sessionHandler = handler;
  }

  /// Applies handler-transformed session events to the screen
  /// state and syncs to banner.
  void _applySessionUpdate(AudioVideoCallStateUpdate update) {
    if (_isDisposed) {
      _logger.info(
        'applySessionUpdate: Skipping, controller disposed',
        name: _logKey,
      );
      return;
    }

    final bannerItemId = ref
        .read(activeCallControllerProvider.notifier)
        .callChatItemId;
    if (bannerItemId != null) {
      _chatItemHandler.seedCallChatItemId(bannerItemId);
    }

    if (update.ownRole != null) {
      _isCaller = update.ownRole == CallRole.caller;
    }

    final nextParticipants = update.participants ?? state.participants;
    final anyHasVideo = nextParticipants.any((p) => p.hasVideo);

    state = state.copyWith(
      status: update.status ?? state.status,
      participants: nextParticipants,
      errorCode: update.errorCode,
      isMicEnabled: update.isMicEnabled ?? state.isMicEnabled,
      isCameraEnabled: update.isCameraEnabled ?? state.isCameraEnabled,
      participantEvent: update.participantEvent,
      hasHadPeer: state.hasHadPeer || update.hasHadPeer,
      isAudioOnly: state.isAudioOnly && !anyHasVideo,
    );

    if (update.peerJustJoined) {
      _clearIncomingCallState();
      ref.read(activeCallControllerProvider.notifier).startTimer();
      _chatItemHandler.updateCallChatItemStatus(CallStatus.inProgress);
    }

    if (!_chatItemHandler.callChatItemEnded &&
        update.status == AudioVideoCallStatus.outgoingRinging &&
        !update.peerJustJoined) {
      _chatItemHandler.updateCallChatItemStatus(CallStatus.ringing);
    }

    if (isEndedCallStatus(update.status ?? state.status)) {
      _clearIncomingCallState();
      ref.read(activeCallControllerProvider.notifier).stopTimer();
      _chatItemHandler.endCallChatItem(
        outcome: resolveCallEndOutcome(
          lastStatus: _lastStatus,
          hasHadPeer: state.hasHadPeer,
        ),
        isCaller: _isCaller,
        hasHadPeer: state.hasHadPeer,
        callDuration: Duration(seconds: state.callDurationSeconds),
      );
    }

    _syncActiveGroupCall(update.status ?? state.status);
  }

  /// The contact's channel DID, or contactId if not found.
  String? get _channelDid {
    final contact = ref.read(contactsServiceProvider).getContactById(contactId);
    return contact?.channelDid ?? contactId;
  }

  /// Applies lifecycle transitions: attaches sessions, clears incoming state,
  /// updates status, records failures, and writes terminal chat items.
  void _applyLifecycleUpdate(CallLifecycleUpdate update) {
    if (_isDisposed) return;
    if (update.attachedSession != null) {
      _attachSession(update.attachedSession!);
    }
    if (update.clearIncomingCall) {
      _clearIncomingCallState();
    }
    if (update.status != null || update.isSpeakerEnabled != null) {
      state = state.copyWith(
        status: update.status ?? state.status,
        isSpeakerEnabled: update.isSpeakerEnabled ?? state.isSpeakerEnabled,
      );
    }
    if (update.reportHangUpFailure) {
      state = state.copyWith(
        actionFailure: CallActionFailureEvent(CallActionFailure.hangUp),
      );
    }
    if (update.endOutcome != null) {
      _chatItemHandler.endCallChatItem(
        outcome: update.endOutcome!,
        isCaller: _isCaller,
        hasHadPeer: state.hasHadPeer,
        callDuration: Duration(seconds: state.callDurationSeconds),
      );
    }
  }

  /// Clears the kept-alive incoming-call state once the call leaves the
  /// joiner-detection window (established, ended, cancelled, or minimized).
  /// Holding it until this point lets the joiner be detected even if this
  /// autoDispose controller rebuilds during navigation, while still hiding the
  /// dashboard incoming banner once the call is underway or over.
  void _clearIncomingCallState() {
    if (_isDisposed) return;
    ref.read(incomingCallStateProvider.notifier).clear();
  }

  /// Applies media toggle updates (mic, camera, speaker, permissions) to state.
  void _applyMediaUpdate(CallMediaUpdate update) {
    if (_isDisposed) return;
    state = state.copyWith(
      isMicEnabled: update.isMicEnabled ?? state.isMicEnabled,
      micPermissionError: update.micPermissionError ?? state.micPermissionError,
      isCameraEnabled: update.isCameraEnabled ?? state.isCameraEnabled,
      cameraPermissionError:
          update.cameraPermissionError ?? state.cameraPermissionError,
      isSpeakerEnabled: update.isSpeakerEnabled ?? state.isSpeakerEnabled,
      actionFailure: update.failure != null
          ? CallActionFailureEvent(update.failure!)
          : state.actionFailure,
    );
  }

  /// Fetches and caches group member contact cards by their DIDs.
  Future<void> _loadGroupMemberNames(String offerLink) async {
    try {
      final sdk = await ref.read(meetingPlaceSdkProvider.future);
      final group = await sdk.getGroupByOfferLink(offerLink);
      if (group == null || _isDisposed) return;
      final cards = <String, ContactCard>{
        for (final member in group.members)
          member.did: ContactCardUtils.fromSdkContactCard(member.contactCard),
      };
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

  /// Syncs screen state to the banner controller,
  /// clearing if call is not visible.
  void _syncActiveCallBanner(AudioVideoCallScreenState value) {
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

  /// Tracks the active group call state, setting or clearing
  /// the active group contact ID.
  void _syncActiveGroupCall(AudioVideoCallStatus status) {
    final notifier = ref.read(activeGroupCallProvider.notifier);
    if (_isGroupContact && isConnectedCallStatus(status)) {
      notifier.state = contactId;
      return;
    }
    if (isEndedCallStatus(status)) {
      if (ref.read(activeGroupCallProvider) == contactId) {
        notifier.state = null;
      }
    }
  }
}
