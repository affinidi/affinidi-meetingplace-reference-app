import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../presentation/themes/app_custom_colors.dart';
import '../../presentation/themes/chat_input_decoration.dart';
import '../../presentation/themes/destructive_elevated_button_style.dart';
import '../../presentation/themes/log_colors.dart';
import '../../presentation/themes/qr_scanner_theme.dart';
import '../../presentation/themes/rounded_input_decoration.dart';

/// Extension on [BuildContext] to easily access theme properties
extension BuildContextExtensions on BuildContext {
  /// Allows accessing localized strings
  AppLocalizations get l10n => AppLocalizations.of(this)!;

  /// Returns the current [ThemeData]
  ThemeData get theme => Theme.of(this);

  /// Returns the primary text theme
  TextTheme get textTheme => TextTheme.of(this);

  /// Returns the icon theme
  IconThemeData get iconTheme => IconTheme.of(this);

  /// Returns the list tile theme
  ListTileThemeData get listTileTheme => ListTileTheme.of(this);

  /// Returns the custom colors defined in the theme
  AppCustomColors get customColors =>
      Theme.of(this).extension<AppCustomColors>()!;

  /// Returns the log colors defined in the theme
  LogColors get logColors => Theme.of(this).extension<LogColors>()!;

  /// Access Material ColorScheme
  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  /// Access custom roundedInputDecoration
  InputDecoration get roundedInputDecoration =>
      Theme.of(this).extension<RoundedInputDecoration>()!.inputDecoration;

  /// Access style for a destructive ElevatedButton
  ButtonStyle get destructiveElevatedButtonStyle =>
      Theme.of(this).extension<DestructiveElevatedButtonStyle>()!.buttonStyle;

  /// Access QR scanner theme
  QRScannerTheme get qrScannerTheme =>
      Theme.of(this).extension<QRScannerTheme>()!;

  /// Returns the current MediaQuery
  MediaQueryData get mediaQuery => MediaQuery.of(this);

  /// Access custom chatInputDecoration
  InputDecoration get chatInputDecoration =>
      Theme.of(this).extension<ChatInputDecoration>()!.inputDecoration;
}
