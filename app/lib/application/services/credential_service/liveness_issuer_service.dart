import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ssi/ssi.dart';

import '../../../infrastructure/providers/meeting_place_sdk_provider.dart';
import '../../../infrastructure/secure_storage/secure_storage.dart';

final livenessIssuerServiceProvider = Provider<LivenessIssuerService>(
  LivenessIssuerService.new,
  name: 'livenessIssuerServiceProvider',
);

class LivenessIssuerService {
  LivenessIssuerService(this._ref);

  final Ref _ref;

  Future<DidManager> getIssuerDidManager() async {
    final storage = await _ref.read(secureStorageProvider.future);
    final sdk = await _ref.read(meetingPlaceSdkProvider.future);

    final storedDid = await storage.readLivenessIssuerDid();
    if (storedDid != null && storedDid.isNotEmpty) {
      return sdk.getDidManager(storedDid);
    }

    final manager = await sdk.generateDid();
    final document = await manager.getDidDocument();
    await storage.writeLivenessIssuerDid(document.id);
    return manager;
  }
}
