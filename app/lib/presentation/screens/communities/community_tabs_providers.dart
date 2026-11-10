import 'package:meeting_place_vtc/meeting_place_vtc.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../application/services/community_offer_service/community_offer_service.dart';
import '../../../application/services/vtc_service/vtc_service.dart';
import '../../../domain/models/vtc/vtc_membership_card.dart';

part 'community_tabs_providers.g.dart';

/// No retry behind the member's back: each one asks the VTA or the
/// community, and the tabs ask again each time the community opens.
Duration? _noRetry(int retryCount, Object error) => null;

/// The member's role in [communityDid], as their VTA keeps it, or null when
/// it holds no role card. Read while a community's page shows, never kept on
/// the phone.
@Riverpod(retry: _noRetry)
Future<String?> communityRole(Ref ref, String communityDid) =>
    ref.read(vtcServiceProvider).communityRole(communityDid);

/// The membership card [communityDid] issued the member, as their VTA keeps
/// it, or null while it is on its way. Read while a community's page shows,
/// never kept on the phone.
@Riverpod(retry: _noRetry)
Future<VtcMembershipCard?> communityMembershipCard(
  Ref ref,
  String communityDid,
) => ref.read(vtcServiceProvider).membershipCard(communityDid);

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
