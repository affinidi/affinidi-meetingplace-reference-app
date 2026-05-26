// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'identities_screen_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(IdentitiesScreenController)
final identitiesScreenControllerProvider =
    IdentitiesScreenControllerProvider._();

final class IdentitiesScreenControllerProvider
    extends
        $NotifierProvider<IdentitiesScreenController, IdentitiesScreenState> {
  IdentitiesScreenControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'identitiesScreenControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$identitiesScreenControllerHash();

  @$internal
  @override
  IdentitiesScreenController create() => IdentitiesScreenController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(IdentitiesScreenState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<IdentitiesScreenState>(value),
    );
  }
}

String _$identitiesScreenControllerHash() =>
    r'8baf5ba6cdc3d795f39c99b46ffa08938eae17eb';

abstract class _$IdentitiesScreenController
    extends $Notifier<IdentitiesScreenState> {
  IdentitiesScreenState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<IdentitiesScreenState, IdentitiesScreenState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<IdentitiesScreenState, IdentitiesScreenState>,
              IdentitiesScreenState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
