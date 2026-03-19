/// Thrown by [AgentRepository.deployAgent] when the backend returns a non-200
/// response or an unexpected error occurs during agent deployment.
class AgentDeploymentException implements Exception {
  const AgentDeploymentException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => 'AgentDeploymentException($statusCode): $message';
}
