import 'package:flutter_test/flutter_test.dart';
import 'package:mpx_flutter_reference_app/domain/models/vtc/vtc_card_delivery.dart';

void main() {
  group('VtcCardDelivery', () {
    test('starts with every step still to come', () {
      const delivery = VtcCardDelivery(personaDid: 'did:peer:2.persona');

      expect(
        VtcDeliveryStep.values.map(delivery.status),
        everyElement(VtcDeliveryStatus.next),
      );
      expect(delivery.isDone, isFalse);
    });

    test('moves a step on, keeping the facts already known', () {
      final delivery = const VtcCardDelivery(personaDid: 'did:peer:2.persona')
          .at(
            VtcDeliveryStep.keysLent,
            VtcDeliveryStatus.done,
            signingKeyId: 'did:peer:2.persona#key-1',
          )
          .at(
            VtcDeliveryStep.signedIn,
            VtcDeliveryStatus.failed,
            mediatorDid: 'did:key:mediator',
          );

      expect(delivery.status(VtcDeliveryStep.keysLent), VtcDeliveryStatus.done);
      expect(
        delivery.status(VtcDeliveryStep.signedIn),
        VtcDeliveryStatus.failed,
      );
      expect(delivery.signingKeyId, 'did:peer:2.persona#key-1');
      expect(delivery.mediatorDid, 'did:key:mediator');
    });

    test('is done once every step is', () {
      var delivery = const VtcCardDelivery(personaDid: 'did:peer:2.persona');
      for (final step in VtcDeliveryStep.values) {
        delivery = delivery.at(step, VtcDeliveryStatus.done);
      }

      expect(delivery.isDone, isTrue);
    });
  });
}
