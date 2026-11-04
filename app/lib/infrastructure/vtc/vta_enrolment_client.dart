import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:meeting_place_vtc/meeting_place_vtc.dart';

import '../../domain/models/vtc/vta_enrolment_offer.dart';

/// Where an enrolment stands on the VTA host.
enum VtaEnrolmentStatus {
  /// No DID was submitted yet.
  open,

  /// A DID was submitted and waits for the VTA admin.
  submitted,

  /// The VTA admin granted the DID.
  granted,

  /// The VTA admin refused the DID.
  refused,

  /// The offer expired before the VTA admin granted the DID.
  expired,
}

/// Why the VTA host did not take or report an enrolment.
enum VtaEnrolmentProblem {
  /// The offer expired on the host.
  expired,

  /// The offer was already used, or the host does not know it.
  alreadyUsed,

  /// The host refused the DID or its proof.
  rejected,

  /// The host answered with a code other than the one the app computed: it
  /// did not receive this phone's DID.
  codeMismatch,

  /// The host could not be reached, or its answer could not be read.
  unreachable,
}

/// Thrown when the VTA host does not take or report an enrolment.
class VtaEnrolmentException implements Exception {
  /// Creates a [VtaEnrolmentException].
  const VtaEnrolmentException(this.problem);

  /// Why the host did not take or report the enrolment.
  final VtaEnrolmentProblem problem;

  @override
  String toString() => 'VtaEnrolmentException(${problem.name})';
}

/// Talks to the VTA host's enrolment exchange, Keyring's v1: submits the
/// phone's DID with a proof it holds the key, and reads the offer's status.
///
/// Follows no redirects, so an HTTPS offer cannot be bounced to plain HTTP
/// or to another host.
class VtaEnrolmentClient {
  /// Creates a [VtaEnrolmentClient].
  VtaEnrolmentClient({Dio? dio, this.allowHttp = false})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              connectTimeout: const Duration(seconds: 15),
              receiveTimeout: const Duration(seconds: 15),
              sendTimeout: const Duration(seconds: 15),
            ),
          );

  /// How long the proof of possession is valid.
  static const proofLifetime = Duration(minutes: 5);

  final Dio _dio;

  /// Whether plain HTTP hosts are reached, in dev builds only.
  final bool allowHttp;

  /// Submits [manager]'s DID to [offer]'s host with a proof bound to the
  /// offer's URL and nonce, and returns the code both screens show.
  ///
  /// Throws [VtaEnrolmentException] when the host refuses the DID, or
  /// answers with a code other than the one computed here.
  Future<String> submit(
    VtaEnrolmentOffer offer,
    Ed25519DidKeySigner manager, {
    required DateTime now,
  }) async {
    final issuedAt = now.millisecondsSinceEpoch ~/ 1000;
    final proof = await _proof(manager, {
      'iss': manager.did,
      'aud': offer.url,
      'nonce': offer.nonce,
      'iat': issuedAt,
      'exp': issuedAt + proofLifetime.inSeconds,
    });

    final response = await _send(
      () => _dio.post<Object?>(
        _endpoint(offer.url, 'submit'),
        data: {'did': manager.did, 'proof': proof},
        options: _options,
      ),
    );
    final status = response.statusCode ?? 0;
    if (status == 410) {
      throw const VtaEnrolmentException(VtaEnrolmentProblem.expired);
    }
    if (status == 404 || status == 409) {
      throw const VtaEnrolmentException(VtaEnrolmentProblem.alreadyUsed);
    }
    if (status >= 500) {
      throw const VtaEnrolmentException(VtaEnrolmentProblem.unreachable);
    }
    if (status < 200 || status >= 300) {
      throw const VtaEnrolmentException(VtaEnrolmentProblem.rejected);
    }

    // The host derives the code from what it received: a different code
    // means it did not receive this DID, and could never match.
    final code = vtaEnrolmentCode(offer.nonce, manager.did);
    final body = response.data;
    if (body is! Map<String, dynamic> || body['code'] != code) {
      throw const VtaEnrolmentException(VtaEnrolmentProblem.codeMismatch);
    }
    return code;
  }

  /// Reads where the enrolment at the offer [url] stands.
  ///
  /// Throws [VtaEnrolmentException] when the host cannot be reached or its
  /// answer cannot be read.
  Future<VtaEnrolmentStatus> status(String url) async {
    final response = await _send(
      () => _dio.get<Object?>(_endpoint(url, 'status'), options: _options),
    );
    final body = response.data;
    if (response.statusCode == 404) return VtaEnrolmentStatus.expired;
    final state = body is Map<String, dynamic> ? body['state'] : null;
    return VtaEnrolmentStatus.values.firstWhere(
      (status) => status.name == state,
      orElse: () =>
          throw const VtaEnrolmentException(VtaEnrolmentProblem.unreachable),
    );
  }

  Options get _options => Options(
    followRedirects: false,
    maxRedirects: 0,
    validateStatus: (_) => true,
    responseType: ResponseType.json,
    contentType: Headers.jsonContentType,
  );

  String _endpoint(String url, String action) {
    final uri = Uri.parse(url);
    if (uri.scheme != 'https' && !(allowHttp && uri.scheme == 'http')) {
      throw const VtaEnrolmentException(VtaEnrolmentProblem.rejected);
    }
    return '$url/$action';
  }

  static Future<Response<Object?>> _send(
    Future<Response<Object?>> Function() request,
  ) async {
    try {
      return await request();
    } on DioException {
      throw const VtaEnrolmentException(VtaEnrolmentProblem.unreachable);
    }
  }

  /// A compact JWS over [payload], signed with [manager]'s Ed25519 key, as
  /// the host verifies it.
  static Future<String> _proof(
    Ed25519DidKeySigner manager,
    Map<String, dynamic> payload,
  ) async {
    final header = {
      'alg': 'EdDSA',
      'kid': manager.verificationMethod,
      'typ': 'JWT',
    };
    final signingInput = '${_encode(header)}.${_encode(payload)}';
    final signature = await manager.sign(
      Uint8List.fromList(ascii.encode(signingInput)),
    );
    return '$signingInput.${_base64UrlNoPad(signature)}';
  }

  static String _encode(Map<String, dynamic> json) =>
      _base64UrlNoPad(utf8.encode(jsonEncode(json)));

  static String _base64UrlNoPad(List<int> bytes) =>
      base64Url.encode(bytes).replaceAll('=', '');
}
