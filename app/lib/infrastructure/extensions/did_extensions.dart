import 'dart:convert';
import 'package:crypto/crypto.dart';

/// Small helpers for working with DIDs and short display formatting.
extension DidExtensions on String {
  /// Compute SHA256 hash of this DID string and return it as hex.
  String get toDidSha256 {
    final hash = sha256.convert(utf8.encode(this)).toString();
    return hash;
  }

  /// Return a shortened "top...tail" representation of this string.
  String topAndTail({int charCountTop = 16, int charCountTail = 8}) {
    if (length <= charCountTop + charCountTail) return this;
    final top = substring(0, charCountTop);
    final tail = substring(length - charCountTail);
    return '$top...$tail';
  }

  /// Return a shortened "top...:last" representation of this DID: its first
  /// [charCountTop] characters, then its last part from the last colon,
  /// such as `:ada-lovelace`. A last part longer than [maxLastPart], such
  /// as a `did:key`'s key, keeps only its last [charCountTail] characters.
  String topAndLastPart({
    int charCountTop = 24,
    int maxLastPart = 20,
    int charCountTail = 8,
  }) {
    final lastColon = lastIndexOf(':');
    final lastPart = lastColon < 0 ? '' : substring(lastColon);
    if (lastPart.isEmpty || lastPart.length > maxLastPart) {
      return topAndTail(
        charCountTop: charCountTop,
        charCountTail: charCountTail,
      );
    }
    const ellipsis = '...';
    // Whole while cutting would save no more than the ellipsis takes.
    if (length <= charCountTop + ellipsis.length + lastPart.length) {
      return this;
    }
    return '${substring(0, charCountTop)}$ellipsis$lastPart';
  }
}
