import 'package:flutter/material.dart';

import '../../../infrastructure/extensions/build_context_extensions.dart';
import '../../themes/app_custom_colors.dart';
import '../cards/credential_card.dart';
import '../loaders/linear_progress_indicator.dart' as custom_loader;
import 'credential/credential_detail_card.dart';
import 'credential/credential_detail_row.dart';

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

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 16),
          const Icon(
            Icons.search_off,
            size: 80,
            color: AppCustomColors.primaryBrand10,
          ),
          const SizedBox(height: 22),
          Text(
            context.l10n.noLivenessCredentialFound,
            style: textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 24),
          ZkpInfoBanner(message: context.l10n.livenessCheckDemoModeNote),
          const Spacer(),
          Row(
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
              const SizedBox(width: 12),
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
    required this.onDoLater,
    required this.onGenerateProof,
  });

  final VoidCallback onDoLater;
  final VoidCallback onGenerateProof;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 50),
          Icon(Icons.check_circle, size: 64, color: Colors.green.shade600),
          const SizedBox(height: 60),
          Text(
            context.l10n.mockLivenessCredentialGenerated,
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 24),
          CredentialCard(
            topLeftText: context.l10n.livenessCredential,
            bottomLeftText: context.l10n.verifiableCredential,
          ),
          const Spacer(),
          Row(
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

class VcDetailsStepView extends StatelessWidget {
  const VcDetailsStepView({
    super.key,
    required this.contactDid,
    required this.isGenerating,
    required this.onCancel,
    this.onBack,
    this.onGenerateProof,
  });

  final String contactDid;
  final bool isGenerating;
  final VoidCallback onCancel;
  final VoidCallback? onBack;
  final VoidCallback? onGenerateProof;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LivenessCredentialCard(contactDid: contactDid),
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
  const LivenessCredentialCard({super.key, required this.contactDid});

  final String contactDid;

  @override
  Widget build(BuildContext context) {
    return CredentialDetailCard(
      title: context.l10n.livenessCredential,
      subtitle: context.l10n.verified,
      details: [
        CredentialDetailRowData(
          label: context.l10n.issuedTo,
          value: contactDid,
        ),
        CredentialDetailRowData(
          label: context.l10n.types,
          value: '[VerifiableCredential, LivenessCredential]',
        ),
        CredentialDetailRowData(label: context.l10n.issuer, value: 'Affinidi'),
        CredentialDetailRowData(
          label: context.l10n.issuedOn,
          value: '17 April 2026', // TODO: Use real date
        ),
        CredentialDetailRowData(label: context.l10n.human, value: 'Yes'),
      ],
    );
  }
}
