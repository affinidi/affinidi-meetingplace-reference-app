import 'dart:convert';

import 'package:crypto/crypto.dart';

/// Why an enrolment offer was refused.
enum VtaEnrolmentOfferProblem {
  /// The text is not an enrolment link, or a field is missing or invalid.
  malformed,

  /// The offer is of a version this app does not read.
  unsupportedVersion,

  /// The offer's submit URL is not HTTPS.
  insecureUrl,

  /// The offer's expiry has passed.
  expired,
}

/// Thrown when scanned or pasted text is not an enrolment offer the app
/// accepts.
class InvalidVtaEnrolmentOfferException implements Exception {
  /// Creates an [InvalidVtaEnrolmentOfferException].
  const InvalidVtaEnrolmentOfferException(this.problem);

  /// Why the offer was refused.
  final VtaEnrolmentOfferProblem problem;

  @override
  String toString() => 'InvalidVtaEnrolmentOfferException(${problem.name})';
}

/// An offer from the member's VTA host to link this phone to their VTA, read
/// from a QR code or a link.
///
/// Keyring's enrolment offer, version 1, so any host that enrols Keyring
/// enrols Meeting Place too:
///
///     keyring://vta/enrol?o=<base64url(JSON offer)>
///
/// The offer is untrusted input: [VtaEnrolmentOffer.parse] checks every field
/// and the expiry before anything is minted or sent.
class VtaEnrolmentOffer {
  /// Creates a [VtaEnrolmentOffer].
  const VtaEnrolmentOffer({
    required this.vtaDid,
    required this.label,
    required this.url,
    required this.nonce,
    required this.expiresAt,
  });

  /// Reads [text] as an enrolment link, as of [now].
  ///
  /// Plain HTTP submit URLs are accepted only when [allowHttp], in dev
  /// builds. Throws [InvalidVtaEnrolmentOfferException] naming why an offer
  /// is refused.
  factory VtaEnrolmentOffer.parse(
    String text, {
    required DateTime now,
    bool allowHttp = false,
  }) {
    final trimmed = text.trim();
    if (trimmed.length > _maxLinkLength || !isLink(trimmed)) {
      throw const InvalidVtaEnrolmentOfferException(
        VtaEnrolmentOfferProblem.malformed,
      );
    }

    final encoded = trimmed
        .substring(linkPrefix.length)
        .split('&')
        .first
        .replaceAll(RegExp('%3D', caseSensitive: false), '=')
        .replaceAll(RegExp(r'=+$'), '');
    final Object? json;
    try {
      if (!_base64Url.hasMatch(encoded)) throw const FormatException();
      json = jsonDecode(utf8.decode(base64Url.decode(_padded(encoded))));
    } on FormatException {
      throw const InvalidVtaEnrolmentOfferException(
        VtaEnrolmentOfferProblem.malformed,
      );
    }
    if (json is! Map<String, dynamic> || json['t'] != _type) {
      throw const InvalidVtaEnrolmentOfferException(
        VtaEnrolmentOfferProblem.malformed,
      );
    }
    if (json['v'] != _version) {
      throw InvalidVtaEnrolmentOfferException(
        json['v'] is int
            ? VtaEnrolmentOfferProblem.unsupportedVersion
            : VtaEnrolmentOfferProblem.malformed,
      );
    }

    final vtaDid = json['vta'];
    final label = json['label'];
    final url = json['url'];
    final nonce = json['n'];
    final exp = json['exp'];
    if (vtaDid is! String ||
        !_isDid(vtaDid) ||
        label is! String ||
        label.length > _maxLabelLength ||
        url is! String ||
        nonce is! String ||
        !_nonce.hasMatch(nonce) ||
        exp is! int) {
      throw const InvalidVtaEnrolmentOfferException(
        VtaEnrolmentOfferProblem.malformed,
      );
    }

    final submitUrl = Uri.tryParse(url);
    if (submitUrl == null ||
        url.length > _maxUrlLength ||
        submitUrl.host.isEmpty ||
        submitUrl.userInfo.isNotEmpty ||
        submitUrl.hasQuery ||
        submitUrl.hasFragment ||
        !const {'https', 'http'}.contains(submitUrl.scheme)) {
      throw const InvalidVtaEnrolmentOfferException(
        VtaEnrolmentOfferProblem.malformed,
      );
    }
    if (submitUrl.scheme != 'https' && !allowHttp) {
      throw const InvalidVtaEnrolmentOfferException(
        VtaEnrolmentOfferProblem.insecureUrl,
      );
    }

    final expiresAt = DateTime.fromMillisecondsSinceEpoch(
      exp * 1000,
      isUtc: true,
    );
    if (now.isAfter(expiresAt)) {
      throw const InvalidVtaEnrolmentOfferException(
        VtaEnrolmentOfferProblem.expired,
      );
    }
    // Offers live for minutes; one that claims to live for days is not one a
    // host made.
    if (expiresAt.isAfter(now.add(_maxLifetime))) {
      throw const InvalidVtaEnrolmentOfferException(
        VtaEnrolmentOfferProblem.malformed,
      );
    }

    return VtaEnrolmentOffer(
      vtaDid: vtaDid,
      label: label.replaceAll(RegExp(r'[\x00-\x1F\x7F]'), ' ').trim(),
      url: url,
      nonce: nonce,
      expiresAt: expiresAt,
    );
  }

  /// Start of every enrolment link.
  static const linkPrefix = 'keyring://vta/enrol?o=';

  static const _type = 'vta-enrol';
  static const _version = 1;
  static const _maxLinkLength = 4096;
  static const _maxUrlLength = 2048;
  static const _maxLabelLength = 200;
  static const _maxLifetime = Duration(days: 1);

  /// A single-use nonce: at least 16 base64url characters.
  static final _nonce = RegExp(r'^[A-Za-z0-9_-]{16,128}$');

  static final _base64Url = RegExp(r'^[A-Za-z0-9_-]+$');

  /// DID of the VTA the phone is being linked to.
  final String vtaDid;

  /// Name of the VTA's host, as the host gives it. Shown, never trusted.
  final String label;

  /// Where the phone submits its DID, and the audience of its proof.
  final String url;

  /// Single-use nonce the proof is bound to.
  final String nonce;

  /// When the host stops accepting the offer.
  final DateTime expiresAt;

  /// Whether [text] reads as an enrolment link rather than, say, a DID.
  static bool isLink(String text) => text.trim().startsWith(linkPrefix);

  static bool _isDid(String text) =>
      text.length <= _maxUrlLength &&
      RegExp(r'^did:[a-z0-9]+:\S+$').hasMatch(text);

  static String _padded(String base64) =>
      base64.padRight(base64.length + (4 - base64.length % 4) % 4, '=');
}

/// Domain separation for the code both screens show.
const _enrolmentCodeTag = 'keyring-vta-enrol/v1';

/// Crockford base32: no I, L, O or U, so no code can be misread as another.
const _crockford = '0123456789ABCDEFGHJKMNPQRSTVWXYZ';

/// The `XXXX-XXXX` code the app and the VTA host both show for the offer
/// [nonce] and the phone's [did], computed as the host computes it.
///
/// The VTA admin compares the two before granting: a different code means
/// the host received someone else's DID.
String vtaEnrolmentCode(String nonce, String did) {
  final digest = sha256
      .convert(utf8.encode('$_enrolmentCodeTag|$nonce|$did'))
      .bytes;
  var bits = 0;
  for (final byte in digest.take(5)) {
    bits = (bits << 8) | byte;
  }
  final code = StringBuffer();
  for (var i = 7; i >= 0; i--) {
    code.write(_crockford[(bits >> (i * 5)) & 31]);
  }
  final text = code.toString();
  return '${text.substring(0, 4)}-${text.substring(4)}';
}
