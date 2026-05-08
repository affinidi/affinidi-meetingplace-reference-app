// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'debug_panel_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$debugPanelControllerHash() =>
    r'39bc1b2be66c011c8d0d232d87f48de32465edef';

@ProviderFor(DebugPanelController)
final debugPanelControllerProvider = DebugPanelControllerProvider._();

final class DebugPanelControllerProvider
    extends $NotifierProvider<DebugPanelController, DebugPanelState> {
  DebugPanelControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'debugPanelControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$debugPanelControllerHash();

  @$internal
  @override
  DebugPanelController create() => DebugPanelController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DebugPanelState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DebugPanelState>(value),
    );
  }
}

>>>>>>> 0452086 (fix: align with transport-agnostic type changes on SDK (#112))
String _$debugPanelControllerHash() =>
    r'39bc1b2be66c011c8d0d232d87f48de32465edef';

/// See also [DebugPanelController].
@ProviderFor(DebugPanelController)
final debugPanelControllerProvider =
    AutoDisposeNotifierProvider<DebugPanelController, DebugPanelState>.internal(
      DebugPanelController.new,
      name: r'debugPanelControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$debugPanelControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$DebugPanelController = AutoDisposeNotifier<DebugPanelState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
