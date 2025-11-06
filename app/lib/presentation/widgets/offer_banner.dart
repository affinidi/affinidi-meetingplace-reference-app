import 'package:flutter/material.dart';

import '../../infrastructure/extensions/build_context_extensions.dart';
import '../../infrastructure/extensions/color_extensions.dart';
import '../helpers/screensize_helper.dart';

class OfferBanner extends StatelessWidget {
  const OfferBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    return Container(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.bottomCenter,
          radius: ScreensizeHelper.getRadiusForScreenWidth(context),
          colors: [
            colorScheme.primary.withAlpha(249),
            colorScheme.primary.withLightness(0.3),
          ],
        ),
      ),
      constraints: BoxConstraints(
          maxHeight: ScreensizeHelper.getConstrainedWidth(context) * 0.25),
      child: Row(
        children: [
          Expanded(
            child: Image.asset(
              'assets/images/meetingplace-banner.png',
              fit: BoxFit.fitWidth,
              alignment: Alignment.center,
            ),
          ),
        ],
      ),
    );
  }
}
