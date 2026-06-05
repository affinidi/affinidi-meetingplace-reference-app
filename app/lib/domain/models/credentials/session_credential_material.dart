import 'package:vc_zkp/vc_zkp.dart';

class SessionCredentialMaterial {
  const SessionCredentialMaterial({
    required this.document,
    required this.holderPrivateKeyHex,
    required this.issuerAx,
    required this.issuerAy,
  });

  final SignedVcDocument document;
  final String holderPrivateKeyHex;
  final String issuerAx;
  final String issuerAy;
}
