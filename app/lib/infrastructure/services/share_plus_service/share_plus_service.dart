import 'package:share_plus/share_plus.dart';

abstract class ShareService {
  Future<ShareResult> share(ShareParams params);
}

class SharePlusService implements ShareService {
  @override
  Future<ShareResult> share(ShareParams params) {
    return SharePlus.instance.share(params);
  }
}
