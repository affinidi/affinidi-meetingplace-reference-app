import 'package:meeting_place_core/meeting_place_core.dart';

class FakePublishOfferResult implements PublishOfferResult<ConnectionOffer> {
  FakePublishOfferResult();

  @override
  dynamic noSuchMethod(Invocation invocation) {
    throw UnimplementedError();
  }
}
