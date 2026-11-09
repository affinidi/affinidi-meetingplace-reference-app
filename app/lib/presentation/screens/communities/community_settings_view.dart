import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:meeting_place_vtc/meeting_place_vtc.dart';

import '../../../application/services/vtc_service/vtc_service.dart';
import '../vtc_join/vtc_community_settings.dart';

/// The member's settings for a community: how other members find them at
/// once, and the community's join phrase too once their role says they
/// administer it.
class CommunitySettingsView extends HookConsumerWidget {
  const CommunitySettingsView({
    super.key,
    required this.communityDid,
    required this.communityName,
  });

  final String communityDid;
  final String communityName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final role = useFuture(
      useMemoized(() => _role(ref.read(vtcServiceProvider)), [communityDid]),
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: VtcCommunitySettings(
        communityDid: communityDid,
        communityName: communityName,
        role: role.data,
      ),
    );
  }

  /// The member's role, or null when their VTA holds no role card or
  /// cannot be asked: the settings every member has still show.
  Future<String?> _role(VtcService service) async {
    try {
      return await service.communityRole(communityDid);
    } on MeetingPlaceVtcSDKException {
      return null;
    } on VtaNotLinkedException {
      return null;
    }
  }
}
