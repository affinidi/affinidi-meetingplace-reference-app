// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'control_plane_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$controlPlaneServiceHash() =>
    r'46dad7adef383448a1aa9ecd7be4892e5a5653ad';

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
///
/// Copied from [ControlPlaneService].
@ProviderFor(ControlPlaneService)
final controlPlaneServiceProvider =
    NotifierProvider<ControlPlaneService, ControlPlaneServiceState>.internal(
  ControlPlaneService.new,
  name: r'controlPlaneServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$controlPlaneServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ControlPlaneService = Notifier<ControlPlaneServiceState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
