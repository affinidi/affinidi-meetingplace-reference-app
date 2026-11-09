import 'package:flutter/material.dart';

import 'tokens/mc_colors.dart';

@immutable
class LogColors extends ThemeExtension<LogColors> {
  const LogColors({
    required this.sdkError,
    required this.sdkWarning,
    required this.sdkDebug,
    required this.sdkInfo,
    required this.sdkOther,
    required this.sdkContext,
    required this.appError,
    required this.appWarning,
    required this.appDebug,
    required this.appInfo,
    required this.appOther,
    required this.appContext,
  });

  static final dark = LogColors(
    sdkError: McColors.dark.dangerText,
    sdkWarning: McColors.dark.warning,
    sdkDebug: McColors.blue,
    sdkInfo: McColors.purple,
    sdkOther: McColors.cyan,
    sdkContext: McColors.lime,
    appError: McColors.dark.bad,
    appWarning: McColors.orange,
    appDebug: McColors.blue,
    appInfo: McColors.dark.ok,
    appOther: McColors.dark.highlightSecondary,
    appContext: McColors.dark.success,
  );

  static final light = LogColors(
    sdkError: McColors.light.dangerText,
    sdkWarning: McColors.light.warning,
    sdkDebug: McColors.blue,
    sdkInfo: const Color(0xFFA236C8),
    sdkOther: const Color(0xFF008085),
    sdkContext: const Color(0xFF597300),
    appError: McColors.light.bad,
    appWarning: const Color(0xFFB27B00),
    appDebug: McColors.blue,
    appInfo: McColors.light.ok,
    appOther: McColors.light.highlightSecondary,
    appContext: McColors.light.success,
  );

  final Color sdkError;
  final Color sdkWarning;
  final Color sdkDebug;
  final Color sdkInfo;
  final Color sdkOther;
  final Color sdkContext;
  final Color appError;
  final Color appWarning;
  final Color appDebug;
  final Color appInfo;
  final Color appOther;
  final Color appContext;

  @override
  LogColors copyWith({
    Color? sdkError,
    Color? sdkWarning,
    Color? sdkDebug,
    Color? sdkInfo,
    Color? sdkOther,
    Color? sdkContext,
    Color? appError,
    Color? appWarning,
    Color? appDebug,
    Color? appInfo,
    Color? appOther,
    Color? appContext,
  }) {
    return LogColors(
      sdkError: sdkError ?? this.sdkError,
      sdkWarning: sdkWarning ?? this.sdkWarning,
      sdkDebug: sdkDebug ?? this.sdkDebug,
      sdkInfo: sdkInfo ?? this.sdkInfo,
      sdkOther: sdkOther ?? this.sdkOther,
      sdkContext: sdkContext ?? this.sdkContext,
      appError: appError ?? this.appError,
      appWarning: appWarning ?? this.appWarning,
      appDebug: appDebug ?? this.appDebug,
      appInfo: appInfo ?? this.appInfo,
      appOther: appOther ?? this.appOther,
      appContext: appContext ?? this.appContext,
    );
  }

  @override
  LogColors lerp(LogColors? other, double t) {
    if (other == null) return this;
    return LogColors(
      sdkError: Color.lerp(sdkError, other.sdkError, t)!,
      sdkWarning: Color.lerp(sdkWarning, other.sdkWarning, t)!,
      sdkDebug: Color.lerp(sdkDebug, other.sdkDebug, t)!,
      sdkInfo: Color.lerp(sdkInfo, other.sdkInfo, t)!,
      sdkOther: Color.lerp(sdkOther, other.sdkOther, t)!,
      sdkContext: Color.lerp(sdkContext, other.sdkContext, t)!,
      appError: Color.lerp(appError, other.appError, t)!,
      appWarning: Color.lerp(appWarning, other.appWarning, t)!,
      appDebug: Color.lerp(appDebug, other.appDebug, t)!,
      appInfo: Color.lerp(appInfo, other.appInfo, t)!,
      appOther: Color.lerp(appOther, other.appOther, t)!,
      appContext: Color.lerp(appContext, other.appContext, t)!,
    );
  }
}
