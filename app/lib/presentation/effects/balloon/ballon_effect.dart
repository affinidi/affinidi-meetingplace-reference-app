import 'dart:math';

import 'package:flutter/material.dart';

import '../screen_effect.dart';

class BalloonEffect extends StatefulWidget {
  const BalloonEffect({super.key, required this.size, this.onComplete});

  final Size size;
  final VoidCallback? onComplete;

  @override
  State<BalloonEffect> createState() => _BalloonEffectState();
}

class _BalloonEffectState extends State<BalloonEffect>
    with TickerProviderStateMixin {
  late final List<_BalloonController> _balloonControllers;
  final random = Random();
  bool _isPlaying = false;
  final effect = ScreenEffect.balloons();

  @override
  void initState() {
    super.initState();

    _balloonControllers = List.generate(
      20,
      (index) => _BalloonController(
        vsync: this,
        duration: Duration(milliseconds: 2000 + random.nextInt(2000)),
        startPosition: Offset(
          (index / 20) * (widget.size.width - 40) + 20,
          widget.size.height + 100,
        ),
        endPosition: Offset(
          (index / 20) * (widget.size.width - 40) +
              20 +
              random.nextDouble() * 40 -
              20,
          -100 + random.nextDouble() * 50,
        ),
        wiggleOffset: 30.0,
      )..start(),
    );

    _isPlaying = true;
    Future.delayed(effect.duration, () {
      if (mounted) {
        setState(() {
          _isPlaying = false;
        });
        widget.onComplete?.call();
      }
    });
  }

  @override
  void dispose() {
    for (var controller in _balloonControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isPlaying) return const SizedBox.shrink();

    return Stack(
      children: _balloonControllers.map((controller) {
        return AnimatedBuilder(
          animation: controller.animation,
          builder: (context, child) {
            final position = controller.getPosition();
            final wiggle = controller.getWiggle();
            return Positioned(
              left: position.dx + wiggle,
              top: position.dy - 50,
              child: Transform.rotate(angle: wiggle / 50, child: child!),
            );
          },
          child: Text(
            '🎈',
            style: TextStyle(fontSize: 40 + random.nextDouble() * 20),
          ),
        );
      }).toList(),
    );
  }
}

class _BalloonController {
  _BalloonController({
    required this.vsync,
    required this.duration,
    required this.startPosition,
    required this.endPosition,
    required this.wiggleOffset,
  }) {
    _controller = AnimationController(duration: duration, vsync: vsync);

    animation = CurvedAnimation(parent: _controller, curve: Curves.easeOut);

    _wiggleAnimation = Tween<double>(
      begin: -wiggleOffset,
      end: wiggleOffset,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }
  final TickerProvider vsync;
  final Duration duration;
  final Offset startPosition;
  final Offset endPosition;
  final double wiggleOffset;
  late final AnimationController _controller;
  late final Animation<double> animation;
  late final Animation<double> _wiggleAnimation;

  void start() {
    _controller.forward();
  }

  Offset getPosition() {
    return Offset.lerp(startPosition, endPosition, animation.value)!;
  }

  double getWiggle() {
    return _wiggleAnimation.value * (1 - animation.value);
  }

  void dispose() {
    _controller.dispose();
  }
}
