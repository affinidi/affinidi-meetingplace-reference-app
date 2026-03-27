import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/config/agent_config.dart';
import '../models/agent_readiness_state.dart';
import '../providers/agent_providers.dart';
import '../screens/agent_onboarding_screen.dart';
import '../screens/agent_vc_screen.dart';
import '../services/agent_learn_service.dart' show AgentLearnService;
import 'deploy_agent_sheet.dart';

/// Shows the AI representative status panel: learning toggle, readiness bar,
/// and the deploy button once the agent is ready.
///
/// Uses [ConsumerStatefulWidget] so the toggle can reflect local state
/// immediately while the [AgentLearnService] persists it asynchronously.
class AgentStatusWidget extends ConsumerStatefulWidget {
  const AgentStatusWidget({required this.ownerDid, super.key});

  final String ownerDid;

  @override
  ConsumerState<AgentStatusWidget> createState() => _AgentStatusWidgetState();
}

class _AgentStatusWidgetState extends ConsumerState<AgentStatusWidget> {
  late bool _isLearning;

  @override
  void initState() {
    super.initState();
    _isLearning = ref.read(agentLearnServiceProvider).isLearningEnabled;
    debugPrint(
      '[AgentWidget] init — learning enabled: $_isLearning, ownerDid: ${widget.ownerDid}',
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.ownerDid.isEmpty) return const SizedBox.shrink();

    final readinessAsync = ref.watch(agentReadinessProvider(widget.ownerDid));

    return Card(
      color: Theme.of(context).colorScheme.surface,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Icon(Icons.smart_toy_outlined, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'AI Personal Representative',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh, size: 20),
                  tooltip: 'Refresh readiness',
                  visualDensity: VisualDensity.compact,
                  onPressed: () {
                    debugPrint(
                      '[AgentWidget] manual refresh for ${widget.ownerDid}',
                    );
                    ref.invalidate(agentReadinessProvider(widget.ownerDid));
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            _ToggleRow(
              isEnabled: _isLearning,
              onChanged: (value) {
                setState(() => _isLearning = value);
                ref.read(agentLearnServiceProvider).setLearningEnabled(value);
              },
            ),
            const SizedBox(height: 12),
            readinessAsync.when(
              data: (readiness) => _ReadinessSection(
                readiness: readiness,
                ownerDid: widget.ownerDid,
              ),
              loading: () => const LinearProgressIndicator(),
              error: (_, err) => Text(
                'Could not load readiness status.',
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Toggle row
// ---------------------------------------------------------------------------

class _ToggleRow extends StatelessWidget {
  const _ToggleRow({required this.isEnabled, required this.onChanged});

  final bool isEnabled;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Learn from my conversations',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              Text(
                'Analyses outbound messages to build your style profile.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
        Switch(value: isEnabled, onChanged: onChanged),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Readiness section
// ---------------------------------------------------------------------------

class _ReadinessSection extends ConsumerWidget {
  const _ReadinessSection({required this.readiness, required this.ownerDid});

  final AgentReadinessState readiness;
  final String ownerDid;

  Color _barColor(int score) {
    if (score >= 80) return Colors.green;
    if (score >= 40) return Colors.blue;
    return Colors.orange;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final score = readiness.scorePercent;
    final color = _barColor(score);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Readiness',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
            ),
            Text(
              '$score%',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: score / 100,
            minHeight: 8,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation(color),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          readiness.statusLabel,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
        if (readiness.isDeployed) ...[
          const SizedBox(height: 12),
          _DeployedBadge(),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () => _openVcScreen(context),
            icon: const Icon(Icons.verified_outlined, size: 16),
            label: const Text('View Agent Credential'),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF6A0DAD),
              side: const BorderSide(color: Color(0xFF6A0DAD)),
            ),
          ),
        ] else if (readiness.isReady) ...[
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: () => _openDeploySheet(context, ref),
            icon: const Icon(Icons.rocket_launch_outlined, size: 18),
            label: const Text('Deploy as My Representative'),
            style: FilledButton.styleFrom(backgroundColor: Colors.green),
          ),
        ] else if (AgentConfig.backendUrl.isNotEmpty) ...[
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () => _openOnboarding(context, ref),
            icon: const Icon(Icons.auto_fix_high_outlined, size: 16),
            label: const Text('Quick Setup'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.deepPurpleAccent,
              side: const BorderSide(color: Colors.deepPurpleAccent),
            ),
          ),
        ],
        if (readiness.feedbackUpCount > 0 || readiness.feedbackDownCount > 0) ...[
          const SizedBox(height: 10),
          _FeedbackStats(
            upCount: readiness.feedbackUpCount,
            downCount: readiness.feedbackDownCount,
          ),
        ],
      ],
    );
  }

  Future<void> _openOnboarding(BuildContext context, WidgetRef ref) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => AgentOnboardingScreen(ownerDid: ownerDid),
      ),
    );
    if (result == true) {
      ref.invalidate(agentReadinessProvider(ownerDid));
    }
  }

  void _openDeploySheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) =>
          DeployAgentSheet(ownerDid: ownerDid, readiness: readiness),
    );
  }

  void _openVcScreen(BuildContext context) {
    Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => AgentVcScreen(ownerDid: ownerDid),
      ),
    );
  }
}

class _DeployedBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6A0DAD), Color(0xFF3B2FBE)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.smart_toy_outlined, color: Colors.white, size: 16),
          SizedBox(width: 8),
          Text(
            'Active Representative',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class _FeedbackStats extends StatelessWidget {
  const _FeedbackStats({required this.upCount, required this.downCount});

  final int upCount;
  final int downCount;

  @override
  Widget build(BuildContext context) {
    final total = upCount + downCount;
    final pct = total > 0 ? (upCount / total * 100).round() : 0;
    return Row(
      children: [
        const Icon(Icons.rate_review_outlined, size: 14, color: Colors.blueGrey),
        const SizedBox(width: 6),
        Text(
          'Message feedback:',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const Spacer(),
        Icon(Icons.thumb_up, size: 13, color: Colors.green.shade600),
        const SizedBox(width: 2),
        Text(
          '$upCount',
          style: Theme.of(context).textTheme.bodySmall
              ?.copyWith(color: Colors.green.shade600),
        ),
        const SizedBox(width: 8),
        Icon(Icons.thumb_down, size: 13, color: Colors.red.shade400),
        const SizedBox(width: 2),
        Text(
          '$downCount',
          style: Theme.of(context).textTheme.bodySmall
              ?.copyWith(color: Colors.red.shade400),
        ),
        const SizedBox(width: 8),
        Text(
          '($pct% positive)',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
          ),
        ),
      ],
    );
  }
}
