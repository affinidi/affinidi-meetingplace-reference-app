import 'package:flutter/material.dart';

import '../../infrastructure/extensions/build_context_extensions.dart';

class BadgedIcon extends StatelessWidget {
  BadgedIcon({super.key, required this.icon, this.count = 0});

  final Widget icon;
  final int count;

  static const _badgeMaxScaleFactor = 1.5;

  @override
  Widget build(BuildContext context) {
    return count > 0
        ? Badge(
            label: Text(
              '$count',
              semanticsLabel: context.l10n.badgeCountSemantics(count),
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
