import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mpx_flutter_reference_app/application/services/vtc_service/vtc_service.dart';
import 'package:mpx_flutter_reference_app/domain/models/vtc/vtc_removal.dart';
import 'package:mpx_flutter_reference_app/l10n/app_localizations.dart';
import 'package:mpx_flutter_reference_app/presentation/screens/communities/removal_notice.dart';
import 'package:mpx_flutter_reference_app/presentation/themes/app_theme.dart';

/// Tells removals as the community's notices are found.
class _FakeVtcService extends Fake implements VtcService {
  final removals = StreamController<VtcRemoval>.broadcast();

  @override
  Stream<VtcRemoval> get removed => removals.stream;
}

void main() {
  late _FakeVtcService service;

  setUp(() => service = _FakeVtcService());

  Future<AppLocalizations> pumpShell(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [vtcServiceProvider.overrideWithValue(service)],
        child: MaterialApp(
          theme: AppTheme.dark,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: Consumer(
              builder: (context, ref, _) {
                listenForRemovals(ref, context);
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return AppLocalizations.of(tester.element(find.byType(SizedBox)))!;
  }

  testWidgets('tells the member a community removed them, and why', (
    tester,
  ) async {
    final l10n = await pumpShell(tester);

    service.removals.add(
      const VtcRemoval(
        communityDid: 'did:web:chess.example',
        name: 'Chess club',
        reason: 'Spam.',
      ),
    );
    await tester.pump();
    await tester.pump();

    expect(
      find.text(l10n.vtcRemovedWithReason('Chess club', 'Spam.')),
      findsOneWidget,
    );
  });

  testWidgets('says no reason when the community gave none', (tester) async {
    final l10n = await pumpShell(tester);

    service.removals.add(
      const VtcRemoval(communityDid: 'did:web:chess.example'),
    );
    await tester.pump();
    await tester.pump();

    expect(
      find.text(l10n.vtcRemoved(l10n.membershipCredentialUnnamed)),
      findsOneWidget,
    );
  });
}
