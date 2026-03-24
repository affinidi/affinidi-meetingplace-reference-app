/// Compile-time configuration for the AI Personal Representative backend.
///
/// Inject at build time via:
///   --dart-define=AGENT_BACKEND_URL=https://your-api.amazonaws.com/prod
class AgentConfig {
  AgentConfig._();

  static const String backendUrl = String.fromEnvironment(
    'AGENT_BACKEND_URL',
    defaultValue:
        'https://8tqfn539mf.execute-api.ap-southeast-1.amazonaws.com/prod',
  );
}
