// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_screen_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(SettingsScreenController)
final settingsScreenControllerProvider = SettingsScreenControllerProvider._();

final class SettingsScreenControllerProvider
    extends $NotifierProvider<SettingsScreenController, SettingsScreenState> {
  SettingsScreenControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'settingsScreenControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$settingsScreenControllerHash();

  @$internal
  @override
  SettingsScreenController create() => SettingsScreenController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SettingsScreenState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SettingsScreenState>(value),
    );
  }
}

String _$settingsScreenControllerHash() =>
    r'4a61a7ad3ea283f90b466693fbf60b7e5a247f87';

abstract class _$SettingsScreenController
    extends $Notifier<SettingsScreenState> {
  SettingsScreenState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<SettingsScreenState, SettingsScreenState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<SettingsScreenState, SettingsScreenState>,
              SettingsScreenState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
