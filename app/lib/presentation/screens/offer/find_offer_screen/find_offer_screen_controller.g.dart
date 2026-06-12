// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'find_offer_screen_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(FindOfferScreenController)
const findOfferScreenControllerProvider = FindOfferScreenControllerProvider._();

final class FindOfferScreenControllerProvider
    extends $NotifierProvider<FindOfferScreenController, FindOfferScreenState> {
  const FindOfferScreenControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'findOfferScreenControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$findOfferScreenControllerHash();

  @$internal
  @override
  FindOfferScreenController create() => FindOfferScreenController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FindOfferScreenState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FindOfferScreenState>(value),
    );
  }
}

String _$findOfferScreenControllerHash() =>
    r'289a6658b078c6fdf3723fa05b9794efbc01ebba';

abstract class _$FindOfferScreenController
    extends $Notifier<FindOfferScreenState> {
  FindOfferScreenState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<FindOfferScreenState, FindOfferScreenState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<FindOfferScreenState, FindOfferScreenState>,
              FindOfferScreenState,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
