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

/// Opens the menu; its selection lands in the returned holder once made.
Future<List<NewConnectionsMenuOption?>> _open(WidgetTester tester) async {
  final selection = <NewConnectionsMenuOption?>[];
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
                selection.add(await NewConnectionsMenu.show(context: context));
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
  return selection;
}

Future<NewConnectionsMenuOption?> _select(
  WidgetTester tester,
  String title,
) async {
  final selection = await _open(tester);
  await tester.ensureVisible(find.text(title));
  await tester.pumpAndSettle();
  await tester.tap(find.text(title));
  await tester.pumpAndSettle();
  return selection.single;
}

void main() {
  testWidgets('leaves signing in to a community to its page', (tester) async {
    await _open(tester);

    expect(find.text('Join a community'), findsOneWidget);
    expect(find.text('Sign in to community'), findsNothing);
  });

  testWidgets('offers joining a community', (tester) async {
    expect(
      await _select(tester, 'Join a community'),
      NewConnectionsMenuOption.joinCommunity,
    );
  });
}
