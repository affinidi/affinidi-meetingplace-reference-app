// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'community_tabs_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The member's role in [communityDid], as their VTA keeps it, or null when
/// it holds no role card. Read while a community's page shows, and again as
/// the cards change, never kept on the phone.

@ProviderFor(communityRole)
const communityRoleProvider = CommunityRoleFamily._();

/// The member's role in [communityDid], as their VTA keeps it, or null when
/// it holds no role card. Read while a community's page shows, and again as
/// the cards change, never kept on the phone.

final class CommunityRoleProvider
    extends $FunctionalProvider<AsyncValue<String?>, String?, FutureOr<String?>>
    with $FutureModifier<String?>, $FutureProvider<String?> {
  /// The member's role in [communityDid], as their VTA keeps it, or null when
  /// it holds no role card. Read while a community's page shows, and again as
  /// the cards change, never kept on the phone.
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

String _$communityRoleHash() => r'738cbce73a858063bba813cab35ad9cdf43d894e';

/// The member's role in [communityDid], as their VTA keeps it, or null when
/// it holds no role card. Read while a community's page shows, and again as
/// the cards change, never kept on the phone.

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
  /// it holds no role card. Read while a community's page shows, and again as
  /// the cards change, never kept on the phone.

  CommunityRoleProvider call(String communityDid) =>
      CommunityRoleProvider._(argument: communityDid, from: this);

  @override
  String toString() => r'communityRoleProvider';
}

/// The membership card [communityDid] issued the member, as their VTA keeps
/// it, or null while it is on its way. Read while a community's page shows,
/// and again as the cards change, never kept on the phone.

@ProviderFor(communityMembershipCard)
const communityMembershipCardProvider = CommunityMembershipCardFamily._();

/// The membership card [communityDid] issued the member, as their VTA keeps
/// it, or null while it is on its way. Read while a community's page shows,
/// and again as the cards change, never kept on the phone.

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
  /// and again as the cards change, never kept on the phone.
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
    r'a52091875884c8b878a205e131b8a6303fbf8552';

/// The membership card [communityDid] issued the member, as their VTA keeps
/// it, or null while it is on its way. Read while a community's page shows,
/// and again as the cards change, never kept on the phone.

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
  /// and again as the cards change, never kept on the phone.

  CommunityMembershipCardProvider call(String communityDid) =>
      CommunityMembershipCardProvider._(argument: communityDid, from: this);

  @override
  String toString() => r'communityMembershipCardProvider';
}

/// The vetter role card [communityDid] issued the member, as their VTA
/// keeps it, in date and not revoked, or null when they may not vet there.
/// Read while a community's page shows, for its Membership and Vetting
/// tabs, and again as the cards change; the vetting desk checks the card
/// again before any ticket.

@ProviderFor(communityVetterCard)
const communityVetterCardProvider = CommunityVetterCardFamily._();

/// The vetter role card [communityDid] issued the member, as their VTA
/// keeps it, in date and not revoked, or null when they may not vet there.
/// Read while a community's page shows, for its Membership and Vetting
/// tabs, and again as the cards change; the vetting desk checks the card
/// again before any ticket.

final class CommunityVetterCardProvider
    extends
        $FunctionalProvider<
          AsyncValue<VtcVetterCard?>,
          VtcVetterCard?,
          FutureOr<VtcVetterCard?>
        >
    with $FutureModifier<VtcVetterCard?>, $FutureProvider<VtcVetterCard?> {
  /// The vetter role card [communityDid] issued the member, as their VTA
  /// keeps it, in date and not revoked, or null when they may not vet there.
  /// Read while a community's page shows, for its Membership and Vetting
  /// tabs, and again as the cards change; the vetting desk checks the card
  /// again before any ticket.
  const CommunityVetterCardProvider._({
    required CommunityVetterCardFamily super.from,
    required String super.argument,
  }) : super(
         retry: _noRetry,
         name: r'communityVetterCardProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$communityVetterCardHash();

  @override
  String toString() {
    return r'communityVetterCardProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<VtcVetterCard?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<VtcVetterCard?> create(Ref ref) {
    final argument = this.argument as String;
    return communityVetterCard(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is CommunityVetterCardProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$communityVetterCardHash() =>
    r'd05b8b5ce60038e95bf135c738396b5bdcb862e8';

/// The vetter role card [communityDid] issued the member, as their VTA
/// keeps it, in date and not revoked, or null when they may not vet there.
/// Read while a community's page shows, for its Membership and Vetting
/// tabs, and again as the cards change; the vetting desk checks the card
/// again before any ticket.

final class CommunityVetterCardFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<VtcVetterCard?>, String> {
  const CommunityVetterCardFamily._()
    : super(
        retry: _noRetry,
        name: r'communityVetterCardProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The vetter role card [communityDid] issued the member, as their VTA
  /// keeps it, in date and not revoked, or null when they may not vet there.
  /// Read while a community's page shows, for its Membership and Vetting
  /// tabs, and again as the cards change; the vetting desk checks the card
  /// again before any ticket.

  CommunityVetterCardProvider call(String communityDid) =>
      CommunityVetterCardProvider._(argument: communityDid, from: this);

  @override
  String toString() => r'communityVetterCardProvider';
}

/// The cards the groups of [communityDid] issued the member, as their VTA
/// keeps them, each with what the community says of it now. Read while a
/// community's page shows, and again as the cards change, never kept on the
/// phone.

@ProviderFor(communityGroupCards)
const communityGroupCardsProvider = CommunityGroupCardsFamily._();

/// The cards the groups of [communityDid] issued the member, as their VTA
/// keeps them, each with what the community says of it now. Read while a
/// community's page shows, and again as the cards change, never kept on the
/// phone.

final class CommunityGroupCardsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<(VtcGroupCard, VtcCardStatus)>>,
          List<(VtcGroupCard, VtcCardStatus)>,
          FutureOr<List<(VtcGroupCard, VtcCardStatus)>>
        >
    with
        $FutureModifier<List<(VtcGroupCard, VtcCardStatus)>>,
        $FutureProvider<List<(VtcGroupCard, VtcCardStatus)>> {
  /// The cards the groups of [communityDid] issued the member, as their VTA
  /// keeps them, each with what the community says of it now. Read while a
  /// community's page shows, and again as the cards change, never kept on the
  /// phone.
  const CommunityGroupCardsProvider._({
    required CommunityGroupCardsFamily super.from,
    required String super.argument,
  }) : super(
         retry: _noRetry,
         name: r'communityGroupCardsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$communityGroupCardsHash();

  @override
  String toString() {
    return r'communityGroupCardsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<(VtcGroupCard, VtcCardStatus)>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<(VtcGroupCard, VtcCardStatus)>> create(Ref ref) {
    final argument = this.argument as String;
    return communityGroupCards(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is CommunityGroupCardsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$communityGroupCardsHash() =>
    r'590344fc9540f576f78abe5f311551016a77dc08';

/// The cards the groups of [communityDid] issued the member, as their VTA
/// keeps them, each with what the community says of it now. Read while a
/// community's page shows, and again as the cards change, never kept on the
/// phone.

final class CommunityGroupCardsFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<List<(VtcGroupCard, VtcCardStatus)>>,
          String
        > {
  const CommunityGroupCardsFamily._()
    : super(
        retry: _noRetry,
        name: r'communityGroupCardsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The cards the groups of [communityDid] issued the member, as their VTA
  /// keeps them, each with what the community says of it now. Read while a
  /// community's page shows, and again as the cards change, never kept on the
  /// phone.

  CommunityGroupCardsProvider call(String communityDid) =>
      CommunityGroupCardsProvider._(argument: communityDid, from: this);

  @override
  String toString() => r'communityGroupCardsProvider';
}

/// Whether the member may vet for [communityDid]: they hold the
/// [communityVetterCard].

@ProviderFor(communityCanVet)
const communityCanVetProvider = CommunityCanVetFamily._();

/// Whether the member may vet for [communityDid]: they hold the
/// [communityVetterCard].

final class CommunityCanVetProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, FutureOr<bool>>
    with $FutureModifier<bool>, $FutureProvider<bool> {
  /// Whether the member may vet for [communityDid]: they hold the
  /// [communityVetterCard].
  const CommunityCanVetProvider._({
    required CommunityCanVetFamily super.from,
    required String super.argument,
  }) : super(
         retry: _noRetry,
         name: r'communityCanVetProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$communityCanVetHash();

  @override
  String toString() {
    return r'communityCanVetProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<bool> create(Ref ref) {
    final argument = this.argument as String;
    return communityCanVet(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is CommunityCanVetProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$communityCanVetHash() => r'67a7bd549d50a73b46f1a4412f3be96b13b93e8e';

/// Whether the member may vet for [communityDid]: they hold the
/// [communityVetterCard].

final class CommunityCanVetFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<bool>, String> {
  const CommunityCanVetFamily._()
    : super(
        retry: _noRetry,
        name: r'communityCanVetProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Whether the member may vet for [communityDid]: they hold the
  /// [communityVetterCard].

  CommunityCanVetProvider call(String communityDid) =>
      CommunityCanVetProvider._(argument: communityDid, from: this);

  @override
  String toString() => r'communityCanVetProvider';
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
