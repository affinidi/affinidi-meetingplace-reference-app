import 'package:meeting_place_relationship/meeting_place_relationship.dart';
import 'package:mpx_flutter_reference_app/application/services/r_cards_service/r_cards_service.dart';

class FakeRCardsService extends RCardsService {
  FakeRCardsService(this._cards);

  final List<RCard> _cards;

  @override
  List<RCard> build() => _cards;
}
