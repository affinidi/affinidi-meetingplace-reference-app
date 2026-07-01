import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meeting_place_matrix/meeting_place_matrix.dart';
import 'package:mpx_flutter_reference_app/application/services/authentication_service/authentication_service.dart';
import 'package:mpx_flutter_reference_app/application/services/settings_service/settings_service.dart';
import 'package:mpx_flutter_reference_app/infrastructure/loggers/app_logger/app_logger.dart';
import 'package:mpx_flutter_reference_app/l10n/app_localizations.dart';
import 'package:mpx_flutter_reference_app/navigation/navigator.dart';
import 'package:mpx_flutter_reference_app/presentation/app/app_header_banner.dart';
import 'package:mpx_flutter_reference_app/presentation/screens/chat/audio_video_call/rules/call_ui_rules.dart';
import 'package:mpx_flutter_reference_app/presentation/themes/app_theme.dart';
import 'package:mpx_flutter_reference_app/presentation/widgets/banners/active_call/active_call_banner.dart';
import 'package:mpx_flutter_reference_app/presentation/widgets/banners/active_call/active_call_controller.dart';
import 'package:mpx_flutter_reference_app/presentation/widgets/banners/active_call/active_call_state.dart';
import 'package:mpx_flutter_reference_app/presentation/widgets/banners/end_call/end_call_banner.dart';
import 'package:mpx_flutter_reference_app/presentation/widgets/banners/end_call/end_call_banner_controller.dart';
import 'package:mpx_flutter_reference_app/presentation/widgets/banners/end_call/end_call_banner_state.dart';
import 'package:mpx_flutter_reference_app/presentation/widgets/banners/incoming_call_banner.dart';

import 'fakes/fake_active_call_controller.dart';
import 'fakes/fake_authentication_service.dart';
import 'fakes/fake_end_call_banner_controller.dart';
import 'fakes/fake_settings_service.dart';
import 'mocks/mock_navigator.dart';

ActiveCallState _minimizedState() => const ActiveCallState(
  contactId: 'contact-1',
  peerName: 'Alice',
  status: AudioVideoCallStatus.active,
  callDurationSeconds: 10,
  isMicEnabled: true,
  isAudioOnly: false,
  isMinimized: true,
  isCameraEnabled: false,
);

Widget wrap(ActiveCallState? callState) => ProviderScope(
  overrides: [
    navigatorProvider.overrideWithValue(RecordingNavigator()),
    authenticationServiceProvider.overrideWith(FakeAuthenticationService.new),
    settingsServiceProvider.overrideWith(FakeSettingsService.new),
    activeCallControllerProvider.overrideWith(
      () => FakeActiveCallController(callState),
    ),
  ],
  child: MaterialApp(
    theme: AppTheme.dark,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: const AppHeaderBanner(child: Scaffold(body: SizedBox.expand())),
  ),
);

Widget wrapWithEndCallBanner(EndCallBannerState? endCallState) => ProviderScope(
  overrides: [
    navigatorProvider.overrideWithValue(RecordingNavigator()),
    authenticationServiceProvider.overrideWith(FakeAuthenticationService.new),
    settingsServiceProvider.overrideWith(FakeSettingsService.new),
    activeCallControllerProvider.overrideWith(
      () => FakeActiveCallController(null),
    ),
    endCallBannerControllerProvider.overrideWith(
      () => FakeEndCallBannerController(endCallState),
    ),
  ],
  child: MaterialApp(
    theme: AppTheme.dark,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: const AppHeaderBanner(child: Scaffold(body: SizedBox.expand())),
  ),
);

void main() {
  setUpAll(() {
    AppLogger.initialize(
      File('${Directory.systemTemp.path}/app_overlay_test.log'),
    );
  });

  group('ActiveCallBanner visibility', () {
    testWidgets('is hidden when there is no active call', (tester) async {
      await tester.pumpWidget(wrap(null));
      await tester.pump();

      expect(find.byType(ActiveCallBanner), findsNothing);
    });

    testWidgets('is hidden when the call is not minimized', (tester) async {
      await tester.pumpWidget(
        wrap(_minimizedState().copyWith(isMinimized: false)),
      );
      await tester.pump();

      expect(find.byType(ActiveCallBanner), findsNothing);
    });

    testWidgets('is visible when a call is minimized', (tester) async {
      await tester.pumpWidget(wrap(_minimizedState()));
      await tester.pump();

      expect(find.byType(ActiveCallBanner), findsOneWidget);
    });
  });

  group('IncomingCallBanner', () {
    testWidgets('is always mounted in the overlay regardless of call state', (
      tester,
    ) async {
      await tester.pumpWidget(wrap(null));
      await tester.pump();

      expect(find.byType(IncomingCallBanner), findsOneWidget);
    });
  });

  group('EndCallBanner visibility', () {
    testWidgets('is hidden when there is no end-call state', (tester) async {
      await tester.pumpWidget(wrapWithEndCallBanner(null));
      await tester.pump();

      expect(find.byType(ActiveCallBanner), findsNothing);
    });

    testWidgets('is visible when end-call state is set', (tester) async {
      await tester.pumpWidget(
        wrapWithEndCallBanner(
          const EndCallBannerState(
            contactId: 'contact-1',
            peerName: 'Alice',
            endState: CallEndState.missedCall,
            isAudioOnly: true,
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(EndCallBanner), findsOneWidget);
      expect(find.byType(ActiveCallBanner), findsNothing);
    });
  });
}
