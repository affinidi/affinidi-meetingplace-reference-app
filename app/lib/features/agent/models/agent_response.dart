class AgentResponse {
  const AgentResponse({required this.response, required this.scope});

  final String response;
  final String scope;

  bool get isInScope => scope == 'in_scope';

  factory AgentResponse.fromJson(Map<String, dynamic> json) => AgentResponse(
    response: json['response'] as String,
    scope: json['scope'] as String,
  );
}
