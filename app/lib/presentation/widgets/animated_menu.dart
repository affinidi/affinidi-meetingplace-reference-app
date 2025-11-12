import 'package:flutter/material.dart';
import 'package:pie_menu/pie_menu.dart';

class AnimatedMenu extends StatelessWidget {
  const AnimatedMenu({
    super.key,
    required this.controller,
    required this.actions,
    required this.child,
    this.menuAlignment = Alignment.center,
    this.menuDisplacement = const Offset(0, 0),
    this.delayDuration = Duration.zero,
    this.overlayColor = Colors.transparent,
  });

  final PieMenuController controller;
  final List<PieAction> actions;
  final Widget child;
  final Alignment menuAlignment;
  final Offset menuDisplacement;
  final Duration delayDuration;
  final Color overlayColor;

  @override
  Widget build(BuildContext context) {
    return PieMenu(
      controller: controller,
      theme: PieTheme.of(context).copyWith(
        overlayColor: overlayColor,
        regularPressShowsMenu: false,
        longPressShowsMenu: true,
        longPressDuration: delayDuration,
        menuAlignment: menuAlignment,
        menuDisplacement: menuDisplacement,
      ),
      actions: actions,
      child: child,
    );
  }
}
