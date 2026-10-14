import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mpx_flutter_reference_app/infrastructure/services/camera_service/camera_service.dart';
import 'package:mpx_flutter_reference_app/infrastructure/services/camera_service/camera_service_state.dart';
import 'package:mpx_flutter_reference_app/l10n/app_localizations.dart';
import 'package:mpx_flutter_reference_app/presentation/dialogs/new_connections_menu/new_connections_menu.dart';
import 'package:mpx_flutter_reference_app/presentation/dialogs/new_connections_menu/new_connections_menu_option.dart';

class _NoCamera extends CameraService {
  @override
  CameraServiceState build() => CameraServiceState(isAvailable: false);
}

void main() {
  testWidgets('offers signing in to a community', (tester) async {
    NewConnectionsMenuOption? selection;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [cameraServiceProvider.overrideWith(_NoCamera.new)],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () async {
                  selection = await NewConnectionsMenu.show(context: context);
                },
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sign in to community'));
    await tester.pumpAndSettle();

    expect(selection, NewConnectionsMenuOption.signInToCommunity);
  });
}
