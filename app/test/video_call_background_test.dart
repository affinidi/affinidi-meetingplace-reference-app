import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meeting_place_matrix/meeting_place_matrix.dart';
import 'package:mpx_flutter_reference_app/application/services/contacts_service/contacts_service.dart';
import 'package:mpx_flutter_reference_app/presentation/themes/app_theme.dart';
import 'package:mpx_flutter_reference_app/presentation/widgets/video_call_background.dart';
import 'package:mpx_flutter_reference_app/presentation/widgets/video_call_peer_placeholder.dart';

import 'fakes/fake_contacts.dart';
import 'fakes/fake_contacts_service.dart';

Widget _wrap({required AudioVideoCallParticipant? remotePeer}) {
  return ProviderScope(
    overrides: [
      contactsServiceProvider.overrideWith(
        () => FakeContactsService(contacts: [FakeContacts.individualContact]),
      ),
    ],
    child: MaterialApp(
      theme: AppTheme.dark,
      home: Scaffold(
        body: VideoCallBackground(
          contactId: FakeContacts.individualContact.id,
          remotePeer: remotePeer,
          session: null,
        ),
      ),
    ),
  );
}

AudioVideoCallParticipant _peer({required bool hasVideo}) =>
    AudioVideoCallParticipant(
      participantId: 'peer',
      isSelf: false,
      hasVideo: hasVideo,
    );

void main() {
  group('When the peer has not joined', () {
    testWidgets('it shows the peer placeholder', (tester) async {
      await tester.pumpWidget(_wrap(remotePeer: null));
      await tester.pump();

      expect(find.byType(VideoCallPeerPlaceholder), findsOneWidget);
    });
  });

  group('When the peer camera has no video', () {
    testWidgets('it shows the peer placeholder', (tester) async {
      await tester.pumpWidget(_wrap(remotePeer: _peer(hasVideo: false)));
      await tester.pump();

      expect(find.byType(VideoCallPeerPlaceholder), findsOneWidget);
    });
  });

  group('When the peer video feed is ready', () {
    testWidgets('it hides the peer placeholder', (tester) async {
      await tester.pumpWidget(_wrap(remotePeer: _peer(hasVideo: true)));
      await tester.pump();

      expect(find.byType(VideoCallPeerPlaceholder), findsNothing);
    });
  });
}
