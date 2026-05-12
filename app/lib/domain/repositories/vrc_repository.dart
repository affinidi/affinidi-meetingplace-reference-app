import '../models/vrc/vrc_credential.dart';

abstract interface class VrcRepository {
  Future<void> saveVrc(VrcCredential credential);
  Future<List<VrcCredential>> listVrcs();
  Future<void> deleteVrc(String id);
  Future<List<VrcCredential>> listVrcsByDid(String did);
  Future<int> countVrcsByDid(String did);
}
