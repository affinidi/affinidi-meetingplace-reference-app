import 'dart:math';

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';

import '../screen_effect.dart';

class ConfettiEffect extends StatefulWidget {
  const ConfettiEffect({
    super.key,
    this.onComplete,
  });

  final VoidCallback? onComplete;

  @override
  State<ConfettiEffect> createState() => _ConfettiEffectState();
}

class _ConfettiEffectState extends State<ConfettiEffect>
    with TickerProviderStateMixin {
  late final ConfettiController _confettiController;
  bool _isPlaying = false;
  final effect = ScreenEffect.confetti();

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: effect.duration,
    );

    _isPlaying = true;
    _confettiController.play();
    Future.delayed(_confettiController.duration, () {
      if (mounted) {
        setState(() {
          _isPlaying = false;
        });
        widget.onComplete?.call();
      }
    });
  }

  @override
  Widget build(Object context) {
    if (!_isPlaying) return const SizedBox.shrink();

    return Stack(
      children: [
        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: _confettiController,
            blastDirection: pi / 2,
            maxBlastForce: 8,
            minBlastForce: 2,
            emissionFrequency: 0.0, // one blast
            numberOfParticles: 150,
            gravity: 0.1,
            particleDrag: 0.03,
            shouldLoop: false,
            colors: const [
              Colors.green,
              Colors.blue,
              Colors.pink,
              Colors.orange,
              Colors.purple,
            ],
            // Remove the createParticlePath parameter to use default
            // rectangular confetti
          ),
        ),
      ],
    );
  }
}
