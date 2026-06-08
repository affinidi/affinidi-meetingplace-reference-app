// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vrc_attachment_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(VrcAttachmentController)
final vrcAttachmentControllerProvider = VrcAttachmentControllerFamily._();

final class VrcAttachmentControllerProvider
    extends $NotifierProvider<VrcAttachmentController, VrcAttachmentState> {
  VrcAttachmentControllerProvider._({
    required VrcAttachmentControllerFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'vrcAttachmentControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$vrcAttachmentControllerHash();

  @override
  String toString() {
    return r'vrcAttachmentControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  VrcAttachmentController create() => VrcAttachmentController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(VrcAttachmentState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<VrcAttachmentState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is VrcAttachmentControllerProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$vrcAttachmentControllerHash() =>
    r'2808fccddae358014e51d48183580fa8b04d349b';

final class VrcAttachmentControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          VrcAttachmentController,
          VrcAttachmentState,
          VrcAttachmentState,
          VrcAttachmentState,
          String
        > {
  VrcAttachmentControllerFamily._()
    : super(
        retry: null,
        name: r'vrcAttachmentControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  VrcAttachmentControllerProvider call(String vcBlob) =>
      VrcAttachmentControllerProvider._(argument: vcBlob, from: this);

  @override
  String toString() => r'vrcAttachmentControllerProvider';
}

abstract class _$VrcAttachmentController extends $Notifier<VrcAttachmentState> {
  late final _$args = ref.$arg as String;
  String get vcBlob => _$args;

  VrcAttachmentState build(String vcBlob);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<VrcAttachmentState, VrcAttachmentState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<VrcAttachmentState, VrcAttachmentState>,
              VrcAttachmentState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}
