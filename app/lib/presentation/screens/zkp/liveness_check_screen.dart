import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../application/services/contacts_service/contacts_service.dart';
import '../../../infrastructure/extensions/build_context_extensions.dart';
import '../../widgets/zkp/liveness_check_widgets.dart';
import '../chat/chat_screen_controller.dart';
import '../chat/proof_flow_controller.dart';
import '../credentials/credentials_screen_controller.dart';

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

  @override
  void initState() {
    super.initState();
    _startSearch();
  }

  Future<void> _startSearch() async {
    await Future<void>.delayed(const Duration(seconds: 3));
    if (!mounted) return;

    final hasCredentials = ref
        .read(credentialsScreenControllerProvider)
        .hasCredentials;

    setState(() {
      _currentStep = hasCredentials ? _FlowStep.foundVC : _FlowStep.vcNotFound;
    });
  }

  Future<void> _handleGenerateCredential() async {
    setState(() => _currentStep = _FlowStep.generatingVC);

    await Future<void>.delayed(const Duration(seconds: 3));
    if (!mounted) return;

    ref.read(credentialsScreenControllerProvider.notifier).saveCredential();
    setState(() => _currentStep = _FlowStep.vcGenerated);
  }

  Future<void> _handleGenerateProof() async {
    setState(() => _isGenerating = true);

    final contactDid = ref
        .read(contactsServiceProvider)
        .getContactById(widget.contactId)
        ?.channelDid;

    await ref
        .read(proofFlowControllerProvider(widget.contactId).notifier)
        .generateAndSendProof(holderDid: contactDid);

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
    final contact = ref
        .watch(contactsServiceProvider)
        .getContactById(widget.contactId);
    final contactDid = contact?.channelDid ?? 'did:example:unknown';

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
      _FlowStep.foundVC => VcDetailsStepView(
        contactDid: contactDid,
        isGenerating: _isGenerating,
        onCancel: _pauseAndPop,
        onBack: _isGenerating ? null : _pauseAndPop,
        onGenerateProof: _isGenerating ? null : _handleGenerateProof,
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
