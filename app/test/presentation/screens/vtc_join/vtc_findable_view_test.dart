import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mpx_flutter_reference_app/application/services/vtc_trust_service/vtc_trust_service.dart';
import 'package:mpx_flutter_reference_app/l10n/app_localizations.dart';
import 'package:mpx_flutter_reference_app/presentation/screens/vtc_join/vtc_findable_view.dart';
import 'package:mpx_flutter_reference_app/presentation/themes/app_theme.dart';

const _communityDid = 'did:webvh:community.example';

/// Whether members can find the member, as the community answers it.
class _FakeTrustService extends Fake implements VtcTrustService {
  bool findable = false;
  VtcTrustFailure? refusal;
  final List<bool> changes = [];

  @override
  Future<bool> isFindable(String communityDid) async => findable;

  @override
  Future<void> setFindable(
    String communityDid, {
    required bool findable,
  }) async {
    if (refusal case final refusal?) throw VtcTrustException(refusal);
    changes.add(findable);
    this.findable = findable;
  }
}

void main() {
  late _FakeTrustService service;

  setUp(() => service = _FakeTrustService());

  Future<void> pumpView(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [vtcTrustServiceProvider.overrideWithValue(service)],
        child: MaterialApp(
          theme: AppTheme.dark,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const Scaffold(
            body: SingleChildScrollView(
              child: VtcFindableView(
                communityDid: _communityDid,
                communityName: 'Club',
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Switch findableSwitch(WidgetTester tester) =>
      tester.widget<Switch>(find.byKey(const Key('vtc_findable_switch')));

  testWidgets('tells what letting members find you does', (tester) async {
    await pumpView(tester);

    expect(find.text('Let members find you'), findsOneWidget);
    expect(
      find.textContaining('Let members of Club find you to vouch for you'),
      findsOneWidget,
    );
    expect(findableSwitch(tester).value, isFalse);
  });

  testWidgets('shows what the community answers', (tester) async {
    service.findable = true;

    await pumpView(tester);

    expect(findableSwitch(tester).value, isTrue);
  });

  testWidgets('lets members find you, then stops them', (tester) async {
    await pumpView(tester);

    await tester.tap(find.byKey(const Key('vtc_findable_switch')));
    await tester.pumpAndSettle();
    expect(findableSwitch(tester).value, isTrue);

    await tester.tap(find.byKey(const Key('vtc_findable_switch')));
    await tester.pumpAndSettle();

    expect(service.changes, [true, false]);
    expect(findableSwitch(tester).value, isFalse);
  });

  testWidgets('says when the community does not allow it', (tester) async {
    service.refusal = VtcTrustFailure.notAllowed;
    await pumpView(tester);

    await tester.tap(find.byKey(const Key('vtc_findable_switch')));
    await tester.pumpAndSettle();

    expect(find.text("Club doesn't let members show this."), findsOneWidget);
    expect(findableSwitch(tester).value, isFalse);
  });

  testWidgets('says when the change failed otherwise', (tester) async {
    service.refusal = VtcTrustFailure.network;
    await pumpView(tester);

    await tester.tap(find.byKey(const Key('vtc_findable_switch')));
    await tester.pumpAndSettle();

    expect(find.text("Couldn't change this. Try again."), findsOneWidget);
  });
}
