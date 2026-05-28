// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'identity_form_screen_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(IdentityFormScreenController)
final identityFormScreenControllerProvider =
    IdentityFormScreenControllerFamily._();

final class IdentityFormScreenControllerProvider
    extends
        $NotifierProvider<
          IdentityFormScreenController,
          IdentityFormScreenState
        > {
  IdentityFormScreenControllerProvider._({
    required IdentityFormScreenControllerFamily super.from,
    required String? super.argument,
  }) : super(
         retry: null,
         name: r'identityFormScreenControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$identityFormScreenControllerHash();

  @override
  String toString() {
    return r'identityFormScreenControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  IdentityFormScreenController create() => IdentityFormScreenController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(IdentityFormScreenState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<IdentityFormScreenState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is IdentityFormScreenControllerProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$identityFormScreenControllerHash() =>
    r'3bffba813b73da813ca237c699f82330fb6c12d7';

final class IdentityFormScreenControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          IdentityFormScreenController,
          IdentityFormScreenState,
          IdentityFormScreenState,
          IdentityFormScreenState,
          String?
        > {
  IdentityFormScreenControllerFamily._()
    : super(
        retry: null,
        name: r'identityFormScreenControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  IdentityFormScreenControllerProvider call(String? identityId) =>
      IdentityFormScreenControllerProvider._(argument: identityId, from: this);

  @override
  String toString() => r'identityFormScreenControllerProvider';
}

abstract class _$IdentityFormScreenController
    extends $Notifier<IdentityFormScreenState> {
  late final _$args = ref.$arg as String?;
  String? get identityId => _$args;

  IdentityFormScreenState build(String? identityId);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<IdentityFormScreenState, IdentityFormScreenState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<IdentityFormScreenState, IdentityFormScreenState>,
              IdentityFormScreenState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}
