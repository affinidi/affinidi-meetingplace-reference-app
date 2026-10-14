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
  });

  /// Restores a [LinkedVta] stored with [toJson].
  factory LinkedVta.fromJson(Map<String, dynamic> json) {
    return LinkedVta(
      vtaDid: json['vtaDid'] as String,
      managerSeed: Uint8List.fromList(
        base64Url.decode(json['managerSeed'] as String),
      ),
      isGranted: json['isGranted'] as bool,
    );
  }

  /// DID of the member's VTA.
  final String vtaDid;

  /// Seed of the manager key.
  final Uint8List managerSeed;

  /// Whether the VTA has granted the manager key.
  final bool isGranted;

  /// Returns a copy marked as granted.
  LinkedVta granted() =>
      LinkedVta(vtaDid: vtaDid, managerSeed: managerSeed, isGranted: true);

  /// Serialises for secure storage.
  Map<String, dynamic> toJson() => {
    'vtaDid': vtaDid,
    'managerSeed': base64Url.encode(managerSeed),
    'isGranted': isGranted,
  };
}
