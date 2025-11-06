import 'package:flutter/material.dart';

@immutable
class LogColors extends ThemeExtension<LogColors> {
  const LogColors({
    this.sdkError = const Color(0xFFD32F2F),
    this.sdkWarning = const Color(0xFFFF9800),
    this.sdkDebug = const Color(0xFF3F51B5),
    this.sdkInfo = const Color(0xFF9C27B0),
    this.sdkOther = Colors.tealAccent,
    this.sdkContext = Colors.limeAccent,
    this.appError = Colors.red,
    this.appWarning = Colors.orange,
    this.appDebug = const Color.fromARGB(255, 3, 104, 192),
    this.appInfo = Colors.green,
    this.appOther = Colors.lightBlue,
    this.appContext = const Color(0xFF4CAF50),
  });

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
