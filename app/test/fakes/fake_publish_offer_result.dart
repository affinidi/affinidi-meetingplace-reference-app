import 'package:meeting_place_core/meeting_place_core.dart';

class FakePublishOfferResult implements PublishOfferResult<ConnectionOffer> {
  FakePublishOfferResult();

  @override
  ConnectionOffer get connectionOffer => throw UnimplementedError();

  @override
  DidManager get groupOwnerDidManager => throw UnimplementedError();

  @override
  DidManager get publishedOfferDidManager => throw UnimplementedError();
}
