import 'package:mpx_flutter_reference_app/infrastructure/providers/app_badge_provider.dart';

class FakeAppBadgeService implements AppBadgeService {
  FakeAppBadgeService({int initialBadgeCount = 0})
      : _lastBadgeCount = initialBadgeCount;

  int _lastBadgeCount;
  int get lastBadgeCount => _lastBadgeCount;

  @override
  Future<void> clearBadge() async {
    _lastBadgeCount = 0;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) {
    throw UnimplementedError();
  }
}
