import 'package:cross_file/cross_file.dart';
import 'package:meeting_place_relationship/meeting_place_relationship.dart';
import 'package:mpx_flutter_reference_app/application/services/r_cards_service/r_cards_service.dart';

class FakeRCardsService extends RCardsService {
  FakeRCardsService(this._cards);

  final List<RCard> _cards;

  bool exportAllCalled = false;
  bool exportSingleCalled = false;
  RCard? lastExportedCard;

  @override
  List<RCard> build() => _cards;

  @override
  Future<XFile> exportAllAsVcf() async {
    exportAllCalled = true;
    return XFile(
      '/tmp/test-r-cards.vcf',
      mimeType: 'text/vcard',
      name: 'R-Cards.vcf',
    );
  }

  @override
  Future<XFile?> exportSingleAsVcf(RCard card) async {
    exportSingleCalled = true;
    lastExportedCard = card;
    return XFile(
      '/tmp/test-r-card.vcf',
      mimeType: 'text/vcard',
      name: 'R-Card.vcf',
    );
  }
}
