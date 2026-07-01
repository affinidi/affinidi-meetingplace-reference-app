import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meeting_place_matrix/meeting_place_matrix.dart';
import 'package:mpx_flutter_reference_app/application/services/contacts_service/contacts_service.dart';
import 'package:mpx_flutter_reference_app/application/services/incoming_call_service/incoming_call_notifier.dart';
import 'package:mpx_flutter_reference_app/application/services/incoming_call_service/incoming_call_service.dart';
import 'package:mpx_flutter_reference_app/application/services/incoming_call_service/incoming_call_state.dart';
import 'package:mpx_flutter_reference_app/infrastructure/loggers/app_logger/app_logger.dart';
import 'package:mpx_flutter_reference_app/l10n/app_localizations.dart';
import 'package:mpx_flutter_reference_app/navigation/navigator.dart';
import 'package:mpx_flutter_reference_app/presentation/themes/app_theme.dart';
import 'package:mpx_flutter_reference_app/presentation/widgets/banners/incoming_call_banner.dart';

import 'fakes/fake_contacts_service.dart';
import 'mocks/mock_navigator.dart';

class _StubIncomingCallState extends IncomingCallNotifier {
  _StubIncomingCallState(this._event);

  final IncomingAudioVideoCallEvent _event;

  @override
  IncomingCallState build() => IncomingCallState.ringing(_event);
}

class _RecordingIncomingCallService extends IncomingCallService {
  final List<String> acceptedCallIds = [];
  final List<String> declinedCallIds = [];

  @override
  void build() {}

  @override
  void accept({required String callId}) => acceptedCallIds.add(callId);

  @override
  void decline({required String callId}) => declinedCallIds.add(callId);
}

IncomingAudioVideoCallEvent _event({
  String otherPartyChannelDid = 'did:key:individual-channel',
  bool isAudioOnly = false,
}) => IncomingAudioVideoCallEvent(
  callId: 'call-1',
  otherPartyChannelDid: otherPartyChannelDid,
  mediaType: isAudioOnly ? CallMediaType.audio : CallMediaType.video,
);

void main() {
  setUpAll(() {
    AppLogger.initialize(
      File('${Directory.systemTemp.path}/incoming_call_banner_test.log'),
    );
  });

  late RecordingNavigator navigator;
  late _RecordingIncomingCallService callService;

  setUp(() {
    navigator = RecordingNavigator();
    callService = _RecordingIncomingCallService();
  });

  Widget wrap(IncomingAudioVideoCallEvent event) => ProviderScope(
    overrides: [
      navigatorProvider.overrideWithValue(navigator),
      contactsServiceProvider.overrideWith(FakeContactsService.new),
      incomingCallProvider.overrideWith(() => _StubIncomingCallState(event)),
      incomingCallServiceProvider.overrideWith(() => callService),
    ],
    child: MaterialApp(
      theme: AppTheme.dark,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const Scaffold(body: IncomingCallBanner()),
    ),
  );

  group('call type icon', () {
    testWidgets('shows the phone icon for an audio-only call', (tester) async {
      await tester.pumpWidget(wrap(_event(isAudioOnly: true)));
      await tester.pump();

      expect(find.byIcon(Icons.phone), findsOneWidget);
      expect(find.byIcon(Icons.videocam), findsNothing);
    });

    testWidgets('shows the video icon for a video call', (tester) async {
      await tester.pumpWidget(wrap(_event(isAudioOnly: false)));
      await tester.pump();

      expect(find.byIcon(Icons.videocam), findsOneWidget);
      expect(find.byIcon(Icons.phone), findsNothing);
    });
  });

  group('accept', () {
    testWidgets('accepts and navigates using the resolved contact id', (
      tester,
    ) async {
      await tester.pumpWidget(wrap(_event()));
      await tester.pump();

      await tester.tap(find.byIcon(Icons.call));
      await tester.pump();

      expect(callService.acceptedCallIds, ['call-1']);
      expect(navigator.goCalls.single, contains('individual-contact-id'));
    });

    testWidgets('falls back to the channel did when no contact is found', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrap(_event(otherPartyChannelDid: 'did:key:unknown')),
      );
      await tester.pump();

      await tester.tap(find.byIcon(Icons.call));
      await tester.pump();

      expect(callService.acceptedCallIds, ['call-1']);
      expect(navigator.goCalls.single, contains('unknown'));
    });

    testWidgets('disappears immediately after accept tap', (tester) async {
      await tester.pumpWidget(wrap(_event()));
      await tester.pump();

      expect(find.byIcon(Icons.call), findsOneWidget);
      await tester.tap(find.byIcon(Icons.call));
      await tester.pump();

      expect(find.byIcon(Icons.call), findsNothing);
      expect(find.byType(SizedBox), findsWidgets);
    });
  });

  group('decline', () {
    testWidgets('declines without navigating', (tester) async {
      await tester.pumpWidget(wrap(_event()));
      await tester.pump();

      await tester.tap(find.byIcon(Icons.call_end));
      await tester.pump();

      expect(callService.declinedCallIds, ['call-1']);
      expect(navigator.goCalls, isEmpty);
    });
  });

  group('swipe to dismiss', () {
    testWidgets('declines when swiped upward past the threshold', (
      tester,
    ) async {
      await tester.pumpWidget(wrap(_event()));
      await tester.pump();

      await tester.fling(
        find.byType(IncomingCallBanner),
        const Offset(0, -400),
        1500,
      );
      await tester.pumpAndSettle();

      expect(callService.declinedCallIds, ['call-1']);
    });

    testWidgets(
      'slide animation returns to resting position after swipe-dismiss',
      (tester) async {
        await tester.pumpWidget(wrap(_event()));
        await tester.pump();

        await tester.fling(
          find.byType(IncomingCallBanner),
          const Offset(0, -400),
          1500,
        );
        await tester.pumpAndSettle();

        // ignore: invalid_use_of_visible_for_testing_member
        final state = tester.state(find.byType(IncomingCallBanner)) as dynamic;
        // ignore: avoid_dynamic_calls
        expect((state.slideController as AnimationController).value, 0.0);
      },
    );
  });
}
