// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'offer_details_screen_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(OfferDetailsScreenController)
const offerDetailsScreenControllerProvider =
    OfferDetailsScreenControllerFamily._();

final class OfferDetailsScreenControllerProvider
    extends
        $NotifierProvider<
          OfferDetailsScreenController,
          OfferDetailsScreenState
        > {
  const OfferDetailsScreenControllerProvider._({
    required OfferDetailsScreenControllerFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'offerDetailsScreenControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$offerDetailsScreenControllerHash();

  @override
  String toString() {
    return r'offerDetailsScreenControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  OfferDetailsScreenController create() => OfferDetailsScreenController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(OfferDetailsScreenState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<OfferDetailsScreenState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is OfferDetailsScreenControllerProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$offerDetailsScreenControllerHash() =>
    r'dbe97ef33355accbe196d57cb5e885fb57494c20';

final class OfferDetailsScreenControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          OfferDetailsScreenController,
          OfferDetailsScreenState,
          OfferDetailsScreenState,
          OfferDetailsScreenState,
          String
        > {
  const OfferDetailsScreenControllerFamily._()
    : super(
        retry: null,
        name: r'offerDetailsScreenControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  OfferDetailsScreenControllerProvider call(String offerLink) =>
      OfferDetailsScreenControllerProvider._(argument: offerLink, from: this);

  @override
  String toString() => r'offerDetailsScreenControllerProvider';
}

abstract class _$OfferDetailsScreenController
    extends $Notifier<OfferDetailsScreenState> {
  late final _$args = ref.$arg as String;
  String get offerLink => _$args;

  OfferDetailsScreenState build(String offerLink);
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(_$args);
    final ref =
        this.ref as $Ref<OfferDetailsScreenState, OfferDetailsScreenState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<OfferDetailsScreenState, OfferDetailsScreenState>,
              OfferDetailsScreenState,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
