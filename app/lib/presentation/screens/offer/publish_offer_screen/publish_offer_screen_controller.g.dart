// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'publish_offer_screen_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

<<<<<<< HEAD
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
=======
String _$publishOfferScreenControllerHash() =>
    r'bd2477d51ec503a4fdb4d041df75ba90389f9936';
>>>>>>> 5e6ffdbc (feat: add 1:1 chat transport selection gated by build-time env var (#127))

@ProviderFor(PublishOfferScreenController)
final publishOfferScreenControllerProvider =
    PublishOfferScreenControllerFamily._();

final class PublishOfferScreenControllerProvider
    extends
        $NotifierProvider<
          PublishOfferScreenController,
          PublishOfferScreenState
        > {
  PublishOfferScreenControllerProvider._({
    required PublishOfferScreenControllerFamily super.from,
    required (String, AppLocalizations) super.argument,
  }) : super(
         retry: null,
         name: r'publishOfferScreenControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$publishOfferScreenControllerHash();

  @override
  String toString() {
    return r'publishOfferScreenControllerProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  PublishOfferScreenController create() => PublishOfferScreenController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PublishOfferScreenState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PublishOfferScreenState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is PublishOfferScreenControllerProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$publishOfferScreenControllerHash() =>
    r'e238cafedfd68d289dc193ae7eb7ddb5804bfc24';

final class PublishOfferScreenControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          PublishOfferScreenController,
          PublishOfferScreenState,
          PublishOfferScreenState,
          PublishOfferScreenState,
          (String, AppLocalizations)
        > {
  PublishOfferScreenControllerFamily._()
    : super(
        retry: null,
        name: r'publishOfferScreenControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  PublishOfferScreenControllerProvider call(
    String identityId,
    AppLocalizations l10n,
  ) => PublishOfferScreenControllerProvider._(
    argument: (identityId, l10n),
    from: this,
  );

  @override
  String toString() => r'publishOfferScreenControllerProvider';
}

abstract class _$PublishOfferScreenController
    extends $Notifier<PublishOfferScreenState> {
  late final _$args = ref.$arg as (String, AppLocalizations);
  String get identityId => _$args.$1;
  AppLocalizations get l10n => _$args.$2;

  PublishOfferScreenState build(String identityId, AppLocalizations l10n);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<PublishOfferScreenState, PublishOfferScreenState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<PublishOfferScreenState, PublishOfferScreenState>,
              PublishOfferScreenState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args.$1, _$args.$2));
  }
}
