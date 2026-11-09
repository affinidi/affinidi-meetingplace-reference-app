import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../application/services/vtc_trust_service/vtc_trust_service.dart';
import '../../../infrastructure/extensions/build_context_extensions.dart';
import '../../widgets/onboarding_style/onboarding_style.dart';

/// Whether other members of the community can find the member to vouch for
/// them: the community shows the identity the member joined with to every
/// member, instead of its administrators only. Read from the community
/// each time, never kept on the phone.
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
    final findable = useState<bool?>(null);
    final busy = useState(false);
    final failure = useState<String?>(null);

    String messageOf(VtcTrustFailure reason) =>
        reason == VtcTrustFailure.notAllowed
        ? l10n.vtcFindableNotAllowed(communityName)
        : l10n.vtcFindableFailed;

    useEffect(() {
      service
          .isFindable(communityDid)
          .then((value) {
            if (context.mounted) findable.value = value;
          })
          .catchError((Object error) {
            if (context.mounted && error is VtcTrustException) {
              failure.value = messageOf(error.failure);
            }
          });
      return null;
    }, [communityDid]);

    Future<void> change(bool value) async {
      busy.value = true;
      failure.value = null;
      try {
        await service.setFindable(communityDid, findable: value);
        findable.value = value;
      } on VtcTrustException catch (error) {
        failure.value = messageOf(error.failure);
      } finally {
        busy.value = false;
      }
    }

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
                value: findable.value ?? false,
                onChanged: findable.value == null || busy.value ? null : change,
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
