import '../exceptions/app_exception.dart';
import '../exceptions/app_exception_type.dart';

extension MapPathExtensions on Map<String, dynamic> {
  /// Returns the string value at the nested [pathKeys] location, or
  /// [defaultValue] if any key is missing or the final value is not a String.
  String getPathValue(List<String> pathKeys, {String defaultValue = ''}) {
    if (pathKeys.isEmpty) return defaultValue;

    var parentElement = this;
    for (var i = 0; i < pathKeys.length; i++) {
      final pathKey = pathKeys[i];
      final elementAtPath = parentElement[pathKey];
      if (elementAtPath == null) {
        return defaultValue;
      }

      if (i == pathKeys.length - 1) {
        return elementAtPath is String ? elementAtPath : defaultValue;
      }

      if (elementAtPath is Map<String, dynamic>) {
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
    for (var i = 0; i < pathKeys.length - 1; i++) {
      final pathKey = pathKeys[i];
      final elementAtPath = parentElement[pathKey];
      if (elementAtPath is Map<String, dynamic>) {
        parentElement = elementAtPath;
      } else if (elementAtPath == null) {
        final newNode = <String, dynamic>{};
        parentElement[pathKey] = newNode;
        parentElement = newNode;
      } else {
        throw AppException(
          "setPathValue: expected a map at key '$pathKey' but found "
          '${elementAtPath.runtimeType}',
          code: AppExceptionType.invalidMapStructure.name,
        );
      }
    }

    parentElement[pathKeys.last] = value;
  }
}
