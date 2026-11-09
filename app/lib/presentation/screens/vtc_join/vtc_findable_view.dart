import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:meeting_place_vtc/meeting_place_vtc.dart';

import '../../../application/services/identities_service/identities_service.dart';
import '../../../application/services/vtc_trust_service/vtc_trust_service.dart';
import '../../../infrastructure/extensions/build_context_extensions.dart';
import '../../widgets/onboarding_style/onboarding_style.dart';

/// How other members of the community find the member to vouch for them:
/// whether the community shows them the identity the member joined with,
/// instead of its administrators only, under that identity's name. Read
/// from the community each time, never kept on the phone.
///
/// The name is always the identity's own, never one typed here. It is sent
/// when the member lets others find them, and brought in step with the
/// identity each time this opens while they can be found.
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
    final identityName = useState('');
    final busy = useState(false);
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
          var mine = await service.directoryCard(communityDid);
          final identityDid = await service.identityDid(communityDid);
          final name =
              identities
                  .where((identity) => identity.did == identityDid)
                  .firstOrNull
                  ?.card
                  .displayName
                  .trim() ??
              '';
          if (mine.isDidVisibleToMembers &&
              name.isNotEmpty &&
              mine.displayName != name) {
            await service.setDirectoryName(communityDid, name: name);
            mine = await service.directoryCard(communityDid);
          }
          if (!context.mounted) return;
          identityName.value = name;
          card.value = mine;
        } on VtcTrustException catch (error) {
          if (context.mounted) failure.value = messageOf(error.failure);
        }
      }

      load();
      return null;
    }, [communityDid, identities]);

    Future<void> run(Future<void> Function() action) async {
      busy.value = true;
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

    Future<void> change(bool findable) => run(() async {
      final name = identityName.value;
      if (findable && name.isNotEmpty) {
        await service.setDirectoryName(communityDid, name: name);
      }
      await service.setFindable(communityDid, findable: findable);
    });

    final loaded = card.value;
    return GlassCard(
      key: const Key('vtc_findable'),
      title: l10n.vtcFindableHeading,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 12,
        children: [
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
          if (identityName.value case final name when name.isNotEmpty)
            Text(
              l10n.vtcDirectoryNameShown(communityName, name),
              key: const Key('vtc_directory_name'),
              style: onboardingNote(context),
            ),
          if (failure.value case final message?)
            OnboardingMessage(message, isError: true),
        ],
      ),
    );
  }
}
