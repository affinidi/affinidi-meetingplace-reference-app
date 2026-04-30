import 'dart:math';

import 'package:flutter/material.dart';

class CircularSpinner extends StatefulWidget {
  const CircularSpinner({
    super.key,
    this.size = 64.0,
    this.color,
    this.duration = const Duration(milliseconds: 1200),
  });

  final double size;
  final Color? color;
  final Duration duration;

  @override
  State<CircularSpinner> createState() => _CircularSpinnerState();
}

class _CircularSpinnerState extends State<CircularSpinner>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? Theme.of(context).colorScheme.primary;

    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            painter: _CircularSpinnerPainter(
              rotation: _controller.value,
              color: color,
            ),
          );
        },
      ),
    );
  }
}

class _CircularSpinnerPainter extends CustomPainter {
  _CircularSpinnerPainter({required this.rotation, required this.color});
  final double rotation;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width / 2;
    
    // Draw the full circle background (light gray or transparent)
    final backgroundPaint = Paint()
      ..color = color.withValues(alpha: 0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;
    
    canvas.drawCircle(center, radius - 2, backgroundPaint);
    
    // Draw the 25% arc (90 degrees) in theme color
    final arcPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;
    
    const sweepAngle = pi / 2; // 90 degrees = 25% of circle
    final startAngle = (rotation * 2 * pi) - (pi / 2); // Start from top and rotate
    
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - 2),
      startAngle,
      sweepAngle,
      false,
      arcPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _CircularSpinnerPainter oldDelegate) =>
      oldDelegate.rotation != rotation || oldDelegate.color != color;
}
