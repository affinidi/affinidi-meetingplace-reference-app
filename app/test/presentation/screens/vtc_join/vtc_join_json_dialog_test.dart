import 'package:flutter_test/flutter_test.dart';
import 'package:mpx_flutter_reference_app/presentation/screens/vtc_join/vtc_join_json_dialog.dart';

void main() {
  group('pnmCredentialCommand', () {
    test('fetches the credential the VTA keeps under its id', () {
      expect(
        pnmCredentialCommand('urn:uuid:card'),
        'pnm cred-vault get urn:uuid:card',
      );
    });

    test('names no command without an id', () {
      expect(pnmCredentialCommand(null), isNull);
      // An id that is no string is not one the VTA keeps it under.
      expect(pnmCredentialCommand(42), isNull);
    });
  });
}
