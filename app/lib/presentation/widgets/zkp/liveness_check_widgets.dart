import 'package:flutter/material.dart';

import '../../../infrastructure/extensions/box_constraints_extensions.dart';
import '../../../infrastructure/extensions/build_context_extensions.dart';
import '../../screens/chat/liveness_credential_view_data.dart';
import '../../screens/credentials/credential_details_screen.dart';
import '../../themes/app_custom_colors.dart';
import '../cards/credential_card.dart';
import '../credentials/liveness_credential_details_table.dart';
import '../loaders/linear_progress_indicator.dart' as custom_loader;
import 'credential/credential_detail_card.dart';

/// Branded circular progress indicator.
class ZkpLoader extends StatelessWidget {
  const ZkpLoader({super.key, this.size = 64});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: 8,
        color: Theme.of(context).colorScheme.primary,
        backgroundColor: AppCustomColors.primaryBrand10,
      ),
    );
  }
}

/// Info banner with icon and message.
class ZkpInfoBanner extends StatelessWidget {
  const ZkpInfoBanner({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info,
            color: AppCustomColors.secondaryBrand90,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: AppCustomColors.secondaryBrand90,
                fontWeight: FontWeight.w400,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SearchingStepView extends StatelessWidget {
  const SearchingStepView({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const SizedBox(height: 50),
          const ZkpLoader(),
          const SizedBox(height: 40),
          Text(
            context.l10n.searchingForLivenessCredential,
            textAlign: TextAlign.center,
            style: textTheme.bodyLarge?.copyWith(color: colorScheme.onSurface),
          ),
        ],
      ),
    );
  }
}

class VcNotFoundStepView extends StatelessWidget {
  const VcNotFoundStepView({
    super.key,
    required this.onCancel,
    required this.onGenerate,
  });

  final VoidCallback onCancel;
  final VoidCallback onGenerate;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 16),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final isCompactScreen = constraints.isCompactScreen;
                        final text = Text(
                          context.l10n.noLivenessCredentialFound,
                          style: textTheme.bodyLarge?.copyWith(
                            color: colorScheme.onSurface,
                            fontWeight: FontWeight.w400,
                          ),
                        );

                        return Flex(
                          spacing: 22,
                          direction: isCompactScreen
                              ? Axis.vertical
                              : Axis.horizontal,
                          crossAxisAlignment: isCompactScreen
                              ? CrossAxisAlignment.stretch
                              : CrossAxisAlignment.start,
                          children: [
                            const Align(
                              alignment: Alignment.topCenter,
                              child: Icon(
                                Icons.search_off,
                                size: 80,
                                color: AppCustomColors.primaryBrand10,
                              ),
                            ),
                            isCompactScreen ? text : Expanded(child: text),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    ZkpInfoBanner(
                      message: context.l10n.livenessCheckDemoModeNote,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              spacing: 12,
              children: [
                Expanded(
                  flex: 1,
                  child: SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      onPressed: onCancel,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                      child: Text(
                        context.l10n.cancel,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      onPressed: onGenerate,
                      child: Text(
                        context.l10n.generateCredential,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class GeneratingVcStepView extends StatelessWidget {
  const GeneratingVcStepView({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(height: 50),
            const ZkpLoader(size: 72),
            const SizedBox(height: 60),
            Text(
              context.l10n.livenessCheckInProgress,
              textAlign: TextAlign.center,
              style: textTheme.titleLarge?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            ZkpInfoBanner(message: context.l10n.livenessCheckSimulatedFlow),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}

class VcGeneratedStepView extends StatelessWidget {
  const VcGeneratedStepView({
    super.key,
    required this.identityId,
    required this.onDoLater,
    required this.onGenerateProof,
  });

  final String? identityId;
  final VoidCallback onDoLater;
  final VoidCallback onGenerateProof;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          spacing: 24,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 20),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final isCompactScreen = constraints.isCompactScreen;
                        final description = Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          spacing: 16,
                          children: [
                            Text(
                              context.l10n.mockLivenessCredentialGenerated,
                              style: const TextStyle(fontSize: 16),
                            ),
                            Text(
                              context.l10n.mockLivenessCredentialNext,
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        );

                        return Flex(
                          spacing: 22,
                          direction: isCompactScreen
                              ? Axis.vertical
                              : Axis.horizontal,
                          crossAxisAlignment: isCompactScreen
                              ? CrossAxisAlignment.stretch
                              : CrossAxisAlignment.start,
                          children: [
                            const Align(
                              alignment: Alignment.topCenter,
                              child: Icon(
                                Icons.check_circle,
                                size: 80,
                                color: AppCustomColors.utilitySuccess100,
                              ),
                            ),
                            isCompactScreen
                                ? description
                                : Expanded(child: description),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 32),
                    CredentialCard(
                      topLeftText: context.l10n.livenessCredential,
                      bottomLeftText: context.l10n.verifiableCredential,
                      onTap: identityId == null
                          ? null
                          : () {
                              Navigator.of(context).push<void>(
                                MaterialPageRoute<void>(
                                  builder: (context) => CredentialDetailsScreen(
                                    identityId: identityId!,
                                    allowDelete: false,
                                  ),
                                ),
                              );
                            },
                    ),
                  ],
                ),
              ),
            ),

            Row(
              spacing: 12,
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onDoLater,
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: colorScheme.primary),
                    ),
                    child: Text(
                      context.l10n.doLater,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onGenerateProof,
                    child: Text(context.l10n.generateProof),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class VcDetailsStepView extends StatelessWidget {
  const VcDetailsStepView({
    super.key,
    required this.credential,
    required this.isGenerating,
    required this.onCancel,
    this.onBack,
    this.onGenerateProof,
    this.onCredentialTap,
  });

  final LivenessCredentialViewData credential;
  final bool isGenerating;
  final VoidCallback onCancel;
  final VoidCallback? onBack;
  final VoidCallback? onGenerateProof;
  final VoidCallback? onCredentialTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LivenessCredentialCard(
            credential: credential,
            onTap: onCredentialTap,
          ),
          const Spacer(),
          if (isGenerating) ...[
            custom_loader.LinearProgressIndicator(),
            const SizedBox(height: 16),
            Center(
              child: Text(
                context.l10n.generatingZeroKnowledgeProof,
                style: const TextStyle(fontSize: 14, color: Colors.black87),
              ),
            ),
            const SizedBox(height: 16),
          ],
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: isGenerating ? null : onCancel,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.red.withValues(alpha: 0.5),
                    disabledForegroundColor: Colors.white.withValues(
                      alpha: 0.5,
                    ),
                  ),
                  child: Text(context.l10n.cancel),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: onGenerateProof,
                  child: Text(context.l10n.generateProof),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class LivenessCredentialCard extends StatelessWidget {
  const LivenessCredentialCard({
    super.key,
    required this.credential,
    this.onTap,
  });

  final LivenessCredentialViewData credential;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return CredentialDetailCard(
      title: context.l10n.livenessCredential,
      subtitle: context.l10n.verified,
      onTap: onTap,
      body: LivenessCredentialDetailsTable(
        record: credential,
        lightTheme: false,
      ),
    );
  }
}
