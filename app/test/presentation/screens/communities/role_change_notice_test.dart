import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mpx_flutter_reference_app/application/services/vtc_service/vtc_service.dart';
import 'package:mpx_flutter_reference_app/domain/models/vtc/vtc_community.dart';
import 'package:mpx_flutter_reference_app/domain/models/vtc/vtc_role_change.dart';
import 'package:mpx_flutter_reference_app/l10n/app_localizations.dart';
import 'package:mpx_flutter_reference_app/presentation/screens/communities/role_change_notice.dart';
import 'package:mpx_flutter_reference_app/presentation/themes/app_theme.dart';

const _chess = 'did:web:chess.example';

/// Tells role changes, in the one community the phone knows.
class _FakeVtcService extends Fake implements VtcService {
  final roleChanges = StreamController<VtcRoleChange>.broadcast();

  @override
  Stream<VtcRoleChange> get roleChanged => roleChanges.stream;

  @override
  Future<VtcCommunity?> community(String communityDid) async =>
      communityDid == _chess
      ? const VtcCommunity(
          communityDid: _chess,
          personaDid: 'did:key:zAda',
          contextId: 'vta',
          name: 'Chess club',
        )
      : null;
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
                listenForRoleChanges(ref, context);
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

  testWidgets('tells the member their new role in a community', (tester) async {
    final l10n = await pumpShell(tester);

    service.roleChanges.add(
      const VtcRoleChange(communityDid: _chess, role: 'admin'),
    );
    await tester.pump();
    await tester.pump();

    expect(
      find.text(l10n.vtcRoleChanged('Chess club', 'Administrator')),
      findsOneWidget,
    );
  });

  testWidgets('names a community it no longer knows as unnamed', (
    tester,
  ) async {
    final l10n = await pumpShell(tester);

    service.roleChanges.add(
      const VtcRoleChange(communityDid: 'did:web:gone', role: 'moderator'),
    );
    await tester.pump();
    await tester.pump();

    expect(
      find.text(
        l10n.vtcRoleChanged(l10n.membershipCredentialUnnamed, 'Moderator'),
      ),
      findsOneWidget,
    );
  });
}
