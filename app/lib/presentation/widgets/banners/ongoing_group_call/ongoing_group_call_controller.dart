import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meeting_place_matrix/meeting_place_matrix.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../application/services/chat_service/chat_session_service.dart';
import '../../../../application/services/contacts_service/contacts_service.dart';
import '../../../../domain/models/contact_card/contact_card.dart';
import '../../../../infrastructure/extensions/contact_card_extensions.dart';
import '../../../../infrastructure/providers/cache_manager_provider.dart';
import '../../../../infrastructure/providers/meeting_place_sdk_provider.dart';
import '../../../screens/chat/chat_screen_controller.dart';
import '../active_call/active_call_controller.dart';
import 'ongoing_group_call_banner_state.dart';

part 'ongoing_group_call_controller.g.dart';

/// Emits the ongoing group call banner data for [contactId], or `null`
/// when the banner must not be shown.
///
/// The banner is shown only when the local user is NOT in a call: while any
/// call is active (from the first outgoing attempt through to connected) the
/// persistent green active-call banner is used instead. It is scoped to the
/// open chat, so an ongoing call in another group is only surfaced once its
/// chat is opened.
@riverpod
Stream<OngoingGroupCallBannerData?> ongoingGroupCallBanner(
  Ref ref,
  String contactId,
) async* {
  final isInCall = ref.watch(
    activeCallControllerProvider.select((state) => state != null),
  );
  if (isInCall) {
    yield null;
    return;
  }

  final provider = chatScreenControllerProvider(contactId);
  final group = ref.watch(provider.select((state) => state.group));
  final isCallSupported = ref.watch(
    provider.select((state) => state.isCallSupported),
  );
  if (group == null || !isCallSupported) {
    yield null;
    return;
  }

  final contact = ref.read(contactsServiceProvider).getContactById(contactId);
  final channelDid = contact?.channelDid;
  if (channelDid == null) {
    yield null;
    return;
  }

  final cacheManager = ref.read(cacheManagerProvider);
  final memberCards = <String, ContactCard>{
    for (final member in group.members)
      member.did: ContactCardUtils.fromSdkContactCard(member.contactCard),
  };

  final sdk = await ref.watch(meetingPlaceSdkProvider.future);
  final chatSession = ref.watch(
    chatSessionServiceProvider(channelDid).notifier,
  );

  final mediaTypeLookups = <String, Future<CallMediaType?>>{};
  Future<CallMediaType?> resolveMediaType(String callId) {
    return mediaTypeLookups.putIfAbsent(callId, () async {
      final mediaType = await chatSession.resolveCallMediaType(callId);
      if (mediaType == null) await mediaTypeLookups.remove(callId);
      return mediaType;
    });
  }

  yield* sdk.watchOngoingGroupCall(groupChannelDid: channelDid).asyncExpand((
    ongoing,
  ) async* {
    final mediaType = ongoing == null
        ? null
        : await resolveMediaType(ongoing.callId);
    yield _toBannerData(
      ongoing: ongoing,
      memberCards: memberCards,
      cacheManager: cacheManager,
      mediaType: mediaType,
    );
  }).distinct();
}

/// Maps an [OngoingGroupCall] snapshot to banner data, de-duplicating people by
/// Matrix user ID and excluding the local user's own memberships.
OngoingGroupCallBannerData? _toBannerData({
  required OngoingGroupCall? ongoing,
  required Map<String, ContactCard> memberCards,
  required BaseCacheManager cacheManager,
  CallMediaType? mediaType,
}) {
  if (ongoing == null) return null;

  final seen = <String>{};
  final avatars = <OngoingGroupCallAvatar>[];
  for (final participant in ongoing.participants) {
    if (participant.isSelf) continue;
    if (!seen.add(participant.matrixUserId)) continue;

    final did = participant.did;
    final card = did != null ? memberCards[did] : null;
    avatars.add(
      OngoingGroupCallAvatar(
        id: did ?? participant.matrixUserId,
        firstName: card?.firstName,
        image: card?.image(cacheManager: cacheManager),
      ),
    );
  }

  if (avatars.isEmpty) return null;
  return OngoingGroupCallBannerData(
    participantCount: avatars.length,
    avatars: avatars,
    isAudioOnly: mediaType != CallMediaType.video,
  );
}
