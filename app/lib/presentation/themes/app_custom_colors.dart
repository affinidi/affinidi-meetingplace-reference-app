import 'package:flutter/material.dart';

import 'tokens/mc_colors.dart';

@immutable
class AppCustomColors extends ThemeExtension<AppCustomColors> {
  const AppCustomColors({
    required this.cyan,
    required this.purple,
    required this.rose,
    required this.violet,
    required this.pureWhite,
    required this.success,
    required this.warning,
    required this.grey900,
    required this.grey700,
    required this.callBubbleGrey,
    required this.whiteOverlay30,
    required this.brown,
    required this.orange,
    required this.disabledGrey,
    required this.darkGrey,
    required this.callControlSurface,
    required this.searchHintText,
    required this.searchFieldFill,
    required this.fromMeColor,
    required this.fromMeDarkColor,
    required this.credentialCardGradientStart,
    required this.credentialCardShadow,
    required this.awaitingMemberWarningText,
    required this.mediaSurfaceOverlay,
    required this.mediaSurfaceBorder,
    required this.callChatItemBackground,
    required this.callChatItemFromMeBackground,
    required this.callChatItemPendingContent,
    required this.callChatItemPendingIconContainer,
    required this.callEndAvatarGradientLight,
    required this.callEndAvatarGradientMid,
    required this.incomingCallBannerBackground,
    required this.incomingCallBannerCallTypeLabel,
  });

  /// Color for concierge messages in chat
  static const conciergeMessageColor = Color.fromARGB(255, 53, 130, 6);
  static const grey800 = Color(0xFF404040);
  static const conciergeCardGradientStart = grey800;
  static const conciergeCardGradientEnd = Color(0xFF1F1F1F);
  static const conciergeActionOnWhite = grey800;

  static const primaryBrand10 = Color(0xFFE8EEFF);
  static const secondaryBrand90 = Color(0xFF1D2138);
  static const utilitySuccess100 = Color(0xFF00A08D);

  // Calls stay dark in both modes, like the video they sit on.
  static const _callSurface = Color(0xFF222223);
  static const _callTextTertiary = Color(0xFF747D8E);

  static final dark = AppCustomColors(
    cyan: McColors.cyan,
    purple: McColors.purple,
    rose: McColors.pink,
    violet: const Color(0xFFB74DDE),
    pureWhite: const Color(0xFFFFFFFF),
    success: McColors.dark.success,
    warning: McColors.dark.warning,
    grey900: McColors.dark.raised,
    grey700: McColors.dark.textTertiary,
    callBubbleGrey: _callSurface,
    whiteOverlay30: McColors.dark.hairline,
    brown: const Color(0xFF8F6100),
    orange: McColors.orange,
    disabledGrey: McColors.dark.textTertiary,
    darkGrey: _callSurface,
    callControlSurface: _callSurface,
    searchHintText: McColors.dark.textTertiary,
    searchFieldFill: McColors.dark.panel,
    fromMeColor: McColors.blue,
    fromMeDarkColor: const Color(0xFF0A182A),
    credentialCardGradientStart: const Color(0xFF000717),
    credentialCardShadow: const Color(0x40000000),
    awaitingMemberWarningText: McColors.dark.textPrimary,
    mediaSurfaceOverlay: const Color(0xBF0E0E0F),
    mediaSurfaceBorder: const Color(0x33F4F6FB),
    callChatItemBackground: _callSurface,
    callChatItemFromMeBackground: McColors.blueDeep,
    callChatItemPendingContent: _callTextTertiary,
    callChatItemPendingIconContainer: const Color(0xFF1C2A3B),
    callEndAvatarGradientLight: const Color(0x33F4F6FB),
    callEndAvatarGradientMid: const Color(0x1AF4F6FB),
    incomingCallBannerBackground: _callSurface,
    incomingCallBannerCallTypeLabel: _callTextTertiary,
  );

  static final light = AppCustomColors(
    cyan: const Color(0xFF008085),
    purple: McColors.purple,
    rose: const Color(0xFFC71788),
    violet: const Color(0xFFA236C8),
    pureWhite: const Color(0xFFFFFFFF),
    success: McColors.light.success,
    warning: McColors.light.warning,
    grey900: McColors.light.raised,
    grey700: McColors.light.textTertiary,
    callBubbleGrey: McColors.light.panel2,
    whiteOverlay30: McColors.light.hairline,
    brown: const Color(0xFF8F6100),
    orange: const Color(0xFFB27B00),
    disabledGrey: McColors.light.textTertiary,
    darkGrey: _callSurface,
    callControlSurface: _callSurface,
    searchHintText: McColors.light.textTertiary,
    searchFieldFill: McColors.light.panel,
    fromMeColor: McColors.blue,
    fromMeDarkColor: McColors.blueDeep,
    credentialCardGradientStart: const Color(0xFF000717),
    credentialCardShadow: const Color(0x1A000000),
    awaitingMemberWarningText: McColors.light.textPrimary,
    mediaSurfaceOverlay: const Color(0xBF0E0E0F),
    mediaSurfaceBorder: const Color(0x33F4F6FB),
    callChatItemBackground: _callSurface,
    callChatItemFromMeBackground: McColors.blueDeep,
    callChatItemPendingContent: _callTextTertiary,
    callChatItemPendingIconContainer: const Color(0xFF1C2A3B),
    callEndAvatarGradientLight: const Color(0x33F4F6FB),
    callEndAvatarGradientMid: const Color(0x1AF4F6FB),
    incomingCallBannerBackground: _callSurface,
    incomingCallBannerCallTypeLabel: _callTextTertiary,
  );

  final Color cyan;
  final Color purple;
  final Color rose;
  final Color violet;
  final Color pureWhite;
  final Color success;
  final Color warning;
  final Color grey900;
  final Color grey700;
  final Color callBubbleGrey;
  final Color whiteOverlay30;
  final Color brown;
  final Color orange;
  final Color disabledGrey;
  final Color darkGrey;
  final Color callControlSurface;
  final Color searchHintText;
  final Color searchFieldFill;
  final Color fromMeColor;
  final Color fromMeDarkColor;
  final Color credentialCardGradientStart;
  final Color credentialCardShadow;
  final Color awaitingMemberWarningText;
  final Color mediaSurfaceOverlay;
  final Color mediaSurfaceBorder;
  final Color callChatItemBackground;
  final Color callChatItemFromMeBackground;
  final Color callChatItemPendingContent;
  final Color callChatItemPendingIconContainer;
  final Color callEndAvatarGradientLight;
  final Color callEndAvatarGradientMid;
  final Color incomingCallBannerBackground;
  final Color incomingCallBannerCallTypeLabel;

  @override
  AppCustomColors copyWith({
    Color? cyan,
    Color? purple,
    Color? rose,
    Color? violet,
    Color? pureWhite,
    Color? success,
    Color? warning,
    Color? grey900,
    Color? grey700,
    Color? callBubbleGrey,
    Color? whiteOverlay30,
    Color? brown,
    Color? orange,
    Color? disabledGrey,
    Color? darkGrey,
    Color? callControlSurface,
    Color? searchHintText,
    Color? searchFieldFill,
    Color? fromMeColor,
    Color? fromMeDarkColor,
    Color? credentialCardGradientStart,
    Color? credentialCardShadow,
    Color? awaitingMemberWarningText,
    Color? mediaSurfaceOverlay,
    Color? mediaSurfaceBorder,
    Color? callChatItemBackground,
    Color? callChatItemFromMeBackground,
    Color? callChatItemPendingContent,
    Color? callChatItemPendingIconContainer,
    Color? callEndAvatarGradientLight,
    Color? callEndAvatarGradientMid,
    Color? incomingCallBannerBackground,
    Color? incomingCallBannerCallTypeLabel,
  }) {
    return AppCustomColors(
      cyan: cyan ?? this.cyan,
      purple: purple ?? this.purple,
      rose: rose ?? this.rose,
      violet: violet ?? this.violet,
      pureWhite: pureWhite ?? this.pureWhite,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      grey900: grey900 ?? this.grey900,
      grey700: grey700 ?? this.grey700,
      callBubbleGrey: callBubbleGrey ?? this.callBubbleGrey,
      whiteOverlay30: whiteOverlay30 ?? this.whiteOverlay30,
      brown: brown ?? this.brown,
      orange: orange ?? this.orange,
      disabledGrey: disabledGrey ?? this.disabledGrey,
      darkGrey: darkGrey ?? this.darkGrey,
      callControlSurface: callControlSurface ?? this.callControlSurface,
      searchHintText: searchHintText ?? this.searchHintText,
      searchFieldFill: searchFieldFill ?? this.searchFieldFill,
      fromMeColor: fromMeColor ?? this.fromMeColor,
      fromMeDarkColor: fromMeDarkColor ?? this.fromMeDarkColor,
      credentialCardGradientStart:
          credentialCardGradientStart ?? this.credentialCardGradientStart,
      credentialCardShadow: credentialCardShadow ?? this.credentialCardShadow,
      awaitingMemberWarningText:
          awaitingMemberWarningText ?? this.awaitingMemberWarningText,
      mediaSurfaceOverlay: mediaSurfaceOverlay ?? this.mediaSurfaceOverlay,
      mediaSurfaceBorder: mediaSurfaceBorder ?? this.mediaSurfaceBorder,
      callChatItemBackground:
          callChatItemBackground ?? this.callChatItemBackground,
      callChatItemFromMeBackground:
          callChatItemFromMeBackground ?? this.callChatItemFromMeBackground,
      callChatItemPendingContent:
          callChatItemPendingContent ?? this.callChatItemPendingContent,
      callChatItemPendingIconContainer:
          callChatItemPendingIconContainer ??
          this.callChatItemPendingIconContainer,
      callEndAvatarGradientLight:
          callEndAvatarGradientLight ?? this.callEndAvatarGradientLight,
      callEndAvatarGradientMid:
          callEndAvatarGradientMid ?? this.callEndAvatarGradientMid,
      incomingCallBannerBackground:
          incomingCallBannerBackground ?? this.incomingCallBannerBackground,
      incomingCallBannerCallTypeLabel:
          incomingCallBannerCallTypeLabel ??
          this.incomingCallBannerCallTypeLabel,
    );
  }

  @override
  AppCustomColors lerp(AppCustomColors? other, double t) {
    if (other is! AppCustomColors) return this;
    return AppCustomColors(
      cyan: Color.lerp(cyan, other.cyan, t)!,
      purple: Color.lerp(purple, other.purple, t)!,
      rose: Color.lerp(rose, other.rose, t)!,
      violet: Color.lerp(violet, other.violet, t)!,
      pureWhite: Color.lerp(pureWhite, other.pureWhite, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      grey900: Color.lerp(grey900, other.grey900, t)!,
      grey700: Color.lerp(grey700, other.grey700, t)!,
      callBubbleGrey: Color.lerp(callBubbleGrey, other.callBubbleGrey, t)!,
      whiteOverlay30: Color.lerp(whiteOverlay30, other.whiteOverlay30, t)!,
      brown: Color.lerp(brown, other.brown, t)!,
      orange: Color.lerp(orange, other.orange, t)!,
      disabledGrey: Color.lerp(disabledGrey, other.disabledGrey, t)!,
      darkGrey: Color.lerp(darkGrey, other.darkGrey, t)!,
      callControlSurface: Color.lerp(
        callControlSurface,
        other.callControlSurface,
        t,
      )!,
      searchHintText: Color.lerp(searchHintText, other.searchHintText, t)!,
      searchFieldFill: Color.lerp(searchFieldFill, other.searchFieldFill, t)!,
      fromMeColor: Color.lerp(fromMeColor, other.fromMeColor, t)!,
      fromMeDarkColor: Color.lerp(fromMeDarkColor, other.fromMeDarkColor, t)!,
      credentialCardGradientStart: Color.lerp(
        credentialCardGradientStart,
        other.credentialCardGradientStart,
        t,
      )!,
      credentialCardShadow: Color.lerp(
        credentialCardShadow,
        other.credentialCardShadow,
        t,
      )!,
      awaitingMemberWarningText: Color.lerp(
        awaitingMemberWarningText,
        other.awaitingMemberWarningText,
        t,
      )!,
      mediaSurfaceOverlay: Color.lerp(
        mediaSurfaceOverlay,
        other.mediaSurfaceOverlay,
        t,
      )!,
      mediaSurfaceBorder: Color.lerp(
        mediaSurfaceBorder,
        other.mediaSurfaceBorder,
        t,
      )!,
      callChatItemBackground: Color.lerp(
        callChatItemBackground,
        other.callChatItemBackground,
        t,
      )!,
      callChatItemFromMeBackground: Color.lerp(
        callChatItemFromMeBackground,
        other.callChatItemFromMeBackground,
        t,
      )!,
      callChatItemPendingContent: Color.lerp(
        callChatItemPendingContent,
        other.callChatItemPendingContent,
        t,
      )!,
      callChatItemPendingIconContainer: Color.lerp(
        callChatItemPendingIconContainer,
        other.callChatItemPendingIconContainer,
        t,
      )!,
      callEndAvatarGradientLight: Color.lerp(
        callEndAvatarGradientLight,
        other.callEndAvatarGradientLight,
        t,
      )!,
      callEndAvatarGradientMid: Color.lerp(
        callEndAvatarGradientMid,
        other.callEndAvatarGradientMid,
        t,
      )!,
      incomingCallBannerBackground: Color.lerp(
        incomingCallBannerBackground,
        other.incomingCallBannerBackground,
        t,
      )!,
      incomingCallBannerCallTypeLabel: Color.lerp(
        incomingCallBannerCallTypeLabel,
        other.incomingCallBannerCallTypeLabel,
        t,
      )!,
    );
  }
}
