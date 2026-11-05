import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mpx_flutter_reference_app/application/services/identities_service/identities_service.dart';
import 'package:mpx_flutter_reference_app/application/services/identities_service/identities_service_state.dart';
import 'package:mpx_flutter_reference_app/domain/models/identity/identity.dart';
import 'package:mpx_flutter_reference_app/infrastructure/loggers/app_logger/app_logger.dart';
import 'package:mpx_flutter_reference_app/l10n/app_localizations.dart';
import 'package:mpx_flutter_reference_app/presentation/screens/identities/identities_screen.dart';
import 'package:mpx_flutter_reference_app/presentation/themes/app_theme.dart';

/// No identity yet; creating one waits until [pendingAdd] completes.
class _SlowIdentitiesService extends IdentitiesService {
  final pendingAdd = Completer<void>();
  final added = <Identity>[];

  @override
  IdentitiesServiceState build() => IdentitiesServiceState();

  @override
  Future<void> addIdentity(Identity identity) async {
    await pendingAdd.future;
    added.add(identity);
  }
}

void main() {
  setUpAll(() {
    AppLogger.initialize(
      File('${Directory.systemTemp.path}/primary_identity_setup_test.log'),
    );
  });

  testWidgets('shows a spinner on the button while the identity is created', (
    tester,
  ) async {
    final service = _SlowIdentitiesService();
    await tester.binding.setSurfaceSize(const Size(1200, 2000));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      ProviderScope(
        overrides: [identitiesServiceProvider.overrideWith(() => service)],
        child: MaterialApp(
          theme: AppTheme.dark,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const Scaffold(body: IdentitiesScreen()),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final button = find.byKey(const Key('primary_identity_save'));
    expect(button, findsOneWidget);
    expect(
      find.descendant(
        of: button,
        matching: find.byType(CircularProgressIndicator),
      ),
      findsNothing,
    );

    await tester.ensureVisible(button);
    await tester.tap(button);
    await tester.pump();

    expect(
      find.descendant(
        of: button,
        matching: find.byType(CircularProgressIndicator),
      ),
      findsOneWidget,
    );

    service.pendingAdd.complete();
    await tester.pump();
    expect(service.added, hasLength(1));
  });
}
