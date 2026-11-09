import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:meeting_place_vtc/meeting_place_vtc.dart';

import '../../../application/services/identities_service/identities_service.dart';
import '../../../application/services/vtc_trust_service/vtc_trust_service.dart';
import '../../../infrastructure/extensions/build_context_extensions.dart';
import '../../widgets/onboarding_style/onboarding_style.dart';

/// How other members of the community find the member to vouch for them:
/// the name they see, and whether the community shows them the identity
/// the member joined with, instead of its administrators only. Read from
/// the community each time, never kept on the phone.
///
/// A card the member never named starts from the name of the identity
/// they joined with, which leaves the phone only once they save it.
class VtcFindableView extends HookConsumerWidget {
  const VtcFindableView({
    super.key,
    required this.communityDid,
    required this.communityName,
  });

  final String communityDid;
  final String communityName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final service = ref.read(vtcTrustServiceProvider);
    final identities = ref.watch(
      identitiesServiceProvider.select((state) => state.identities),
    );
    final card = useState<MyDirectoryCard?>(null);
    final nameField = useTextEditingController();
    final busy = useState(false);
    final saved = useState(false);
    final failure = useState<String?>(null);

    String messageOf(VtcTrustFailure reason) => switch (reason) {
      VtcTrustFailure.notAllowed => l10n.vtcFindableNotAllowed(communityName),
      VtcTrustFailure.nameRefused => l10n.vtcDirectoryNameRefused(
        communityName,
      ),
      _ => l10n.vtcFindableFailed,
    };

    useEffect(() {
      Future<void> load() async {
        try {
          final mine = await service.directoryCard(communityDid);
          final identityDid = await service.identityDid(communityDid);
          if (!context.mounted) return;
          final joinedAs = identities
              .where((identity) => identity.did == identityDid)
              .firstOrNull;
          nameField.text =
              mine.displayName ?? joinedAs?.card.displayName.trim() ?? '';
          card.value = mine;
        } on VtcTrustException catch (error) {
          if (context.mounted) failure.value = messageOf(error.failure);
        }
      }

      load();
      return null;
    }, [communityDid]);

    Future<void> run(Future<void> Function() action) async {
      busy.value = true;
      saved.value = false;
      failure.value = null;
      try {
        await action();
        card.value = await service.directoryCard(communityDid);
      } on VtcTrustException catch (error) {
        failure.value = messageOf(error.failure);
      } finally {
        busy.value = false;
      }
    }

    Future<void> saveName() => run(() async {
      await service.setDirectoryName(communityDid, name: nameField.text);
      saved.value = true;
    });

    Future<void> change(bool findable) =>
        run(() => service.setFindable(communityDid, findable: findable));

    final loaded = card.value;
    return GlassCard(
      key: const Key('vtc_findable'),
      title: l10n.vtcFindableHeading,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 12,
        children: [
          OnboardingTextField(
            key: const Key('vtc_directory_name'),
            controller: nameField,
            label: l10n.vtcDirectoryNameLabel(communityName),
            enabled: loaded != null && !busy.value,
            onSubmitted: (_) => saveName(),
          ),
          Text(
            saved.value
                ? l10n.vtcDirectoryNameSaved
                : l10n.vtcDirectoryNameNote(communityName),
            style: onboardingNote(context),
          ),
          OnboardingButton(
            key: const Key('vtc_directory_name_save'),
            label: l10n.vtcDirectoryNameSave,
            isOutlined: true,
            isLoading: busy.value,
            onPressed: loaded == null ? null : saveName,
          ),
          // A Row, not a SwitchListTile: the onboarding layout measures
          // intrinsic heights, which a ListTile misreports.
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.vtcFindableIntro(communityName),
                  style: onboardingNote(context),
                ),
              ),
              Switch.adaptive(
                key: const Key('vtc_findable_switch'),
                value: loaded?.isDidVisibleToMembers ?? false,
                onChanged: loaded == null || busy.value ? null : change,
                activeTrackColor: Colors.white,
                activeThumbColor: context.colorScheme.primary,
              ),
            ],
          ),
          if (failure.value case final message?)
            OnboardingMessage(message, isError: true),
        ],
      ),
    );
  }
}
