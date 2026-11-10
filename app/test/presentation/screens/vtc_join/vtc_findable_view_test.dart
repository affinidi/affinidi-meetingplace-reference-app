import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image/image.dart' as img;
import 'package:meeting_place_vtc/meeting_place_vtc.dart';
import 'package:mpx_flutter_reference_app/application/services/identities_service/identities_service.dart';
import 'package:mpx_flutter_reference_app/application/services/identities_service/identities_service_state.dart';
import 'package:mpx_flutter_reference_app/application/services/vtc_trust_service/vtc_trust_service.dart';
import 'package:mpx_flutter_reference_app/domain/models/identity/identity.dart';
import 'package:mpx_flutter_reference_app/l10n/app_localizations.dart';
import 'package:mpx_flutter_reference_app/presentation/screens/vtc_join/vtc_findable_view.dart';
import 'package:mpx_flutter_reference_app/presentation/themes/app_theme.dart';
import 'package:mpx_flutter_reference_app/presentation/widgets/onboarding_style/onboarding_style.dart';

import '../../../fakes/fake_identities.dart';
import '../../../fakes/fake_identities_service.dart';

const _communityDid = 'did:webvh:community.example';

/// The member's directory card, as the community answers it.
class _FakeTrustService extends Fake implements VtcTrustService {
  String? avatarSha256;
  final List<String?> pictures = [];

  @override
  Future<void> setDirectoryPicture(
    String communityDid, {
    required String? base64,
  }) async {
    if (refusal case final refusal?) throw VtcTrustException(refusal);
    pictures.add(base64);
    avatarSha256 = base64 == null ? null : 'sha-of-picture';
  }

  bool findable = false;
  bool hidden = false;
  String? name;
  VtcTrustFailure? refusal;
  final List<bool> changes = [];
  final List<String> names = [];

  /// How often the card was read.
  int reads = 0;

  /// Holds the card back until completed.
  Completer<void>? readGate;

  /// Why reading the card fails, if it does.
  VtcTrustFailure? readRefusal;

  /// Holds the name back until completed.
  Completer<void>? nameGate;

  @override
  Future<MyDirectoryCard> directoryCard(String communityDid) async {
    reads++;
    await readGate?.future;
    if (readRefusal case final refusal?) throw VtcTrustException(refusal);
    return MyDirectoryCard(
      entryId: 'dir_me',
      isDidVisibleToMembers: findable,
      isHidden: hidden,
      displayName: name,
    );
  }

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
    if (findable) hidden = false;
  }

  @override
  Future<void> setDirectoryName(
    String communityDid, {
    required String name,
  }) async {
    await nameGate?.future;
    if (refusal case final refusal?) throw VtcTrustException(refusal);
    names.add(name);
    this.name = name;
  }
}

void main() {
  late _FakeTrustService service;
  late Identity joinedAs;

  setUp(() {
    service = _FakeTrustService();
    joinedAs = FakeIdentities.primaryIdentity;
  });

  /// The primary identity with a picture.
  Identity withPicture() => joinedAs.copyWith(
    card: joinedAs.card.copyWith(
      profilePic: base64Encode(
        img.encodePng(img.Image(width: 300, height: 300)),
      ),
    ),
  );

  late FakeIdentitiesService identitiesService;

  /// What the app keeps while it runs, across showing the view again.
  ProviderContainer keptWhileRunning() {
    identitiesService = FakeIdentitiesService(
      IdentitiesServiceState(
        currentIdentity: joinedAs,
        identities: [joinedAs, FakeIdentities.secondaryIdentity],
      ),
    );
    final container = ProviderContainer(
      overrides: [
        vtcTrustServiceProvider.overrideWithValue(service),
        identitiesServiceProvider.overrideWith(() => identitiesService),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  /// Shows the view, or something else in its place, with [container], and
  /// lets it settle when [settles].
  Future<void> pumpView(
    WidgetTester tester, {
    ProviderContainer? container,
    bool open = true,
    bool settles = true,
  }) async {
    await tester.binding.setSurfaceSize(const Size(400, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container ?? keptWhileRunning(),
        child: MaterialApp(
          theme: AppTheme.dark,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: SingleChildScrollView(
              child: open
                  ? const VtcFindableView(
                      communityDid: _communityDid,
                      communityName: 'Club',
                    )
                  : const SizedBox.shrink(),
            ),
          ),
        ),
      ),
    );
    if (settles) await tester.pumpAndSettle();
  }

  Switch findableSwitch(WidgetTester tester) =>
      tester.widget<Switch>(find.byKey(const Key('vtc_findable_switch')));

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
    expect(
      find.text(
        'Members of Club see you as John Doe, with the name and picture of '
        'the identity you joined with.',
      ),
      findsOneWidget,
    );
    expect(findableSwitch(tester).value, isFalse);
  });

  testWidgets('colours the switch as every other switch', (tester) async {
    await pumpView(tester);

    final findable = findableSwitch(tester);
    expect(findable.activeTrackColor, isNull);
    expect(findable.activeThumbColor, isNull);
  });

  testWidgets('sends the identity\'s name when letting members find you', (
    tester,
  ) async {
    await pumpView(tester);
    expect(service.names, isEmpty, reason: 'nothing leaves before that');

    await tapKey(tester, 'vtc_findable_switch');

    expect(service.names, ['John Doe']);
    expect(service.changes, [true]);
  });

  testWidgets('brings a findable member\'s name in step with the identity', (
    tester,
  ) async {
    service
      ..findable = true
      ..name = 'Johnny';

    await pumpView(tester);

    expect(service.names, ['John Doe']);
  });

  testWidgets('makes findable again a card hidden when joining', (
    tester,
  ) async {
    service
      ..findable = true
      ..hidden = true;

    await pumpView(tester);

    expect(service.changes, [true]);
    expect(findableSwitch(tester).value, isTrue);
  });

  testWidgets('sends the identity\'s picture when letting members find you', (
    tester,
  ) async {
    joinedAs = withPicture();
    await pumpView(tester);
    expect(service.pictures, isEmpty, reason: 'nothing leaves before that');

    await tapKey(tester, 'vtc_findable_switch');

    expect(service.pictures, [joinedAs.card.profilePic]);
    expect(service.changes, [true]);
  });

  testWidgets('adds the picture to a findable card without one', (
    tester,
  ) async {
    joinedAs = withPicture();
    service
      ..findable = true
      ..name = 'John Doe';

    await pumpView(tester);

    expect(service.pictures, [joinedAs.card.profilePic]);
  });

  testWidgets('sends no picture an identity does not have', (tester) async {
    await pumpView(tester);

    await tapKey(tester, 'vtc_findable_switch');

    expect(service.pictures, isEmpty);
  });

  testWidgets('leaves the name alone while members cannot find you', (
    tester,
  ) async {
    service.name = 'Johnny';

    await pumpView(tester);

    expect(service.names, isEmpty);
  });

  testWidgets('says when the community does not take the name', (tester) async {
    service.refusal = VtcTrustFailure.nameRefused;
    await pumpView(tester);

    await tapKey(tester, 'vtc_findable_switch');

    expect(find.text("Club doesn't accept this name."), findsOneWidget);
    expect(findableSwitch(tester).value, isFalse);
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

  final syncing = find.byKey(const Key('vtc_findable_syncing'));

  testWidgets('shows the kept answer at once, and asks again', (tester) async {
    final container = keptWhileRunning();
    await pumpView(tester, container: container);
    await pumpView(tester, container: container, open: false);
    // Already in step with the identity: nothing to write.
    service
      ..findable = true
      ..name = 'John Doe'
      ..readGate = Completer();

    await pumpView(tester, container: container, settles: false);
    await tester.pump();

    expect(findableSwitch(tester).value, isFalse);
    expect(findableSwitch(tester).onChanged, isNotNull);
    expect(syncing, findsOneWidget);
    service.readGate!.complete();
    await tester.pumpAndSettle();
    expect(findableSwitch(tester).value, isTrue);
    expect(syncing, findsNothing);
    expect(service.reads, 2);
  });

  testWidgets('reads the card once when first opened', (tester) async {
    await pumpView(tester);

    expect(service.reads, 1);
  });

  testWidgets('shows the card before bringing it in step', (tester) async {
    service
      ..findable = true
      ..name = 'Johnny'
      ..nameGate = Completer();

    await pumpView(tester, settles: false);
    await tester.pump();
    await tester.pump();

    expect(findableSwitch(tester).value, isTrue);
    expect(syncing, findsOneWidget);
    expect(service.names, isEmpty);
    service.nameGate!.complete();
    await tester.pumpAndSettle();
    expect(service.names, ['John Doe']);
    expect(syncing, findsNothing);
  });

  testWidgets('keeps the answer when asking again fails', (tester) async {
    final container = keptWhileRunning();
    service.findable = true;
    await pumpView(tester, container: container);
    await pumpView(tester, container: container, open: false);
    service.readRefusal = VtcTrustFailure.network;

    await pumpView(tester, container: container);

    expect(findableSwitch(tester).value, isTrue);
    expect(find.byType(OnboardingMessage), findsNothing);
  });

  testWidgets('says when the card cannot be read at all', (tester) async {
    service.readRefusal = VtcTrustFailure.network;

    await pumpView(tester);

    expect(findableSwitch(tester).onChanged, isNull);
    expect(find.text("Couldn't change this. Try again."), findsOneWidget);
  });

  testWidgets('asks no more when other identities change', (tester) async {
    await pumpView(tester);

    identitiesService.setState(
      IdentitiesServiceState(currentIdentity: joinedAs, identities: [joinedAs]),
    );
    await tester.pumpAndSettle();

    expect(service.reads, 1);
  });
}
