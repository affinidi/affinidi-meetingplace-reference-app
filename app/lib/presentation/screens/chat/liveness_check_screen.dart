import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../application/services/credential_service/liveness_errors.dart';
import '../../../infrastructure/extensions/build_context_extensions.dart';
import '../../widgets/zkp/liveness_check_widgets.dart';
import '../credentials/credential_details_screen.dart';
import 'liveness_check_screen_controller.dart';

class LivenessCheckScreen extends ConsumerStatefulWidget {
  const LivenessCheckScreen({required this.contactId, super.key});

  final String contactId;

  @override
  ConsumerState<LivenessCheckScreen> createState() =>
      _LivenessCheckScreenState();
}

class _LivenessCheckScreenState extends ConsumerState<LivenessCheckScreen> {
  static const _livenessThresholdErrorPrefix =
      'Liveness evidence did not meet threshold:';

  String _localizeLivenessError(String error) {
    if (error == LivenessCredentialSessionMissingException.message) {
      return context.l10n.livenessCredentialSessionMissing;
    }

    if (error.startsWith(_livenessThresholdErrorPrefix)) {
      return context.l10n.livenessEvidenceThresholdNotMet;
    }

    return context.l10n.error(error);
  }

  @override
  void initState() {
    super.initState();
    unawaited(
      ref
          .read(
            livenessCheckScreenControllerProvider(widget.contactId).notifier,
          )
          .initialize(),
    );
  }

  Future<void> _handleGenerateCredential() async {
    final error = await ref
        .read(livenessCheckScreenControllerProvider(widget.contactId).notifier)
        .generateCredential(context);
    if (!mounted || error == null) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(_localizeLivenessError(error))));
  }

  Future<void> _handleGenerateProof() async {
    final error = await ref
        .read(livenessCheckScreenControllerProvider(widget.contactId).notifier)
        .generateAndSendProof();

    if (!mounted) return;
    if (error == null) {
      Navigator.of(context).pop();
      return;
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(_localizeLivenessError(error))));
  }

  Future<void> _pauseAndPop() async {
    await ref
        .read(livenessCheckScreenControllerProvider(widget.contactId).notifier)
        .pauseHumanZkpRequestFlow();
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final controllerState = ref.watch(
      livenessCheckScreenControllerProvider(widget.contactId),
    );
    final credential = controllerState.credential;
    final currentStep = controllerState.currentStep;
    final isGenerating = controllerState.isGenerating;
    final proofIdentityId = controllerState.proofIdentityId;

    final String appBarTitle;
    final VoidCallback? onBack;

    switch (currentStep) {
      case LivenessCheckFlowStep.vcNotFound:
      case LivenessCheckFlowStep.generatingVC:
        appBarTitle = context.l10n.livenessCheckDemoMode;
        onBack = currentStep == LivenessCheckFlowStep.vcNotFound
            ? _pauseAndPop
            : null;
      default:
        appBarTitle = context.l10n.livenessCredentialRequest;
        onBack = isGenerating ? null : _pauseAndPop;
    }

    final body = switch (currentStep) {
      LivenessCheckFlowStep.searchingVC => const SearchingStepView(),
      LivenessCheckFlowStep.vcNotFound => VcNotFoundStepView(
        onCancel: _pauseAndPop,
        onGenerate: _handleGenerateCredential,
      ),
      LivenessCheckFlowStep.generatingVC => const GeneratingVcStepView(),
      LivenessCheckFlowStep.vcGenerated => VcGeneratedStepView(
        identityId: proofIdentityId,
        onDoLater: _pauseAndPop,
        onGenerateProof: _handleGenerateProof,
      ),
      LivenessCheckFlowStep.foundVC when credential != null =>
        VcDetailsStepView(
          credential: credential,
          isGenerating: isGenerating,
          onCancel: _pauseAndPop,
          onBack: isGenerating ? null : _pauseAndPop,
          onGenerateProof: isGenerating ? null : _handleGenerateProof,
          onCredentialTap: () {
            Navigator.of(context).push<void>(
              MaterialPageRoute<void>(
                builder: (context) => CredentialDetailsScreen(
                  identityId: credential.identityId,
                  allowDelete: false,
                ),
              ),
            );
          },
        ),
      LivenessCheckFlowStep.foundVC => VcNotFoundStepView(
        onCancel: _pauseAndPop,
        onGenerate: _handleGenerateCredential,
      ),
    };

    return Scaffold(
      appBar: AppBar(
        backgroundColor: context.colorScheme.primary,
        foregroundColor: Colors.white,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.bottomCenter,
              radius: 1,
              colors: [
                context.colorScheme.primary,
                const Color.fromARGB(159, 5, 19, 94),
              ],
            ),
          ),
        ),
        title: Text(
          appBarTitle,
          style: context.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        leading: onBack != null
            ? IconButton(icon: const Icon(Icons.arrow_back), onPressed: onBack)
            : null,
        automaticallyImplyLeading: onBack != null,
      ),
      body: body,
    );
  }
}
