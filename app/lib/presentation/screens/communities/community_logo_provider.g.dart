// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'community_logo_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The logo [communityDid] publishes in its profile, or null when it gives
/// none or cannot be reached. Read once while the app runs, so the
/// Communities tab does not ask every community each time it shows.

@ProviderFor(communityLogo)
const communityLogoProvider = CommunityLogoFamily._();

/// The logo [communityDid] publishes in its profile, or null when it gives
/// none or cannot be reached. Read once while the app runs, so the
/// Communities tab does not ask every community each time it shows.

final class CommunityLogoProvider
    extends $FunctionalProvider<AsyncValue<Uri?>, Uri?, FutureOr<Uri?>>
    with $FutureModifier<Uri?>, $FutureProvider<Uri?> {
  /// The logo [communityDid] publishes in its profile, or null when it gives
  /// none or cannot be reached. Read once while the app runs, so the
  /// Communities tab does not ask every community each time it shows.
  const CommunityLogoProvider._({
    required CommunityLogoFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'communityLogoProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$communityLogoHash();

  @override
  String toString() {
    return r'communityLogoProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<Uri?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Uri?> create(Ref ref) {
    final argument = this.argument as String;
    return communityLogo(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is CommunityLogoProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$communityLogoHash() => r'2a21f79d1c5780c4f286c7df3ca26ae6f49ecf5a';

/// The logo [communityDid] publishes in its profile, or null when it gives
/// none or cannot be reached. Read once while the app runs, so the
/// Communities tab does not ask every community each time it shows.

final class CommunityLogoFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<Uri?>, String> {
  const CommunityLogoFamily._()
    : super(
        retry: null,
        name: r'communityLogoProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  /// The logo [communityDid] publishes in its profile, or null when it gives
  /// none or cannot be reached. Read once while the app runs, so the
  /// Communities tab does not ask every community each time it shows.

  CommunityLogoProvider call(String communityDid) =>
      CommunityLogoProvider._(argument: communityDid, from: this);

  @override
  String toString() => r'communityLogoProvider';
}
