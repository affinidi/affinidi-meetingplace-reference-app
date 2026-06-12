// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'publish_offer_screen_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(PublishOfferScreenController)
const publishOfferScreenControllerProvider =
    PublishOfferScreenControllerFamily._();

final class PublishOfferScreenControllerProvider
    extends
        $NotifierProvider<
          PublishOfferScreenController,
          PublishOfferScreenState
        > {
  const PublishOfferScreenControllerProvider._({
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
    r'ac05312366ee33a50420aee077de86206fef71ee';

final class PublishOfferScreenControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          PublishOfferScreenController,
          PublishOfferScreenState,
          PublishOfferScreenState,
          PublishOfferScreenState,
          (String, AppLocalizations)
        > {
  const PublishOfferScreenControllerFamily._()
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
    final created = build(_$args.$1, _$args.$2);
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
    element.handleValue(ref, created);
  }
}
