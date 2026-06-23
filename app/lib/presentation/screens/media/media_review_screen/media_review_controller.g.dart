// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'media_review_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(MediaReviewController)
const mediaReviewControllerProvider = MediaReviewControllerProvider._();

final class MediaReviewControllerProvider
    extends $NotifierProvider<MediaReviewController, void> {
  const MediaReviewControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'mediaReviewControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$mediaReviewControllerHash();

  @$internal
  @override
  MediaReviewController create() => MediaReviewController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$mediaReviewControllerHash() =>
    r'3e576e1445e7f2ec38686b4a795f7065e7d88126';

abstract class _$MediaReviewController extends $Notifier<void> {
  void build();
  @$mustCallSuper
  @override
  void runBuild() {
    build();
    final ref = this.ref as $Ref<void, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<void, void>,
              void,
              Object?,
              Object?
            >;
    element.handleValue(ref, null);
  }
}
