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
  final receipt = TrustTaskReceipt(
    type: JoinTask.submit,
    documentId: 'urn:uuid:submit',
    signer: 'did:webvh:persona',
    answeredBy: 'did:webvh:community',
    cryptosuite: 'eddsa-jcs-2022',
    verificationMethod: 'did:webvh:persona#key-0',
    signedAt: DateTime.utc(2026, 11, 4, 10, 12),
    answeredAt: DateTime.utc(2026, 11, 4, 10, 13),
  );
  final applying = community.withApplication(
    isMember: false,
    requestId: 'request-1',
    receipt: receipt,
  );

  group('VtcCommunity submit receipt', () {
    test('is stored and restored', () {
      final restored = VtcCommunity.fromJson(applying.toJson());

      expect(restored.submitReceipt?.toJson(), receipt.toJson());
    });

    test('is absent from records stored before receipts were kept', () {
      final json = applying.toJson()..remove('submitReceipt');

      expect(VtcCommunity.fromJson(json).submitReceipt, isNull);
    });

    test('is kept while the same request stays open', () {
      final again = applying.withApplication(
        isMember: false,
        requestId: 'request-1',
      );

      expect(again.submitReceipt, same(receipt));
      expect(applying.settled(false).submitReceipt, same(receipt));
    });

    test('is dropped once the request is decided', () {
      expect(applying.withApplication(isMember: true).submitReceipt, isNull);
      expect(applying.rejected('Members only').submitReceipt, isNull);
    });
  });
}
