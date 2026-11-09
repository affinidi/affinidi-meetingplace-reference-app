import 'package:flutter/material.dart';

import '../../infrastructure/extensions/build_context_extensions.dart';
import '../helpers/screensize_helper.dart';
import 'onboarding_style/onboarding_style.dart';

class OfferBanner extends StatelessWidget {
  const OfferBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: onboardingGradient(
        context,
        radius: ScreensizeHelper.getRadiusForScreenWidth(context),
      ),
      constraints: BoxConstraints(
        maxHeight: ScreensizeHelper.getConstrainedWidth(context) * 0.25,
      ),
      child: Row(
        children: [
          Expanded(
            child: Image.asset(
              'assets/images/meetingplace-banner.png',
              color: context.mcColors.textPrimary,
              colorBlendMode: BlendMode.modulate,
              fit: BoxFit.fitWidth,
              alignment: Alignment.center,
            ),
          ),
        ],
      ),
    );
  }
}
