import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:meeting_place_core/meeting_place_core.dart';

import '../../../../infrastructure/extensions/contact_card_extensions.dart';
import '../../application/services/contacts_service/contacts_service.dart';
import '../../infrastructure/extensions/build_context_extensions.dart';
import '../../infrastructure/providers/cache_manager_provider.dart';
import '../../navigation/routes/dashboard_routes.dart';
import '../painting/cached_base64_image.dart';
import '../themes/tokens/mc_radius.dart';
import '../widgets/images/default_profile_image.dart';
import 'profile_circle_avatar.dart';

class ConnectionSuccessBottomSheet extends ConsumerWidget {
  const ConnectionSuccessBottomSheet({super.key, required this.channel});

  final Channel channel;

  static void show({required BuildContext context, required Channel channel}) {
    showModalBottomSheet<void>(
      context: context,
      isDismissible: true,
      useSafeArea: true,
      builder: (context) => ConnectionSuccessBottomSheet(channel: channel),
      useRootNavigator: true,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final card = channel.otherPartyContactCard;
    final cacheManager = ref.read(cacheManagerProvider);
    final profilePic = card?.hasProfilePic ?? false
        ? CachedBase64Image(card!.profilePic, cacheManager: cacheManager)
        : defaultProfileImage;
    final l10n = context.l10n;
    final mc = context.mcColors;

    void startChatting() {
      final channelDid = channel.otherPartyPermanentChannelDid;
      if (channelDid == null) return;

      final contact = ref
          .read(contactsServiceProvider)
          .getContactByChannelDid(channelDid);
      if (contact == null) return;

      context.pop();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ChatRoute(contactId: contact.id).go(context);
      });
    }

    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setState) {
        return Stack(
          children: [
            Container(
              height: 180,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(McRadius.md),
                color: context.colorScheme.surfaceContainerLow,
                border: Border.all(color: mc.hairline),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: ProfileCircleAvatar(
                        radius: 40,
                        image: profilePic as ImageProvider<Object>,
                      ),
                    ),
                    if (card != null)
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SizedBox(
                          width: 180,
                          child: Text(
                            l10n.oobConnectedTo(card.firstName),
                            maxLines: 3,
                            style: context.textTheme.titleSmall?.copyWith(
                              color: mc.textPrimary,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 36,
              right: 25,
              child: ElevatedButton(
                onPressed: startChatting,
                child: Text(l10n.oobChatTo),
              ),
            ),
          ],
        );
      },
    );
  }
}
