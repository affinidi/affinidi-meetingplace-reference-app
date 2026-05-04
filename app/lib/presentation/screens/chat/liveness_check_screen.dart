import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../application/services/contacts_service/contacts_service.dart';
import '../../../infrastructure/extensions/build_context_extensions.dart';
import '../../widgets/cards/credential_card.dart';
import '../../widgets/loaders/circular_spinner.dart';
import '../credentials/credentials_screen_controller.dart';
import 'chat_screen_controller.dart';
import 'proof_flow_controller.dart';

class LivenessCheckScreen extends ConsumerStatefulWidget {
  const LivenessCheckScreen({
    required this.contactId,
    super.key,
  });

  final String contactId;

  @override
  ConsumerState<LivenessCheckScreen> createState() =>
      _LivenessCheckScreenState();
}

enum FlowStep {
  searchingVC,
  vcNotFound,
  generatingVC,
  vcGenerated,
  foundVC,
}

class _LivenessCheckScreenState extends ConsumerState<LivenessCheckScreen> {
  FlowStep _currentStep = FlowStep.searchingVC;
  bool _isGenerating = false;

  @override
  void initState() {
    super.initState();
    _startSearch();
  }

  Future<void> _startSearch() async {
    // Wait 3 seconds before checking for VC
    await Future<void>.delayed(const Duration(seconds: 3));
    
    if (!mounted) return;
    
    // Check if user has credentials
    final hasCredentials = ref.read(credentialsScreenControllerProvider).hasCredentials;
    
    setState(() {
      _currentStep = hasCredentials ? FlowStep.foundVC : FlowStep.vcNotFound;
    });
  }

  Future<void> _handleGenerateCredential() async {
    setState(() {
      _currentStep = FlowStep.generatingVC;
    });

    // Simulate credential generation
    await Future<void>.delayed(const Duration(seconds: 3));
    
    if (!mounted) return;

    // Save credential to Credentials tab
    ref.read(credentialsScreenControllerProvider.notifier).saveCredential();
    
    setState(() {
      _currentStep = FlowStep.vcGenerated;
    });
  }

  void _handleDoLater() {
    // Insert paused notice
    ref
        .read(chatScreenControllerProvider(widget.contactId).notifier)
        .insertZkpPausedNotice();
    
    Navigator.of(context).pop();
  }

  void _handleCancel() {
    // Insert paused notice
    ref
        .read(chatScreenControllerProvider(widget.contactId).notifier)
        .insertZkpPausedNotice();
    
    Navigator.of(context).pop();
  }

  void _handleBack() {
    // Insert paused notice
    ref
        .read(chatScreenControllerProvider(widget.contactId).notifier)
        .insertZkpPausedNotice();
    
    Navigator.of(context).pop();
  }

  Future<void> _handleGenerateProof() async {
    setState(() {
      _isGenerating = true;
    });

    final contact = ref.read(contactsServiceProvider).getContactById(widget.contactId);
    final contactDid = contact?.channelDid;

    final controller = ref.read(
      proofFlowControllerProvider(widget.contactId).notifier,
    );

    await controller.generateAndSendProof(holderDid: contactDid);

    if (!mounted) return;
    
    Navigator.of(context).pop();
  }
  PreferredSizeWidget _buildAppBar(BuildContext context, String title, VoidCallback? onBackPressed) {
    return AppBar(
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
        title,
        style: context.textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: onBackPressed,
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final contact = ref.watch(contactsServiceProvider).getContactById(widget.contactId);
    final contactDid = contact?.channelDid ?? 'did:example:unknown';

    if (_currentStep == FlowStep.searchingVC) {
      // Screen: Searching for VC
      return Scaffold(
        appBar: _buildAppBar(context, 'Liveness Credential Request', _handleBack),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(height: 50),
              CircularSpinner(size: 64, color: colorScheme.primary),
              const SizedBox(height: 60),
              Text(
                'Searching for Liveness Credential...',
                textAlign: TextAlign.center,
                style: textTheme.titleLarge?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_currentStep == FlowStep.vcNotFound) {
      // Screen: VC Not Found (Demo Mode)
      return Scaffold(
        appBar: _buildAppBar(context, 'Liveness Check (Demo Mode)', _handleBack),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 50),
              const Icon(
                Icons.search_off,
                size: 64,
                color: Colors.grey,
              ),
              const SizedBox(height: 60),
              const Text(
                'No Liveness Credential was found.\n\n'
                'To continue, a mock Liveness Credential will be generated locally. '
                'This credential is used to demonstrate how a Zero‑Knowledge Proof (ZKP) is derived.',
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.grey.shade700,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'This reference app runs in demo mode and does not perform a real liveness check.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _handleCancel,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                      child: Text(context.l10n.cancel),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _handleGenerateCredential,
                      child: Text(context.l10n.generateCredential),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }

    if (_currentStep == FlowStep.generatingVC) {
      // Screen: Generating VC
      return Scaffold(
        appBar: _buildAppBar(context, 'Liveness Check (Demo Mode)', null),  // Disabled during generation
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(height: 50),
                CircularSpinner(size: 64, color: colorScheme.primary),
                const SizedBox(height: 60),
                Text(
                  'Liveness Check in progress...',
                  textAlign: TextAlign.center,
                style: textTheme.titleLarge?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.grey.shade700,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'This is a simulated flow for development and demonstration purposes only.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              ],
            ),
          ),
        ),
      );
    }

    if (_currentStep == FlowStep.vcGenerated) {
      // Screen: VC Generated Successfully
      return Scaffold(
        appBar: _buildAppBar(context, 'Liveness Credential Request', _handleBack),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 50),
              Icon(
                Icons.check_circle,
                size: 64,
                color: Colors.green.shade600,
              ),
              const SizedBox(height: 60),
              const Text(
                'A mock Liveness Credential has been generated and securely stored under the Credentials tab.\n'
                'You can now continue to generate a Human Zero-Knowledge proof.',
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontSize: 16,
                ),
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
                      onPressed: _handleDoLater,
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: colorScheme.primary),
                      ),
                      child: const Text(
                        'Do later',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _handleGenerateProof,
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

    // Screen 4: VC Details
    return Scaffold(
      appBar: _buildAppBar(context, 'Liveness Credential Request', _isGenerating ? null : _handleBack),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(25.0),
                border: Border.all(
                  color: colorScheme.primary,
                  width: 1,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: const Alignment(-0.5, -1.3),
                        end: const Alignment(0.342, 2.2),
                        colors: [
                          colorScheme.primary,
                          colorScheme.primary.withValues(alpha: 0.7),
                        ],
                        stops: const [0.4, 1.075],
                      ),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(24),
                        topRight: Radius.circular(24),
                      ),
                    ),
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.verified_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Liveness Credential',
                                style: textTheme.titleMedium?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Verified',
                                style: textTheme.bodySmall?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Body
                  Container(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            children: [
                              _buildDetailRow(
                                'Issued to',
                                contactDid,
                              ),
                              Divider(
                                color: colorScheme.primary,
                                height: 16,
                              ),
                              _buildDetailRow(
                                'Types',
                                '[VerifiableCredential, LivenessCredential]',
                              ),
                              Divider(
                                color: colorScheme.primary,
                                height: 16,
                              ),
                              _buildDetailRow(
                                'Issuer',
                                'Affinidi',
                              ),
                              Divider(
                                color: colorScheme.primary,
                                height: 16,
                              ),
                              _buildDetailRow(
                                'Issued on',
                                '17 April 2026',
                              ),
                              Divider(
                                color: colorScheme.primary,
                                height: 16,
                              ),
                              _buildDetailRow(
                                'Human',
                                'Yes',
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            if (_isGenerating) ...[
              const LinearProgressIndicator(),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  context.l10n.generatingZeroKnowledgeProof,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isGenerating ? null : _handleCancel,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.red.withValues(alpha: 0.5),
                      disabledForegroundColor: Colors.white.withValues(alpha: 0.5),
                    ),
                    child: Text(context.l10n.cancel),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isGenerating ? null : _handleGenerateProof,
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

  Widget _buildDetailRow(String label, String value) {
    return _DetailRow(label: label, value: value);
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
