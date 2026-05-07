// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'authentication_screen_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(AuthenticationScreenController)
final authenticationScreenControllerProvider =
    AuthenticationScreenControllerProvider._();

final class AuthenticationScreenControllerProvider
    extends
        $NotifierProvider<
          AuthenticationScreenController,
          AuthenticationScreenState
        > {
  AuthenticationScreenControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authenticationScreenControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authenticationScreenControllerHash();

  @$internal
  @override
  AuthenticationScreenController create() => AuthenticationScreenController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AuthenticationScreenState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AuthenticationScreenState>(value),
    );
  }
}

String _$authenticationScreenControllerHash() =>
    r'51d71712b8fd68b5d2de0b67f0a71ab40eaf3bb2';

abstract class _$AuthenticationScreenController
    extends $Notifier<AuthenticationScreenState> {
  AuthenticationScreenState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<AuthenticationScreenState, AuthenticationScreenState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AuthenticationScreenState, AuthenticationScreenState>,
              AuthenticationScreenState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
