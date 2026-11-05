import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:meeting_place_core/meeting_place_core.dart';

import '../../../application/services/community_offer_service/community_offer_service.dart';
import '../../../application/services/vtc_service/vtc_service.dart';
import '../../../infrastructure/extensions/build_context_extensions.dart';
import '../../widgets/onboarding_style/onboarding_style.dart';
import '../../widgets/qr/qr_code_view.dart';

/// An admin's join phrase for the community: a short phrase people enter
/// or scan in Meeting Place to find the community instead of its DID.
/// Shown only to an admin of the community.
class VtcJoinPhraseView extends HookConsumerWidget {
  const VtcJoinPhraseView({
    super.key,
    required this.communityDid,
    required this.communityName,
  });

  final String communityDid;
  final String communityName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final service = ref.read(communityOfferServiceProvider);
    final vtc = ref.read(vtcServiceProvider);
    final reload = useState(0);
    final busy = useState(false);
    final failure = useState<String?>(null);
    final load = useMemoized(
      () async => (
        isAdmin: await vtc.adminRoleCard(communityDid) != null,
        offer: await service.published(communityDid),
      ),
      [reload.value],
    );
    final loaded = useFuture(load);
    final data = loaded.data;
    if (data == null || !data.isAdmin) return const SizedBox.shrink();
    final offer = data.offer;

    Future<void> run(Future<void> Function() action) async {
      busy.value = true;
      failure.value = null;
      try {
        await action();
        reload.value++;
      } on Exception catch (error) {
        failure.value = l10n.vtcJoinPhraseFailure(switch (error) {
          CommunityPhraseTakenException() => 'taken',
          NotCommunityAdminException() => 'notAdmin',
          VtaNotLinkedException() => 'vtaMissing',
          _ => 'other',
        });
      } finally {
        busy.value = false;
      }
    }

    Future<void> publish() async {
      final phrase = await _askPhrase(context);
      if (phrase == null || phrase.isEmpty) return;
      await run(
        () => service.publish(
          communityDid,
          phrase: phrase,
          communityName: communityName,
        ),
      );
    }

    Future<void> withdraw(ConnectionOffer offer) async {
      if (await _confirmWithdraw(context, offer)) {
        await run(() => service.withdraw(communityDid));
      }
    }

    return GlassCard(
      key: const Key('vtc_join_phrase'),
      title: l10n.vtcJoinPhraseHeading,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 12,
        children: [
          if (offer == null)
            Text(
              l10n.vtcJoinPhraseIntro(communityName),
              style: onboardingNote(context),
            )
          else ...[
            SelectableText(
              offer.mnemonic,
              key: const Key('vtc_join_phrase_text'),
              textAlign: TextAlign.center,
              style: context.textTheme.titleMedium?.copyWith(
                color: Colors.white,
              ),
            ),
            Center(
              child: ColoredBox(
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: QrCodeView(data: offer.mnemonic, size: 160),
                ),
              ),
            ),
            Text(
              l10n.vtcJoinPhrasePublished(
                communityName,
                offer.mnemonic,
                _date(context, offer.expiresAt),
              ),
              style: onboardingNote(context),
            ),
            Text(
              l10n.vtcJoinPhraseVisibility(communityName),
              style: onboardingNote(context),
            ),
          ],
          if (failure.value case final message?)
            OnboardingMessage(message, isError: true),
          OnboardingButton(
            label: offer == null
                ? l10n.vtcJoinPhrasePublishAction
                : l10n.vtcJoinPhraseWithdrawAction,
            isOutlined: true,
            isLoading: busy.value,
            onPressed: offer == null ? publish : () => withdraw(offer),
          ),
        ],
      ),
    );
  }

  Future<String?> _askPhrase(BuildContext context) => showDialog<String>(
    context: context,
    builder: (context) => _PhraseDialog(communityName: communityName),
  );

  Future<bool> _confirmWithdraw(
    BuildContext context,
    ConnectionOffer offer,
  ) async {
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.vtcJoinPhraseWithdrawTitle(offer.mnemonic)),
        content: Text(
          l10n.vtcJoinPhraseWithdrawMessage(_date(context, offer.expiresAt)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.generalCancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: context.colorScheme.error,
              foregroundColor: Colors.white,
            ),
            child: Text(l10n.vtcJoinPhraseWithdrawAction),
          ),
        ],
      ),
    );
    return confirmed ?? false;
  }

  static String _date(BuildContext context, DateTime? at) => at == null
      ? ''
      : DateFormat.yMMMd(context.l10n.localeName).format(at.toLocal());
}

/// Asks an admin for the phrase to publish.
class _PhraseDialog extends HookWidget {
  const _PhraseDialog({required this.communityName});

  final String communityName;

  /// What Meeting Place accepts in a phrase, as on the find offer screen.
  static final _phraseCharacters = RegExp(r'[0-9!\-_a-zA-Z\s]');

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final field = useTextEditingController();
    void submit() => Navigator.of(context).pop(field.text.trim());
    return AlertDialog(
      title: Text(l10n.vtcJoinPhraseDialogTitle(communityName)),
      content: TextField(
        key: const Key('vtc_join_phrase_field'),
        controller: field,
        autofocus: true,
        inputFormatters: [FilteringTextInputFormatter.allow(_phraseCharacters)],
        decoration: InputDecoration(labelText: l10n.vtcJoinPhraseHint),
        onSubmitted: (_) => submit(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.generalCancel),
        ),
        ElevatedButton(
          onPressed: submit,
          child: Text(l10n.vtcJoinPhrasePublishAction),
        ),
      ],
    );
  }
}
