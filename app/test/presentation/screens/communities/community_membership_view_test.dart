import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:meeting_place_vtc/meeting_place_vtc.dart';
import 'package:mpx_flutter_reference_app/application/services/identities_service/identities_service.dart';
import 'package:mpx_flutter_reference_app/application/services/identities_service/identities_service_state.dart';
import 'package:mpx_flutter_reference_app/application/services/vtc_service/vtc_service.dart';
import 'package:mpx_flutter_reference_app/domain/models/identity/identity.dart';
import 'package:mpx_flutter_reference_app/domain/models/vtc/vtc_community.dart';
import 'package:mpx_flutter_reference_app/domain/models/vtc/vtc_left_membership.dart';
import 'package:mpx_flutter_reference_app/domain/models/vtc/vtc_membership_card.dart';
import 'package:mpx_flutter_reference_app/domain/models/vtc/vtc_vetter_card.dart';
import 'package:mpx_flutter_reference_app/infrastructure/providers/app_logger_provider.dart';
import 'package:mpx_flutter_reference_app/l10n/app_localizations.dart';
import 'package:mpx_flutter_reference_app/presentation/screens/communities/community_membership_view.dart';
import 'package:mpx_flutter_reference_app/presentation/screens/vtc_join/vtc_membership_card_view.dart';
import 'package:mpx_flutter_reference_app/presentation/themes/app_theme.dart';
import 'package:mpx_flutter_reference_app/presentation/themes/tokens/mc_icons.dart';

import '../../../fakes/fake_identities.dart';
import '../../../fakes/fake_identities_service.dart';
import '../../../mocks/fake_app_logger.dart';

const _club = 'did:webvh:QmClub:vtc.example';
const _me = 'did:webvh:QmMe:vta.example:me';

/// The identity [did] on the member's VTA, named [name], in the context the
/// membership lives in.
Identity _vtaIdentity(String did, String name) =>
    FakeIdentities.primaryIdentity.copyWith(
      did: did,
      card: FakeIdentities.primaryIdentity.card.copyWith(
        did: did,
        displayName: name,
      ),
      vtaContextId: 'vta',
      vtaProfileId: '01PROFILE',
    );

/// The member's role, membership card and vetter card, as their VTA keeps
/// them, and their membership until they leave.
class _FakeVtcService extends Fake implements VtcService {
  bool member = true;

  String? role = 'moderator';
  VtcMembershipCard? card = const VtcMembershipCard(
    issuer: _club,
    memberDid: _me,
    credential: {
      'type': ['VerifiableCredential', 'MembershipCredential'],
      'issuer': _club,
      'credentialSubject': {'id': _me},
    },
  );
  VtcVetterCard? heldVetterCard;
  Exception? failure;
  final cardChanges = StreamController<void>.broadcast();

  @override
  Stream<void> get membershipsChanged => cardChanges.stream;

  @override
  Future<String?> communityRole(String communityDid) async {
    if (failure case final failure?) throw failure;
    return role;
  }

  @override
  Future<VtcMembershipCard?> membershipCard(
    String communityDid, {
    void Function(MembershipCardStep step)? onStep,
  }) async => card;

  @override
  Future<VtcVetterCard?> vetterCard(String communityDid) async =>
      heldVetterCard;

  @override
  Future<CommunityProfile> readProfile(String communityDid) async =>
      const CommunityProfile(communityDid: _club);

  @override
  Future<VtcCommunity?> community(String communityDid) async => member
      ? const VtcCommunity(
          communityDid: _club,
          personaDid: _me,
          contextId: 'vta',
        )
      : null;

  @override
  Future<List<VtcCommunity>> communities() async => [?await community(_club)];

  @override
  Future<void> leave(
    String communityDid, {
    void Function(VtcLeaveStep step)? onStep,
  }) async {
    VtcLeaveStep.values.forEach(onStep ?? (_) {});
    member = false;
  }
}

void main() {
  late _FakeVtcService service;
  var identities = IdentitiesServiceState();

  setUp(() {
    service = _FakeVtcService();
    identities = IdentitiesServiceState();
  });

  Future<AppLocalizations> pumpView(WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(400, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          vtcServiceProvider.overrideWithValue(service),
          identitiesServiceProvider.overrideWith(
            () => FakeIdentitiesService(identities),
          ),
          appLoggerProvider.overrideWithValue(FakeAppLogger()),
        ],
        child: MaterialApp(
          theme: AppTheme.dark,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          // A page below, for the view to close back to.
          home: Builder(
            builder: (context) => TextButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const Scaffold(
                    body: CommunityMembershipView(
                      communityDid: _club,
                      communityName: 'Football club',
                    ),
                  ),
                ),
              ),
              child: const Text('Communities'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Communities'));
    await tester.pumpAndSettle();
    return AppLocalizations.of(
      tester.element(find.byType(CommunityMembershipView)),
    )!;
  }

  testWidgets('shows the role and the membership card', (tester) async {
    await pumpView(tester);

    expect(
      find.descendant(
        of: find.byKey(const Key('community_membership_role')),
        matching: find.text('Moderator'),
      ),
      findsOneWidget,
    );
    expect(find.byType(VtcMembershipCardView), findsOneWidget);
  });

  group('identity', () {
    Finder identityLine() =>
        find.byKey(const Key('community_membership_identity'));

    testWidgets('shows the identity joined with above the cards', (
      tester,
    ) async {
      identities = IdentitiesServiceState(
        identities: [_vtaIdentity('did:webvh:QmAda:vta.example:ada', 'Ada')],
      );

      final l10n = await pumpView(tester);

      expect(
        find.descendant(
          of: identityLine(),
          matching: find.text(l10n.vtcCommunityIdentityNewDid('Ada')),
        ),
        findsOneWidget,
      );
      expect(
        tester.getTopLeft(identityLine()).dy,
        lessThan(
          tester.getTopLeft(find.byKey(const Key('vtc_membership_card'))).dy,
        ),
      );
    });

    testWidgets('says when the community knows the identity\'s own DID', (
      tester,
    ) async {
      identities = IdentitiesServiceState(
        identities: [_vtaIdentity(_me, 'Ada')],
      );

      final l10n = await pumpView(tester);

      expect(
        find.descendant(
          of: identityLine(),
          matching: find.text(l10n.vtcCommunityIdentityOwnDid('Ada')),
        ),
        findsOneWidget,
      );
    });

    testWidgets('shows none for a membership of a new identity', (
      tester,
    ) async {
      identities = IdentitiesServiceState(
        identities: [
          _vtaIdentity(
            'did:webvh:QmAda:vta.example:ada',
            'Ada',
          ).copyWith(vtaContextId: 'mpx-other'),
        ],
      );

      await pumpView(tester);

      expect(identityLine(), findsNothing);
    });
  });

  testWidgets('folds each card\'s details away until opened', (tester) async {
    await pumpView(tester);
    expect(find.text(_me), findsNothing);

    await tester.tap(find.byIcon(McIcons.chevronDown));
    await tester.pumpAndSettle();

    expect(find.text(_me), findsOneWidget);
  });

  testWidgets('lists a vetter\'s card under the membership card', (
    tester,
  ) async {
    service.heldVetterCard = const VtcVetterCard(
      issuer: _club,
      vetterDid: _me,
      credential: {
        'type': ['VerifiableCredential', 'AuthorityCredential'],
        'issuer': _club,
        'credentialSubject': {'id': _me},
      },
    );

    await pumpView(tester);

    final membershipCard = find.byKey(const Key('vtc_membership_card'));
    final vetterCard = find.byKey(const Key('vtc_vetter_role_card'));
    expect(vetterCard, findsOneWidget);
    expect(
      tester.getTopLeft(vetterCard).dy,
      greaterThan(tester.getTopLeft(membershipCard).dy),
    );
    expect(find.byIcon(McIcons.chevronDown), findsNWidgets(2));
  });

  testWidgets('shows no vetter card to a member who is not a vetter', (
    tester,
  ) async {
    await pumpView(tester);

    expect(find.byKey(const Key('vtc_vetter_role_card')), findsNothing);
  });

  testWidgets('shows the new role once the cards change', (tester) async {
    await pumpView(tester);
    service.role = 'admin';

    service.cardChanges.add(null);
    await tester.pumpAndSettle();

    expect(
      find.descendant(
        of: find.byKey(const Key('community_membership_role')),
        matching: find.text('Administrator'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('says the card is on its way until the VTA holds it', (
    tester,
  ) async {
    service
      ..role = null
      ..card = null;

    final l10n = await pumpView(tester);

    expect(find.byKey(const Key('community_membership_role')), findsNothing);
    expect(find.byType(VtcMembershipCardView), findsNothing);
    expect(find.text(l10n.vtcMembershipCardOnItsWay), findsOneWidget);
  });

  group('leave', () {
    Finder leaveButton() => find.byKey(const Key('community_membership_leave'));
    Finder confirmButton() => find.descendant(
      of: find.byType(AlertDialog),
      matching: find.text('Leave community'),
    );

    testWidgets('leaves after confirming, then closes the community', (
      tester,
    ) async {
      final l10n = await pumpView(tester);

      await tester.tap(leaveButton());
      await tester.pumpAndSettle();
      expect(
        find.text(l10n.vtcJoinLeaveTitle('Football club')),
        findsOneWidget,
      );

      await tester.tap(confirmButton());
      await tester.pumpAndSettle();
      expect(service.member, isFalse);
      expect(find.text(l10n.vtcJoinLeft('Football club')), findsOneWidget);

      await tester.tap(find.text(l10n.generalDone));
      await tester.pumpAndSettle();
      expect(find.byType(CommunityMembershipView), findsNothing);
      expect(find.text('Communities'), findsOneWidget);
    });

    testWidgets('stays a member when the member cancels', (tester) async {
      final l10n = await pumpView(tester);

      await tester.tap(leaveButton());
      await tester.pumpAndSettle();
      await tester.tap(find.text(l10n.generalCancel));
      await tester.pumpAndSettle();

      expect(service.member, isTrue);
      expect(find.byType(CommunityMembershipView), findsOneWidget);
    });
  });

  testWidgets('asks to link a VTA when none is', (tester) async {
    service.failure = const VtaNotLinkedException();

    final l10n = await pumpView(tester);

    expect(find.text(l10n.membershipCredentialsVtaMissing), findsOneWidget);
  });

  testWidgets('says when the VTA cannot be reached', (tester) async {
    service.failure = MeetingPlaceVtcSDKException(
      message: 'unreachable',
      code: MeetingPlaceVtcSDKErrorCode.values.first,
    );

    final l10n = await pumpView(tester);

    expect(find.text(l10n.membershipCredentialsUnreachable), findsOneWidget);
  });
}
