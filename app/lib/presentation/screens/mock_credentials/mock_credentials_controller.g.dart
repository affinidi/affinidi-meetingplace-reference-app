// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mock_credentials_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Shows the test credentials this phone can issue and which of the
/// member's identities hold each, and imports one for an identity. Only a
/// failure's code is logged; never a DID or a credential.

@ProviderFor(MockCredentialsController)
const mockCredentialsControllerProvider = MockCredentialsControllerProvider._();

/// Shows the test credentials this phone can issue and which of the
/// member's identities hold each, and imports one for an identity. Only a
/// failure's code is logged; never a DID or a credential.
final class MockCredentialsControllerProvider
    extends $NotifierProvider<MockCredentialsController, MockCredentialsState> {
  /// Shows the test credentials this phone can issue and which of the
  /// member's identities hold each, and imports one for an identity. Only a
  /// failure's code is logged; never a DID or a credential.
  const MockCredentialsControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'mockCredentialsControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$mockCredentialsControllerHash();

  @$internal
  @override
  MockCredentialsController create() => MockCredentialsController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MockCredentialsState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MockCredentialsState>(value),
    );
  }
}

String _$mockCredentialsControllerHash() =>
    r'ace70dfab1333cf940c2c694ecd728144c739cef';

/// Shows the test credentials this phone can issue and which of the
/// member's identities hold each, and imports one for an identity. Only a
/// failure's code is logged; never a DID or a credential.

abstract class _$MockCredentialsController
    extends $Notifier<MockCredentialsState> {
  MockCredentialsState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<MockCredentialsState, MockCredentialsState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<MockCredentialsState, MockCredentialsState>,
              MockCredentialsState,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
