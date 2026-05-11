import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:meeting_place_relationship/meeting_place_relationship.dart';

import '../../../infrastructure/providers/cache_manager_provider.dart';
import '../../../navigation/routes/dashboard_routes.dart';
import '../../painting/cached_base64_image.dart';
import '../../widgets/cards/r_card_header_card.dart';
import 'r_card_details_screen.dart' show RCardDetailsScreen;

/// Provider used to trigger the "return" animation when navigating back
/// from [RCardDetailsScreen].
final returningCardProvider = StateProvider<String?>((ref) => null);

class RCardsDeck extends ConsumerStatefulWidget {
  const RCardsDeck({
    super.key,
    required this.deckKey,
    required this.cards,
    required this.extractSubject,
  });

  final String deckKey;
  final List<RCard> cards;
  final RCardSubject? Function(String) extractSubject;

  @override
  ConsumerState<RCardsDeck> createState() => _RCardsDeckState();
}

class _RCardsDeckState extends ConsumerState<RCardsDeck>
    with TickerProviderStateMixin {
  static const _fadeAnimationDuration = Duration(milliseconds: 500);
  static const _slideAnimationDuration = Duration(milliseconds: 300);
  static const _initialAnimationStaggerInterval = 80;
  static const _slideStartDelay = Duration(milliseconds: 300);
  static const _returnAnimationCleanupDelay = Duration(milliseconds: 1000);
  static const _overlayOpacityPerCard = 0.2;
  static const _maxOverlayOpacity = 0.4;

  late List<AnimationController> _fadeControllers;
  late List<AnimationController> _slideControllers;
  late List<AnimationController> _overlayControllers;
  late AnimationController _initialSlideDownController;
  late List<Animation<double>> _fadeAnimations;
  late List<Animation<Offset>> _slideUpAnimations;
  late List<Animation<double>> _overlayAnimations;
  late Animation<Offset> _initialSlideDownAnimation;

  String? _lastReturningCard;
  int? _returningIndex;
  bool _hasPlayedInitialAnimation = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations(isInitialLoad: true);
  }

  void _initializeAnimations({bool isInitialLoad = false}) {
    _fadeControllers = List.generate(
      widget.cards.length,
      (index) =>
          AnimationController(duration: _fadeAnimationDuration, vsync: this),
    );

    _slideControllers = List.generate(
      widget.cards.length,
      (index) =>
          AnimationController(duration: _slideAnimationDuration, vsync: this),
    );

    _overlayControllers = List.generate(
      widget.cards.length,
      (index) =>
          AnimationController(duration: _fadeAnimationDuration, vsync: this),
    );

    _initialSlideDownController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
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

    _overlayAnimations = _overlayControllers.map((controller) {
      return Tween<double>(
        begin: 0.0,
        end: 0.8,
      ).animate(CurvedAnimation(parent: controller, curve: Curves.easeOut));
    }).toList();

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
          Duration(milliseconds: i * _initialAnimationStaggerInterval),
          () {
            if (mounted) {
              _fadeControllers[i].forward();
              _slideControllers[i].forward();
              _overlayControllers[i].forward();
            }
          },
        );
      } else {
        _fadeControllers[i].forward();
        _slideControllers[i].forward();
        _overlayControllers[i].forward();
      }
    }
  }

  void _handleReturningCard(String? returningCardId) {
    if (returningCardId == null || returningCardId == _lastReturningCard) {
      return;
    }

    _lastReturningCard = returningCardId;
    final returningIndex = widget.cards.indexWhere(
      (card) => card.subjectDid == returningCardId,
    );
    if (returningIndex == -1) return;

    setState(() => _returningIndex = returningIndex);

    for (var i = 0; i < _fadeControllers.length; i++) {
      _fadeControllers[i].reset();
      _slideControllers[i].reset();
      _overlayControllers[i].reset();

      if (i == returningIndex) {
        _fadeControllers[i].value = 0.0;
        _slideControllers[i].value = 1.0;
        _fadeControllers[i].forward();
        Future.delayed(_fadeAnimationDuration, () {
          if (mounted) {
            _overlayControllers[i].forward();
          }
        });
        continue;
      }

      _fadeControllers[i].forward();
      _overlayControllers[i].forward();

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
      if (!mounted) return;
      _lastReturningCard = null;
      setState(() => _returningIndex = null);
      ref.read(returningCardProvider.notifier).state = null;
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
    for (final controller in _overlayControllers) {
      controller.dispose();
    }
    _initialSlideDownController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(RCardsDeck oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.cards.length != widget.cards.length) {
      for (final controller in _fadeControllers) {
        controller.dispose();
      }
      for (final controller in _slideControllers) {
        controller.dispose();
      }
      for (final controller in _overlayControllers) {
        controller.dispose();
      }
      _initializeAnimations();
    }
  }

  @override
  Widget build(BuildContext context) {
    final cacheManager = ref.read(cacheManagerProvider);

    ref.listen<String?>(returningCardProvider, (previous, next) {
      if (next != null && next != previous) {
        _handleReturningCard(next);
      }
    });

    const cardHeight = RCardHeaderCard.height;
    const overlapOffset = 60.0;

    return SizedBox(
      height: cardHeight + (widget.cards.length - 1) * overlapOffset,
      child: SlideTransition(
        position: _initialSlideDownAnimation,
        child: Stack(
          children: [
            for (var i = widget.cards.length - 1; i >= 0; i--)
              Positioned(
                top: (widget.cards.length - 1 - i) * overlapOffset,
                left: 0,
                right: 0,
                child: _returningIndex != null && i == _returningIndex
                    ? FadeTransition(
                        opacity: _fadeAnimations[i],
                        child: _buildCardWithOverlay(
                          i,
                          widget.cards[i],
                          widget.extractSubject,
                          cacheManager,
                        ),
                      )
                    : FadeTransition(
                        opacity: _fadeAnimations[i],
                        child: _returningIndex != null && i < _returningIndex!
                            ? SlideTransition(
                                position: _slideUpAnimations[i],
                                child: _buildCardWithOverlay(
                                  i,
                                  widget.cards[i],
                                  widget.extractSubject,
                                  cacheManager,
                                ),
                              )
                            : _buildCardWithOverlay(
                                i,
                                widget.cards[i],
                                widget.extractSubject,
                                cacheManager,
                              ),
                      ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardWithOverlay(
    int index,
    RCard card,
    RCardSubject? Function(String) extractSubject,
    BaseCacheManager cacheManager,
  ) {
    final targetOverlayOpacity = index == 0
        ? 0.0
        : (index * _overlayOpacityPerCard).clamp(0.0, _maxOverlayOpacity);

    return _RCardItem(
      card: card,
      extractSubject: extractSubject,
      cacheManager: cacheManager,
      overlayOpacity: targetOverlayOpacity,
      overlayAnimation: _overlayAnimations[index],
    );
  }
}

class _RCardItem extends StatefulWidget {
  const _RCardItem({
    required this.card,
    required this.extractSubject,
    required this.cacheManager,
    required this.overlayOpacity,
    required this.overlayAnimation,
  });

  final RCard card;
  final RCardSubject? Function(String) extractSubject;
  final BaseCacheManager cacheManager;
  final double overlayOpacity;
  final Animation<double> overlayAnimation;

  @override
  State<_RCardItem> createState() => _RCardItemState();
}

class _RCardItemState extends State<_RCardItem>
    with SingleTickerProviderStateMixin {
  late final AnimationController _liftController;
  late final Animation<double> _liftAnimation;

  @override
  void initState() {
    super.initState();
    _liftController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _liftAnimation = Tween<double>(
      begin: 0.0,
      end: -20.0,
    ).animate(CurvedAnimation(parent: _liftController, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _liftController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final subject = widget.extractSubject(widget.card.vcBlob);
    final name = subject?.name.trim() ?? '';
    final displayName = name.isNotEmpty ? name : widget.card.subjectDid;
    final profilePic = subject?.profilePic?.trim();

    return AnimatedBuilder(
      animation: _liftAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _liftAnimation.value),
          child: child,
        );
      },
      child: Stack(
        children: [
          GestureDetector(
            onTap: () => RCardDetailsRoute(
              subjectDid: widget.card.subjectDid,
            ).push<void>(context),
            onLongPressStart: (_) => _liftController.forward(),
            onLongPressEnd: (_) => _liftController.reverse(),
            onLongPressCancel: () => _liftController.reverse(),
            child: Hero(
              tag: 'r_card_${widget.card.subjectDid}',
              child: RCardHeaderCard(
                name: displayName,
                avatarImage: profilePic == null || profilePic.isEmpty
                    ? null
                    : CachedBase64Image(
                        profilePic,
                        cacheManager: widget.cacheManager,
                      ),
              ),
            ),
          ),
          // Depth overlay for stacked cards behind the top card
          if (widget.overlayOpacity > 0)
            AnimatedBuilder(
              animation: widget.overlayAnimation,
              builder: (context, _) {
                return IgnorePointer(
                  child: Container(
                    height: RCardHeaderCard.height,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(
                        alpha:
                            widget.overlayAnimation.value *
                            widget.overlayOpacity,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
