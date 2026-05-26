// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'accept_offer_screen_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(AcceptOfferScreenController)
final acceptOfferScreenControllerProvider =
    AcceptOfferScreenControllerFamily._();

final class AcceptOfferScreenControllerProvider
    extends
        $NotifierProvider<AcceptOfferScreenController, AcceptOfferScreenState> {
  AcceptOfferScreenControllerProvider._({
    required AcceptOfferScreenControllerFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'acceptOfferScreenControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$acceptOfferScreenControllerHash();

  @override
  String toString() {
    return r'acceptOfferScreenControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  AcceptOfferScreenController create() => AcceptOfferScreenController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AcceptOfferScreenState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AcceptOfferScreenState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is AcceptOfferScreenControllerProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$acceptOfferScreenControllerHash() =>
    r'190cfd5d51825ca24a494778f673b29bae5ea7a4';

final class AcceptOfferScreenControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          AcceptOfferScreenController,
          AcceptOfferScreenState,
          AcceptOfferScreenState,
          AcceptOfferScreenState,
          String
        > {
  AcceptOfferScreenControllerFamily._()
    : super(
        retry: null,
        name: r'acceptOfferScreenControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  AcceptOfferScreenControllerProvider call(String mnemonic) =>
      AcceptOfferScreenControllerProvider._(argument: mnemonic, from: this);

  @override
  String toString() => r'acceptOfferScreenControllerProvider';
}

abstract class _$AcceptOfferScreenController
    extends $Notifier<AcceptOfferScreenState> {
  late final _$args = ref.$arg as String;
  String get mnemonic => _$args;

  AcceptOfferScreenState build(String mnemonic);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<AcceptOfferScreenState, AcceptOfferScreenState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AcceptOfferScreenState, AcceptOfferScreenState>,
              AcceptOfferScreenState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}
