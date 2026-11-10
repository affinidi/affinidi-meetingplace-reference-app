import 'package:meeting_place_vtc/meeting_place_vtc.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../application/services/community_offer_service/community_offer_service.dart';
import '../../../application/services/vtc_service/vtc_service.dart';
import '../../../domain/models/vtc/vtc_group_card.dart';
import '../../../domain/models/vtc/vtc_membership_card.dart';
import '../../../domain/models/vtc/vtc_membership_entry.dart';
import '../../../domain/models/vtc/vtc_vetter_card.dart';

part 'community_tabs_providers.g.dart';

/// No retry behind the member's back: each one asks the VTA or the
/// community, and the tabs ask again each time the community opens.
Duration? _noRetry(int retryCount, Object error) => null;

/// Reads [ref]'s provider again each time the member's membership cards
/// change, e.g. once a community's new role card is kept.
void _readAgainOnCardChanges(Ref ref) {
  final changes = ref
      .read(vtcServiceProvider)
      .membershipsChanged
      .listen((_) => ref.invalidateSelf());
  ref.onDispose(changes.cancel);
}

/// The member's role in [communityDid], as their VTA keeps it, or null when
/// it holds no role card. Read while a community's page shows, and again as
/// the cards change, never kept on the phone.
@Riverpod(retry: _noRetry)
Future<String?> communityRole(Ref ref, String communityDid) {
  _readAgainOnCardChanges(ref);
  return ref.read(vtcServiceProvider).communityRole(communityDid);
}

/// The membership card [communityDid] issued the member, as their VTA keeps
/// it, or null while it is on its way. Read while a community's page shows,
/// and again as the cards change, never kept on the phone.
@Riverpod(retry: _noRetry)
Future<VtcMembershipCard?> communityMembershipCard(
  Ref ref,
  String communityDid,
) {
  _readAgainOnCardChanges(ref);
  return ref.read(vtcServiceProvider).membershipCard(communityDid);
}

/// The vetter role card [communityDid] issued the member, as their VTA
/// keeps it, in date and not revoked, or null when they may not vet there.
/// Read while a community's page shows, for its Membership and Vetting
/// tabs, and again as the cards change; the vetting desk checks the card
/// again before any ticket.
@Riverpod(retry: _noRetry)
Future<VtcVetterCard?> communityVetterCard(Ref ref, String communityDid) {
  _readAgainOnCardChanges(ref);
  return ref.read(vtcServiceProvider).vetterCard(communityDid);
}

/// The cards the groups of [communityDid] issued the member, as their VTA
/// keeps them, each with what the community says of it now. Read while a
/// community's page shows, and again as the cards change, never kept on the
/// phone.
@Riverpod(retry: _noRetry)
Future<List<(VtcGroupCard, VtcCardStatus)>> communityGroupCards(
  Ref ref,
  String communityDid,
) async {
  _readAgainOnCardChanges(ref);
  final service = ref.read(vtcServiceProvider);
  final cards = await service.groupCards(communityDid);
  final statuses = await Future.wait([
    for (final card in cards) service.checkGroupCardStatus(card),
  ]);
  return [for (final (index, card) in cards.indexed) (card, statuses[index])];
}

/// Whether the member may vet for [communityDid]: they hold the
/// [communityVetterCard].
@Riverpod(retry: _noRetry)
Future<bool> communityCanVet(Ref ref, String communityDid) async =>
    await ref.watch(communityVetterCardProvider(communityDid).future) != null;

/// What a community publishes about itself, or null when it cannot be read,
/// and the join phrase this phone published for it, or null when none is or
/// Meeting Place cannot be reached.
typedef CommunityInfo = (CommunityProfile? profile, String? joinPhrase);

/// What [communityDid] publishes about itself, read while its page shows.
@Riverpod(retry: _noRetry)
Future<CommunityInfo> communityInfo(Ref ref, String communityDid) async {
  // Read together: neither waits for the other.
  final joinPhrase = _joinPhrase(ref, communityDid);
  return (await _profile(ref, communityDid), await joinPhrase);
}

/// Unsigned, the profile only describes the community.
Future<CommunityProfile?> _profile(Ref ref, String communityDid) async {
  try {
    return await ref.read(vtcServiceProvider).readProfile(communityDid);
  } on MeetingPlaceVtcSDKException {
    return null;
  }
}

Future<String?> _joinPhrase(Ref ref, String communityDid) async {
  try {
    return (await ref
            .read(communityOfferServiceProvider)
            .published(communityDid))
        ?.mnemonic;
  } on Exception {
    return null;
  }
}
