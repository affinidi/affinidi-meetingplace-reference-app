import 'package:meeting_place_vtc/meeting_place_vtc.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../application/services/vtc_service/vtc_service.dart';

part 'community_logo_provider.g.dart';

/// The logo [communityDid] publishes in its profile, or null when it gives
/// none or cannot be reached. Read once while the app runs, so the
/// Communities tab does not ask every community each time it shows.
@Riverpod(keepAlive: true)
Future<Uri?> communityLogo(Ref ref, String communityDid) async {
  try {
    return (await ref.read(vtcServiceProvider).readProfile(communityDid))
        .logoUrl;
  } on MeetingPlaceVtcSDKException {
    return null;
  }
}
