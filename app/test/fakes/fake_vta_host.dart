import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:mpx_flutter_reference_app/domain/models/vtc/vta_enrolment_offer.dart';
import 'package:ssi/ssi.dart';

/// A VTA host's enrolment exchange, Keyring's v1, as the lab enrol page
/// serves it: checks a submitted DID's proof as the page does and answers
/// the code it derives.
class FakeVtaHost implements HttpClientAdapter {
  FakeVtaHost({required this.vtaDid});

  static const nonce = 'AAAAAAAAAAAAAAAAAAAAAA';
  static const url = 'https://host.example/api/offers/$nonce';

  /// DID of the VTA the offer names.
  final String vtaDid;

  /// When true, every request fails as if the host were down.
  bool isDown = false;

  /// Where the offer stands.
  String state = 'open';

  /// The DID the host received.
  String? did;

  /// When set, the code the host answers instead of the one it derives.
  String? answerCode;

  /// When set, the status `submit` answers with instead of checking.
  int? submitStatus;

  /// Number of status reads.
  int statusReads = 0;

  /// The enrolment link the host shows, expiring at [expiresAt].
  String link({
    required DateTime expiresAt,
    int version = 1,
    String offerUrl = url,
  }) => encodeLink({
    'v': version,
    't': 'vta-enrol',
    'vta': vtaDid,
    'label': 'Lab host',
    'url': offerUrl,
    'n': nonce,
    'exp': expiresAt.millisecondsSinceEpoch ~/ 1000,
  });

  /// [offer] as an enrolment link, base64url without padding.
  static String encodeLink(Map<String, dynamic> offer) =>
      VtaEnrolmentOffer.linkPrefix +
      base64Url.encode(utf8.encode(jsonEncode(offer))).replaceAll('=', '');

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    if (isDown) {
      throw DioException.connectionError(
        requestOptions: options,
        reason: 'down',
      );
    }
    final path = options.uri.toString();
    if (path == '$url/status' && options.method == 'GET') {
      statusReads++;
      return _answer(200, {'state': state});
    }
    if (path == '$url/submit' && options.method == 'POST') {
      final bytes = <int>[];
      await for (final chunk in requestStream!) {
        bytes.addAll(chunk);
      }
      final body = jsonDecode(utf8.decode(bytes)) as Map<String, dynamic>;
      return _submit(body);
    }
    return _answer(404, {'error': 'unknown offer'});
  }

  Future<ResponseBody> _submit(Map<String, dynamic> body) async {
    if (submitStatus case final status?) return _answer(status, {});
    if (state != 'open') return _answer(409, {'error': 'not open'});

    final submitted = body['did'] as String;
    final segments = (body['proof'] as String).split('.');
    final header = _decode(segments[0]);
    final payload = _decode(segments[1]);
    final kid = header['kid'] as String;
    if (header['alg'] != 'EdDSA' ||
        header['typ'] != 'JWT' ||
        kid.split('#').first != payload['iss'] ||
        payload['iss'] != submitted ||
        payload['aud'] != url ||
        payload['nonce'] != nonce ||
        payload['exp'] is! int) {
      return _answer(400, {'error': 'bad proof'});
    }
    final verifier = await DidVerifier.create(
      algorithm: SignatureScheme.ed25519,
      issuerDid: submitted,
      kid: kid,
    );
    final isValid = verifier.verify(
      Uint8List.fromList(ascii.encode('${segments[0]}.${segments[1]}')),
      _bytes(segments[2]),
    );
    if (!isValid) return _answer(401, {'error': 'bad signature'});

    did = submitted;
    state = 'submitted';
    return _answer(202, {
      'state': 'submitted',
      'code': answerCode ?? vtaEnrolmentCode(nonce, submitted),
    });
  }

  static Map<String, dynamic> _decode(String segment) =>
      jsonDecode(utf8.decode(_bytes(segment))) as Map<String, dynamic>;

  static Uint8List _bytes(String segment) => base64Url.decode(
    segment.padRight(segment.length + (4 - segment.length % 4) % 4, '='),
  );

  static ResponseBody _answer(int status, Map<String, dynamic> body) =>
      ResponseBody.fromString(
        jsonEncode(body),
        status,
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType],
        },
      );

  @override
  void close({bool force = false}) {}
}
