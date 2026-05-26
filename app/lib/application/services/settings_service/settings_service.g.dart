// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Service responsible for application settings and mediator configuration.
///
/// This service provides functionality to:
/// - Restore and persist the preferred mediator DID
/// - Load available default and custom mediators
/// - Manage debug mode toggling and its persistence
/// - Track onboarding completion flag
///
/// It reads environment defaults and secure storage, exposes the combined list
/// of mediators, and updates persistent storage when settings change.

@ProviderFor(SettingsService)
final settingsServiceProvider = SettingsServiceProvider._();

/// Service responsible for application settings and mediator configuration.
///
/// This service provides functionality to:
/// - Restore and persist the preferred mediator DID
/// - Load available default and custom mediators
/// - Manage debug mode toggling and its persistence
/// - Track onboarding completion flag
///
/// It reads environment defaults and secure storage, exposes the combined list
/// of mediators, and updates persistent storage when settings change.
final class SettingsServiceProvider
    extends $NotifierProvider<SettingsService, SettingsServiceState> {
  /// Service responsible for application settings and mediator configuration.
  ///
  /// This service provides functionality to:
  /// - Restore and persist the preferred mediator DID
  /// - Load available default and custom mediators
  /// - Manage debug mode toggling and its persistence
  /// - Track onboarding completion flag
  ///
  /// It reads environment defaults and secure storage, exposes the combined list
  /// of mediators, and updates persistent storage when settings change.
  SettingsServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'settingsServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$settingsServiceHash();

  @$internal
  @override
  SettingsService create() => SettingsService();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SettingsServiceState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SettingsServiceState>(value),
    );
  }
}

String _$settingsServiceHash() => r'b38a9046f8af9f60707320bfd11ff7b6a2d233e3';

/// Service responsible for application settings and mediator configuration.
///
/// This service provides functionality to:
/// - Restore and persist the preferred mediator DID
/// - Load available default and custom mediators
/// - Manage debug mode toggling and its persistence
/// - Track onboarding completion flag
///
/// It reads environment defaults and secure storage, exposes the combined list
/// of mediators, and updates persistent storage when settings change.

abstract class _$SettingsService extends $Notifier<SettingsServiceState> {
  SettingsServiceState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<SettingsServiceState, SettingsServiceState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<SettingsServiceState, SettingsServiceState>,
              SettingsServiceState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
