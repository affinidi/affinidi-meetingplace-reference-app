import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:meeting_place_personal_agent/meeting_place_personal_agent.dart';

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
    final errorMessage = ref.watch(
      provider.select((state) => state.errorMessage),
    );
    final setupResult = ref.watch(
      provider.select((state) => state.setupResult),
    );

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
                  _StatusCard(isReady: isReady, isSettingUp: isSettingUp),
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
  const _StatusCard({required this.isReady, required this.isSettingUp});

  final bool isReady;
  final bool isSettingUp;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colorScheme = context.colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final title = isReady
        ? l10n.personalAgentStatusConnected
        : isSettingUp
        ? l10n.personalAgentStatusSettingUp
        : l10n.personalAgentStatusNotConnected;
    final subtitle = isReady
        ? l10n.personalAgentStatusSubtitleConnected
        : l10n.personalAgentStatusSubtitleNotConnected;
    final icon = isReady ? Icons.check_circle : Icons.pending_outlined;

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
