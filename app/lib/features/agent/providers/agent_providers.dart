import 'package:http/http.dart' as http;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/config/agent_config.dart';
import '../../../infrastructure/providers/shared_preferences_provider.dart';
import '../models/agent_readiness_state.dart';
import '../models/deployment_result.dart';
import '../repositories/agent_repository.dart';
import '../services/agent_learn_service.dart';

part 'agent_providers.g.dart';

/// Shared HTTP client — single instance for the lifetime of the app.
@Riverpod(keepAlive: true)
http.Client httpClient(HttpClientRef ref) => http.Client();

/// Provides [AgentLearnService] backed by the app-wide [SharedPreferences]
/// instance (already initialised before [ProviderScope] starts).
@Riverpod(keepAlive: true)
AgentLearnService agentLearnService(AgentLearnServiceRef ref) {
  return AgentLearnService(
    prefs: ref.read(sharedPreferencesProvider),
    client: ref.read(httpClientProvider),
    backendUrl: AgentConfig.backendUrl,
  );
}

/// Provides [AgentRepository] for readiness polling and deployment calls.
@Riverpod(keepAlive: true)
AgentRepository agentRepository(AgentRepositoryRef ref) {
  return AgentRepository(
    client: ref.read(httpClientProvider),
    backendUrl: AgentConfig.backendUrl,
  );
}

/// Auto-disposing readiness fetch — invalidate to force a refresh.
@riverpod
Future<AgentReadinessState> agentReadiness(
  AgentReadinessRef ref,
  String ownerDid,
) {
  return ref.read(agentRepositoryProvider).getReadiness(ownerDid);
}

/// Manages the full deploy lifecycle. State is
/// [AsyncValue<DeploymentResult?>]:
///   • [AsyncData(null)]    — idle
///   • [AsyncLoading]       — in-flight
///   • [AsyncData(result)]  — success
///   • [AsyncError]         — failed
@Riverpod(keepAlive: true)
class DeploymentNotifier extends _$DeploymentNotifier {
  @override
  AsyncValue<DeploymentResult?> build() => const AsyncData(null);

  Future<void> deploy(String ownerDid) async {
    if (state is AsyncLoading) return;
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(agentRepositoryProvider).deployAgent(ownerDid),
    );
  }

  void reset() => state = const AsyncData(null);
}
