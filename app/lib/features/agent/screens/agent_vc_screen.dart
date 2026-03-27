import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../models/agent_vc_data.dart';
import '../providers/agent_providers.dart';

/// Full-screen viewer for the user's issued AgentConfigVC.
class AgentVcScreen extends ConsumerStatefulWidget {
  const AgentVcScreen({required this.ownerDid, super.key});

  final String ownerDid;

  @override
  ConsumerState<AgentVcScreen> createState() => _AgentVcScreenState();
}

class _AgentVcScreenState extends ConsumerState<AgentVcScreen> {
  AgentVcData? _vc;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data =
        await ref.read(agentRepositoryProvider).getAgentVc(widget.ownerDid);
    if (!mounted) return;
    setState(() {
      _vc = data;
      _loading = false;
      _error = data == null ? 'Could not load credential data.' : null;
    });
  }

  Future<void> _claimInVault() async {
    final uri = _vc?.credentialOfferUri;
    if (uri == null) return;
    // Deep-link into the Affinidi Vault app
    await Clipboard.setData(ClipboardData(text: uri));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Credential offer URL copied. Open Affinidi Vault and paste it to claim.',
        ),
        duration: Duration(seconds: 4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Agent Credential'),
        centerTitle: false,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Text(
                    _error!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                )
              : _VcContent(
                  vc: _vc!,
                  onClaim: _vc?.credentialOfferUri != null ? _claimInVault : null,
                ),
    );
  }
}

// ── VC content ──────────────────────────────────────────────────────────────

class _VcContent extends StatelessWidget {
  const _VcContent({required this.vc, required this.onClaim});

  final AgentVcData vc;
  final VoidCallback? onClaim;

  @override
  Widget build(BuildContext context) {
    final claims = vc.claims;
    // hardLimits is stored as { items: [...] } to match the TAgentConfigV1R1 schema shape.
    final hardLimitsRaw = claims['hardLimits'];
    final hardLimits = (hardLimitsRaw is Map
            ? (hardLimitsRaw['items'] as List<dynamic>? ?? [])
            : (hardLimitsRaw as List<dynamic>? ?? []))
        .map((e) => e.toString())
        .toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6A0DAD), Color(0xFF3B2FBE)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.verified_outlined,
                      color: Colors.white,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Agent Config Credential',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            claims['agentName'] as String? ??
                                'My AI Representative',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _MetaRow(
                  label: 'Issued',
                  value: _formatDate(vc.issuedAt),
                ),
                const SizedBox(height: 4),
                _MetaRow(
                  label: 'Holder',
                  value: _truncateDid(vc.holderDid),
                ),
                const SizedBox(height: 4),
                _MetaRow(
                  label: 'ID',
                  value: _truncate(vc.issuanceId, 24),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Claims section
          const _SectionHeader(label: 'Credential Claims'),
          const SizedBox(height: 8),
          _ClaimRow(
            icon: Icons.smart_toy_outlined,
            label: 'Model',
            value: claims['modelProvider'] as String? ?? '—',
          ),
          _ClaimRow(
            icon: Icons.code,
            label: 'Version',
            value: claims['configVersion'] as String? ?? '—',
          ),
          _ClaimRow(
            icon: Icons.message_outlined,
            label: 'Trained on',
            value: '${claims['trainedOnMessages'] ?? 0} messages',
          ),
          _ClaimRow(
            icon: Icons.share_outlined,
            label: 'Delegation scope',
            value: claims['delegationScope'] as String? ?? '—',
          ),
          _ClaimRow(
            icon: Icons.fingerprint,
            label: 'Prompt hash',
            value: _truncate(claims['systemPromptHash'] as String? ?? '', 20),
          ),

          if (hardLimits.isNotEmpty) ...[
            const SizedBox(height: 16),
            const _SectionHeader(label: 'Hard Limits'),
            const SizedBox(height: 8),
            for (final limit in hardLimits)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.block,
                      size: 14,
                      color: Colors.red.shade400,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        limit,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
          ],

          const SizedBox(height: 24),

          // Claim in Vault button (only shown if offer URI is present)
          if (onClaim != null) ...[
            FilledButton.icon(
              onPressed: onClaim,
              icon: const Icon(Icons.account_balance_wallet_outlined, size: 18),
              label: const Text('Claim in Affinidi Vault'),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF6A0DAD),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Opens your Affinidi Vault to store this credential.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.5),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) =>
      '${dt.day} ${_months[dt.month - 1]} ${dt.year}';

  String _truncateDid(String did) {
    if (did.length <= 30) return did;
    return '${did.substring(0, 16)}…${did.substring(did.length - 10)}';
  }

  String _truncate(String s, int max) =>
      s.length > max ? '${s.substring(0, max)}…' : s;

  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          '$label: ',
          style: const TextStyle(
            color: Colors.white60,
            fontSize: 11,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: Theme.of(context).textTheme.labelMedium?.copyWith(
        fontWeight: FontWeight.w700,
        color: Theme.of(context)
            .colorScheme
            .onSurface
            .withValues(alpha: 0.5),
        letterSpacing: 0.8,
      ),
    );
  }
}

class _ClaimRow extends StatelessWidget {
  const _ClaimRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: Colors.blueGrey),
          const SizedBox(width: 10),
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(value, style: Theme.of(context).textTheme.bodySmall),
          ),
        ],
      ),
    );
  }
}
