import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../application/services/context_routing_service/context_routing_service.dart';
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

    final contextUploading = ref.watch(
      provider.select((state) => state.contextUploading),
    );
    final isConnecting = ref.watch(
      provider.select((state) => state.isConnecting),
    );
    final connectingLabel = ref.watch(
      provider.select((state) => state.connectingLabel),
    );
    final contextUploadError = ref.watch(
      provider.select((state) => state.contextUploadError),
    );
    final errorMessage = ref.watch(
      provider.select((state) => state.errorMessage),
    );
    final contextRoutingState = ref.watch<ContextRoutingState>(
      contextRoutingServiceProvider,
    );

    Future<void> uploadRoutingContext(AgentContext target) async {
      final pickedFile = await _pickTextFile(ref);
      if (pickedFile == null) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('No context created')));
        return;
      }

      final outcome = await controller.uploadRoutingContext(
        target,
        fileName: pickedFile.fileName,
        content: pickedFile.content,
      );

      if (!context.mounted) return;

      if (!outcome.uploaded) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('No context created')));
        return;
      }

      final label = target == AgentContext.work ? 'Work AI' : 'Personal AI';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$label uploaded: ${outcome.fileName}')),
      );
    }

    return ColoredBox(
      color: colorScheme.surface,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SectionBanner(
              title: l10n.tabsTitle(Tabs.personalAgent.name),
              subtitle: 'Set up your AI. Choose what context to set up.',
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  if (errorMessage != null) ...[
                    const SizedBox(height: 8),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: colorScheme.errorContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Text(
                          errorMessage,
                          style: TextStyle(color: colorScheme.onErrorContainer),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  _AgentContextSetupCard(
                    state: contextRoutingState,
                    isUploading: contextUploading,
                    isConnecting: isConnecting,
                    connectingLabel: connectingLabel,
                    uploadError: contextUploadError,
                    onUploadWork: () => uploadRoutingContext(AgentContext.work),
                    onUploadPersonal: () =>
                        uploadRoutingContext(AgentContext.personal),
                  ),
                ],
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
    required this.state,
    required this.isUploading,
    required this.isConnecting,
    required this.connectingLabel,
    required this.uploadError,
    required this.onUploadWork,
    required this.onUploadPersonal,
  });

  final ContextRoutingState state;
  final bool isUploading;
  final bool isConnecting;
  final String? connectingLabel;
  final String? uploadError;
  final VoidCallback onUploadWork;
  final VoidCallback onUploadPersonal;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final textTheme = Theme.of(context).textTheme;

    String subtitleFor(AgentContext contextTarget) {
      final file = state.fileNameForContext(contextTarget);
      if (file == null || file.isEmpty) return 'Choose a file to set up';
      return 'Already set up: $file';
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
                isLocked
                    ? Icons.check_circle_outline
                    : Icons.upload_file_outlined,
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
              'Set up your AI',
              style: textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Choose what context to set up.',
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
                'Connecting ${connectingLabel ?? 'agent'}...',
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 6),
              const LinearProgressIndicator(minHeight: 3),
            ],
            const SizedBox(height: 12),
            buildRow(
              title: 'Work Agent',
              subtitle: subtitleFor(AgentContext.work),
              isLocked: state.workContextUploaded,
              onPressed: onUploadWork,
            ),
            const SizedBox(height: 10),
            buildRow(
              title: 'Personal Agent',
              subtitle: subtitleFor(AgentContext.personal),
              isLocked: state.personalContextUploaded,
              onPressed: onUploadPersonal,
            ),
          ],
        ),
      ),
    );
  }
}
