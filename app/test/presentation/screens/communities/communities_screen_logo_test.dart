import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:meeting_place_vtc/meeting_place_vtc.dart';
import 'package:mpx_flutter_reference_app/application/services/vtc_service/vtc_service.dart';
import 'package:mpx_flutter_reference_app/domain/models/vtc/vtc_community.dart';
import 'package:mpx_flutter_reference_app/l10n/app_localizations.dart';
import 'package:mpx_flutter_reference_app/presentation/screens/communities/communities_screen.dart';
import 'package:mpx_flutter_reference_app/presentation/themes/app_theme.dart';
import 'package:mpx_flutter_reference_app/presentation/themes/tokens/mc_icons.dart';

const _chess = 'did:web:chess.example';
const _football = 'did:web:football.example';
const _unreachable = 'did:web:gone.example';
final _chessLogo = Uri.parse('https://chess.example/logo.png');

/// Three communities: one with a logo, one without, one whose profile
/// cannot be read.
class _FakeVtcService extends Fake implements VtcService {
  final List<String> profileReads = [];

  @override
  Stream<void> get membershipsChanged => const Stream.empty();

  @override
  Future<List<VtcCommunity>> communities() async => [
    for (final (did, name) in [
      (_chess, 'Chess club'),
      (_football, 'Football club'),
      (_unreachable, 'Gone club'),
    ])
      VtcCommunity(
        communityDid: did,
        personaDid: 'did:key:z$name',
        contextId: 'vta',
        name: name,
      ),
  ];

  @override
  Future<CommunityProfile> readProfile(String communityDid) async {
    profileReads.add(communityDid);
    return switch (communityDid) {
      _chess => CommunityProfile(communityDid: _chess, logoUrl: _chessLogo),
      _football => const CommunityProfile(communityDid: _football),
      _ => throw MeetingPlaceVtcSDKException(
        message: 'unreachable',
        code: MeetingPlaceVtcSDKErrorCode.values.first,
      ),
    };
  }
}

void main() {
  late _FakeVtcService service;

  setUp(() => service = _FakeVtcService());

  ProviderContainer keptWhileRunning() {
    final container = ProviderContainer(
      overrides: [vtcServiceProvider.overrideWithValue(service)],
    );
    addTearDown(container.dispose);
    return container;
  }

  /// Shows the Communities tab, or something else in its place, with
  /// [container], which keeps what the app keeps while it runs.
  Future<void> pumpScreen(
    WidgetTester tester, {
    ProviderContainer? container,
    bool open = true,
  }) async {
    final scope = container ?? keptWhileRunning();
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: scope,
        child: MaterialApp(
          theme: AppTheme.dark,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: open ? const CommunitiesScreen() : const SizedBox.shrink(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Finder inRow(String did, Finder finder) =>
      find.descendant(of: find.byKey(Key('community_$did')), matching: finder);

  testWidgets('shows the logo a community gives', (tester) async {
    await pumpScreen(tester);

    expect(find.byKey(const Key('community_logo_$_chess')), findsOneWidget);
    final logo = tester.widget<Image>(inRow(_chess, find.byType(Image)));
    expect((logo.image as NetworkImage).url, _chessLogo.toString());
  });

  testWidgets('shows the community icon without a logo', (tester) async {
    await pumpScreen(tester);

    for (final did in [_football, _unreachable]) {
      expect(find.byKey(Key('community_logo_$did')), findsNothing);
      expect(inRow(did, find.byIcon(McIcons.community)), findsOneWidget);
    }
  });

  testWidgets('reads each profile once while the app runs', (tester) async {
    final container = keptWhileRunning();
    await pumpScreen(tester, container: container);
    await pumpScreen(tester, container: container, open: false);

    await pumpScreen(tester, container: container);

    expect(service.profileReads, hasLength(3));
  });
}
