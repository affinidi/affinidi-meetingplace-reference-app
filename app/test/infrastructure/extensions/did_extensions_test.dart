import 'package:flutter_test/flutter_test.dart';
import 'package:mpx_flutter_reference_app/infrastructure/extensions/did_extensions.dart';

void main() {
  group('topAndLastPart', () {
    test('keeps the start and the part after the last colon', () {
      const did =
          'did:webvh:QmPEQVM1JPTyrvEgBcDXwjK4TeyLGSX1PxjgyeAisdWM1p:'
          'webvh.example.com:people:ada-lovelace';

      expect(did.topAndLastPart(), 'did:webvh:QmPEQVM1JPTyrv...:ada-lovelace');
    });

    test('keeps a long last part whole from its colon', () {
      const did =
          'did:webvh:QmPEQVM1JPTyrvEgBcDXwjK4TeyLGSX1PxjgyeAisdWM1p:'
          'vta.example.com:mpx-01JC5ZQ8D3WX4N7Q2K9T6V1B0M';

      expect(
        did.topAndLastPart(),
        'did:webvh:QmPEQVM1JPTyrv...:mpx-01JC5ZQ8D3WX4N7Q2K9T6V1B0M',
      );
    });

    test('keeps the last characters when the last colon starts it', () {
      const did = 'did:key:z6MkhaXgBZDvotDkL5257faiztiGiC2QtKLGpbnnEGta2doK';

      expect(did.topAndLastPart(), 'did:key:z6MkhaXgBZDvotDk...EGta2doK');
    });

    test('leaves a short DID whole', () {
      const did = 'did:webvh:QmP:vta.example:ada';

      expect(did.topAndLastPart(), did);
    });
  });
}
