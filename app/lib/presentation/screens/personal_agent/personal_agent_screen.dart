import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:meeting_place_personal_agent/meeting_place_personal_agent.dart';

import '../../../application/services/context_routing_service/context_routing_service.dart';
import '../../../infrastructure/extensions/build_context_extensions.dart';
import '../../../navigation/tabs/tabs.dart';
import '../../widgets/section_banner.dart';
import 'personal_agent_screen_controller.dart';

class PersonalAgentScreen extends ConsumerWidget {
  const PersonalAgentScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final colorScheme = context.colorScheme;
    final provider = personalAgentScreenControllerProvider;
    final controller = ref.read(provider.notifier);

    final isReady = ref.watch(provider.select((state) => state.isReady));
    final isSettingUp = ref.watch(
      provider.select((state) => state.isSettingUp),
    );
    final contextProvisioned = ref.watch(
      provider.select((state) => state.contextProvisioned),
    );
    final contextUploading = ref.watch(
      provider.select((state) => state.contextUploading),
    );
    final contextUploadError = ref.watch(
      provider.select((state) => state.contextUploadError),
    );
    final errorMessage = ref.watch(
      provider.select((state) => state.errorMessage),
    );
    final setupResult = ref.watch(
      provider.select((state) => state.setupResult),
    );
    final contextRoutingState = ref.watch<ContextRoutingState>(
      contextRoutingServiceProvider,
    );

    Future<void> uploadRoutingContext(AgentContext target) async {
      final picked = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['txt'],
      );
      if (picked == null || picked.files.isEmpty || !context.mounted) return;
      final file = picked.files.first;
      final bytes = await file.readAsBytes();
      if (bytes.isEmpty) return;

      // Keep local per-channel routing state in sync with the uploaded file.
      // This is used by channel-level context selection.
      final content = String.fromCharCodes(bytes);

      await ref
          .read<ContextRoutingService>(contextRoutingServiceProvider.notifier)
          .markContextUploaded(context: target, fileName: file.name);

      // Also upload the selected file to the Personal AI setup backend so the
      // agent memory is actually updated (previously this action only updated
      // local UI state).
      if (setupResult?.setupId?.isNotEmpty == true) {
        await controller.uploadContext(content);
      }

      if (!context.mounted) return;
      final label = target == AgentContext.work ? 'Work AI' : 'Personal AI';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$label context uploaded: ${file.name}')),
      );
    }

    // When the MPX connection is ready but context has not been uploaded,
    // show the first-time onboarding flow instead of the management screen.
    if (isReady && !contextProvisioned) {
      return ColoredBox(
        color: colorScheme.surface,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SectionBanner(
                title: l10n.tabsTitle(Tabs.personalAgent.name),
                subtitle: l10n.personalAgentPanelSubtitle,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: _ContextRoutingUploadsCard(
                  state: contextRoutingState,
                  onUploadWork: () => uploadRoutingContext(AgentContext.work),
                  onUploadPersonal: () =>
                      uploadRoutingContext(AgentContext.personal),
                ),
              ),
              Expanded(
                child: _ContextSetupView(
                  isUploading: contextUploading,
                  uploadError: contextUploadError,
                  onUpload: controller.uploadContext,
                ),
              ),
            ],
          ),
        ),
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
              subtitle: l10n.personalAgentPanelSubtitle,
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _StatusCard(
                    isReady: isReady,
                    isSettingUp: isSettingUp,
                    contextProvisioned: contextProvisioned,
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                      disabledBackgroundColor: colorScheme.primary.withValues(
                        alpha: 0.35,
                      ),
                      disabledForegroundColor: colorScheme.onPrimary,
                    ),
                    onPressed: isSettingUp
                        ? null
                        : controller.connectPersonalAi,
                    icon: isSettingUp
                        ? SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: colorScheme.onPrimary,
                            ),
                          )
                        : const Icon(Icons.link),
                    label: Text(
                      isSettingUp
                          ? l10n.personalAgentSetupInProgressButton
                          : isReady
                          ? l10n.personalAgentReconnectButton
                          : l10n.personalAgentConnectButton,
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: controller.openSetupPrompt,
                    icon: const Icon(Icons.info_outline),
                    label: Text(l10n.personalAgentReviewSetupPrompt),
                  ),
                  if (errorMessage != null) ...[
                    const SizedBox(height: 16),
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
                  _ContextRoutingUploadsCard(
                    state: contextRoutingState,
                    onUploadWork: () => uploadRoutingContext(AgentContext.work),
                    onUploadPersonal: () =>
                        uploadRoutingContext(AgentContext.personal),
                  ),
                  const SizedBox(height: 16),
                  _WhatToExpectCard(isReady: isReady),
                  if (setupResult != null) ...[
                    const SizedBox(height: 24),
                    _ConnectedSummary(result: setupResult),
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

class _ContextRoutingUploadsCard extends StatelessWidget {
  const _ContextRoutingUploadsCard({
    required this.state,
    required this.onUploadWork,
    required this.onUploadPersonal,
  });

  final ContextRoutingState state;
  final VoidCallback onUploadWork;
  final VoidCallback onUploadPersonal;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final textTheme = Theme.of(context).textTheme;

    String subtitleFor(AgentContext contextTarget) {
      final file = state.fileNameForContext(contextTarget);
      if (file == null || file.isEmpty) return 'Not uploaded yet';
      return 'Uploaded: $file';
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
              'Channel Context Files',
              style: textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Upload one file for Work AI and one for Personal AI. '
              'You can choose either context per channel.',
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            _ContextUploadRow(
              title: 'Work AI (ctx0)',
              subtitle: subtitleFor(AgentContext.work),
              uploaded: state.workContextUploaded,
              onPressed: onUploadWork,
            ),
            const SizedBox(height: 10),
            _ContextUploadRow(
              title: 'Personal AI (ctx1)',
              subtitle: subtitleFor(AgentContext.personal),
              uploaded: state.personalContextUploaded,
              onPressed: onUploadPersonal,
            ),
          ],
        ),
      ),
    );
  }
}

class _ContextUploadRow extends StatelessWidget {
  const _ContextUploadRow({
    required this.title,
    required this.subtitle,
    required this.uploaded,
    required this.onPressed,
  });

  final String title;
  final String subtitle;
  final bool uploaded;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        OutlinedButton.icon(
          onPressed: onPressed,
          icon: Icon(uploaded ? Icons.sync : Icons.upload_file_outlined),
          label: Text(uploaded ? 'Re-upload' : 'Upload'),
        ),
      ],
    );
  }
}

class _ConnectedSummary extends StatelessWidget {
  const _ConnectedSummary({required this.result});

  final PersonalAgentSetupResult result;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      color: colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.personalAgentConnectedSectionTitle,
              style: textTheme.titleMedium?.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            DefaultTextStyle(
              style: textTheme.bodyMedium!.copyWith(
                color: colorScheme.onSurface,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.personalAgentSummaryContextId(result.contextId)),
                  Text(
                    l10n.personalAgentSummaryContextCreated(
                      '${result.contextCreated}',
                    ),
                  ),
                  Text(
                    l10n.personalAgentSummaryProfile(
                      result.profile.displayName,
                    ),
                  ),
                  Text(
                    l10n.personalAgentSummaryAgentCreated(
                      '${result.agentCreated}',
                    ),
                  ),
                  Text(
                    l10n.personalAgentSummaryMode(
                      modeToWire(result.profile.mode),
                    ),
                  ),
                  if (result.setupStatus != null)
                    Text(
                      l10n.personalAgentSummarySetupStatus(
                        '${result.setupStatus}',
                      ),
                    ),
                  if (result.offerAvailable != null)
                    Text(
                      l10n.personalAgentSummaryOfferAvailable(
                        '${result.offerAvailable}',
                      ),
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

class _StatusCard extends StatelessWidget {
  const _StatusCard({
    required this.isReady,
    required this.isSettingUp,
    required this.contextProvisioned,
  });

  final bool isReady;
  final bool isSettingUp;
  final bool contextProvisioned;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colorScheme = context.colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final title = isReady && contextProvisioned
        ? l10n.personalAgentStatusConnected
        : isReady
        ? l10n.personalAgentStatusContextRequired
        : isSettingUp
        ? l10n.personalAgentStatusSettingUp
        : l10n.personalAgentStatusNotConnected;
    final subtitle = isReady && contextProvisioned
        ? l10n.personalAgentStatusSubtitleConnected
        : l10n.personalAgentStatusSubtitleNotConnected;
    final icon = isReady && contextProvisioned
        ? Icons.check_circle
        : Icons.pending_outlined;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: colorScheme.primary),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(subtitle, style: textTheme.bodyMedium),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WhatToExpectCard extends StatelessWidget {
  const _WhatToExpectCard({required this.isReady});

  final bool isReady;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    if (isReady) {
      return const SizedBox.shrink();
    }

    final textTheme = Theme.of(context).textTheme;
    final colorScheme = context.colorScheme;

    Widget step(String value) => Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• '),
          Expanded(child: Text(value, style: textTheme.bodyMedium)),
        ],
      ),
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.personalAgentWhatHappensNext,
              style: textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            step(l10n.personalAgentStepCreateOffer),
            step(l10n.personalAgentStepFetchMnemonic),
            step(l10n.personalAgentStepAcceptOffer),
            step(l10n.personalAgentStepContactAppears),
          ],
        ),
      ),
    );
  }
}

/// First-time context onboarding flow. Shown when the MPX connection is
/// ready but the user has not yet uploaded their context file.
class _ContextSetupView extends StatefulWidget {
  const _ContextSetupView({
    required this.isUploading,
    required this.uploadError,
    required this.onUpload,
  });

  final bool isUploading;
  final String? uploadError;
  final Future<void> Function(String content) onUpload;

  @override
  State<_ContextSetupView> createState() => _ContextSetupViewState();
}

class _ContextSetupViewState extends State<_ContextSetupView> {
  String? _fileName;
  String? _fileContent;
  bool _uploadSucceeded = false;

  @override
  void didUpdateWidget(_ContextSetupView oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Detect transition: was uploading → no longer uploading with no error.
    if (oldWidget.isUploading &&
        !widget.isUploading &&
        widget.uploadError == null) {
      setState(() => _uploadSucceeded = true);
    }
    // Reset success flag if a new file is picked or an error appears.
    if (widget.uploadError != null && _uploadSucceeded) {
      setState(() => _uploadSucceeded = false);
    }
  }

  Future<void> _pickFile() async {
    // TODO (AB): should use filePickerPlatformProvider
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['txt'],
    );
    if (result == null || result.files.isEmpty) return;
    final file = result.files.first;
    final bytes = await file.readAsBytes();
    if (bytes.isEmpty) return;
    setState(() {
      _fileName = file.name;
      _fileContent = String.fromCharCodes(bytes);
      _uploadSucceeded = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = context.l10n;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // Header icon
        Center(
          child: Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.psychology_outlined,
              size: 36,
              color: colorScheme.onPrimaryContainer,
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Title
        Text(
          l10n.personalAgentContextSetupTitle,
          style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),

        // Description
        Text(
          l10n.personalAgentContextSetupDescription,
          style: textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 28),

        // What to include card
        DecoratedBox(
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
                  l10n.personalAgentContextWhatToIncludeTitle,
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                for (final item in [
                  l10n.personalAgentContextWhatToIncludeItem1,
                  l10n.personalAgentContextWhatToIncludeItem2,
                  l10n.personalAgentContextWhatToIncludeItem3,
                  l10n.personalAgentContextWhatToIncludeItem4,
                ])
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('• '),
                        Expanded(child: Text(item, style: textTheme.bodySmall)),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),

        // File picker area
        InkWell(
          onTap: widget.isUploading ? null : _pickFile,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              border: Border.all(
                color: _fileContent != null
                    ? colorScheme.primary
                    : colorScheme.outlineVariant,
                width: _fileContent != null ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(12),
              color: _fileContent != null
                  ? colorScheme.primaryContainer.withValues(alpha: 0.3)
                  : null,
            ),
            child: Column(
              children: [
                Icon(
                  _fileContent != null
                      ? Icons.check_circle_outline
                      : Icons.upload_file_outlined,
                  size: 32,
                  color: _fileContent != null
                      ? colorScheme.primary
                      : colorScheme.onSurfaceVariant,
                ),
                const SizedBox(height: 8),
                Text(
                  _fileContent != null
                      ? _fileName ?? l10n.personalAgentContextFileSelected
                      : l10n.personalAgentContextPickFile,
                  style: textTheme.bodyMedium?.copyWith(
                    color: _fileContent != null
                        ? colorScheme.primary
                        : colorScheme.onSurfaceVariant,
                    fontWeight: _fileContent != null ? FontWeight.w600 : null,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (_fileContent != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      l10n.personalAgentContextFileTapToChange,
                      style: textTheme.labelSmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Upload error
        if (widget.uploadError != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Text(
                  widget.uploadError!,
                  style: TextStyle(color: colorScheme.onErrorContainer),
                ),
              ),
            ),
          ),

        // Upload success
        if (_uploadSucceeded)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: colorScheme.primary,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _fileName != null
                            ? l10n.personalAgentContextUploadedFile(_fileName!)
                            : l10n.personalAgentContextUploadSuccess,
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

        // Upload button
        FilledButton.icon(
          style: FilledButton.styleFrom(
            disabledBackgroundColor: colorScheme.primary.withValues(
              alpha: 0.35,
            ),
            disabledForegroundColor: colorScheme.onPrimary,
          ),
          onPressed: widget.isUploading || _fileContent == null
              ? null
              : () async {
                  if (_fileContent != null) {
                    await widget.onUpload(_fileContent!);
                  }
                },
          icon: widget.isUploading
              ? SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: colorScheme.onPrimary,
                  ),
                )
              : const Icon(Icons.cloud_upload_outlined),
          label: Text(
            widget.isUploading
                ? l10n.personalAgentContextUploading
                : l10n.personalAgentContextUploadButton,
          ),
        ),
      ],
    );
  }
}
