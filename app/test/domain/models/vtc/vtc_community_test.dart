import 'package:flutter_test/flutter_test.dart';
import 'package:meeting_place_vtc/meeting_place_vtc.dart';
import 'package:mpx_flutter_reference_app/domain/models/vtc/vtc_community.dart';

void main() {
  const community = VtcCommunity(
    communityDid: 'did:webvh:community',
    personaDid: 'did:webvh:persona',
    contextId: 'context-1',
    isMember: false,
  );
  final submit = TrustTaskDocument.create(
    type: JoinTask.submit,
    issuer: 'did:webvh:persona',
    recipient: 'did:webvh:community',
    payload: const {
      'attributes': [
        {'type': 'name', 'value': 'Alice'},
      ],
    },
  );
  final exchange = TrustTaskExchange(
    request: submit,
    answer: TrustTaskDocument.create(
      type: '${JoinTask.submit}#response',
      issuer: 'did:webvh:community',
      recipient: 'did:webvh:persona',
      threadId: submit.id,
      payload: const {'requestId': 'request-1'},
    ),
  );
  final applying = community.withApplication(
    isMember: false,
    requestId: 'request-1',
    exchange: exchange,
  );

  group('VtcCommunity submit exchange', () {
    test('is stored and restored as it was on the wire', () {
      final restored = VtcCommunity.fromJson(applying.toJson());

      expect(restored.submitExchange?.toJson(), exchange.toJson());
      expect(restored.submitReceipt?.type, JoinTask.submit);
      expect(restored.submitReceipt?.answeredBy, 'did:webvh:community');
    });

    test('is absent from records stored without one', () {
      final json = applying.toJson()..remove('submitExchange');

      expect(VtcCommunity.fromJson(json).submitExchange, isNull);
    });

    test('is dropped when unreadable, the record kept', () {
      final json = applying.toJson()
        ..['submitExchange'] = {'request': 'garbled'};

      final restored = VtcCommunity.fromJson(json);

      expect(restored.submitExchange, isNull);
      expect(restored.joinRequestId, 'request-1');
    });

    test('is kept while the same request stays open', () {
      final again = applying.withApplication(
        isMember: false,
        requestId: 'request-1',
      );

      expect(again.submitExchange, same(exchange));
      expect(applying.settled(false).submitExchange, same(exchange));
    });

    test('is dropped once the request is decided', () {
      expect(applying.withApplication(isMember: true).submitExchange, isNull);
      expect(applying.rejected('Members only').submitExchange, isNull);
    });
  });
}
