import 'package:meeting_place_credentials/meeting_place_credentials.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'meeting_place_sdk_provider.dart';
import 'r_cards_repository_provider.dart';
import 'vrc_repository_provider.dart';

part 'credentials_sdk_provider.g.dart';

/// Provides the `MeetingPlaceCredentialsSDK` instance backed by the
/// `MeetingPlaceCoreSDK` from `meetingPlaceSdkProvider`.
///
/// Injects the [RCardRepository] from [rCardsRepositoryProvider]
/// so that every incoming R-Card is automatically persisted in the local
/// encrypted database.
///
/// Keep-alive ensures the credentials SDK is initialized once and shared
/// across the app lifetime.
@Riverpod(keepAlive: true)
Future<MeetingPlaceCredentialsSDK> credentialsSdk(Ref ref) async {
  final coreSDK = await ref.read(meetingPlaceSdkProvider.future);
  final rCardRepository = await ref.read(rCardsRepositoryProvider.future);
  final vrcRepository = await ref.read(vrcRepositoryProvider.future);

  return MeetingPlaceCredentialsSDK(
    coreSDK: coreSDK,
    rCardRepository: rCardRepository,
    vrcRepository: vrcRepository,
  );
}
