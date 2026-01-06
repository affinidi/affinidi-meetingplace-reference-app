import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../../../domain/models/identity/identity.dart';
import '../../../infrastructure/extensions/build_context_extensions.dart';
import '../../../infrastructure/extensions/identities_extensions.dart';
import '../swipeable_cards.dart';
import 'identity_card.dart';
import 'identity_placeholder_card.dart';

class IdentityPicker extends HookWidget {
  const IdentityPicker({
    required super.key,
    required this.identities,
    this.onCreateIdentity,
    this.onDeleteIdentity,
    this.onFindOfferForIdentity,
    this.onEditIdentity,
    this.onPublishOfferForIdentity,
    required this.onSelectedIdentity,
    this.displayMode = false,
    this.swipeDirection = const AllowedSwipeDirection.symmetric(
      horizontal: true,
      vertical: false,
    ),
    this.initialCardIndex = -1,
    required this.cacheManager,
  });

  final List<Identity> identities;
  final void Function(Identity identity) onSelectedIdentity;
  final void Function()? onCreateIdentity;
  final void Function(Identity identity)? onDeleteIdentity;
  final void Function(Identity identity)? onFindOfferForIdentity;
  final void Function(Identity identity)? onEditIdentity;
  final void Function(Identity identity)? onPublishOfferForIdentity;
  final int initialCardIndex;
  final bool displayMode;
  final AllowedSwipeDirection swipeDirection;
  final BaseCacheManager cacheManager;

  @override
  Widget build(BuildContext context) {
    final cardSwiperController = CardSwiperController();

    useEffect(
      () {
        if (!context.mounted) return;

        if (initialCardIndex != -1) {
          Future.microtask(() {
            cardSwiperController.moveTo(initialCardIndex);
          });
        }

        return null;
      },
      [initialCardIndex],
    );

    if (identities.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 48.0, horizontal: 24.0),
        child: Center(
          child: Text(
            context.l10n.noIdentityDetected,
            style: context.textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final keyValue = '${(key as ValueKey).value}_deck_${identities.length}';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: SwipeableCards<Identity>(
        key: ValueKey(keyValue),
        controller: cardSwiperController,
        items: identities,
        maxHeight: displayMode ? 250 : 450,
        maxWidth: context.mediaQuery.size.width * 0.9,
        allowedSwipeDirection: swipeDirection,
        cardBuilder: (context, identity) {
          return identity.isPlaceholder
              ? IdentityPlaceholderCard(onCreateIdentity)
              : IdentityCard(
                  identity: identity,
                  displayMode: displayMode,
                  onDeleteIdentity: onDeleteIdentity,
                  onFindOfferForIdentity: onFindOfferForIdentity,
                  onEditIdentity: onEditIdentity,
                  onPublishOfferForIdentity: onPublishOfferForIdentity,
                  cacheManager: cacheManager,
                );
        },
        onCardChange: (index) {
          final identityToSelect = identities[index];
          if (identityToSelect.isPlaceholder) return;

          onSelectedIdentity(identityToSelect);
        },
        onSwipe: (prev, curr, direction) {
          if (direction != CardSwiperDirection.bottom) return;

          final identityToDelete = identities[prev];
          if (identityToDelete.isPrimary || identityToDelete.isPlaceholder) {
            return;
          }

          onDeleteIdentity?.call(identityToDelete);
        },
      ),
    );
  }
}
