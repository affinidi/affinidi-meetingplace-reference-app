import 'dart:convert';

/// Returns `null` if [s] cannot be decoded as a JSON object.
Map<String, dynamic>? decodeJsonOrNull(String s) {
  try {
    return (jsonDecode(s) as Map).cast<String, dynamic>();
  } catch (_) {
    return null;
  }
}

Object? _canonicalizeValue(Object? value) {
  if (value is List) {
    return value.map(_canonicalizeValue).toList();
  }

  if (value is Map) {
    final entries =
        value.entries
            .map((e) => MapEntry(e.key.toString(), _canonicalizeValue(e.value)))
            .toList()
          ..sort((a, b) => a.key.compareTo(b.key));

    return <String, Object?>{for (final e in entries) e.key: e.value};
  }

  return value;
}

/// Re-encodes [json] with object keys sorted recursively so that two
/// semantically equal JSON strings produce identical output.
String canonicalizeJsonString(String json) {
  final decoded = jsonDecode(json);
  return jsonEncode(_canonicalizeValue(decoded));
}
