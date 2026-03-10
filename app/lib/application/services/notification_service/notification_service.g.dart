// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$notificationServiceHash() =>
    r'b63bfe651b102ebecb42be4c6c517432e853e9de';

/// Service responsible for tracking notification counters for app features.
///
/// This service:
/// - Observes contacts and connections providers for badge counts.
/// - Maintains per-type counters (contacts, connections) in state.
/// - Exposes counter state via the provider for UI to display aggregated
///  counts.
///
/// Copied from [NotificationService].
@ProviderFor(NotificationService)
final notificationServiceProvider =
    NotifierProvider<NotificationService, NotificationServiceState>.internal(
      NotificationService.new,
      name: r'notificationServiceProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$notificationServiceHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$NotificationService = Notifier<NotificationServiceState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
