import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../services/share_plus_service/share_plus_service.dart';

final shareServiceProvider = Provider<ShareService>((ref) {
  return SharePlusService();
});
