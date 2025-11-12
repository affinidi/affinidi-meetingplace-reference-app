import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SlideUpTransitionPage<T> extends CustomTransitionPage<T> {
  SlideUpTransitionPage({
    required super.child,
    super.key,
    super.transitionDuration,
    super.reverseTransitionDuration,
  }) : super(
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 1),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            );
          },
        );
}
