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
import '../widgets/images/default_profile_image.dart';

class ConnectionSuccessBottomSheet extends ConsumerWidget {
  const ConnectionSuccessBottomSheet({
    super.key,
    required this.channel,
  });

  final Channel channel;

  static void show({
    required BuildContext context,
    required Channel channel,
  }) {
    showModalBottomSheet<void>(
      backgroundColor: Colors.black,
      context: context,
      isDismissible: true,
      builder: (context) => ConnectionSuccessBottomSheet(
        channel: channel,
      ),
      useRootNavigator: true,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final card = channel.otherPartyContactCard;
    final cacheManager = ref.read(cacheManagerProvider);
    final profilePic = card?.hasProfilePic ?? false
        ? CachedBase64Image(
            card!.profilePic,
            cacheManager: cacheManager,
          )
        : defaultProfileImage;
    final l10n = context.l10n;

    void startChatting() {
      final channelDid = channel.otherPartyPermanentChannelDid;
      if (channelDid == null) return;

      final contact =
          ref.read(contactsServiceProvider).getContactByChannelDid(channelDid);
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
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                gradient: RadialGradient(
                  center: Alignment.bottomCenter,
                  radius: 1.3,
                  colors: [
                    Color.fromARGB(249, 3, 104, 192),
                    Color.fromARGB(120, 5, 19, 94),
                  ],
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: CircleAvatar(
                        maxRadius: 40,
                        backgroundImage: profilePic as ImageProvider<Object>,
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
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.white,
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
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(249, 3, 104, 192),
                ),
                child: Text(
                  l10n.oobChatTo,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
