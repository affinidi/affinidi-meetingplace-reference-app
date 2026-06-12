// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'liveness_credentials_repository_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(livenessCredentialsRepository)
const livenessCredentialsRepositoryProvider =
    LivenessCredentialsRepositoryProvider._();

final class LivenessCredentialsRepositoryProvider
    extends
        $FunctionalProvider<
          AsyncValue<LivenessCredentialsRepository>,
          LivenessCredentialsRepository,
          FutureOr<LivenessCredentialsRepository>
        >
    with
        $FutureModifier<LivenessCredentialsRepository>,
        $FutureProvider<LivenessCredentialsRepository> {
  const LivenessCredentialsRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'livenessCredentialsRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$livenessCredentialsRepositoryHash();

  @$internal
  @override
  $FutureProviderElement<LivenessCredentialsRepository> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<LivenessCredentialsRepository> create(Ref ref) {
    return livenessCredentialsRepository(ref);
  }
}

String _$livenessCredentialsRepositoryHash() =>
    r'ed4a6c9e03d9faec15d85fabedf2d5011e85bddc';
