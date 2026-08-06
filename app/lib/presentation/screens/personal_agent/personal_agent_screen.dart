import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../application/services/context_routing_service/context_routing_service.dart';
import '../../../application/services/personal_ai_service/personal_ai_authorization_snapshot.dart';
import '../../../domain/models/contacts/contact.dart';
import '../../../domain/models/trust_task/trust_task_record.dart';
import '../../../infrastructure/extensions/build_context_extensions.dart';
import '../../../infrastructure/providers/app_logger_provider.dart';
import '../../../l10n/app_localizations.dart';
import '../../../navigation/tabs/tabs.dart';
import '../../widgets/section_banner.dart';
import 'personal_agent_screen_controller.dart';
import 'trust_task_history_controller.dart';

class PersonalAgentScreen extends ConsumerWidget {
  const PersonalAgentScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final colorScheme = context.colorScheme;
    final provider = personalAgentScreenControllerProvider;
    final controller = ref.read(provider.notifier);

    final ui = ref.watch(
      provider.select(
        (state) => (
          contextUploading: state.contextUploading,
          isConnecting: state.isConnecting,
          connectingLabel: state.connectingLabel,
          contextUploadError: state.contextUploadError,
          errorMessage: state.errorMessage,
          workContact: state.workContact,
          workSnapshot: state.workAuthorizationSnapshot,
          showWorkAuthorization: state.showWorkAuthorization,
          workContextUploaded: state.workContextUploaded,
          workContextFileName: state.workContextFileName,
          autoResponseEnabled: state.autoResponseEnabled,
          autoResponseLoading: state.autoResponseLoading,
          autoResponseAvailable: state.autoResponseAvailable,
        ),
      ),
    );

    Future<void> cancelRoutingContext(AgentContext target) async {
      final label = target == AgentContext.work
          ? l10n.agentContextWorkAiLabel
          : l10n.agentContextWorkAiLabel;
      final agentLabel = target == AgentContext.work
          ? l10n.personalAgentWorkAgentTitle
          : l10n.personalAgentWorkAgentTitle;
      final shouldCancel = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text(l10n.personalAgentCancelConnectionTitle(label)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(l10n.personalAgentCancelConnectionContent(agentLabel)),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.of(dialogContext).pop(false),
                      child: Text(l10n.generalCancel),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: () => Navigator.of(dialogContext).pop(true),
                      child: const Text('Disconnect'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );

      if (shouldCancel != true) {
        return;
      }

      try {
        await controller.disconnectRoutingContext(target);
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.personalAgentConnectionCancelled(label))),
        );
      } catch (_) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.personalAgentCancelConnectionError(label)),
          ),
        );
      }
    }

    Future<void> connectWorkOneDrive() async {
      try {
        final outcome = await controller.connectWorkOneDrive();
        if (!context.mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(outcome.message)));
      } catch (error, stackTrace) {
        final exactError = error.toString();
        ref
            .read(appLoggerProvider)
            .error(
              'Work AI Microsoft 365 connection failed in UI action. exactError=$exactError',
              error: error,
              stackTrace: stackTrace,
              name: 'PERSONALAGENT',
            );
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Microsoft 365 connection failed. Check logs.'),
          ),
        );
      }
    }

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          SectionBanner(
            title: l10n.tabsTitle(Tabs.personalAgent.name),
            subtitle: l10n.personalAgentSetupSectionSubtitle,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (ui.errorMessage != null) ...[
                  _GlassPanel(
                    borderColor: colorScheme.error.withValues(alpha: 0.42),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.error_outline, color: colorScheme.error),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            ui.errorMessage!,
                            style: TextStyle(
                              color: colorScheme.onErrorContainer,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (ui.showWorkAuthorization) ...[
                    const SizedBox(height: 16),
                    _AgentAuthorizationCard(
                      title: l10n.personalAgentMyWorkAiTitle,
                      contextLabel: l10n.personalAgentWorkContextLabel,
                      snapshot: ui.workSnapshot,
                      contact: ui.workContact,
                      onCancel: () => cancelRoutingContext(AgentContext.work),
                    ),
                  ],
                ],
                _AgentContextSetupCard(
                  workContextUploaded: ui.workContextUploaded,
                  workContextFileName: ui.workContextFileName,
                  isUploading: ui.contextUploading,
                  isConnecting: ui.isConnecting,
                  connectingLabel: ui.connectingLabel,
                  uploadError: ui.contextUploadError,
                  onUploadWork: connectWorkOneDrive,
                  onResetWork: () => cancelRoutingContext(AgentContext.work),
                ),
                const SizedBox(height: 16),
                _GlassPanel(
                  padding: EdgeInsets.zero,
                  child: Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(22),
                    child: SwitchListTile(
                      title: const Text('Auto Response'),
                      subtitle: const Text(
                        'Agent responds without approval when enabled',
                      ),
                      value: ui.autoResponseEnabled,
                      onChanged:
                          ui.autoResponseLoading || !ui.autoResponseAvailable
                          ? null
                          : (_) => controller.toggleAutoResponse(),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(22),
                      ),
                    ),
                  ),
                ),
                if (ui.showWorkAuthorization) ...[
                  const SizedBox(height: 16),
                  _AgentAuthorizationCard(
                    title: l10n.personalAgentMyWorkAiTitle,
                    contextLabel: l10n.personalAgentWorkContextLabel,
                    snapshot: ui.workSnapshot,
                    contact: ui.workContact,
                    onCancel: () => cancelRoutingContext(AgentContext.work),
                  ),
                ],
                const SizedBox(height: 16),
                const _TrustTaskHistorySection(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TrustTaskHistorySection extends ConsumerWidget {
  const _TrustTaskHistorySection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final colorScheme = context.colorScheme;
    final state = ref.watch(trustTaskHistoryControllerProvider);
    final controller = ref.read(trustTaskHistoryControllerProvider.notifier);

    return _GlassPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(Icons.history, color: colorScheme.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n.trustTaskHistoryTitle,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              IconButton(
                tooltip: l10n.trustTaskHistoryRefresh,
                onPressed: state.isLoading ? null : controller.refresh,
                icon: state.isLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.refresh),
              ),
            ],
          ),
          const SizedBox(height: 4),
          _buildBody(context, l10n, colorScheme, state, controller),
        ],
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    AppLocalizations l10n,
    ColorScheme colorScheme,
    TrustTaskHistoryState state,
    TrustTaskHistoryController controller,
  ) {
    if (state.isLoading && state.records.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (state.status == TrustTaskHistoryStatus.error && state.records.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          children: [
            Text(
              l10n.trustTaskHistoryError,
              style: TextStyle(color: colorScheme.error),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: controller.refresh,
              child: Text(l10n.trustTaskHistoryRetry),
            ),
          ],
        ),
      );
    }

    if (state.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Center(
          child: Text(
            l10n.trustTaskHistoryEmpty,
            style: TextStyle(color: colorScheme.onSurfaceVariant),
          ),
        ),
      );
    }

    return Column(
      children: [
        for (final record in state.records)
          _TrustTaskHistoryTile(record: record),
        if (state.hasMore)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: state.isLoadingMore
                ? const Padding(
                    padding: EdgeInsets.all(8),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : TextButton(
                    onPressed: controller.loadMore,
                    child: Text(l10n.trustTaskHistoryLoadMore),
                  ),
          ),
      ],
    );
  }
}

class _TrustTaskHistoryTile extends StatelessWidget {
  const _TrustTaskHistoryTile({required this.record});

  final TrustTaskRecord record;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colorScheme = context.colorScheme;

    return Material(
      color: Colors.transparent,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: EdgeInsets.zero,
          childrenPadding: const EdgeInsets.only(bottom: 12),
          expandedCrossAxisAlignment: CrossAxisAlignment.stretch,
          leading: Icon(
            Icons.assignment_turned_in_outlined,
            color: colorScheme.primary,
          ),
          title: Row(
            children: [
              Expanded(
                child: Text(
                  l10n.trustTaskHistoryItemTitle,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontSize: 13),
                ),
              ),
              const SizedBox(width: 8),
              _StatusChip(record: record),
            ],
          ),
          subtitle: Text(
            _formatTimestamp(record.timestamp),
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(fontSize: 11),
          ),
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withValues(
                  alpha: 0.4,
                ),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: colorScheme.outlineVariant),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.trustTaskHistoryDetails,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      fontSize: 10,
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  for (final entry in _detailEntries(record))
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 3),
                      child: _DetailRow(label: entry.key, value: entry.value),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Flattens the raw audit entry into ordered `label → value` pairs for the
  /// expandable details view. Falls back to the mapped fields when the raw map
  /// is unavailable (e.g. records built directly in tests).
  static List<MapEntry<String, String>> _detailEntries(TrustTaskRecord record) {
    final source = record.raw.isNotEmpty
        ? record.raw
        : <String, dynamic>{
            'id': record.id,
            'timestamp':
                record.timestamp.toUtc().millisecondsSinceEpoch ~/ 1000,
            'outcome': record.rawOutcome,
            if (record.entryId != null) 'resource': record.entryId,
            if (record.actor != null) 'actor': record.actor,
            if (record.contextId != null) 'context_id': record.contextId,
            if (record.detail != null) 'detail': record.detail,
          };

    final keys = source.keys.toList()..sort();
    return [
      for (final key in keys) MapEntry(key, _stringifyValue(source[key])),
    ];
  }

  static String _stringifyValue(Object? value) {
    if (value == null) return '—';
    if (value is String) return value.isEmpty ? '—' : value;
    if (value is num || value is bool) return value.toString();
    try {
      return const JsonEncoder.withIndent('  ').convert(value);
    } catch (_) {
      return value.toString();
    }
  }

  static String _formatTimestamp(DateTime timestamp) {
    String two(int n) => n.toString().padLeft(2, '0');
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final month = months[timestamp.month - 1];
    return '$month ${timestamp.day}, ${timestamp.year} '
        '${two(timestamp.hour)}:${two(timestamp.minute)}';
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 96,
          child: Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              fontSize: 11,
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: SelectableText(
            value,
            style: theme.textTheme.bodySmall?.copyWith(
              fontSize: 11,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.record});

  final TrustTaskRecord record;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colorScheme = context.colorScheme;

    late final Color color;
    late final String label;
    switch (record.status) {
      case TrustTaskStatus.signed:
        color = Colors.green;
        label = l10n.trustTaskStatusSigned;
      case TrustTaskStatus.denied:
        color = colorScheme.error;
        label = l10n.trustTaskStatusDenied;
      case TrustTaskStatus.unknown:
        color = colorScheme.outline;
        label = l10n.trustTaskStatusUnknown;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _GlassPanel extends StatelessWidget {
  const _GlassPanel({
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.borderColor,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: colorScheme.surface.withValues(alpha: 0.54),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: borderColor ?? Colors.white.withValues(alpha: 0.16),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.22),
                blurRadius: 24,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}

class _AgentStatusPill extends StatelessWidget {
  const _AgentStatusPill({
    required this.icon,
    required this.label,
    required this.highlighted,
  });

  final IconData icon;
  final String label;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final foreground = highlighted
        ? colorScheme.onPrimary
        : colorScheme.onSurface.withValues(alpha: 0.76);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: highlighted
            ? colorScheme.primary.withValues(alpha: 0.86)
            : Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: foreground, size: 16),
            const SizedBox(width: 6),
            Text(
              label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: foreground,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _friendlyIdentifier(String value) {
  final words = value
      .replaceAll('-', ' ')
      .replaceAll('_', ' ')
      .trim()
      .split(RegExp(r'\s+'));
  return words
      .where((word) => word.isNotEmpty)
      .map((word) => '${word[0].toUpperCase()}${word.substring(1)}')
      .join(' ');
}

String _breakableIdentifier(String value) {
  return value.replaceAllMapped(
    RegExp(r'([:/._-])'),
    (match) => '${match.group(1)} ',
  );
}

class _AgentAuthorizationCard extends StatelessWidget {
  const _AgentAuthorizationCard({
    required this.title,
    required this.contextLabel,
    required this.snapshot,
    required this.contact,
    required this.onCancel,
  });

  final String title;
  final String contextLabel;
  final PersonalAiAuthorizationSnapshot? snapshot;
  final Contact? contact;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colorScheme = context.colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final domainMap = snapshot?.domainMap ?? const <String, dynamic>{};
    final entries = snapshot?.entries ?? const <Map<String, dynamic>>[];

    String rawValue(Map<String, dynamic> source, String key) {
      final value = source[key];
      if (value == null) return l10n.personalAgentNotAvailable;
      final text = value.toString().trim();
      return text.isEmpty ? l10n.personalAgentNotAvailable : text;
    }

    String readableValue(Map<String, dynamic> source, String key) {
      final text = rawValue(source, key);
      if (text == l10n.personalAgentNotAvailable) return text;
      if (key == 'operation' || key == 'task_type') {
        final parts = text.split('/').where((part) => part.isNotEmpty).toList();
        return _friendlyIdentifier(parts.isEmpty ? text : parts.last);
      }
      if (key == 'outcome' || key == 'source') {
        return _friendlyIdentifier(text);
      }
      if (key == 'timestamp') {
        return text.replaceFirst('T', ' ').replaceFirst('Z', ' UTC');
      }
      return _breakableIdentifier(text);
    }

    Widget mapChip(String label, String value) {
      return ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 160),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: colorScheme.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: colorScheme.primary.withValues(alpha: 0.16),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      );
    }

    Widget detailRow(String label, String value, {bool emphasize = false}) {
      return Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 96,
              child: Text(
                label,
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                value,
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurface,
                  height: 1.25,
                  fontWeight: FontWeight.w600,
                ),
                softWrap: true,
                overflow: TextOverflow.visible,
              ),
            ),
          ],
        ),
      );
    }

    Widget entryCard(Map<String, dynamic> entry, int index) {
      return DecoratedBox(
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.34),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: colorScheme.outlineVariant.withValues(alpha: 0.44),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.task_alt_outlined,
                    size: 18,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      entries.length > 1
                          ? 'Entry ${index + 1}'
                          : 'Trust task entry',
                      style: textTheme.labelLarge?.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  Flexible(
                    child: Text(
                      readableValue(entry, 'channel'),
                      style: textTheme.labelSmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.end,
                    ),
                  ),
                ],
              ),
              detailRow(
                'Outcome',
                readableValue(entry, 'outcome'),
                emphasize: true,
              ),
              detailRow('Operation', readableValue(entry, 'operation')),
              detailRow('Actor', readableValue(entry, 'actor')),
              detailRow('Vault', readableValue(entry, 'vault_entry')),
              detailRow('Time', readableValue(entry, 'timestamp')),
            ],
          ),
        ),
      );
    }

    return _GlassPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  color: colorScheme.secondary.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(9),
                  child: Icon(
                    Icons.smart_toy_outlined,
                    color: colorScheme.secondary,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      contextLabel,
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant.withValues(
                          alpha: 0.72,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Flexible(
                child: Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: _AgentStatusPill(
                    icon: contact == null
                        ? Icons.radio_button_unchecked
                        : Icons.check_circle_outline,
                    label: contact == null
                        ? l10n.personalAgentNotSetUp
                        : l10n.personalAgentConnectedSectionTitle,
                    highlighted: contact != null,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          DecoratedBox(
            decoration: BoxDecoration(
              color: colorScheme.surface.withValues(alpha: 0.42),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: colorScheme.outlineVariant.withValues(alpha: 0.42),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.account_tree_outlined,
                        color: colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Domain map',
                          style: textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      mapChip('Domain', readableValue(domainMap, 'domain_id')),
                      mapChip(
                        'Context',
                        readableValue(domainMap, 'context_id'),
                      ),
                      mapChip(
                        'Scope',
                        readableValue(domainMap, 'context_scope'),
                      ),
                    ],
                  ),
                  detailRow('Source', readableValue(domainMap, 'source')),
                  detailRow('Task type', readableValue(domainMap, 'task_type')),
                  detailRow('Agent DID', readableValue(domainMap, 'agent_did')),
                  const SizedBox(height: 14),
                  if (entries.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        l10n.personalAgentNoSnapshotYet,
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    )
                  else
                    for (final indexedEntry in entries.indexed) ...[
                      if (indexedEntry.$1 > 0) const SizedBox(height: 10),
                      entryCard(indexedEntry.$2, indexedEntry.$1),
                    ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: contact == null ? null : onCancel,
              icon: const Icon(Icons.link_off_outlined),
              label: Text(l10n.personalAgentCancelConnection),
            ),
          ),
        ],
      ),
    );
  }
}

class _AgentContextSetupCard extends StatelessWidget {
  const _AgentContextSetupCard({
    required this.workContextUploaded,
    required this.workContextFileName,
    required this.isUploading,
    required this.isConnecting,
    required this.connectingLabel,
    required this.uploadError,
    required this.onUploadWork,
    required this.onResetWork,
  });

  final bool workContextUploaded;
  final String? workContextFileName;
  final bool isUploading;
  final bool isConnecting;
  final String? connectingLabel;
  final String? uploadError;
  final VoidCallback onUploadWork;
  final VoidCallback onResetWork;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colorScheme = context.colorScheme;
    final textTheme = Theme.of(context).textTheme;

    String subtitleFor(AgentContext contextTarget) {
      final file = workContextFileName;
      return file == null || file.isEmpty
          ? 'Connect Microsoft 365 to set up Work AI'
          : l10n.personalAgentAlreadySetUp(file);
    }

    Widget buildContextTile({
      required String title,
      required String subtitle,
      required IconData icon,
      required bool isLocked,
      required VoidCallback onPressed,
      VoidCallback? onReset,
    }) {
      final disabled = isUploading || isConnecting || isLocked;
      final accentColor = isLocked
          ? context.customColors.success
          : colorScheme.primary;

      return Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: disabled ? null : onPressed,
          child: Ink(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: isLocked ? 0.1 : 0.075),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: accentColor.withValues(alpha: isLocked ? 0.55 : 0.28),
              ),
            ),
            child: Row(
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Icon(
                      isLocked ? Icons.check_circle_outline : icon,
                      color: accentColor,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        subtitle,
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurface.withValues(alpha: 0.66),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  width: 24,
                  height: 24,
                  child: isLocked && onReset != null
                      ? IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          tooltip: l10n.personalAgentCancelConnection,
                          onPressed: (isUploading || isConnecting)
                              ? null
                              : onReset,
                          icon: Icon(
                            Icons.restart_alt_rounded,
                            color: colorScheme.onSurface.withValues(
                              alpha: (isUploading || isConnecting)
                                  ? 0.35
                                  : 0.78,
                            ),
                          ),
                        )
                      : Icon(
                          isLocked
                              ? Icons.lock_outline
                              : Icons.arrow_forward_rounded,
                          color: colorScheme.onSurface.withValues(
                            alpha: disabled ? 0.35 : 0.78,
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return _GlassPanel(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.personalAgentSetupCardTitle,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      l10n.personalAgentSetupCardDescription,
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.68),
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Icon(
                Icons.route_outlined,
                color: colorScheme.secondary.withValues(alpha: 0.9),
              ),
            ],
          ),
          if (uploadError != null) ...[
            const SizedBox(height: 12),
            Text(uploadError!, style: TextStyle(color: colorScheme.error)),
          ],
          if (isConnecting) ...[
            const SizedBox(height: 12),
            Text(
              l10n.personalAgentConnecting(
                connectingLabel ?? l10n.personalAgentDefaultConnectingLabel,
              ),
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: const LinearProgressIndicator(minHeight: 4),
            ),
          ],
          const SizedBox(height: 14),
          buildContextTile(
            title: l10n.personalAgentWorkAgentTitle,
            subtitle: subtitleFor(AgentContext.work),
            icon: Icons.cloud_sync_outlined,
            isLocked: workContextUploaded,
            onPressed: onUploadWork,
            onReset: onResetWork,
          ),
        ],
      ),
    );
  }
}
