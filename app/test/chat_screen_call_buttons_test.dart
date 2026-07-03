import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mpx_flutter_reference_app/infrastructure/configuration/environment.dart';
import 'package:mpx_flutter_reference_app/infrastructure/loggers/app_logger/app_logger.dart';
import 'package:mpx_flutter_reference_app/infrastructure/providers/app_logger_provider.dart';
import 'package:mpx_flutter_reference_app/l10n/app_localizations.dart';
import 'package:mpx_flutter_reference_app/presentation/screens/chat/chat_screen.dart';
import 'package:mpx_flutter_reference_app/presentation/screens/chat/chat_screen_controller.dart';
import 'package:mpx_flutter_reference_app/presentation/screens/chat/chat_screen_state.dart';
import 'package:mpx_flutter_reference_app/presentation/themes/app_theme.dart';
import 'package:mpx_flutter_reference_app/presentation/widgets/banners/active_call/active_call_controller.dart';

import 'fakes/fake_contacts.dart';
import 'fakes/fake_environment.dart';
import 'mocks/fake_active_call_controller.dart';
import 'mocks/fake_app_logger.dart';

const _kContactId = 'test-contact-id';

class _FixedChatScreenController extends ChatScreenController {
  _FixedChatScreenController(this._fixed);

  final ChatScreenState _fixed;

  @override
  ChatScreenState build(String contactId) => _fixed;

  @override
  Future<void> initialize() async {}

  @override
  Future<void> onScreenOpened() async {}

  @override
  void disposeVoicePlaybackResources() {}
}

Widget _wrap({
  required ChatScreenState state,
  required bool audioVideoCallsEnabled,
}) {
  return ProviderScope(
    overrides: [
      appLoggerProvider.overrideWithValue(FakeAppLogger()),
      environmentProvider.overrideWithValue(
        FakeEnvironment(audioVideoCallsEnabled: audioVideoCallsEnabled),
      ),
      activeCallControllerProvider.overrideWith(FakeActiveCallController.new),
      chatScreenControllerProvider(
        _kContactId,
      ).overrideWith(() => _FixedChatScreenController(state)),
    ],
    child: MaterialApp(
      theme: AppTheme.dark,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const ChatScreen(contactId: _kContactId),
    ),
  );
}

ChatScreenState _individualState({bool isCallSupported = true}) =>
    ChatScreenState(
      contact: FakeContacts.individualContact,
      isInitialized: false,
      isCallSupported: isCallSupported,
    );

ChatScreenState _groupState() => ChatScreenState(
  contact: FakeContacts.groupContact,
  isInitialized: false,
  isCallSupported: true,
);

void main() {
  setUpAll(() {
    AppLogger.initialize(
      File('${Directory.systemTemp.path}/chat_screen_call_buttons_test.log'),
    );
  });

  group('Chat screen call buttons', () {
    testWidgets(
      'hidden when AUDIO_VIDEO_CALLS_ENABLED is false (1:1, call supported)',
      (tester) async {
        await tester.pumpWidget(
          _wrap(state: _individualState(), audioVideoCallsEnabled: false),
        );
        await tester.pump();

        expect(find.byIcon(Icons.call), findsNothing);
        expect(find.byIcon(Icons.videocam), findsNothing);
      },
    );

    testWidgets('visible when flag is on, call is supported, and chat is 1:1', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(state: _individualState(), audioVideoCallsEnabled: true),
      );
      await tester.pump();

      expect(find.byIcon(Icons.call), findsOneWidget);
      expect(find.byIcon(Icons.videocam), findsOneWidget);
    });

    testWidgets('hidden when flag is on but call is not supported', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          state: _individualState(isCallSupported: false),
          audioVideoCallsEnabled: true,
        ),
      );
      await tester.pump();

      expect(find.byIcon(Icons.call), findsNothing);
      expect(find.byIcon(Icons.videocam), findsNothing);
    });

    testWidgets('hidden in a group chat even when flag is on', (tester) async {
      await tester.pumpWidget(
        _wrap(state: _groupState(), audioVideoCallsEnabled: true),
      );
      await tester.pump();

      expect(find.byIcon(Icons.call), findsNothing);
      expect(find.byIcon(Icons.videocam), findsNothing);
    });
  });
}
