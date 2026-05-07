// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'control_plane_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
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

@ProviderFor(ControlPlaneService)
final controlPlaneServiceProvider = ControlPlaneServiceProvider._();

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
final class ControlPlaneServiceProvider
    extends $NotifierProvider<ControlPlaneService, ControlPlaneServiceState> {
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
  ControlPlaneServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'controlPlaneServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$controlPlaneServiceHash();

  @$internal
  @override
  ControlPlaneService create() => ControlPlaneService();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ControlPlaneServiceState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ControlPlaneServiceState>(value),
    );
  }
}

String _$controlPlaneServiceHash() =>
    r'1d9b0ea123b16ebc5f51fa80c01534978e933868';

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

abstract class _$ControlPlaneService
    extends $Notifier<ControlPlaneServiceState> {
  ControlPlaneServiceState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<ControlPlaneServiceState, ControlPlaneServiceState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ControlPlaneServiceState, ControlPlaneServiceState>,
              ControlPlaneServiceState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
