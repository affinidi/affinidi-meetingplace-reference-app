/// Generic application-level exception used to surface domain and
///  infrastructure errors in a typed way across the codebase.
///
/// Factory parameters:
/// - [message] - Human readable error message.
/// - [code] - Code classifying the error (used for mapping to UI/handling).
class AppException implements Exception {
  AppException(this.message, {required this.code});

  final String message;
  final String code;

  @override
  String toString() => message;
}
