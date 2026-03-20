// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'matrix_rtc_delegate_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$matrixRtcDelegateHash() => r'f0f778138e18806e8d9767edbcb1b5d66906de1b';

/// A singleton `FlutterMatrixRTCDelegate` that is injected into the `VoIP`
/// instance. Kept alive so the call layer can install an
/// `EncryptionKeyProvider` on it before a call starts.
///
/// Copied from [matrixRtcDelegate].
@ProviderFor(matrixRtcDelegate)
final matrixRtcDelegateProvider = Provider<FlutterMatrixRTCDelegate>.internal(
  matrixRtcDelegate,
  name: r'matrixRtcDelegateProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$matrixRtcDelegateHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef MatrixRtcDelegateRef = ProviderRef<FlutterMatrixRTCDelegate>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
