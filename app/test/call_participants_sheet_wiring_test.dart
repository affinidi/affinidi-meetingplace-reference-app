import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meeting_place_matrix/meeting_place_matrix.dart';
import 'package:mpx_flutter_reference_app/application/services/contacts_service/contacts_service.dart';
import 'package:mpx_flutter_reference_app/application/services/incoming_call_service/incoming_call_notifier.dart';
import 'package:mpx_flutter_reference_app/application/services/incoming_call_service/incoming_call_state.dart';
import 'package:mpx_flutter_reference_app/domain/models/contact_card/contact_card.dart';
import 'package:mpx_flutter_reference_app/infrastructure/loggers/app_logger/app_logger.dart';
import 'package:mpx_flutter_reference_app/infrastructure/providers/app_logger_provider.dart';
import 'package:mpx_flutter_reference_app/infrastructure/providers/cache_manager_provider.dart';
import 'package:mpx_flutter_reference_app/infrastructure/providers/meeting_place_sdk_provider.dart';
import 'package:mpx_flutter_reference_app/infrastructure/services/permission_service/permission_service.dart';
import 'package:mpx_flutter_reference_app/l10n/app_localizations.dart';
import 'package:mpx_flutter_reference_app/presentation/screens/chat/audio_video_call/audio_video_call_screen.dart';
import 'package:mpx_flutter_reference_app/presentation/screens/chat/audio_video_call/audio_video_call_screen_controller.dart';
import 'package:mpx_flutter_reference_app/presentation/screens/chat/audio_video_call/audio_video_call_screen_state.dart';
import 'package:mpx_flutter_reference_app/presentation/screens/chat/audio_video_call/participants/call_participant_list_sheet.dart';
import 'package:mpx_flutter_reference_app/presentation/themes/app_theme.dart';
import 'package:mpx_flutter_reference_app/presentation/widgets/banners/active_call/active_call_controller.dart';

import 'fakes/fake_cache_manager.dart';
import 'fakes/fake_permission_service.dart';
import 'mocks/fake_active_call_controller.dart';
import 'mocks/fake_app_logger.dart';
import 'mocks/fake_contacts_service.dart';
import 'mocks/fake_meeting_place_matrix_sdk.dart';

const _kContactId = 'group-wiring-contact';

class _FakeIncomingCallState extends IncomingCallNotifier {
  @override
  IncomingCallState build() => const IncomingCallState.idle();
}

class _FixedStateController extends AudioVideoCallScreenController {
  _FixedStateController(this._fixed);

  final AudioVideoCallScreenState _fixed;

  @override
  AudioVideoCallScreenState build(String contactId) => _fixed;

  @override
  Future<void> startCall({bool isAudioOnly = false}) async {}
}

ContactCard _card(String did, String firstName) => ContactCard(
  id: did,
  did: did,
  type: 'contact',
  firstName: firstName,
  displayName: firstName,
);

Widget _wrap(AudioVideoCallScreenState state) {
  return ProviderScope(
    overrides: [
      appLoggerProvider.overrideWithValue(FakeAppLogger()),
      contactsServiceProvider.overrideWith(FakeContactsService.new),
      meetingPlaceSdkProvider.overrideWith(
        (ref) async => FakeMeetingPlaceMatrixSDK(),
      ),
      permissionServiceProvider.overrideWithValue(FakePermissionService()),
      cacheManagerProvider.overrideWith((ref) => FakeCacheManager()),
      incomingCallProvider.overrideWith(_FakeIncomingCallState.new),
      activeCallControllerProvider.overrideWith(FakeActiveCallController.new),
      audioVideoCallScreenControllerProvider(
        _kContactId,
      ).overrideWith(() => _FixedStateController(state)),
    ],
    child: MaterialApp(
      theme: AppTheme.dark,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const AudioVideoCallScreen(contactId: _kContactId),
    ),
  );
}

void main() {
  setUpAll(() {
    AppLogger.initialize(
      File('${Directory.systemTemp.path}/call_participants_wiring_test.log'),
    );
  });

  // A group call in which Alice (did:a) has joined and Bob (did:b) has not.
  AudioVideoCallScreenState groupState({bool isAudioOnly = true}) =>
      AudioVideoCallScreenState(
        status: AudioVideoCallStatus.active,
        peerName: 'Study Group',
        isGroupContact: true,
        isAudioOnly: isAudioOnly,
        memberContactCards: {
          'did:a': _card('did:a', 'Alice'),
          'did:b': _card('did:b', 'Bob'),
        },
        participants: const [
          AudioVideoCallParticipant(participantId: 'self-1', isSelf: true),
          AudioVideoCallParticipant(participantId: 'p-a', did: 'did:a'),
        ],
      );

  testWidgets('group call shows the participants button in the top bar', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap(groupState()));
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(find.byIcon(Icons.people_alt_outlined), findsOneWidget);
  });

  testWidgets(
    'tapping the participants button opens the sheet split by connection',
    (tester) async {
      await tester.pumpWidget(_wrap(groupState()));
      await tester.pump();

      await tester.tap(find.byIcon(Icons.people_alt_outlined));
      await tester.pumpAndSettle();

      final sheet = find.byType(CallParticipantListSheet);
      expect(sheet, findsOneWidget);

      // Section headers and the connected count derived from call state.
      expect(find.text('1 connected'), findsOneWidget);
      expect(find.text('Connected'), findsOneWidget);
      expect(find.text('Not connected'), findsOneWidget);

      // Within the sheet: Alice connected (no bell), Bob not (bell shown).
      expect(
        find.descendant(of: sheet, matching: find.text('Alice')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: sheet, matching: find.text('Bob')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: sheet, matching: find.byIcon(Icons.notifications)),
        findsOneWidget,
      );
    },
  );

  testWidgets('video group call participants button opens the sheet', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap(groupState(isAudioOnly: false)));
    await tester.pump();

    await tester.tap(find.byIcon(Icons.people_alt_outlined));
    await tester.pumpAndSettle();

    expect(find.byType(CallParticipantListSheet), findsOneWidget);
  });
}
