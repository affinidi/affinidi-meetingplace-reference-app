import 'package:meeting_place_vtc/meeting_place_vtc.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../application/services/vtc_service/vtc_service.dart';
import '../../../domain/models/vtc/vtc_membership_entry.dart';
import '../../../infrastructure/providers/app_logger_provider.dart';
import 'membership_credentials_state.dart';

part 'membership_credentials_controller.g.dart';

const _logKey = 'MembershipCredentialsController';

/// The member's membership cards, and whether each one's community still
/// holds it. Only a failure's code is logged; never a DID or a card.
@riverpod
class MembershipCredentialsController
    extends _$MembershipCredentialsController {
  late final VtcService _service = ref.read(vtcServiceProvider);

  @override
  MembershipCredentialsState build() {
    // The Credentials tab stays alive in the background: read again
    // whenever a card is kept or a membership left.
    final changes = _service.membershipsChanged.listen((_) => refresh());
    ref.onDispose(changes.cancel);
    Future.microtask(refresh);
    return MembershipCredentialsState();
  }

  /// Reads the cards from the VTA again, then checks each with its
  /// community.
  Future<void> refresh() async {
    state = state.copyWith(isLoading: true, failure: null);
    final List<VtcMembershipEntry> entries;
    try {
      entries = await _service.membershipCredentials();
    } on VtaNotLinkedException {
      if (!ref.mounted) return;
      state = state.copyWith(
        isLoading: false,
        failure: MembershipCredentialsFailure.vtaMissing,
      );
      return;
    } on MeetingPlaceVtcSDKException catch (error) {
      _log(error.code);
      if (!ref.mounted) return;
      state = state.copyWith(
        isLoading: false,
        failure: MembershipCredentialsFailure.unreachable,
      );
      return;
    }
    if (!ref.mounted) return;
    state = state.copyWith(
      isLoading: false,
      entries: entries,
      readAt: DateTime.now(),
      statuses: const {},
    );
    await Future.wait([for (final entry in entries) check(entry.key)]);
  }

  /// Asks the community of the card [key] whether it still holds it.
  Future<void> check(String key) async {
    final entry = state.entries.where((entry) => entry.key == key).firstOrNull;
    if (entry == null || state.checking.contains(key)) return;
    state = state.copyWith(checking: {...state.checking, key});
    final status = await _service.checkMembershipStatus(entry);
    if (status.failure case final code?) _log(code);
    if (!ref.mounted) return;
    state = state.copyWith(
      checking: {...state.checking}..remove(key),
      statuses: {...state.statuses, key: status},
    );
  }

  void _log(MeetingPlaceVtcSDKErrorCode code) => ref
      .read(appLoggerProvider)
      .warning('failed: ${code.name}', name: _logKey);
}

/// The website the community [communityDid] lists in its profile, or null
/// when it lists none or cannot be reached. The profile is unsigned: a link
/// to follow, never proof of anything.
@riverpod
Future<Uri?> communityWebsite(Ref ref, String communityDid) async {
  try {
    final profile = await ref
        .read(vtcServiceProvider)
        .readProfile(communityDid);
    return profile.website;
  } on MeetingPlaceVtcSDKException {
    return null;
  }
}
