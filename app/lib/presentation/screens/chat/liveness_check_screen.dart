import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../application/services/contacts_service/contacts_service.dart';
import '../../../application/services/credential_service/credential_service.dart';
import '../../../application/services/credential_service/credential_service_state.dart';
import '../../../domain/models/credentials/liveness_credential_record.dart';
import '../../../domain/models/identity/identity.dart';
import '../../../infrastructure/extensions/build_context_extensions.dart';
import '../../widgets/zkp/liveness_check_widgets.dart';
import 'chat_screen_controller.dart';
import 'proof_flow_controller.dart';

enum _FlowStep { searchingVC, vcNotFound, generatingVC, vcGenerated, foundVC }

class LivenessCheckScreen extends ConsumerStatefulWidget {
  const LivenessCheckScreen({required this.contactId, super.key});

  final String contactId;

  @override
  ConsumerState<LivenessCheckScreen> createState() =>
      _LivenessCheckScreenState();
}

class _LivenessCheckScreenState extends ConsumerState<LivenessCheckScreen> {
  _FlowStep _currentStep = _FlowStep.searchingVC;
  bool _isGenerating = false;
  Identity? _proofIdentity;

  @override
  void initState() {
    super.initState();
    _initProofContext();
  }

  Future<void> _initProofContext() async {
    final identity = await ref
        .read(contactsServiceProvider.notifier)
        .resolveIdentityForContact(widget.contactId);
    if (!mounted) return;

    setState(() => _proofIdentity = identity);
    await _startSearch();
  }

  LivenessCredentialRecord? get _identityCredential {
    final identity = _proofIdentity;
    if (identity == null) return null;
    return ref.watch(
      credentialServiceProvider.select(
        (state) => state.credentialFor(identity.id),
      ),
    );
  }

  Future<void> _startSearch() async {
    await Future<void>.delayed(const Duration(seconds: 3));
    if (!mounted) return;

    final identity = _proofIdentity;
    if (identity == null) {
      setState(() => _currentStep = _FlowStep.vcNotFound);
      return;
    }

    await ref.read(credentialServiceProvider.notifier).ensureInitialized();
    final hasCredential = ref
        .read(credentialServiceProvider)
        .hasCredentialFor(identity.id);

    setState(() {
      _currentStep = hasCredential ? _FlowStep.foundVC : _FlowStep.vcNotFound;
    });
  }

  Future<void> _handleGenerateCredential() async {
    final identity = _proofIdentity;
    if (identity == null || identity.did.isEmpty) return;

    setState(() => _currentStep = _FlowStep.generatingVC);

    await Future<void>.delayed(const Duration(seconds: 3));
    if (!mounted) return;

    await ref
        .read(credentialServiceProvider.notifier)
        .issueLivenessCredential(
          identityId: identity.id,
          holderDid: identity.did,
        );
    setState(() => _currentStep = _FlowStep.vcGenerated);
  }

  Future<void> _handleGenerateProof() async {
    setState(() => _isGenerating = true);

    await ref
        .read(proofFlowControllerProvider(widget.contactId).notifier)
        .generateAndSendProof();

    if (!mounted) return;
    Navigator.of(context).pop();
  }

  void _pauseAndPop() {
    ref
        .read(chatScreenControllerProvider(widget.contactId).notifier)
        .insertZkpPausedNotice();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final credential = _identityCredential;

    final String appBarTitle;
    final VoidCallback? onBack;

    switch (_currentStep) {
      case _FlowStep.vcNotFound:
      case _FlowStep.generatingVC:
        appBarTitle = context.l10n.livenessCheckDemoMode;
        onBack = _currentStep == _FlowStep.vcNotFound ? _pauseAndPop : null;
      default:
        appBarTitle = context.l10n.livenessCredentialRequest;
        onBack = _isGenerating ? null : _pauseAndPop;
    }

    final body = switch (_currentStep) {
      _FlowStep.searchingVC => const SearchingStepView(),
      _FlowStep.vcNotFound => VcNotFoundStepView(
        onCancel: _pauseAndPop,
        onGenerate: _handleGenerateCredential,
      ),
      _FlowStep.generatingVC => const GeneratingVcStepView(),
      _FlowStep.vcGenerated => VcGeneratedStepView(
        onDoLater: _pauseAndPop,
        onGenerateProof: _handleGenerateProof,
      ),
      _FlowStep.foundVC when credential != null => VcDetailsStepView(
        credential: credential,
        isGenerating: _isGenerating,
        onCancel: _pauseAndPop,
        onBack: _isGenerating ? null : _pauseAndPop,
        onGenerateProof: _isGenerating ? null : _handleGenerateProof,
      ),
      _FlowStep.foundVC => VcNotFoundStepView(
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
