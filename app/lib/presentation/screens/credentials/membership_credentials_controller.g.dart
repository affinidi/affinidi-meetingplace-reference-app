// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'membership_credentials_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The member's membership cards, and whether each one's community still
/// holds it. Only a failure's code is logged; never a DID or a card.

@ProviderFor(MembershipCredentialsController)
const membershipCredentialsControllerProvider =
    MembershipCredentialsControllerProvider._();

/// The member's membership cards, and whether each one's community still
/// holds it. Only a failure's code is logged; never a DID or a card.
final class MembershipCredentialsControllerProvider
    extends
        $NotifierProvider<
          MembershipCredentialsController,
          MembershipCredentialsState
        > {
  /// The member's membership cards, and whether each one's community still
  /// holds it. Only a failure's code is logged; never a DID or a card.
  const MembershipCredentialsControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'membershipCredentialsControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$membershipCredentialsControllerHash();

  @$internal
  @override
  MembershipCredentialsController create() => MembershipCredentialsController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MembershipCredentialsState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MembershipCredentialsState>(value),
    );
  }
}

String _$membershipCredentialsControllerHash() =>
    r'ec9ec21ed3a30537c610990147e90102a6410025';

/// The member's membership cards, and whether each one's community still
/// holds it. Only a failure's code is logged; never a DID or a card.

abstract class _$MembershipCredentialsController
    extends $Notifier<MembershipCredentialsState> {
  MembershipCredentialsState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref =
        this.ref
            as $Ref<MembershipCredentialsState, MembershipCredentialsState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                MembershipCredentialsState,
                MembershipCredentialsState
              >,
              MembershipCredentialsState,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

/// The website the community [communityDid] lists in its profile, or null
/// when it lists none or cannot be reached. The profile is unsigned: a link
/// to follow, never proof of anything.

@ProviderFor(communityWebsite)
const communityWebsiteProvider = CommunityWebsiteFamily._();

/// The website the community [communityDid] lists in its profile, or null
/// when it lists none or cannot be reached. The profile is unsigned: a link
/// to follow, never proof of anything.

final class CommunityWebsiteProvider
    extends $FunctionalProvider<AsyncValue<Uri?>, Uri?, FutureOr<Uri?>>
    with $FutureModifier<Uri?>, $FutureProvider<Uri?> {
  /// The website the community [communityDid] lists in its profile, or null
  /// when it lists none or cannot be reached. The profile is unsigned: a link
  /// to follow, never proof of anything.
  const CommunityWebsiteProvider._({
    required CommunityWebsiteFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'communityWebsiteProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$communityWebsiteHash();

  @override
  String toString() {
    return r'communityWebsiteProvider'
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
    return communityWebsite(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is CommunityWebsiteProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$communityWebsiteHash() => r'1d30cf96b497d232a34cb24ddb62255dd456b3aa';

/// The website the community [communityDid] lists in its profile, or null
/// when it lists none or cannot be reached. The profile is unsigned: a link
/// to follow, never proof of anything.

final class CommunityWebsiteFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<Uri?>, String> {
  const CommunityWebsiteFamily._()
    : super(
        retry: null,
        name: r'communityWebsiteProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The website the community [communityDid] lists in its profile, or null
  /// when it lists none or cannot be reached. The profile is unsigned: a link
  /// to follow, never proof of anything.

  CommunityWebsiteProvider call(String communityDid) =>
      CommunityWebsiteProvider._(argument: communityDid, from: this);

  @override
  String toString() => r'communityWebsiteProvider';
}
