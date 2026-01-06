import 'dart:io';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../../navigation/router_config_provider.dart';
import '../themes/app_theme.dart';
import '../widgets/banners/no_connection_banner.dart';
import 'app_controller.dart';

class App extends ConsumerWidget {
  const App({
    super.key,
    this.locale,
  });

  final Locale? locale;

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    final routerConfig = ref.watch(routerConfigProvider);
    ref.read(appControllerProvider);

    return MaterialApp.router(
      scrollBehavior: (!kIsWeb && Platform.isMacOS)
          ? const ScrollBehavior().copyWith(
              dragDevices: {
                PointerDeviceKind.touch,
                PointerDeviceKind.mouse,
                PointerDeviceKind.trackpad,
              },
            )
          : null,
      debugShowCheckedModeBanner: false,
      title: 'Meeting Place',
      routerConfig: routerConfig,
      theme: AppTheme.dark,
      localizationsDelegates: [
        ...AppLocalizations.localizationsDelegates,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      locale: locale,
      builder: (context, child) {
        if (child == null) return const SizedBox.shrink();

        return MediaQuery.withNoTextScaling(
          child: Stack(
            children: [
              child,
              const SafeArea(child: NoConnectionBanner()),
            ],
          ),
        );
      },
    );
  }
}
