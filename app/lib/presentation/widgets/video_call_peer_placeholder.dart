import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/services/contacts_service/contacts_service.dart';
import '../../infrastructure/extensions/build_context_extensions.dart';
import '../../infrastructure/extensions/contact_card_extensions.dart';
import '../../infrastructure/providers/cache_manager_provider.dart';
import 'profile_circle_avatar.dart';

/// Avatar placeholder shown full-screen behind a 1:1 video call when the
/// remote peer has no active video track (camera turned off mid-call, or the
/// video feed still initialising).
///
/// Displays the peer's profile picture (resolved from the contact identified
/// by [contactId]), falling back to a person icon when the contact has no
/// profile picture. Mirrors [ProfileCircleAvatar] usage in the self-view PiP
/// window so both sides render a consistent placeholder.
class VideoCallPeerPlaceholder extends ConsumerWidget {
  const VideoCallPeerPlaceholder({super.key, required this.contactId});

  final String contactId;

  static const double _diameter = 192;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final card = ref.watch(
      contactsServiceProvider.select((s) => s.getContactById(contactId)?.card),
    );
    final image = card?.hasProfilePic == true
        ? card!.image(cacheManager: ref.read(cacheManagerProvider))
        : null;

    return Center(
      child: ProfileCircleAvatar(
        radius: _diameter / 2,
        image: image,
        child: Icon(
          Icons.person,
          size: _diameter / 2,
          color: context.colorScheme.onSurface,
        ),
      ),
    );
  }
}
