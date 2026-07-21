import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../application/services/context_routing_service/context_routing_service.dart';
import '../../../application/services/personal_ai_service/personal_ai_authorization_snapshot.dart';
import '../../../domain/models/contacts/contact.dart';
import '../../../infrastructure/extensions/build_context_extensions.dart';
import '../../../infrastructure/media/file_picker/file_picker_platform_provider.dart';
import '../../../navigation/tabs/tabs.dart';
import '../../widgets/section_banner.dart';
import 'personal_agent_screen_controller.dart';

class PersonalAgentScreen extends ConsumerWidget {
  const PersonalAgentScreen({super.key});

  Future<({String fileName, String content})?> _pickTextFile(
    WidgetRef ref,
  ) async {
    final picker = ref.read(filePickerPlatformProvider);
    final picked = await picker.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['txt'],
    );
    if (picked == null || picked.files.isEmpty) {
      return null;
    }

    final file = picked.files.first;
    final bytes = await file.readAsBytes();
    if (bytes.isEmpty) {
      return null;
    }

    return (fileName: file.name, content: String.fromCharCodes(bytes));
  }

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
          personalContact: state.personalContact,
          workSnapshot: state.workAuthorizationSnapshot,
          personalSnapshot: state.personalAuthorizationSnapshot,
          showWorkAuthorization: state.showWorkAuthorization,
          showPersonalAuthorization: state.showPersonalAuthorization,
          workContextUploaded: state.workContextUploaded,
          personalContextUploaded: state.personalContextUploaded,
          workContextFileName: state.workContextFileName,
          personalContextFileName: state.personalContextFileName,
        ),
      ),
    );

    Future<void> uploadRoutingContext(AgentContext target) async {
      final pickedFile = await _pickTextFile(ref);
      if (pickedFile == null) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.personalAgentNoContextCreated)),
        );
        return;
      }

      final outcome = await controller.uploadRoutingContext(
        target,
        fileName: pickedFile.fileName,
        content: pickedFile.content,
      );

      if (!context.mounted) return;

      if (!outcome.uploaded) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.personalAgentNoContextCreated)),
        );
        return;
      }

      final label = target == AgentContext.work
          ? l10n.agentContextWorkAiLabel
          : l10n.agentContextPersonalAiLabel;
      final uploadedFileName = outcome.fileName ?? pickedFile.fileName;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n.personalAgentContextUploadedSnackBar(label, uploadedFileName),
          ),
        ),
      );
    }

    Future<void> cancelRoutingContext(AgentContext target) async {
      final label = target == AgentContext.work
          ? l10n.agentContextWorkAiLabel
          : l10n.agentContextPersonalAiLabel;
      final agentLabel = target == AgentContext.work
          ? l10n.personalAgentWorkAgentTitle
          : l10n.personalAgentPersonalAgentTitle;
      final shouldCancel = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text(l10n.personalAgentCancelConnectionTitle(label)),
          content: Text(l10n.personalAgentCancelConnectionContent(agentLabel)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(l10n.personalAgentKeepConnection),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(l10n.personalAgentCancelConnection),
            ),
          ],
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
      } catch (error) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.toString())));
      }
    }

    return ColoredBox(
      color: colorScheme.surface,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SectionBanner(
              title: l10n.tabsTitle(Tabs.personalAgent.name),
              subtitle: l10n.personalAgentSetupSectionSubtitle,
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  if (ui.errorMessage != null) ...[
                    const SizedBox(height: 8),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: colorScheme.errorContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Text(
                          ui.errorMessage!,
                          style: TextStyle(color: colorScheme.onErrorContainer),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  _AgentContextSetupCard(
                    workContextUploaded: ui.workContextUploaded,
                    personalContextUploaded: ui.personalContextUploaded,
                    workContextFileName: ui.workContextFileName,
                    personalContextFileName: ui.personalContextFileName,
                    isUploading: ui.contextUploading,
                    isConnecting: ui.isConnecting,
                    connectingLabel: ui.connectingLabel,
                    uploadError: ui.contextUploadError,
                    onUploadWork: connectWorkOneDrive,
                    onUploadPersonal: () =>
                        uploadRoutingContext(AgentContext.personal),
                  ),
                  if (ui.showWorkAuthorization ||
                      ui.showPersonalAuthorization) ...[
                    const SizedBox(height: 16),
                    if (ui.showWorkAuthorization)
                      _AgentAuthorizationCard(
                        title: l10n.personalAgentMyWorkAiTitle,
                        contextLabel: l10n.personalAgentWorkContextLabel,
                        snapshot: ui.workSnapshot,
                        contact: ui.workContact,
                        onCancel: () => cancelRoutingContext(AgentContext.work),
                      ),
                    if (ui.showWorkAuthorization &&
                        ui.showPersonalAuthorization)
                      const SizedBox(height: 12),
                    if (ui.showPersonalAuthorization)
                      _AgentAuthorizationCard(
                        title: l10n.personalAgentMyPersonalAiTitle,
                        contextLabel: l10n.personalAgentPersonalContextLabel,
                        snapshot: ui.personalSnapshot,
                        contact: ui.personalContact,
                        onCancel: () =>
                            cancelRoutingContext(AgentContext.personal),
                      ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
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
    final capabilities =
        snapshot?.capabilities.join(' + ') ?? l10n.personalAgentNotAvailable;
    final provisionStatus =
        (snapshot?.provision?['status'] as String?) ??
        l10n.personalAgentNotAvailable;
    final updatedAt =
        snapshot?.lastUpdated?.toLocal().toString() ??
        l10n.personalAgentNoSnapshotYet;

    Widget row(String label, String value) {
      return Padding(
        padding: const EdgeInsets.only(top: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 120,
              child: Text(
                label,
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            Expanded(
              child: Text(
                value,
                style: textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.smart_toy_outlined, color: colorScheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Text(
                  contact == null
                      ? l10n.personalAgentNotSetUp
                      : l10n.personalAgentConnectedSectionTitle,
                  style: textTheme.labelSmall?.copyWith(
                    color: contact == null
                        ? colorScheme.onSurfaceVariant
                        : colorScheme.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              contextLabel,
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            row(
              l10n.personalAgentAuthAgentDid,
              snapshot?.agentDid ?? l10n.personalAgentNotAvailable,
            ),
            row(
              l10n.personalAgentAuthAclRole,
              snapshot?.aclRole ?? l10n.personalAgentNotAvailable,
            ),
            row(l10n.personalAgentAuthCapabilities, capabilities),
            row(
              l10n.personalAgentAuthContextScope,
              snapshot?.contextScope ?? l10n.personalAgentNotAvailable,
            ),
            row(
              l10n.personalAgentAuthDomainId,
              snapshot?.domainId ?? l10n.personalAgentNotAvailable,
            ),
            row(l10n.personalAgentAuthProvision, provisionStatus),
            row(l10n.personalAgentAuthUpdated, updatedAt),
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
      ),
    );
  }
}

class _AgentContextSetupCard extends StatelessWidget {
  const _AgentContextSetupCard({
    required this.workContextUploaded,
    required this.personalContextUploaded,
    required this.workContextFileName,
    required this.personalContextFileName,
    required this.isUploading,
    required this.isConnecting,
    required this.connectingLabel,
    required this.uploadError,
    required this.onUploadWork,
    required this.onUploadPersonal,
  });

  final bool workContextUploaded;
  final bool personalContextUploaded;
  final String? workContextFileName;
  final String? personalContextFileName;
  final bool isUploading;
  final bool isConnecting;
  final String? connectingLabel;
  final String? uploadError;
  final VoidCallback onUploadWork;
  final VoidCallback onUploadPersonal;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colorScheme = context.colorScheme;
    final textTheme = Theme.of(context).textTheme;

    String subtitleFor(AgentContext contextTarget) {
      final file = contextTarget == AgentContext.work
          ? workContextFileName
          : personalContextFileName;
      if (contextTarget == AgentContext.work) {
        return 'Connect OneDrive to set up work context';
      }
      if (file == null || file.isEmpty) {
        return l10n.personalAgentChooseFileToSetUp;
      }
      return l10n.personalAgentAlreadySetUp(file);
    }

    Widget buildRow({
      required String title,
      required String subtitle,
      required bool isLocked,
      required VoidCallback onPressed,
    }) {
      return SizedBox(
        width: double.infinity,
        child: FilledButton(
          onPressed: (isUploading || isConnecting || isLocked)
              ? null
              : onPressed,
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            backgroundColor: colorScheme.primary,
            foregroundColor: colorScheme.onPrimary,
          ),
          child: Row(
            children: [
              Icon(
                isLocked ? Icons.check_circle_outline : Icons.cloud_outlined,
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
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onPrimary.withValues(alpha: 0.8),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      );
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.personalAgentSetupCardTitle,
              style: textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              l10n.personalAgentSetupCardDescription,
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            if (uploadError != null) ...[
              const SizedBox(height: 10),
              Text(uploadError!, style: TextStyle(color: colorScheme.error)),
            ],
            if (isConnecting) ...[
              const SizedBox(height: 10),
              Text(
                l10n.personalAgentConnecting(
                  connectingLabel ?? l10n.personalAgentDefaultConnectingLabel,
                ),
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 6),
              const LinearProgressIndicator(minHeight: 3),
            ],
            const SizedBox(height: 12),
            buildRow(
              title: l10n.personalAgentWorkAgentTitle,
              subtitle: subtitleFor(AgentContext.work),
              isLocked: workContextUploaded,
              onPressed: onUploadWork,
            ),
            const SizedBox(height: 10),
            buildRow(
              title: l10n.personalAgentPersonalAgentTitle,
              subtitle: subtitleFor(AgentContext.personal),
              isLocked: personalContextUploaded,
              onPressed: onUploadPersonal,
            ),
          ],
        ),
      ),
    );
  }
}
