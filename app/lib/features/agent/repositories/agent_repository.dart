import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/agent_deployment_exception.dart';
import '../models/agent_readiness_state.dart';
import '../models/deployment_result.dart';

/// Data-access layer for the AI Personal Representative backend.
///
/// [getReadiness] is safe to call at any time — returns [AgentReadinessState.initial]
/// on any error so the UI never hard-crashes from a network failure.
///
/// [deployAgent] throws [AgentDeploymentException] on non-200 so callers can
/// surface a proper error banner.
class AgentRepository {
  const AgentRepository({
    required http.Client client,
    required String backendUrl,
  }) : _client = client,
       _backendUrl = backendUrl;

  final http.Client _client;
  final String _backendUrl;

  Future<AgentReadinessState> getReadiness(String ownerDid) async {
    try {
      final uri = Uri.parse(
        '$_backendUrl/readiness',
      ).replace(queryParameters: {'did': ownerDid});
      final response = await _client.get(uri);
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        return AgentReadinessState.fromJson(json);
      }
      return AgentReadinessState.initial();
    } catch (_) {
      return AgentReadinessState.initial();
    }
  }

  Future<DeploymentResult> deployAgent(String ownerDid) async {
    final response = await _client.post(
      Uri.parse('$_backendUrl/deploy-agent'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'ownerDid': ownerDid}),
    );
    if (response.statusCode != 200) {
      throw AgentDeploymentException(
        'Deployment failed: ${response.body}',
        statusCode: response.statusCode,
      );
    }
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return DeploymentResult.fromJson(json);
  }
}
