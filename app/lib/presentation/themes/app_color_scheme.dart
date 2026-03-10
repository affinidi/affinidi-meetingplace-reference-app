import 'package:flutter/material.dart';

class AppColorScheme {
  static final _appColor = const Color.fromARGB(255, 3, 104, 192);
  static final dark =
      ColorScheme.fromSeed(seedColor: _appColor) //
          .copyWith(
            brightness: Brightness.dark,
            primary: _appColor,
            secondary: Colors.lightBlue,
            surface: Colors.black,
            surfaceContainerHigh: const Color.fromARGB(255, 46, 48, 53),
            surfaceContainerHighest: Colors.black,
            onSurface: Colors.white,
            onSurfaceVariant: Colors.white,
            onSecondaryContainer: Colors.white,
            surfaceContainer: Colors.black,
            secondaryContainer: Colors.lightBlue,
            errorContainer: Colors.red,
            onErrorContainer: Colors.white,
          );
}
