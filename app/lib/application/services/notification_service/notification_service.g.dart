// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Service responsible for tracking notification counters for app features.
///
/// This service:
/// - Observes contacts and connections providers for badge counts.
/// - Maintains per-type counters (contacts, connections) in state.
/// - Exposes counter state via the provider for UI to display aggregated
///  counts.

@ProviderFor(NotificationService)
const notificationServiceProvider = NotificationServiceProvider._();

/// Service responsible for tracking notification counters for app features.
///
/// This service:
/// - Observes contacts and connections providers for badge counts.
/// - Maintains per-type counters (contacts, connections) in state.
/// - Exposes counter state via the provider for UI to display aggregated
///  counts.
final class NotificationServiceProvider
    extends $NotifierProvider<NotificationService, NotificationServiceState> {
  /// Service responsible for tracking notification counters for app features.
  ///
  /// This service:
  /// - Observes contacts and connections providers for badge counts.
  /// - Maintains per-type counters (contacts, connections) in state.
  /// - Exposes counter state via the provider for UI to display aggregated
  ///  counts.
  const NotificationServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'notificationServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$notificationServiceHash();

  @$internal
  @override
  NotificationService create() => NotificationService();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(NotificationServiceState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<NotificationServiceState>(value),
    );
  }
}

String _$notificationServiceHash() =>
    r'b63bfe651b102ebecb42be4c6c517432e853e9de';

/// Service responsible for tracking notification counters for app features.
///
/// This service:
/// - Observes contacts and connections providers for badge counts.
/// - Maintains per-type counters (contacts, connections) in state.
/// - Exposes counter state via the provider for UI to display aggregated
///  counts.

abstract class _$NotificationService
    extends $Notifier<NotificationServiceState> {
  NotificationServiceState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref =
        this.ref as $Ref<NotificationServiceState, NotificationServiceState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<NotificationServiceState, NotificationServiceState>,
              NotificationServiceState,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
