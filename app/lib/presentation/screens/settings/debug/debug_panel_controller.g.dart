// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'debug_panel_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

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

String _$debugPanelControllerHash() =>
    r'39bc1b2be66c011c8d0d232d87f48de32465edef';

abstract class _$DebugPanelController extends $Notifier<DebugPanelState> {
  DebugPanelState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<DebugPanelState, DebugPanelState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<DebugPanelState, DebugPanelState>,
              DebugPanelState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
