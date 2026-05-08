extension MapPathExtensions on Map<dynamic, dynamic> {
  /// Returns the string value at the nested [pathKeys] location, or
  /// [defaultValue] if any key is missing or the final value is not a String.
  String getPathValue(List<String> pathKeys, {String defaultValue = ''}) {
    if (pathKeys.isEmpty) return defaultValue;

    var parentElement = this;
    for (final pathKey in pathKeys) {
      final elementAtPath = parentElement[pathKey];
      if (elementAtPath == null) {
        return defaultValue;
      }

      if ((pathKey == pathKeys.last) && elementAtPath is String) {
        return elementAtPath;
      }

      if (elementAtPath is Map<dynamic, dynamic>) {
        parentElement = elementAtPath;
      } else {
        return defaultValue;
      }
    }

    return defaultValue;
  }

  /// Writes [value] at the nested [pathKeys] location, creating intermediate
  /// maps as needed.
  void setPathValue(List<String> pathKeys, String value) {
    if (pathKeys.isEmpty) return;

    var parentElement = this;
    for (final pathKey in pathKeys) {
      if (pathKey == pathKeys.last) continue;

      final elementAtPath = parentElement[pathKey];
      if (elementAtPath is Map<dynamic, dynamic>) {
        parentElement = elementAtPath;
      } else if (elementAtPath == null) {
        final newNode = <dynamic, dynamic>{};
        parentElement[pathKey] = newNode;
        parentElement = newNode;
      } else {
        throw StateError(
          "setPathValue: expected a map at key '$pathKey' but found "
          '${elementAtPath.runtimeType}',
        );
      }
    }

    parentElement[pathKeys.last] = value;
  }
}
