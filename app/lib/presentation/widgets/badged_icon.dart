import 'package:flutter/material.dart';

class BadgedIcon extends StatelessWidget {
  BadgedIcon({
    super.key,
    required this.label,
    required this.icon,
    this.count = 0,
  });

  final String label;
  final Widget icon;
  final int count;

  static const _badgeMaxScaleFactor = 1.5;

  @override
  Widget build(BuildContext context) {
    return count > 0
        ? Badge(
            offset: const Offset(15, 0),
            label: Text(
              '$count',
              textScaler:
                  (MediaQuery.maybeTextScalerOf(context) ??
                          TextScaler.noScaling)
                      .clamp(maxScaleFactor: _badgeMaxScaleFactor),
            ),
            child: icon,
          )
        : icon;
  }
}
