import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:meeting_place_vtc/meeting_place_vtc.dart';
import 'package:mpx_flutter_reference_app/application/services/identities_service/identities_service.dart';
import 'package:mpx_flutter_reference_app/application/services/identities_service/identities_service_state.dart';
import 'package:mpx_flutter_reference_app/application/services/vtc_trust_service/vtc_trust_service.dart';
import 'package:mpx_flutter_reference_app/l10n/app_localizations.dart';
import 'package:mpx_flutter_reference_app/presentation/screens/vtc_join/vtc_findable_view.dart';
import 'package:mpx_flutter_reference_app/presentation/themes/app_theme.dart';

import '../../../fakes/fake_identities.dart';
import '../../../fakes/fake_identities_service.dart';

const _communityDid = 'did:webvh:community.example';

/// The member's directory card, as the community answers it.
class _FakeTrustService extends Fake implements VtcTrustService {
  bool findable = false;
  String? name;
  VtcTrustFailure? refusal;
  final List<bool> changes = [];
  final List<String> names = [];

  @override
  Future<MyDirectoryCard> directoryCard(String communityDid) async =>
      MyDirectoryCard(
        entryId: 'dir_me',
        isDidVisibleToMembers: findable,
        displayName: name,
      );

  @override
  Future<String?> identityDid(String communityDid) async =>
      FakeIdentities.primaryIdentity.did;

  @override
  Future<void> setFindable(
    String communityDid, {
    required bool findable,
  }) async {
    if (refusal case final refusal?) throw VtcTrustException(refusal);
    changes.add(findable);
    this.findable = findable;
  }

  @override
  Future<void> setDirectoryName(
    String communityDid, {
    required String name,
  }) async {
    if (refusal case final refusal?) throw VtcTrustException(refusal);
    names.add(name);
    this.name = name;
  }
}

void main() {
  late _FakeTrustService service;

  setUp(() => service = _FakeTrustService());

  Future<void> pumpView(WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(400, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          vtcTrustServiceProvider.overrideWithValue(service),
          identitiesServiceProvider.overrideWith(
            () => FakeIdentitiesService(
              IdentitiesServiceState(
                currentIdentity: FakeIdentities.primaryIdentity,
                identities: [
                  FakeIdentities.primaryIdentity,
                  FakeIdentities.secondaryIdentity,
                ],
              ),
            ),
          ),
        ],
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

  String nameText(WidgetTester tester) => tester
      .widget<EditableText>(
        find.descendant(
          of: find.byKey(const Key('vtc_directory_name')),
          matching: find.byType(EditableText),
        ),
      )
      .controller
      .text;

  Future<void> tapKey(WidgetTester tester, String key) async {
    await tester.ensureVisible(find.byKey(Key(key)));
    await tester.tap(find.byKey(Key(key)));
    await tester.pumpAndSettle();
  }

  testWidgets('tells what letting members find you does', (tester) async {
    await pumpView(tester);

    expect(find.text('Let members find you'), findsOneWidget);
    expect(
      find.textContaining('Let members of Club find you to vouch for you'),
      findsOneWidget,
    );
    expect(find.text('Members of Club see this name.'), findsOneWidget);
    expect(findableSwitch(tester).value, isFalse);
  });

  testWidgets('starts an unnamed card from the identity joined with', (
    tester,
  ) async {
    await pumpView(tester);

    expect(nameText(tester), 'John Doe');
    expect(service.names, isEmpty, reason: 'nothing leaves before saving');
  });

  testWidgets('shows the name the community holds', (tester) async {
    service.name = 'Johnny';

    await pumpView(tester);

    expect(nameText(tester), 'Johnny');
  });

  testWidgets('saves the name members see', (tester) async {
    await pumpView(tester);

    await tester.enterText(find.byKey(const Key('vtc_directory_name')), 'JD');
    await tapKey(tester, 'vtc_directory_name_save');

    expect(service.names, ['JD']);
    expect(find.text('Saved. Members now see this name.'), findsOneWidget);
  });

  testWidgets('says when the community does not take the name', (tester) async {
    service.refusal = VtcTrustFailure.nameRefused;
    await pumpView(tester);

    await tapKey(tester, 'vtc_directory_name_save');

    expect(find.text("Club doesn't accept this name."), findsOneWidget);
  });

  testWidgets('shows what the community answers', (tester) async {
    service.findable = true;

    await pumpView(tester);

    expect(findableSwitch(tester).value, isTrue);
  });

  testWidgets('lets members find you, then stops them', (tester) async {
    await pumpView(tester);

    await tapKey(tester, 'vtc_findable_switch');
    expect(findableSwitch(tester).value, isTrue);

    await tapKey(tester, 'vtc_findable_switch');

    expect(service.changes, [true, false]);
    expect(findableSwitch(tester).value, isFalse);
  });

  testWidgets('says when the community does not allow it', (tester) async {
    service.refusal = VtcTrustFailure.notAllowed;
    await pumpView(tester);

    await tapKey(tester, 'vtc_findable_switch');

    expect(find.text("Club doesn't let members show this."), findsOneWidget);
    expect(findableSwitch(tester).value, isFalse);
  });

  testWidgets('says when the change failed otherwise', (tester) async {
    service.refusal = VtcTrustFailure.network;
    await pumpView(tester);

    await tapKey(tester, 'vtc_findable_switch');

    expect(find.text("Couldn't change this. Try again."), findsOneWidget);
  });
}
