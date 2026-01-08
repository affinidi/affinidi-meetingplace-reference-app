import 'package:mpx_flutter_reference_app/infrastructure/services/share_plus_service/share_plus_service.dart';
import 'package:share_plus/share_plus.dart';

class FakeShareService implements ShareService {
  final List<ShareParams> sharedParams = [];

  @override
  Future<ShareResult> share(ShareParams params) async {
    sharedParams.add(params);
    return const ShareResult('', ShareResultStatus.success);
  }
}
