import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';

/// A reusable widget that implements a swipeable
/// card interface using FlipCardSwiper
class SwipeableCards<T> extends StatelessWidget {
  const SwipeableCards({
    super.key,
    required this.items,
    required this.cardBuilder,
    this.onCardChange,
    this.onSwipe,
    this.maxWidth = 450,
    this.maxHeight = 250,
    this.allowedSwipeDirection = const AllowedSwipeDirection.symmetric(
      horizontal: true,
      vertical: false,
    ),
    this.initialIndex,
    this.controller,
  });

  /// List of data items to be displayed as cards.
  final List<T> items;

  /// Builder function to create each card based on the item data.
  final Widget Function(
    BuildContext context,
    T item,
  )
  cardBuilder;

  /// Called when the top card changes.
  final void Function(int newIndex)? onCardChange;

  /// Called when a card is swiped.
  final void Function(
    int previousIndex,
    int currentIndex,
    CardSwiperDirection direction,
  )?
  onSwipe;

  /// Maximum width of each card.
  final double? maxWidth;

  /// Maximum height of each card.
  final double? maxHeight;

  /// Allowed swipe directions for the cards.
  final AllowedSwipeDirection allowedSwipeDirection;

  final int? initialIndex;

  /// External controller for programmatic control
  final CardSwiperController? controller;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: maxWidth,
      height: maxHeight,
      child: CardSwiper(
        padding: const EdgeInsets.all(10),
        initialIndex: initialIndex ?? 0,
        controller: controller ?? CardSwiperController(),
        onSwipe: (previousIndex, currentIndex, direction) async {
          if (onSwipe != null && currentIndex != null) {
            onSwipe?.call(previousIndex, currentIndex, direction);
          }

          if (onCardChange != null && currentIndex != null) {
            onCardChange?.call(currentIndex);
          }
          return true;
        },
        allowedSwipeDirection: allowedSwipeDirection,
        cardsCount: items.length,
        numberOfCardsDisplayed: items.length > 1 ? 2 : items.length,
        cardBuilder: (context, index, percentThresholdX, percentThresholdY) =>
            cardBuilder(context, items[index]),
      ),
    );
  }
}
