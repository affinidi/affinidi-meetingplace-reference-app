import 'dart:convert';
import 'dart:typed_data';

/// The member's VTA this phone is linked to, and the manager key the phone
/// acts as towards it.
///
/// The manager key gives administrative rights on the VTA: it is kept in
/// secure storage on this device only and never logged.
class LinkedVta {
  /// Creates a [LinkedVta].
  const LinkedVta({
    required this.vtaDid,
    required this.managerSeed,
    required this.isGranted,
    this.enrolment,
  });

  /// Restores a [LinkedVta] stored with [toJson].
  factory LinkedVta.fromJson(Map<String, dynamic> json) {
    final enrolment = json['enrolment'];
    return LinkedVta(
      vtaDid: json['vtaDid'] as String,
      managerSeed: Uint8List.fromList(
        base64Url.decode(json['managerSeed'] as String),
      ),
      isGranted: json['isGranted'] as bool,
      enrolment: enrolment == null
          ? null
          : VtaEnrolment.fromJson(enrolment as Map<String, dynamic>),
    );
  }

  /// DID of the member's VTA.
  final String vtaDid;

  /// Seed of the manager key.
  final Uint8List managerSeed;

  /// Whether the VTA has granted the manager key.
  final bool isGranted;

  /// The enrolment through the VTA host this link was started with, while
  /// the host has not granted it. Null for a manual link.
  final VtaEnrolment? enrolment;

  /// Returns a copy marked as granted, done with its enrolment.
  LinkedVta granted() =>
      LinkedVta(vtaDid: vtaDid, managerSeed: managerSeed, isGranted: true);

  /// Serialises for secure storage.
  Map<String, dynamic> toJson() => {
    'vtaDid': vtaDid,
    'managerSeed': base64Url.encode(managerSeed),
    'isGranted': isGranted,
    if (enrolment case final enrolment?) 'enrolment': enrolment.toJson(),
  };
}

/// A manager key submitted to the VTA host by an enrolment offer, waiting
/// for the VTA admin to grant it on the host.
class VtaEnrolment {
  /// Creates a [VtaEnrolment].
  const VtaEnrolment({
    required this.url,
    required this.code,
    required this.expiresAt,
  });

  /// Restores a [VtaEnrolment] stored with [toJson].
  factory VtaEnrolment.fromJson(Map<String, dynamic> json) => VtaEnrolment(
    url: json['url'] as String,
    code: json['code'] as String,
    expiresAt: DateTime.parse(json['expiresAt'] as String),
  );

  /// The offer's URL on the host, where its status is read.
  final String url;

  /// The code the app and the host both show.
  final String code;

  /// When the host stops accepting a grant for the offer.
  final DateTime expiresAt;

  /// Serialises for secure storage.
  Map<String, dynamic> toJson() => {
    'url': url,
    'code': code,
    'expiresAt': expiresAt.toUtc().toIso8601String(),
  };
}
