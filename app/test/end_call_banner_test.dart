import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mpx_flutter_reference_app/infrastructure/loggers/app_logger/app_logger.dart';
import 'package:mpx_flutter_reference_app/l10n/app_localizations.dart';
import 'package:mpx_flutter_reference_app/navigation/navigator.dart';
import 'package:mpx_flutter_reference_app/presentation/screens/chat/audio_video_call/rules/call_ui_rules.dart';
import 'package:mpx_flutter_reference_app/presentation/themes/app_theme.dart';
import 'package:mpx_flutter_reference_app/presentation/widgets/banners/end_call/end_call_banner.dart';
import 'package:mpx_flutter_reference_app/presentation/widgets/banners/end_call/end_call_banner_controller.dart';
import 'package:mpx_flutter_reference_app/presentation/widgets/banners/end_call/end_call_banner_state.dart';

import 'fakes/fake_end_call_banner_controller.dart';
import 'mocks/mock_navigator.dart';

const _contactId = 'contact-1';
const _peerName = 'Alice';

EndCallBannerState _state({
  required CallEndState endState,
  required bool isAudioOnly,
}) => EndCallBannerState(
  contactId: _contactId,
  peerName: _peerName,
  endState: endState,
  isAudioOnly: isAudioOnly,
);

void main() {
  setUpAll(() {
    AppLogger.initialize(
      File('${Directory.systemTemp.path}/end_call_banner_test.log'),
    );
  });

  late RecordingNavigator navigator;

  setUp(() {
    navigator = RecordingNavigator();
  });

  Widget wrap(EndCallBannerState? state) => ProviderScope(
    overrides: [
      navigatorProvider.overrideWithValue(navigator),
      endCallBannerControllerProvider.overrideWith(
        () => FakeEndCallBannerController(state),
      ),
    ],
    child: MaterialApp(
      theme: AppTheme.dark,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const Scaffold(body: EndCallBanner()),
    ),
  );

  group('visibility', () {
    testWidgets('is hidden when state is null', (tester) async {
      await tester.pumpWidget(wrap(null));
      await tester.pump();

      expect(find.byType(EndCallBanner), findsOneWidget);
      expect(find.byType(Container), findsNothing);
    });

    testWidgets('is visible when state is set', (tester) async {
      await tester.pumpWidget(
        wrap(_state(endState: CallEndState.missedCall, isAudioOnly: true)),
      );
      await tester.pump();

      expect(find.text(_peerName), findsOneWidget);
    });
  });

  group('status label', () {
    testWidgets('shows no-answer label for missed call', (tester) async {
      await tester.pumpWidget(
        wrap(_state(endState: CallEndState.missedCall, isAudioOnly: true)),
      );
      await tester.pump();

      expect(find.textContaining('answer'), findsOneWidget);
    });

    testWidgets('shows no-answer label for declined call', (tester) async {
      await tester.pumpWidget(
        wrap(_state(endState: CallEndState.declinedCall, isAudioOnly: false)),
      );
      await tester.pump();

      expect(find.textContaining('answer'), findsOneWidget);
    });

    testWidgets('both missed and declined show identical message', (
      tester,
    ) async {
      // Missed call
      await tester.pumpWidget(
        wrap(_state(endState: CallEndState.missedCall, isAudioOnly: true)),
      );
      await tester.pump();
      final missedText = find.textContaining('answer');
      expect(missedText, findsOneWidget);

      // Declined call - should show same message
      await tester.pumpWidget(
        wrap(_state(endState: CallEndState.declinedCall, isAudioOnly: false)),
      );
      await tester.pump();
      final declinedText = find.textContaining('answer');
      expect(declinedText, findsOneWidget);
    });
  });

  group('call type icon', () {
    testWidgets('shows phone icon for audio-only call', (tester) async {
      await tester.pumpWidget(
        wrap(_state(endState: CallEndState.missedCall, isAudioOnly: true)),
      );
      await tester.pump();

      expect(find.byIcon(Icons.call), findsOneWidget);
      expect(find.byIcon(Icons.videocam), findsNothing);
    });

    testWidgets('shows videocam icon for video call', (tester) async {
      await tester.pumpWidget(
        wrap(_state(endState: CallEndState.declinedCall, isAudioOnly: false)),
      );
      await tester.pump();

      expect(find.byIcon(Icons.videocam), findsOneWidget);
      expect(find.byIcon(Icons.call), findsNothing);
    });
  });

  group('tap navigation', () {
    testWidgets('navigates to call screen with correct contact', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrap(_state(endState: CallEndState.missedCall, isAudioOnly: true)),
      );
      await tester.pump();

      await tester.tap(find.text(_peerName));
      await tester.pump();

      expect(navigator.goCalls, isNotEmpty);
      expect(navigator.goCalls.first, contains(_contactId));
    });
  });

  group('auto-dismiss and animation', () {
    testWidgets('banner content is centered on screen', (tester) async {
      await tester.pumpWidget(
        wrap(_state(endState: CallEndState.missedCall, isAudioOnly: true)),
      );
      await tester.pump();

      final row = find.byType(Row);
      expect(row, findsWidgets);
      final rowWidget = tester.widget<Row>(row.first);
      expect(rowWidget.mainAxisAlignment, equals(MainAxisAlignment.center));
    });
  });
}
