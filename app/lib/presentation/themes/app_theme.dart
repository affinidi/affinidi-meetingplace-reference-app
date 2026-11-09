import 'package:flutter/material.dart';

import 'app_color_scheme.dart';
import 'app_custom_colors.dart';
import 'chat_input_decoration.dart';
import 'destructive_elevated_button_style.dart';
import 'log_colors.dart';
import 'qr_scanner_theme.dart';
import 'rounded_input_decoration.dart';
import 'tokens/mc_colors.dart';
import 'tokens/mc_radius.dart';
import 'tokens/mc_spacing.dart';
import 'tokens/mc_typography.dart';

/// The app's Material themes, built from the Mission Control design language.
///
/// Colour stays a signal: blue fills only the primary action and checked
/// controls, structure comes from hairlines, and selection never fills.
class AppTheme {
  static final dark = _build(
    AppColorScheme.dark,
    McColors.dark,
    AppCustomColors.dark,
    LogColors.dark,
  );

  static final light = _build(
    AppColorScheme.light,
    McColors.light,
    AppCustomColors.light,
    LogColors.light,
  );

  static const _buttonPadding = EdgeInsets.symmetric(
    horizontal: McSpacing.s6,
    vertical: McSpacing.s3,
  );
  static const _buttonMinimumSize = Size(64, 44);
  static const _buttonTextStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
  );

  static ThemeData _build(
    ColorScheme scheme,
    McColors mc,
    AppCustomColors customColors,
    LogColors logColors,
  ) {
    final textTheme = McTypography.textTheme.apply(
      fontFamily: McTypography.fontFamily,
      bodyColor: mc.textPrimary,
      displayColor: mc.textPrimary,
    );

    OutlineInputBorder inputBorder(Color color, {double width = 1}) =>
        OutlineInputBorder(
          borderRadius: BorderRadius.circular(McRadius.sm),
          borderSide: BorderSide(color: color, width: width),
        );

    final fieldDecoration = InputDecoration(
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: McSpacing.s3,
        vertical: McSpacing.s3,
      ),
      hintStyle: textTheme.bodyMedium?.copyWith(color: mc.textTertiary),
      border: inputBorder(mc.hairlineStrong),
      enabledBorder: inputBorder(mc.hairlineStrong),
      disabledBorder: inputBorder(mc.hairline),
      focusedBorder: inputBorder(
        McColors.blue,
        width: McSpacing.focusRingWidth,
      ),
      errorBorder: inputBorder(McColors.danger),
      focusedErrorBorder: inputBorder(
        McColors.danger,
        width: McSpacing.focusRingWidth,
      ),
    );

    final pill = WidgetStateProperty.all<OutlinedBorder>(const StadiumBorder());

    return ThemeData(
      useMaterial3: true,
      brightness: scheme.brightness,
      colorScheme: scheme,
      fontFamily: McTypography.fontFamily,
      textTheme: textTheme,
      scaffoldBackgroundColor: mc.canvas,
      canvasColor: mc.canvas,
      disabledColor: mc.textTertiary,
      dividerColor: mc.hairline,
      extensions: <ThemeExtension<dynamic>>[
        mc,
        customColors,
        logColors,
        QRScannerTheme(colorScheme: scheme),
        ChatInputDecoration(
          fieldDecoration.copyWith(
            hintMaxLines: 1,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: McSpacing.s3,
            ),
          ),
        ),
        RoundedInputDecoration(fieldDecoration),
        DestructiveElevatedButtonStyle(
          ButtonStyle(
            elevation: const WidgetStatePropertyAll(0),
            backgroundColor: WidgetStateProperty.resolveWith(
              (states) =>
                  states.contains(WidgetState.hovered) ||
                      states.contains(WidgetState.pressed)
                  ? mc.dangerText.withValues(alpha: 0.12)
                  : Colors.transparent,
            ),
            foregroundColor: WidgetStateProperty.resolveWith(
              (states) => states.contains(WidgetState.disabled)
                  ? mc.textTertiary
                  : mc.dangerText,
            ),
            side: WidgetStateProperty.resolveWith(
              (states) => BorderSide(
                color: states.contains(WidgetState.disabled)
                    ? mc.hairline
                    : mc.dangerText.withValues(alpha: 0.55),
              ),
            ),
            shape: pill,
            textStyle: const WidgetStatePropertyAll(_buttonTextStyle),
            padding: const WidgetStatePropertyAll(_buttonPadding),
            minimumSize: const WidgetStatePropertyAll(_buttonMinimumSize),
          ),
        ),
      ],
      appBarTheme: AppBarTheme(
        backgroundColor: mc.canvas,
        foregroundColor: mc.textPrimary,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: textTheme.titleLarge,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: mc.canvas,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        // Selection is the text tier and a marker, never a pill.
        indicatorColor: Colors.transparent,
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            color: states.contains(WidgetState.selected)
                ? mc.textPrimary
                : mc.textTertiary,
          ),
        ),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => textTheme.labelMedium?.copyWith(
            color: states.contains(WidgetState.selected)
                ? mc.textPrimary
                : mc.textTertiary,
          ),
        ),
      ),
      iconTheme: IconThemeData(color: mc.textSecondary),
      inputDecorationTheme: InputDecorationTheme(
        // Most fields sit in form rows that draw their own hairlines.
        filled: false,
        fillColor: Colors.transparent,
        border: InputBorder.none,
        focusedBorder: InputBorder.none,
        hintStyle: textTheme.bodyMedium?.copyWith(color: mc.textTertiary),
        labelStyle: textTheme.bodyMedium?.copyWith(color: mc.textSecondary),
        errorStyle: textTheme.bodySmall?.copyWith(color: mc.dangerText),
        errorMaxLines: 3,
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: McColors.blue,
        selectionColor: McColors.blue.withValues(alpha: 0.3),
        selectionHandleColor: McColors.blue,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? McColors.textOnPrimary
              : mc.textTertiary,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? McColors.blue
              : scheme.surfaceContainerHighest,
        ),
        trackOutlineColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? Colors.transparent
              : mc.control,
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? McColors.blue
              : Colors.transparent,
        ),
        checkColor: const WidgetStatePropertyAll(McColors.textOnPrimary),
        side: BorderSide(color: mc.control),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(McSpacing.s1),
        ),
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? McColors.blue
              : mc.control,
        ),
      ),
      listTileTheme: ListTileThemeData(
        selectedTileColor: mc.hoverWash,
        selectedColor: mc.textPrimary,
        iconColor: mc.textSecondary,
        textColor: mc.textPrimary,
        titleTextStyle: textTheme.bodyLarge,
        subtitleTextStyle: textTheme.bodySmall?.copyWith(
          color: mc.textSecondary,
        ),
        leadingAndTrailingTextStyle: textTheme.labelLarge,
      ),
      // Panels, as on the community page.
      cardTheme: CardThemeData(
        color: scheme.surfaceContainerLow,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(McRadius.lg),
          side: BorderSide(color: mc.hairline),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: mc.raised,
        surfaceTintColor: Colors.transparent,
        barrierColor: mc.scrim,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(McRadius.lg),
          side: BorderSide(color: mc.hairline),
        ),
        titleTextStyle: textTheme.titleLarge,
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: mc.textSecondary,
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: mc.raised,
        modalBackgroundColor: mc.raised,
        surfaceTintColor: Colors.transparent,
        modalBarrierColor: mc.scrim,
        elevation: 0,
        modalElevation: 0,
        dragHandleColor: mc.control,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(McRadius.lg),
          ),
        ),
      ),
      // A raised panel whose open edge is a hairline, over the shared scrim.
      drawerTheme: DrawerThemeData(
        backgroundColor: mc.raised,
        surfaceTintColor: Colors.transparent,
        scrimColor: mc.scrim,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: const BorderRadius.horizontal(
            right: Radius.circular(McRadius.lg),
          ),
          side: BorderSide(color: mc.hairline),
        ),
        endShape: RoundedRectangleBorder(
          borderRadius: const BorderRadius.horizontal(
            left: Radius.circular(McRadius.lg),
          ),
          side: BorderSide(color: mc.hairline),
        ),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: mc.raised,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        textStyle: textTheme.bodyMedium,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(McRadius.sm),
          side: BorderSide(color: mc.hairline),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: scheme.surfaceContainerHighest,
        contentTextStyle: textTheme.bodyMedium,
        actionTextColor: mc.highlightSecondary,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(McRadius.sm),
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: McColors.blue,
        linearTrackColor: mc.hairline,
        circularTrackColor: Colors.transparent,
      ),
      datePickerTheme: DatePickerThemeData(
        backgroundColor: mc.raised,
        surfaceTintColor: Colors.transparent,
        headerBackgroundColor: mc.raised,
        headerForegroundColor: mc.textPrimary,
        dividerColor: mc.hairline,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(McRadius.lg),
        ),
        dayForegroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return McColors.textOnPrimary;
          }
          if (states.contains(WidgetState.disabled)) {
            return mc.textTertiary;
          }
          return mc.textPrimary;
        }),
        dayBackgroundColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? McColors.blue
              : Colors.transparent,
        ),
        todayBorder: BorderSide(color: mc.hairlineStrong),
        cancelButtonStyle: ButtonStyle(
          foregroundColor: WidgetStatePropertyAll(mc.textSecondary),
          textStyle: const WidgetStatePropertyAll(_buttonTextStyle),
        ),
        confirmButtonStyle: ButtonStyle(
          foregroundColor: WidgetStatePropertyAll(mc.highlightSecondary),
          textStyle: const WidgetStatePropertyAll(_buttonTextStyle),
        ),
      ),
      timePickerTheme: TimePickerThemeData(
        backgroundColor: mc.raised,
        dialBackgroundColor: scheme.surfaceContainerHigh,
        dialHandColor: McColors.blue,
        hourMinuteTextColor: mc.textPrimary,
        hourMinuteColor: scheme.surfaceContainerHigh,
        dayPeriodTextColor: mc.textPrimary,
        dayPeriodColor: scheme.surfaceContainerHigh,
        dayPeriodShape: const StadiumBorder(),
        dayPeriodBorderSide: BorderSide(color: mc.hairlineStrong),
        helpTextStyle: textTheme.labelLarge?.copyWith(color: mc.textSecondary),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(McRadius.lg),
        ),
        cancelButtonStyle: ButtonStyle(
          foregroundColor: WidgetStatePropertyAll(mc.textSecondary),
          textStyle: const WidgetStatePropertyAll(_buttonTextStyle),
        ),
        confirmButtonStyle: ButtonStyle(
          foregroundColor: WidgetStatePropertyAll(mc.highlightSecondary),
          textStyle: const WidgetStatePropertyAll(_buttonTextStyle),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: _primaryButtonStyle(mc, pill),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: _primaryButtonStyle(mc, pill),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith(
            (states) =>
                states.contains(WidgetState.hovered) ||
                    states.contains(WidgetState.pressed)
                ? McColors.controlHoverWash
                : Colors.transparent,
          ),
          foregroundColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.disabled)
                ? mc.textTertiary
                : mc.textPrimary,
          ),
          side: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) {
              return BorderSide(color: mc.hairline);
            }
            if (states.contains(WidgetState.hovered) ||
                states.contains(WidgetState.pressed)) {
              return BorderSide(color: mc.highlightSecondary);
            }
            return BorderSide(color: mc.hairlineStrong);
          }),
          shape: pill,
          textStyle: const WidgetStatePropertyAll(_buttonTextStyle),
          padding: const WidgetStatePropertyAll(_buttonPadding),
          minimumSize: const WidgetStatePropertyAll(_buttonMinimumSize),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: mc.highlightSecondary,
          disabledForegroundColor: mc.textTertiary,
          shape: const StadiumBorder(),
          textStyle: textTheme.labelLarge,
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: McColors.blue,
        foregroundColor: McColors.textOnPrimary,
        elevation: 0,
        focusElevation: 0,
        hoverElevation: 0,
        highlightElevation: 0,
        shape: StadiumBorder(),
      ),
      // A row of siblings: body labels in the same weight either way so
      // nothing moves, no ink, and the selected one carries the square 2px
      // signal line.
      tabBarTheme: TabBarThemeData(
        labelColor: mc.textPrimary,
        unselectedLabelColor: mc.textSecondary,
        labelStyle: textTheme.bodyMedium,
        unselectedLabelStyle: textTheme.bodyMedium,
        overlayColor: const WidgetStatePropertyAll(Colors.transparent),
        splashFactory: NoSplash.splashFactory,
        indicatorSize: TabBarIndicatorSize.label,
        indicator: const UnderlineTabIndicator(
          borderSide: BorderSide(
            color: McColors.blue,
            width: McSpacing.accentLine,
          ),
        ),
        dividerColor: mc.hairline,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: Colors.transparent,
        selectedColor: McColors.controlHoverWash,
        labelStyle: McTypography.monoLabel.copyWith(color: mc.textSecondary),
        padding: const EdgeInsets.symmetric(
          horizontal: McSpacing.s2,
          vertical: McSpacing.s05,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(McRadius.xs),
        ),
        side: BorderSide(color: mc.hairlineStrong),
        brightness: scheme.brightness,
      ),
      dividerTheme: DividerThemeData(
        color: mc.hairline,
        thickness: McSpacing.hairline,
        space: 0,
        indent: 0,
        endIndent: 0,
      ),
    );
  }

  /// Solid blue, white label, pill: the one primary action.
  static ButtonStyle _primaryButtonStyle(
    McColors mc,
    WidgetStateProperty<OutlinedBorder> shape,
  ) => ButtonStyle(
    elevation: const WidgetStatePropertyAll(0),
    backgroundColor: WidgetStateProperty.resolveWith(
      (states) =>
          states.contains(WidgetState.disabled) ? mc.panel2 : McColors.blue,
    ),
    foregroundColor: WidgetStateProperty.resolveWith(
      (states) => states.contains(WidgetState.disabled)
          ? mc.textTertiary
          : McColors.textOnPrimary,
    ),
    shape: shape,
    textStyle: const WidgetStatePropertyAll(_buttonTextStyle),
    padding: const WidgetStatePropertyAll(_buttonPadding),
    minimumSize: const WidgetStatePropertyAll(_buttonMinimumSize),
  );
}
