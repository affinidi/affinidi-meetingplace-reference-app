import 'package:flutter/material.dart';

import 'app_color_scheme.dart';
import 'app_custom_colors.dart';
import 'chat_input_decoration.dart';
import 'destructive_elevated_button_style.dart';
import 'log_colors.dart';
import 'qr_scanner_theme.dart';
import 'rounded_input_decoration.dart';

class AppTheme {
  static final darkColorScheme = AppColorScheme.dark;
  static final _customColors = const AppCustomColors();

  static final _roundedInputDecorationBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(30),
    borderSide: BorderSide(color: darkColorScheme.onSurfaceVariant, width: 1),
  );

  static final dark = ThemeData(
    useMaterial3: true,
    fontFamily: 'Figtree',
    colorScheme: darkColorScheme,
    extensions: <ThemeExtension<dynamic>>[
      _customColors,
      const LogColors(),
      QRScannerTheme(colorScheme: darkColorScheme),
      ChatInputDecoration(
        InputDecoration(
          hintMaxLines: 1,
          hintStyle: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
                color: darkColorScheme.onSurface.withValues(alpha: 0.48),
                width: 0.5),
            borderRadius: BorderRadius.circular(32.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: darkColorScheme.primary, width: 1.0),
            borderRadius: BorderRadius.circular(32.0),
          ),
          disabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
                color: darkColorScheme.onSurface.withValues(alpha: 0.48),
                width: 0.5),
            borderRadius: BorderRadius.circular(32.0),
          ),
          border: OutlineInputBorder(
            borderSide: BorderSide(
                color: darkColorScheme.onSurface.withValues(alpha: 0.48),
                width: 0.5),
            borderRadius: BorderRadius.circular(32.0),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
        ),
      ),
      RoundedInputDecoration(
        InputDecoration(
          border: _roundedInputDecorationBorder,
          focusedBorder: _roundedInputDecorationBorder,
          enabledBorder: _roundedInputDecorationBorder,
          errorBorder: _roundedInputDecorationBorder,
          disabledBorder: _roundedInputDecorationBorder,
          focusedErrorBorder: _roundedInputDecorationBorder,
          hintStyle: TextStyle(color: darkColorScheme.onSurfaceVariant),
        ),
      ),
      DestructiveElevatedButtonStyle(
        ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.disabled)
                ? darkColorScheme.onSurface.withValues(alpha: 0.20)
                : darkColorScheme.errorContainer,
          ),
          foregroundColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.disabled)
                ? darkColorScheme.onSurface.withValues(alpha: 0.60)
                : darkColorScheme.onErrorContainer,
          ),
          textStyle: WidgetStateProperty.all(
            const TextStyle(
              fontSize: 16,
            ),
          ),
          padding: WidgetStateProperty.all(const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 4,
          )),
        ),
      )
    ],
    textTheme: const TextTheme(
      bodyLarge: TextStyle(fontSize: 16),
      bodyMedium: TextStyle(fontSize: 14),
      bodySmall: TextStyle(fontSize: 10),
      headlineMedium: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
      headlineSmall: TextStyle(fontSize: 12),
    ),
    appBarTheme: const AppBarTheme(
      titleTextStyle: TextStyle(fontSize: 16),
    ),
    navigationBarTheme: NavigationBarThemeData(
      labelTextStyle: WidgetStateTextStyle.resolveWith((states) {
        return TextStyle(
          color: (states.contains(WidgetState.selected))
              ? darkColorScheme.secondaryContainer
              : darkColorScheme.onSurface.withValues(alpha: 1 - 0.38),
          fontSize: 12,
        );
      }),
      indicatorColor: darkColorScheme.primary,
      backgroundColor: darkColorScheme.surface,
    ),
    iconTheme: IconThemeData(color: darkColorScheme.onSurfaceVariant),
    inputDecorationTheme: InputDecorationTheme(
      filled: false,
      fillColor: Colors.transparent,
      border: InputBorder.none,
      focusedBorder: InputBorder.none,
      hintStyle: TextStyle(
        color: darkColorScheme.onSurfaceVariant.withAlpha(120),
        fontSize: 14,
      ),
      errorStyle: TextStyle(
        color: darkColorScheme.error,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
      errorMaxLines: 3,
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return darkColorScheme.primary;
        }
        return darkColorScheme.onSurfaceVariant;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return darkColorScheme.primaryContainer;
        }
        return darkColorScheme.surfaceContainerHighest;
      }),
    ),
    listTileTheme: ListTileThemeData(
      selectedTileColor: darkColorScheme.primary,
      selectedColor: darkColorScheme.onPrimary,
      iconColor: darkColorScheme.primary,
      textColor: darkColorScheme.onSurface,
      subtitleTextStyle: const TextStyle(fontSize: 12),
      leadingAndTrailingTextStyle:
          const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    ),
    datePickerTheme: DatePickerThemeData(
      backgroundColor: _customColors.grey900,
      headerBackgroundColor: darkColorScheme.primary.withValues(alpha: 0.90),
      headerForegroundColor: darkColorScheme.onPrimary,
      dayForegroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return darkColorScheme.onPrimary;
        }
        if (states.contains(WidgetState.disabled)) {
          return darkColorScheme.onSurface.withValues(alpha: 0.3);
        }
        return darkColorScheme.onSurface;
      }),
      cancelButtonStyle: ButtonStyle(
        textStyle: WidgetStateProperty.all(
          const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
      confirmButtonStyle: ButtonStyle(
        textStyle: WidgetStateProperty.all(
          const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
    ),
    timePickerTheme: TimePickerThemeData(
      backgroundColor: _customColors.grey900,
      dialBackgroundColor: Colors.grey[800],
      hourMinuteTextColor: darkColorScheme.onPrimary,
      hourMinuteColor: darkColorScheme.primary,
      dayPeriodTextColor: darkColorScheme.onPrimary,
      dayPeriodColor: darkColorScheme.primary,
      dayPeriodShape: const StadiumBorder(),
      helpTextStyle: TextStyle(
        color: darkColorScheme.onPrimary,
        fontWeight: FontWeight.bold,
        fontSize: 16,
      ),
      cancelButtonStyle: ButtonStyle(
        textStyle: WidgetStateProperty.all(
          const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
      confirmButtonStyle: ButtonStyle(
        textStyle: WidgetStateProperty.all(
          const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.disabled)
              ? darkColorScheme.onSurface.withValues(alpha: 0.20)
              : darkColorScheme.primary,
        ),
        foregroundColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.disabled)
              ? darkColorScheme.onSurface.withValues(alpha: 0.60)
              : darkColorScheme.onPrimary,
        ),
        textStyle: WidgetStateProperty.all(
          const TextStyle(
            fontSize: 16,
          ),
        ),
        padding: WidgetStateProperty.all(const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 4,
        )),
        minimumSize: const WidgetStatePropertyAll(Size(100, 40)),
      ),
    ),
    tabBarTheme: TabBarThemeData(
      labelColor: darkColorScheme.onSurface,
      dividerColor: Colors.transparent,
    ),
    disabledColor: darkColorScheme.onSurface.withValues(alpha: 1 - 0.38),
    chipTheme: ChipThemeData(
      backgroundColor: _customColors.success,
      labelStyle: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 12,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      brightness: Brightness.dark,
      side: BorderSide.none,
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: darkColorScheme.primary,
        textStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
    dividerTheme: DividerThemeData(
      color: _customColors.whiteOverlay30,
      thickness: 1,
      space: 0,
      indent: 0,
      endIndent: 0,
    ),
  );
}
