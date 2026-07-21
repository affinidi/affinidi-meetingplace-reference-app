import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../application/services/contacts_service/contacts_service.dart';
import '../../../application/services/identities_service/identities_service.dart';
import '../../../infrastructure/extensions/build_context_extensions.dart';
import '../../../infrastructure/extensions/contact_card_extensions.dart';
import '../../../infrastructure/providers/cache_manager_provider.dart';
import '../profile_circle_avatar.dart';

/// Avatar placeholder shown full-screen behind a 1:1 video call when the
/// peer has no active video track (camera turned off mid-call, or the
/// video feed still initialising).
///
/// Displays the peer's profile picture (resolved from the contact identified
/// by [contactId]), falling back to a person icon when the contact has no
/// profile picture. Mirrors [ProfileCircleAvatar] usage in the self-view PiP
/// window so both sides render a consistent placeholder.
class VideoCallPeerPlaceholder extends ConsumerWidget {
  const VideoCallPeerPlaceholder({
    super.key,
    required this.contactId,
    this.showCurrentIdentity = false,
    this.diameter = _defaultDiameter,
  });

  final String contactId;
  final bool showCurrentIdentity;
  final double diameter;

  static const double _defaultDiameter = 192;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contactCard = ref.watch(
      contactsServiceProvider.select((s) => s.getContactById(contactId)?.card),
    );
    final identityCard = showCurrentIdentity
        ? ref.watch(
            identitiesServiceProvider.select(
              (s) => (s.currentIdentity ?? s.identities.firstOrNull)?.card,
            ),
          )
        : null;
    final card = identityCard?.hasProfilePic == true
        ? identityCard
        : contactCard;
    final image = card?.hasProfilePic == true
        ? card!.image(cacheManager: ref.read(cacheManagerProvider))
        : null;

    return Center(
      child: ProfileCircleAvatar(
        radius: diameter / 2,
        image: image,
        child: Icon(
          Icons.person,
          size: diameter / 2,
          color: context.colorScheme.onSurface,
        ),
      ),
    );
  }
}
