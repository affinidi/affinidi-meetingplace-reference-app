import 'dart:async';

import 'package:flutter/material.dart';
import 'package:meeting_place_core/meeting_place_core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:synchronized/synchronized.dart';

import '../../../infrastructure/exceptions/app_exception.dart';
import '../../../infrastructure/exceptions/app_exception_type.dart';
import '../../../infrastructure/firebase_messaging/push_notifications_handler.dart';
import '../../../infrastructure/loggers/app_logger/app_logger.dart';
import '../../../infrastructure/providers/app_logger_provider.dart';
import '../../../infrastructure/providers/meeting_place_sdk_provider.dart';
import '../network_connectivity_service/network_connectivity_service.dart';
import 'control_plane_service_state.dart';

part 'control_plane_service.g.dart';

/// Service responsible for processing control plane stream events and device
///  tokens.
///
/// This service:
/// - Subscribes to the MeetingPlaceCoreSDK control plane stream and routes
/// events to domain
/// streams:
///   - onInvitationAccepted
///   - onGroupInvitationAccepted
///   - onConnectionOfferApproved
///   - onChannelInaugurated
/// - Registers the device push token with the SDK and triggers queued event
///   processing.
/// - Observes app lifecycle changes to trigger event processing on resume
///  (clears badges and processes events).
/// - Serializes control plane event processing to avoid concurrent runs.
///
/// The service exposes event streams that other services (ContactsService
/// , ConnectionsService) consume to create/update domain models and UI state
/// . It does not expose public mutation APIs;
/// it acts as an adapter between the SDK control plane feed,
/// push notifications, and app-level services.
@Riverpod(keepAlive: true)
class ControlPlaneService extends _$ControlPlaneService
    with WidgetsBindingObserver {
  ControlPlaneService() : super();
  static const _logKey = 'CTLPLNSVC';

  Stream<ControlPlaneStreamEvent>? _controlPlaneEventsStream;
  late final AppLogger _logger = ref.read(appLoggerProvider);

  final StreamController<Channel> _invitationAcceptedController =
      StreamController<Channel>.broadcast();
  Stream<Channel> get onInvitationAccepted =>
      _invitationAcceptedController.stream;

  final StreamController<Channel> _groupInvitationAcceptedController =
      StreamController<Channel>.broadcast();
  Stream<Channel> get onGroupInvitationAccepted =>
      _groupInvitationAcceptedController.stream;

  final StreamController<Channel> _connectionOfferApprovedController =
      StreamController<Channel>.broadcast();
  Stream<Channel> get onConnectionOfferApproved =>
      _connectionOfferApprovedController.stream;

  final StreamController<Channel> _channelActivityController =
      StreamController<Channel>.broadcast();
  Stream<Channel> get onChannelActivity => _channelActivityController.stream;

  MeetingPlaceCoreSDK? _sdk;
  _ControlPlaneEventsProcessor? _eventProcessor;

  String? _lastAttemptedDeviceToken;
  String? _lastRegisteredDeviceToken;
  late final _registerDeviceTokenLock = Lock();

  @override
  ControlPlaneServiceState build() {
    WidgetsBinding.instance.addObserver(this);

    ref.onDispose(() {
      WidgetsBinding.instance.removeObserver(this);
    });

    ref
        .read(pushNotificationsHandlerProvider.notifier)
        .onReceivedDeviceToken
        .listen((token) {
      Future(() => _registerDeviceToken(token));
    });

    ref
        .read(pushNotificationsHandlerProvider.notifier)
        .onFailedToGetDeviceToken
        .listen((_) {
      Future(() {
        if (state.isDeviceTokenRegistered == null) {
          state = state.copyWith(isDeviceTokenRegistered: false);
        }
      });
    });

    ref.listen(
      networkConnectivityServiceProvider.select((state) => state.isConnected),
      (previous, next) {
        if (previous != null && previous != next && next == true) {
          if (_lastRegisteredDeviceToken != null) return;

          if (_lastAttemptedDeviceToken != null) {
            Future(() => _registerDeviceToken(_lastAttemptedDeviceToken!));
          } else {
            Future(_askForTokenAgain);
          }
        }
      },
      fireImmediately: true,
    );

    ref
        .read(pushNotificationsHandlerProvider.notifier)
        .onPushNotificationReceived
        .listen((_) {
      Future(_processEvents);
    });

    ref.read(meetingPlaceSdkProvider.future).then((sdk) {
      if (_sdk != null) return;
      _sdk = sdk;
      _controlPlaneEventsStream = sdk.controlPlaneEventsStream;
      _controlPlaneEventsStream?.listen(_handleControlPlaneEvent);
    });

    return const ControlPlaneServiceState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _handleAppResumed();
    }
  }

  /// Register the device token with the MeetingPlaceCoreSDK.
  ///
  /// Persists the [token] in the SDK for push notifications and marks the
  /// service as ready to process control plane events. Triggers an immediate
  /// processing of queued events after registration.
  ///
  /// [token] - The device token obtained from the push provider.
  ///
  /// Throws:
  /// - Propagates any exceptions from the MeetingPlaceCoreSDK registration or
  ///  event processing.
  ///
  /// Returns:
  /// - `Future<void>` completes when registration and subsequent processing
  ///  finish.
  Future<void> _registerDeviceToken(String token) async {
    await _registerDeviceTokenLock.synchronized(() async {
      if (_lastRegisteredDeviceToken == token) return;

      _lastAttemptedDeviceToken = token;

      _logger.info(
        'Device token received: $token',
        name: _logKey,
      );

      try {
        final sdk = await ref.read(meetingPlaceSdkProvider.future);
        _logger.info(
          'Registering device with MeetingPlaceCoreSDK',
          name: _logKey,
        );
        await sdk.registerForPushNotifications(token);
        _lastRegisteredDeviceToken = token;

        if (state.isDeviceTokenRegistered != true) {
          state = state.copyWith(isDeviceTokenRegistered: true);
        }
        _logger.info(
          'Device registration completed successfully',
          name: _logKey,
        );
      } catch (error, stackTrace) {
        if (state.isDeviceTokenRegistered == null) {
          state = state.copyWith(isDeviceTokenRegistered: false);
        }
        _logger.error(
          'Failed to register device token',
          error: error,
          stackTrace: stackTrace,
          name: _logKey,
        );
      }
      await _processEvents();
    });
  }

  /// Handle a control plane stream event from the MeetingPlaceCoreSDK.
  ///
  /// Evaluates the [event] type and channel status, routing it to the
  /// appropriate internal stream:
  /// - Invitation accepted -> onInvitationAccepted / onGroupInvitationAccepted
  /// - Offer finalised -> onConnectionOfferApproved (only for inaugurated
  ///  channels)
  /// - Channel activity -> onChannelInaugurated (only for inaugurated channels)
  ///
  /// [event] - The control plane stream event received from the SDK.
  ///
  /// Throws:
  /// - [AppException] when finalised/activity events are received for non-inaugurated channels.
  void _handleControlPlaneEvent(ControlPlaneStreamEvent event) {
    final channel = event.channel;
    _logger.info(
      'Handling event of type ${event.type.name} - '
      'channel status: ${channel.status} - '
      'permanentChannelDid: ${channel.permanentChannelDid} - '
      'otherPartyPermanentChannelDid: '
      '${channel.otherPartyPermanentChannelDid}',
      name: _logKey,
    );
    if ((event.type == ControlPlaneEventType.InvitationAccept &&
            channel.status == ChannelStatus.waitingForApproval) ||
        (event.type == ControlPlaneEventType.InvitationGroupAccept &&
            channel.status == ChannelStatus.inaugurated)) {
      if (channel.type == ChannelType.group) {
        _logger.info(
          'Group invitation accepted for channel: '
          '${channel.permanentChannelDid}',
          name: _logKey,
        );
        _groupInvitationAcceptedController.add(channel);
      } else {
        _logger.info(
          'Invitation accepted for channel: '
          '${channel.permanentChannelDid}',
          name: _logKey,
        );
        _invitationAcceptedController.add(channel);
      }
      return;
    }

    if (event.type == ControlPlaneEventType.OfferFinalised ||
        event.type == ControlPlaneEventType.GroupMembershipFinalised) {
      if (channel.status == ChannelStatus.inaugurated) {
        _logger.info(
          'Connection offer approved and finalized for channel: '
          '${channel.permanentChannelDid}',
          name: _logKey,
        );
        _connectionOfferApprovedController.add(channel);
      } else {
        _logger.error(
          'Received a finalised offer for a non-inaugurated channel: '
          '${channel.permanentChannelDid}',
          name: _logKey,
        );
        throw AppException(
          'Received a finalised offer for a non-inaugurated channel',
          code: AppExceptionType.other.name,
        );
      }
      return;
    }

    if (event.type == ControlPlaneEventType.ChannelActivity) {
      if (channel.status == ChannelStatus.inaugurated) {
        _logger.info(
          'Channel activity detected for inaugurated channel: '
          '${channel.permanentChannelDid}',
          name: _logKey,
        );
        _channelActivityController.add(channel);
      } else {
        _logger.error(
          'Received channel activity for non-inaugurated channel: '
          '${channel.permanentChannelDid}',
          name: _logKey,
        );
        throw AppException(
          'Received channel activity for a non-inaugurated channel',
          code: AppExceptionType.other.name,
        );
      }
      return;
    }
  }

  /// Handle app resume: clear badges and optionally process control plane
  /// events.
  ///
  /// On resume, if there are pending badges, the badge is cleared and the
  /// control plane events processor is invoked to handle any queued events.
  ///
  /// Returns:
  /// - `Future<void>` completes when badge clear and event processing (if any)
  ///  finish.
  ///
  /// Throws:
  /// - Propagates exceptions from app badge service or event processing.
  Future<void> _handleAppResumed() async {
    await _processEvents();
  }

  /// Trigger processing of control plane events if the service is ready.
  ///
  /// Will no-op if a device token has not been registered yet.
  ///
  /// Returns:
  /// - `Future<void>` completes when (if) processing has been triggered.
  ///
  /// Throws:
  /// - Propagates any exceptions thrown during processing initiation.
  Future<void> _processEvents() async {
    if (state.isDeviceTokenRegistered != true) return;

    if (_sdk == null) {
      _logger.error(
        '''Trying to process control plane events but MeetingPlaceCoreSDK is not yet initialized''',
        name: _logKey,
      );
      return;
    }

    _eventProcessor ??= _ControlPlaneEventsProcessor(
      sdk: _sdk!,
      logger: _logger,
      onDidStart: () => state = state.copyWith(isProcessing: true),
      onDidEnd: () => state = state.copyWith(isProcessing: false),
    );
    _eventProcessor!.run();
  }

  Future<void> _askForTokenAgain() async {
    await ref.read(pushNotificationsHandlerProvider.notifier).getToken();
  }
}

class _ControlPlaneEventsProcessor {
  _ControlPlaneEventsProcessor({
    required MeetingPlaceCoreSDK sdk,
    required AppLogger logger,
    required VoidCallback onDidStart,
    required VoidCallback onDidEnd,
  })  : _sdk = sdk,
        _logger = logger,
        _onDidStart = onDidStart,
        _onDidEnd = onDidEnd;

  static const _logKey = 'CTLPLNEVTPROC';
  final MeetingPlaceCoreSDK _sdk;
  final AppLogger _logger;
  final VoidCallback _onDidStart;
  final VoidCallback _onDidEnd;

  // Queue and only call processEvents one at the time
  bool _isProcessing = false;
  // Don't add more request to the queue if there is already one
  // pending requests
  bool _shouldRunAgain = false;

  /// Schedule processing of control plane events ensuring single concurrent
  /// run.
  ///
  /// If a processing run is already in progress, this call marks that another
  /// run should be executed once the current run completes.
  void run() {
    if (_isProcessing) {
      _shouldRunAgain = true;
      return;
    }
    _runProcess();
  }

  /// Execute processing of control plane events.
  ///
  /// Calls the SDK's `processControlPlaneEvents` in a loop while additional
  /// runs have been requested during processing. Logs start and end of each
  /// run.
  ///
  /// Returns:
  /// - `Future<void>` completes when processing finishes.
  ///
  /// Throws:
  /// - Propagates any exceptions thrown by the MeetingPlaceCoreSDK during
  /// event processing.
  Future<void> _runProcess() async {
    _isProcessing = true;
    _logger.info(
      'Processing events started ...',
      name: _logKey,
    );
    _onDidStart.call();

    do {
      _shouldRunAgain = false;

      final completer = Completer<void>();
      try {
        await _sdk.processControlPlaneEvents(
          onDone: () {
            completer.complete();
          },
        );
      } catch (error, stackTrace) {
        _logger.error(
          'Error during processing control plane events',
          error: error,
          stackTrace: stackTrace,
          name: _logKey,
        );
        completer.complete();
        rethrow;
      }
      await completer.future;
    } while (_shouldRunAgain);
    _logger.info(
      'Processing ended.',
      name: _logKey,
    );
    _isProcessing = false;
    _onDidEnd.call();
  }
}
