import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meeting_place_relationship/meeting_place_relationship.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'meeting_place_sdk_provider.dart';
import 'r_cards_repository_provider.dart';

part 'relationship_sdk_provider.g.dart';

/// Provides the `MeetingPlaceRelationshipSDK` instance backed by the
/// `MeetingPlaceCoreSDK` from `meetingPlaceSdkProvider`.
///
/// Injects the [RCardRepository] from [rCardsRepositoryProvider]
/// so that every incoming R-Card is automatically persisted in the local
/// encrypted database.
///
/// Keep-alive ensures the relationship SDK is initialized once and shared
/// across the app lifetime.
@Riverpod(keepAlive: true)
Future<MeetingPlaceRelationshipSDK> relationshipSdk(Ref ref) async {
  final coreSDK = await ref.read(meetingPlaceSdkProvider.future);
  final repository = await ref.read(rCardsRepositoryProvider.future);

  return MeetingPlaceRelationshipSDK(
    coreSDK: coreSDK,
    rCardRepository: repository,
  );
}
