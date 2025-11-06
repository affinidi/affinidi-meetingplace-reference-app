import 'package:mpx_flutter_reference_app/infrastructure/providers/app_badge_provider.dart';

class FakeAppBadgeService extends AppBadgeService {
  FakeAppBadgeService({this.badgeCount = 0});

  int badgeCount;

  @override
  Future<void> setBadge(int count) async {
    badgeCount = count;
  }

  @override
  Future<void> clearBadge() async {
    badgeCount = 0;
  }
}
