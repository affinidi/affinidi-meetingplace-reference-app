import 'dart:convert';
import 'package:http/http.dart' as http;

/// Helper class for AWS Rekognition Face Liveness backend services
class AwsServices {
  /// Your backend URL for face liveness operations
  static const String backendUrl = 'https://msi.tail51fed5.ts.net';

  /// Get session data from your Spring Boot backend (without credentials)
  static Future<Map<String, String>> getSessionFromBackend() async {
    try {
      // Get only session ID from backend
      final response = await http.post(
        Uri.parse('$backendUrl/face-liveness/create-session'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({}),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return {
          'sessionId': data['sessionId'] ?? '',
          'region': data['region'] ?? 'us-east-1',
        };
      }

      throw Exception('Failed to get session: ${response.statusCode}');
    } catch (e) {
      print('Error getting session: $e');
      return {};
    }
  }

  /// Fetch liveness verification results from your backend
  static Future<Map<String, dynamic>> fetchLivenessResults({
    required String sessionId,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$backendUrl/face-liveness/results?sessionId=$sessionId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      throw Exception(
          'Failed to fetch liveness results: ${response.statusCode}');
    } catch (e) {
      print('Error fetching liveness results: $e');
      return {'verified': false, 'error': e.toString()};
    }
  }
}
