import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meeting_place_relationship/meeting_place_relationship.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'meeting_place_sdk_provider.dart';

part 'relationship_sdk_provider.g.dart';

/// Provides the `MeetingPlaceRelationshipSDK` instance backed by the
/// `MeetingPlaceCoreSDK` from `meetingPlaceSdkProvider`.
///
/// Keep-alive ensures the relationship SDK is initialized once and shared
/// across the app lifetime.
@Riverpod(keepAlive: true)
Future<MeetingPlaceRelationshipSDK> relationshipSdk(Ref ref) async {
  final coreSDK = await ref.read(meetingPlaceSdkProvider.future);
  return MeetingPlaceRelationshipSDK(coreSDK: coreSDK);
}
