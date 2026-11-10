import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:meeting_place_vtc/meeting_place_vtc.dart';
import 'package:mpx_flutter_reference_app/application/services/vtc_service/vtc_service.dart';
import 'package:mpx_flutter_reference_app/infrastructure/providers/app_logger_provider.dart';
import 'package:mpx_flutter_reference_app/l10n/app_localizations.dart';
import 'package:mpx_flutter_reference_app/presentation/screens/vtc_rooms/vtc_room_screen.dart';
import 'package:mpx_flutter_reference_app/presentation/screens/vtc_rooms/vtc_rooms_screen.dart';
import 'package:mpx_flutter_reference_app/presentation/themes/app_theme.dart';

import '../../../mocks/fake_app_logger.dart';

const _club = 'did:webvh:QmClub:vtc.example';
const _talks = 'did:webvh:QmTalks:vtc.example:room-dids:talks';
const _me = 'did:key:z6MkMe';
const _speaker = 'did:key:z6MkSpeaker';

final _until = DateTime.utc(2027, 2, 7);
final _at = DateTime.utc(2026, 11, 10, 9);

RoomOffer _offer({Set<RoomAction> actions = const {RoomAction.read}}) =>
    RoomOffer(
      roomId: _talks,
      host: _club,
      label: 'DevCon 2026 — Talks',
      description: 'Talk abstracts and slides.',
      visibility: RoomVisibility.attributed,
      actions: actions,
      validUntil: _until,
      offeredAt: _at,
      isOpen: true,
      invitation: '{}',
      membership: const {},
      authority: const {},
    );

RoomMembership _room({
  Set<RoomAction> actions = const {RoomAction.read},
  RoomMemberState state = RoomMemberState.admitted,
}) => RoomMembership(
  roomId: _talks,
  host: _club,
  label: 'DevCon 2026 — Talks',
  visibility: RoomVisibility.attributed,
  actions: actions,
  validUntil: _until,
  state: state,
  roomState: RoomState.active,
  offeredAt: _at,
  admittedAt: _at,
);

/// A community with one room, the Talks room, as one member sees it.
class _FakeVtcService extends Fake implements VtcService {
  List<RoomOffer> offers = [];
  List<RoomMembership> rooms = [];
  final List<RoomOffer> accepted = [];
  final List<(String, String?)> written = [];
  final Map<String, RoomRecord> records = {};
  Exception? refuseWrite;

  @override
  Future<RoomOffers> roomOffers(String communityDid) async =>
      RoomOffers(offers: offers, renewals: const []);

  @override
  Future<List<RoomMembership>> roomMemberships(String communityDid) async =>
      rooms;

  @override
  Future<RoomAcceptance> acceptRoomOffer(
    String communityDid,
    RoomOffer offer,
  ) async {
    accepted.add(offer);
    offers = [];
    rooms = [_room(actions: offer.actions)];
    return RoomAcceptance(roomId: offer.roomId, alreadyJoined: false);
  }

  @override
  Future<String> roomMemberDid(String communityDid) async => _me;

  @override
  Future<RoomRecords> roomRecords(
    String communityDid,
    RoomMembership room,
  ) async => RoomRecords(
    roomId: room.roomId,
    complete: true,
    records: [
      for (final record in records.values)
        RoomRecordSummary(
          key: record.key,
          version: record.version,
          status: record.status,
          updatedAt: _at,
        ),
    ],
  );

  @override
  Future<RoomRecord?> roomRecord(
    String communityDid,
    RoomMembership room, {
    required String key,
  }) async => records[key];

  @override
  Future<RoomWrite> writeRoomRecord(
    String communityDid,
    RoomMembership room, {
    required String title,
    String? body,
  }) async {
    if (refuseWrite case final error?) throw error;
    written.add((title, body));
    final key = 'k${records.length + 1}';
    records[key] = RoomRecord(
      roomId: room.roomId,
      key: key,
      version: records.length + 1,
      status: RoomRecordStatus.active,
      author: _me,
      updatedAt: _at,
      title: title,
      body: body,
    );
    return RoomWrite(key: key, version: records.length);
  }
}

void main() {
  late _FakeVtcService service;

  setUp(() => service = _FakeVtcService());

  Future<void> pump(WidgetTester tester, Widget home) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          vtcServiceProvider.overrideWithValue(service),
          appLoggerProvider.overrideWithValue(FakeAppLogger()),
        ],
        child: MaterialApp(
          theme: AppTheme.dark,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: home,
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  group('VtcRoomsScreen', () {
    testWidgets('accepts an offer, then lists the room', (tester) async {
      service.offers = [_offer()];
      await pump(
        tester,
        const VtcRoomsScreen(communityDid: _club, communityName: 'DevCon'),
      );

      expect(find.text('Offered to you'), findsOneWidget);
      expect(find.text('Read only'), findsOneWidget);
      await tester.tap(find.byKey(const Key('vtc_room_accept_$_talks')));
      await tester.pumpAndSettle();

      expect(service.accepted.single.roomId, _talks);
      expect(find.text("You're in DevCon 2026 — Talks."), findsOneWidget);
      expect(find.text('Offered to you'), findsNothing);
      expect(find.byKey(const Key('vtc_room_$_talks')), findsOneWidget);
      expect(find.textContaining('did:'), findsNothing);
    });

    testWidgets('says so when there are no rooms', (tester) async {
      await pump(tester, const VtcRoomsScreen(communityDid: _club));

      expect(find.textContaining('No rooms yet'), findsOneWidget);
    });
  });

  group('VtcRoomScreen', () {
    testWidgets('lets a speaker write a record and shows it as theirs', (
      tester,
    ) async {
      await pump(
        tester,
        VtcRoomScreen(
          communityDid: _club,
          room: _room(actions: {RoomAction.read, RoomAction.write}),
        ),
      );
      expect(find.textContaining('Tap Write'), findsOneWidget);

      await tester.tap(find.byKey(const Key('vtc_room_write')));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const Key('vtc_room_write_title')),
        'Opening keynote',
      );
      await tester.enterText(
        find.byKey(const Key('vtc_room_write_body')),
        'Welcome to DevCon 2026',
      );
      await tester.pump();
      await tester.tap(find.byKey(const Key('vtc_room_write_send')));
      await tester.pumpAndSettle();

      expect(service.written.single, (
        'Opening keynote',
        'Welcome to DevCon 2026',
      ));
      expect(find.text('Opening keynote'), findsOneWidget);
      expect(find.text('Welcome to DevCon 2026'), findsOneWidget);
      expect(find.textContaining('Written by you'), findsOneWidget);
    });

    testWidgets('shows an attendee the talks, with no way to write', (
      tester,
    ) async {
      service.records['k1'] = RoomRecord(
        roomId: _talks,
        key: 'k1',
        version: 1,
        status: RoomRecordStatus.active,
        author: _speaker,
        updatedAt: _at,
        title: 'Opening keynote',
        body: 'Welcome to DevCon 2026',
      );
      await pump(tester, VtcRoomScreen(communityDid: _club, room: _room()));

      expect(find.text('Opening keynote'), findsOneWidget);
      expect(find.textContaining('Written by another member'), findsOneWidget);
      expect(find.byKey(const Key('vtc_room_read_only')), findsOneWidget);
      expect(find.byKey(const Key('vtc_room_write')), findsNothing);
      expect(find.textContaining('did:'), findsNothing);
    });

    testWidgets('says a refused write was refused for reading only', (
      tester,
    ) async {
      service.refuseWrite = MeetingPlaceVtcSDKException.refused(
        'rooms/keys/act:actionNotHeld',
      );
      await pump(
        tester,
        VtcRoomScreen(
          communityDid: _club,
          room: _room(actions: {RoomAction.read, RoomAction.write}),
        ),
      );

      await tester.tap(find.byKey(const Key('vtc_room_write')));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const Key('vtc_room_write_title')),
        'Sneaky',
      );
      await tester.pump();
      await tester.tap(find.byKey(const Key('vtc_room_write_send')));
      await tester.pumpAndSettle();

      expect(
        find.textContaining('You can only read this room'),
        findsOneWidget,
      );
    });
  });
}
