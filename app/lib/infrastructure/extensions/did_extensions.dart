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
}
