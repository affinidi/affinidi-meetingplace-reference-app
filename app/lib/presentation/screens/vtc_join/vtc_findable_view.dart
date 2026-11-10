import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../application/services/vtc_trust_service/vtc_trust_service.dart';
import '../../../infrastructure/extensions/build_context_extensions.dart';
import '../../themes/tokens/mc_spacing.dart';
import '../../widgets/onboarding_style/onboarding_style.dart';
import 'vtc_findable_controller.dart';

const _syncingSize = 16.0;

/// How other members of the community find the member to vouch for them:
/// whether the community shows them the identity the member joined with,
/// instead of its administrators only, under that identity's name. Kept
/// while the app runs, and read from the community again each time this
/// opens, while the kept answer shows.
///
/// The name and picture are always the identity's own, never ones chosen
/// here. They are sent when the member lets others find them; while they
/// can be found, the name is brought in step with the identity each time
/// this opens, and a picture added to a card without one.
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
    final controller = vtcFindableControllerProvider(communityDid);
    final findable = ref.watch(controller);
    final syncing = useState<Future<void>?>(null);
    useEffect(() {
      // Not while building: syncing changes what is shown.
      Future.microtask(
        () => syncing.value = ref.read(controller.notifier).sync(),
      );
      return null;
    }, [communityDid]);
    final isSyncing =
        useFuture(syncing.value).connectionState == ConnectionState.waiting;
    final busy = useState(false);
    final failure = useState<String?>(null);

    String messageOf(VtcTrustFailure reason) => switch (reason) {
      VtcTrustFailure.notAllowed => l10n.vtcFindableNotAllowed(communityName),
      VtcTrustFailure.nameRefused => l10n.vtcDirectoryNameRefused(
        communityName,
      ),
      _ => l10n.vtcFindableFailed,
    };

    Future<void> change(bool value) async {
      busy.value = true;
      failure.value = null;
      try {
        await ref.read(controller.notifier).setFindable(value);
      } on VtcTrustException catch (error) {
        failure.value = messageOf(error.failure);
      } finally {
        if (context.mounted) busy.value = false;
      }
    }

    final loaded = findable.value?.card;
    final message =
        failure.value ??
        switch (findable.error) {
          final VtcTrustException error when !findable.hasValue => messageOf(
            error.failure,
          ),
          _ => null,
        };
    return GlassCard(
      key: const Key('vtc_findable'),
      title: l10n.vtcFindableHeading,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: McSpacing.s3,
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
              // Over the kept answer, while the community is asked again.
              if (isSyncing && loaded != null)
                const SizedBox.square(
                  key: Key('vtc_findable_syncing'),
                  dimension: _syncingSize,
                  child: CircularProgressIndicator.adaptive(strokeWidth: 2),
                ),
              Switch.adaptive(
                key: const Key('vtc_findable_switch'),
                value: loaded?.isFindable ?? false,
                onChanged: loaded == null || busy.value ? null : change,
              ),
            ],
          ),
          if (message case final message?)
            OnboardingMessage(message, isError: true),
        ],
      ),
    );
  }
}
