import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meeting_place_chat/meeting_place_chat.dart'
    show AudioVideoCallStatus;
import 'package:mpx_flutter_reference_app/infrastructure/loggers/app_logger/app_logger.dart';
import 'package:mpx_flutter_reference_app/l10n/app_localizations.dart';
import 'package:mpx_flutter_reference_app/navigation/navigator.dart';
import 'package:mpx_flutter_reference_app/presentation/themes/app_theme.dart';
import 'package:mpx_flutter_reference_app/presentation/widgets/banners/active_call/active_call_banner.dart';
import 'package:mpx_flutter_reference_app/presentation/widgets/banners/active_call/active_call_controller.dart';
import 'package:mpx_flutter_reference_app/presentation/widgets/banners/active_call/active_call_state.dart';

import 'fakes/fake_active_call_controller.dart';
import 'mocks/mock_navigator.dart';

ActiveCallState _state({required bool isAudioOnly}) => ActiveCallState(
  contactId: 'contact-123',
  peerName: 'Alice',
  status: AudioVideoCallStatus.active,
  callDurationSeconds: 5,
  isMicEnabled: true,
  isAudioOnly: isAudioOnly,
  isMinimized: true,
);

void main() {
  setUpAll(() {
    AppLogger.initialize(
      File('${Directory.systemTemp.path}/active_call_banner_test.log'),
    );
  });

  late RecordingNavigator navigator;

  setUp(() {
    navigator = RecordingNavigator();
  });

  Widget wrap(ActiveCallState state) => ProviderScope(
    overrides: [
      navigatorProvider.overrideWithValue(navigator),
      activeCallControllerProvider.overrideWith(
        () => FakeActiveCallController(state),
      ),
    ],
    child: MaterialApp(
      theme: AppTheme.dark,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const Scaffold(body: ActiveCallBanner()),
    ),
  );

  group('call type icon', () {
    testWidgets('shows the phone icon for an audio-only call', (tester) async {
      await tester.pumpWidget(wrap(_state(isAudioOnly: true)));
      await tester.pump();

      expect(find.byIcon(Icons.phone), findsOneWidget);
      expect(find.byIcon(Icons.videocam), findsNothing);
    });

    testWidgets('shows the video icon for a video call', (tester) async {
      await tester.pumpWidget(wrap(_state(isAudioOnly: false)));
      await tester.pump();

      expect(find.byIcon(Icons.videocam), findsOneWidget);
      expect(find.byIcon(Icons.phone), findsNothing);
    });
  });

  group('tap navigation', () {
    testWidgets('preserves audio-only when reopening the call screen', (
      tester,
    ) async {
      await tester.pumpWidget(wrap(_state(isAudioOnly: true)));
      await tester.pump();

      await tester.tap(find.text('Alice'));
      await tester.pump();

      expect(navigator.goCalls.single, contains('is-audio-only=true'));
    });

    testWidgets('omits the audio-only flag when reopening a video call', (
      tester,
    ) async {
      await tester.pumpWidget(wrap(_state(isAudioOnly: false)));
      await tester.pump();

      await tester.tap(find.text('Alice'));
      await tester.pump();

      expect(navigator.goCalls.single, isNot(contains('is-audio-only')));
    });
  });
}
