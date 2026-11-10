// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'community_tabs_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The member's role in [communityDid], as their VTA keeps it, or null when
/// it holds no role card. Read while a community's page shows, never kept on
/// the phone.

@ProviderFor(communityRole)
const communityRoleProvider = CommunityRoleFamily._();

/// The member's role in [communityDid], as their VTA keeps it, or null when
/// it holds no role card. Read while a community's page shows, never kept on
/// the phone.

final class CommunityRoleProvider
    extends $FunctionalProvider<AsyncValue<String?>, String?, FutureOr<String?>>
    with $FutureModifier<String?>, $FutureProvider<String?> {
  /// The member's role in [communityDid], as their VTA keeps it, or null when
  /// it holds no role card. Read while a community's page shows, never kept on
  /// the phone.
  const CommunityRoleProvider._({
    required CommunityRoleFamily super.from,
    required String super.argument,
  }) : super(
         retry: _noRetry,
         name: r'communityRoleProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$communityRoleHash();

  @override
  String toString() {
    return r'communityRoleProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<String?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<String?> create(Ref ref) {
    final argument = this.argument as String;
    return communityRole(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is CommunityRoleProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$communityRoleHash() => r'fddc7f5f281ebf76d38b090542697c20e3c012ef';

/// The member's role in [communityDid], as their VTA keeps it, or null when
/// it holds no role card. Read while a community's page shows, never kept on
/// the phone.

final class CommunityRoleFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<String?>, String> {
  const CommunityRoleFamily._()
    : super(
        retry: _noRetry,
        name: r'communityRoleProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The member's role in [communityDid], as their VTA keeps it, or null when
  /// it holds no role card. Read while a community's page shows, never kept on
  /// the phone.

  CommunityRoleProvider call(String communityDid) =>
      CommunityRoleProvider._(argument: communityDid, from: this);

  @override
  String toString() => r'communityRoleProvider';
}

/// The membership card [communityDid] issued the member, as their VTA keeps
/// it, or null while it is on its way. Read while a community's page shows,
/// never kept on the phone.

@ProviderFor(communityMembershipCard)
const communityMembershipCardProvider = CommunityMembershipCardFamily._();

/// The membership card [communityDid] issued the member, as their VTA keeps
/// it, or null while it is on its way. Read while a community's page shows,
/// never kept on the phone.

final class CommunityMembershipCardProvider
    extends
        $FunctionalProvider<
          AsyncValue<VtcMembershipCard?>,
          VtcMembershipCard?,
          FutureOr<VtcMembershipCard?>
        >
    with
        $FutureModifier<VtcMembershipCard?>,
        $FutureProvider<VtcMembershipCard?> {
  /// The membership card [communityDid] issued the member, as their VTA keeps
  /// it, or null while it is on its way. Read while a community's page shows,
  /// never kept on the phone.
  const CommunityMembershipCardProvider._({
    required CommunityMembershipCardFamily super.from,
    required String super.argument,
  }) : super(
         retry: _noRetry,
         name: r'communityMembershipCardProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$communityMembershipCardHash();

  @override
  String toString() {
    return r'communityMembershipCardProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<VtcMembershipCard?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<VtcMembershipCard?> create(Ref ref) {
    final argument = this.argument as String;
    return communityMembershipCard(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is CommunityMembershipCardProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$communityMembershipCardHash() =>
    r'7d29a6c8b030a30e9780eccce76018caf58e1758';

/// The membership card [communityDid] issued the member, as their VTA keeps
/// it, or null while it is on its way. Read while a community's page shows,
/// never kept on the phone.

final class CommunityMembershipCardFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<VtcMembershipCard?>, String> {
  const CommunityMembershipCardFamily._()
    : super(
        retry: _noRetry,
        name: r'communityMembershipCardProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The membership card [communityDid] issued the member, as their VTA keeps
  /// it, or null while it is on its way. Read while a community's page shows,
  /// never kept on the phone.

  CommunityMembershipCardProvider call(String communityDid) =>
      CommunityMembershipCardProvider._(argument: communityDid, from: this);

  @override
  String toString() => r'communityMembershipCardProvider';
}

/// What [communityDid] publishes about itself, read while its page shows.

@ProviderFor(communityInfo)
const communityInfoProvider = CommunityInfoFamily._();

/// What [communityDid] publishes about itself, read while its page shows.

final class CommunityInfoProvider
    extends
        $FunctionalProvider<
          AsyncValue<CommunityInfo>,
          CommunityInfo,
          FutureOr<CommunityInfo>
        >
    with $FutureModifier<CommunityInfo>, $FutureProvider<CommunityInfo> {
  /// What [communityDid] publishes about itself, read while its page shows.
  const CommunityInfoProvider._({
    required CommunityInfoFamily super.from,
    required String super.argument,
  }) : super(
         retry: _noRetry,
         name: r'communityInfoProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$communityInfoHash();

  @override
  String toString() {
    return r'communityInfoProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<CommunityInfo> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<CommunityInfo> create(Ref ref) {
    final argument = this.argument as String;
    return communityInfo(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is CommunityInfoProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$communityInfoHash() => r'038cd76afe85fc1f52f7fdb6286c0dd2ad989b36';

/// What [communityDid] publishes about itself, read while its page shows.

final class CommunityInfoFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<CommunityInfo>, String> {
  const CommunityInfoFamily._()
    : super(
        retry: _noRetry,
        name: r'communityInfoProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// What [communityDid] publishes about itself, read while its page shows.

  CommunityInfoProvider call(String communityDid) =>
      CommunityInfoProvider._(argument: communityDid, from: this);

  @override
  String toString() => r'communityInfoProvider';
}
