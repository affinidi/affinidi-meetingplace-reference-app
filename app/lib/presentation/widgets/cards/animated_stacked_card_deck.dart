import 'package:flutter/material.dart';

/// A reusable animated stacked card deck widget that displays multiple cards
/// in an overlapping stack layout with sophisticated animations.
///
/// Features:
/// - Smooth fade-in animations for each card
/// - Staggered entry animations
/// - Overlay depth effect for stacked cards
/// - Slide transition on initial load
/// - Optional returning card animation (when navigating back)
/// - Customizable card builder and animation parameters
class AnimatedStackedCardDeck<T> extends StatefulWidget {
  const AnimatedStackedCardDeck({
    super.key,
    required this.items,
    required this.cardBuilder,
    this.cardHeight = 120.0,
    this.overlapOffset = 60.0,
    this.fadeAnimationDuration = const Duration(milliseconds: 500),
    this.slideAnimationDuration = const Duration(milliseconds: 300),
    this.initialAnimationStaggerInterval = 80,
    this.returningIndex,
    this.onReturningAnimationComplete,
  });

  /// List of items to display as stacked cards
  final List<T> items;

  /// Builder function that creates a card widget for each item.
  /// Called with the context, the item, its index, and a fade animation.
  final Widget Function(BuildContext, T, int, Animation<double>) cardBuilder;

  /// Height of each card in the stack
  final double cardHeight;

  /// Vertical offset between stacked cards
  final double overlapOffset;

  /// Duration of the fade animation for each card
  final Duration fadeAnimationDuration;

  /// Duration of the slide animation (for returning cards)
  final Duration slideAnimationDuration;

  /// Stagger interval between card animations in milliseconds
  final int initialAnimationStaggerInterval;

  /// Index of the card that is returning from navigation
  final int? returningIndex;

  /// Callback when returning animation completes
  final VoidCallback? onReturningAnimationComplete;

  @override
  State<AnimatedStackedCardDeck<T>> createState() =>
      _AnimatedStackedCardDeckState<T>();
}

class _AnimatedStackedCardDeckState<T> extends State<AnimatedStackedCardDeck<T>>
    with TickerProviderStateMixin {
  static const _initialSlideAnimationDuration = Duration(milliseconds: 600);
  static const _slideStartDelay = Duration(milliseconds: 300);
  static const _returnAnimationCleanupDelay = Duration(milliseconds: 1000);
  static const _overlayOpacityPerCard = 0.2;
  static const _maxOverlayOpacity = 0.4;

  late List<AnimationController> _fadeControllers;
  late List<AnimationController> _slideControllers;
  late List<Animation<double>> _fadeAnimations;
  late List<Animation<Offset>> _slideUpAnimations;
  late List<Animation<double>> _overlayAnimations;
  late AnimationController _initialSlideDownController;
  late Animation<Offset> _initialSlideDownAnimation;
  bool _hasPlayedInitialAnimation = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations(isInitialLoad: true);
  }

  void _initializeAnimations({bool isInitialLoad = false}) {
    _fadeControllers = List.generate(
      widget.items.length,
      (index) => AnimationController(
        duration: widget.fadeAnimationDuration,
        vsync: this,
      ),
    );

    _slideControllers = List.generate(
      widget.items.length,
      (index) => AnimationController(
        duration: widget.slideAnimationDuration,
        vsync: this,
      ),
    );

    _fadeAnimations = _fadeControllers.map((controller) {
      return Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(parent: controller, curve: Curves.easeOut));
    }).toList();

    _slideUpAnimations = _slideControllers.map((controller) {
      return Tween<Offset>(
        begin: const Offset(0, 2),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: controller, curve: Curves.easeOut));
    }).toList();

    _overlayAnimations = _fadeControllers.map((controller) {
      return Tween<double>(
        begin: 0.0,
        end: 0.8,
      ).animate(CurvedAnimation(parent: controller, curve: Curves.easeOut));
    }).toList();

    _initialSlideDownController = AnimationController(
      duration: _initialSlideAnimationDuration,
      vsync: this,
    );

    _initialSlideDownAnimation =
        Tween<Offset>(begin: const Offset(0, -0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _initialSlideDownController,
            curve: Curves.easeOut,
          ),
        );

    if (isInitialLoad && !_hasPlayedInitialAnimation) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _initialSlideDownController.forward();
          _hasPlayedInitialAnimation = true;
        }
      });
    } else if (_hasPlayedInitialAnimation) {
      _initialSlideDownController.value = 1.0;
    }

    for (var i = 0; i < _fadeControllers.length; i++) {
      if (isInitialLoad) {
        Future.delayed(
          Duration(milliseconds: i * widget.initialAnimationStaggerInterval),
          () {
            if (mounted) {
              _fadeControllers[i].forward();
              _slideControllers[i].forward();
            }
          },
        );
      } else {
        _fadeControllers[i].forward();
        _slideControllers[i].forward();
      }
    }
  }

  void _handleReturningCard(int returningIndex) {
    for (var i = 0; i < _fadeControllers.length; i++) {
      _fadeControllers[i].reset();
      _slideControllers[i].reset();

      if (i == returningIndex) {
        _fadeControllers[i].value = 0.0;
        _slideControllers[i].value = 1.0;
        _fadeControllers[i].forward();
        continue;
      }

      _fadeControllers[i].forward();

      if (i >= returningIndex) {
        _slideControllers[i].value = 1.0;
      }
    }

    Future.delayed(_slideStartDelay, () {
      if (mounted) {
        for (var j = 0; j < returningIndex; j++) {
          _slideControllers[j].forward();
        }
      }
    });

    Future.delayed(_returnAnimationCleanupDelay, () {
      if (mounted) {
        widget.onReturningAnimationComplete?.call();
      }
    });
  }

  @override
  void dispose() {
    for (final controller in _fadeControllers) {
      controller.dispose();
    }
    for (final controller in _slideControllers) {
      controller.dispose();
    }
    _initialSlideDownController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(AnimatedStackedCardDeck<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.items.length != widget.items.length) {
      for (final controller in _fadeControllers) {
        controller.dispose();
      }
      for (final controller in _slideControllers) {
        controller.dispose();
      }
      _initialSlideDownController.dispose();
      _initializeAnimations();
    } else if (widget.returningIndex != null &&
        oldWidget.returningIndex != widget.returningIndex) {
      _handleReturningCard(widget.returningIndex!);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) {
      return const SizedBox.shrink();
    }

    final totalHeight =
        widget.cardHeight + (widget.items.length - 1) * widget.overlapOffset;

    return SizedBox(
      height: totalHeight,
      child: SlideTransition(
        position: _initialSlideDownAnimation,
        child: Stack(
          children: [
            for (var i = widget.items.length - 1; i >= 0; i--)
              Positioned(
                top: (widget.items.length - 1 - i) * widget.overlapOffset,
                left: 0,
                right: 0,
                child:
                    widget.returningIndex != null && i == widget.returningIndex
                    ? FadeTransition(
                        opacity: _fadeAnimations[i],
                        child: _buildCardWithOverlay(i),
                      )
                    : FadeTransition(
                        opacity: _fadeAnimations[i],
                        child:
                            widget.returningIndex != null &&
                                i < widget.returningIndex!
                            ? SlideTransition(
                                position: _slideUpAnimations[i],
                                child: _buildCardWithOverlay(i),
                              )
                            : _buildCardWithOverlay(i),
                      ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardWithOverlay(int index) {
    return Stack(
      children: [
        // Card
        widget.cardBuilder(
          context,
          widget.items[index],
          index,
          _fadeAnimations[index],
        ),
        // Depth overlay for stacked cards
        if (index != 0)
          AnimatedBuilder(
            animation: _overlayAnimations[index],
            builder: (context, _) {
              final overlayOpacity = (index * _overlayOpacityPerCard).clamp(
                0.0,
                _maxOverlayOpacity,
              );
              return IgnorePointer(
                child: Container(
                  height: widget.cardHeight,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(
                      alpha: _overlayAnimations[index].value * overlayOpacity,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              );
            },
          ),
      ],
    );
  }
}
