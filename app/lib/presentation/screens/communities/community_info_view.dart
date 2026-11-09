import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:meeting_place_vtc/meeting_place_vtc.dart';

import '../../../application/services/community_offer_service/community_offer_service.dart';
import '../../../application/services/vtc_service/vtc_service.dart';
import '../../../infrastructure/extensions/build_context_extensions.dart';
import '../../widgets/onboarding_style/onboarding_style.dart';
import '../vtc_join/vtc_community_profile.dart';

/// What a community publishes about itself — what it is about, its
/// website and contact — with its DID, and the join phrase this phone
/// published for it, if any. The DID shows also when the profile cannot be
/// read.
class CommunityInfoView extends HookConsumerWidget {
  const CommunityInfoView({super.key, required this.communityDid});

  final String communityDid;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final load = useMemoized(
      () async => (
        await _profile(ref.read(vtcServiceProvider)),
        await _joinPhrase(ref.read(communityOfferServiceProvider)),
      ),
      [communityDid],
    );
    final loaded = useFuture(load);
    final data = loaded.data;
    if (data == null) return const Center(child: OnboardingSpinner());
    final (profile, joinPhrase) = data;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 12,
        children: [
          VtcCommunityProfile(
            communityDid: communityDid,
            description: profile?.description,
            website: profile?.website,
            contactEmail: profile?.contactEmail,
            joinPhrase: joinPhrase,
          ),
          if (profile == null)
            OnboardingMessage(
              context.l10n.communityInfoUnavailable,
              isError: false,
            ),
        ],
      ),
    );
  }

  /// The community's profile, or null when it cannot be read: unsigned,
  /// it only describes the community.
  Future<CommunityProfile?> _profile(VtcService service) async {
    try {
      return await service.readProfile(communityDid);
    } on MeetingPlaceVtcSDKException {
      return null;
    }
  }

  /// The join phrase this phone published, or null when none is or
  /// Meeting Place cannot be reached.
  Future<String?> _joinPhrase(CommunityOfferService service) async {
    try {
      return (await service.published(communityDid))?.mnemonic;
    } on Exception {
      return null;
    }
  }
}
