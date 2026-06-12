// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'r_cards_screen_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(RCardsScreenController)
const rCardsScreenControllerProvider = RCardsScreenControllerProvider._();

final class RCardsScreenControllerProvider
    extends $NotifierProvider<RCardsScreenController, RCardsScreenState> {
  const RCardsScreenControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'rCardsScreenControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$rCardsScreenControllerHash();

  @$internal
  @override
  RCardsScreenController create() => RCardsScreenController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RCardsScreenState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RCardsScreenState>(value),
    );
  }
}

String _$rCardsScreenControllerHash() =>
    r'12d13e9f49c656a544c185060bb003fd6304aea9';

abstract class _$RCardsScreenController extends $Notifier<RCardsScreenState> {
  RCardsScreenState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<RCardsScreenState, RCardsScreenState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<RCardsScreenState, RCardsScreenState>,
              RCardsScreenState,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
