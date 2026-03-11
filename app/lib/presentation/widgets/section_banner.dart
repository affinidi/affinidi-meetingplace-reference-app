import 'package:flutter/material.dart';

import '../../infrastructure/extensions/build_context_extensions.dart';
import '../../infrastructure/extensions/color_extensions.dart';
import '../helpers/screensize_helper.dart';

class SectionBanner extends StatelessWidget {
  const SectionBanner({
    super.key,
    required this.title,
    required this.subtitle,
    this.onTap,
    required this.icon,
    this.showProgress,
  });

  final String title;
  final String subtitle;
  final Widget icon;
  final bool? showProgress;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return Card.filled(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            height: 85,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(10)),
              gradient: RadialGradient(
                center: Alignment.bottomCenter,
                radius: ScreensizeHelper.getRadiusForScreenWidth(context),
                colors: [
                  colorScheme.primary.withAlpha(249),
                  colorScheme.primary.withLightness(0.3),
                ],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                spacing: 12,
                children: [
                  Expanded(
                    flex: 1,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      //mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(title, style: context.textTheme.headlineMedium),
                        Text(
                          subtitle,
                          maxLines: 3,
                          style: context.textTheme.headlineSmall,
                        ),
                      ],
                    ),
                  ),
                  (showProgress != null && showProgress!)
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator.adaptive(),
                        )
                      : Container(
                          width: 40,
                          height: 40,
                          child: Opacity(
                            opacity: 0.5,
                            child: FittedBox(child: icon, fit: BoxFit.contain),
                          ),
                        ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
