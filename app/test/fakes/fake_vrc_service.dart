import 'package:mpx_flutter_reference_app/application/services/vrc_service/vrc_service.dart';
import 'package:mpx_flutter_reference_app/domain/models/vrc/vrc_credential.dart';

class FakeVrcService extends VrcService {
  FakeVrcService({
    List<VrcCredential> credentials = const [],
    this.hasVrc = false,
    int? vrcCount,
  }) : _credentials = credentials,
       _vrcCount = vrcCount;

  final List<VrcCredential> _credentials;
  final int? _vrcCount;
  bool hasVrc;

  @override
  List<VrcCredential> build() => _credentials;

  @override
  Future<bool> hasVrcInChannel(String? channelId) async => hasVrc;

  @override
  Future<int> countVrcsByDid(String did) async =>
      _vrcCount ?? _credentials.length;
}
