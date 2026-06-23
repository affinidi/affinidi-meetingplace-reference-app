import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mpx_flutter_reference_app/l10n/app_localizations.dart';
import 'package:mpx_flutter_reference_app/presentation/screens/chat/audio_video_call/call_controls_bar.dart';
import 'package:mpx_flutter_reference_app/presentation/themes/app_theme.dart';

Widget _wrap(Widget child) => MaterialApp(
  theme: AppTheme.dark,
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: Scaffold(body: child),
);

CallButtonConfig _btn({
  bool isEnabled = true,
  bool isDisabled = false,
  VoidCallback? onTap,
}) => CallButtonConfig(
  isEnabled: isEnabled,
  isDisabled: isDisabled,
  onTap: onTap ?? () {},
);

void main() {
  group('CallControlsBar', () {
    testWidgets('shows mic icon when mic is enabled', (tester) async {
      await tester.pumpWidget(
        _wrap(
          CallControlsBar(
            mic: _btn(isEnabled: true),
            speaker: _btn(),
            camera: _btn(),
            onEndCall: () {},
          ),
        ),
      );
      await tester.pump();

      expect(find.byIcon(Icons.mic), findsOneWidget);
    });

    testWidgets('shows mic_off icon when mic is disabled', (tester) async {
      await tester.pumpWidget(
        _wrap(
          CallControlsBar(
            mic: _btn(isEnabled: false),
            speaker: _btn(),
            camera: _btn(),
            onEndCall: () {},
          ),
        ),
      );
      await tester.pump();

      expect(find.byIcon(Icons.mic_off), findsOneWidget);
    });

    testWidgets('shows camera button when camera is provided', (tester) async {
      await tester.pumpWidget(
        _wrap(
          CallControlsBar(
            mic: _btn(),
            speaker: _btn(),
            camera: _btn(isEnabled: true),
            onEndCall: () {},
          ),
        ),
      );
      await tester.pump();

      expect(find.byIcon(Icons.videocam), findsOneWidget);
    });

    testWidgets('hides camera button when camera is null (audio-only)', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(CallControlsBar(mic: _btn(), speaker: _btn(), onEndCall: () {})),
      );
      await tester.pump();

      expect(find.byIcon(Icons.videocam), findsNothing);
      expect(find.byIcon(Icons.videocam_off), findsNothing);
    });

    testWidgets('calls onMicToggle when mic button is tapped', (tester) async {
      var tapped = false;

      await tester.pumpWidget(
        _wrap(
          CallControlsBar(
            mic: _btn(onTap: () => tapped = true),
            speaker: _btn(),
            camera: _btn(),
            onEndCall: () {},
          ),
        ),
      );
      await tester.pump();

      await tester.tap(find.byIcon(Icons.mic));
      expect(tapped, isTrue);
    });

    testWidgets('calls onCameraToggle when camera button is tapped', (
      tester,
    ) async {
      var tapped = false;

      await tester.pumpWidget(
        _wrap(
          CallControlsBar(
            mic: _btn(),
            speaker: _btn(),
            camera: _btn(onTap: () => tapped = true),
            onEndCall: () {},
          ),
        ),
      );
      await tester.pump();

      await tester.tap(find.byIcon(Icons.videocam));
      expect(tapped, isTrue);
    });

    testWidgets('calls onEndCall when end-call button is tapped', (
      tester,
    ) async {
      var tapped = false;

      await tester.pumpWidget(
        _wrap(
          CallControlsBar(
            mic: _btn(),
            speaker: _btn(),
            camera: _btn(),
            onEndCall: () => tapped = true,
          ),
        ),
      );
      await tester.pump();

      await tester.tap(find.byIcon(Icons.call_end));
      expect(tapped, isTrue);
    });

    testWidgets('shows volume_up icon when speaker is on', (tester) async {
      await tester.pumpWidget(
        _wrap(
          CallControlsBar(
            mic: _btn(),
            speaker: _btn(isEnabled: true),
            camera: _btn(),
            onEndCall: () {},
          ),
        ),
      );
      await tester.pump();

      expect(find.byIcon(Icons.volume_up), findsOneWidget);
    });

    testWidgets('shows volume_up icon when speaker is off', (tester) async {
      await tester.pumpWidget(
        _wrap(
          CallControlsBar(
            mic: _btn(),
            speaker: _btn(isEnabled: false),
            camera: _btn(),
            onEndCall: () {},
          ),
        ),
      );
      await tester.pump();

      expect(find.byIcon(Icons.volume_up), findsOneWidget);
    });

    testWidgets('shows speaker button in audio-only mode', (tester) async {
      await tester.pumpWidget(
        _wrap(
          CallControlsBar(
            mic: _btn(),
            speaker: _btn(isEnabled: false),
            onEndCall: () {},
          ),
        ),
      );
      await tester.pump();

      expect(find.byIcon(Icons.volume_up), findsOneWidget);
    });

    testWidgets('calls onSpeakerToggle when speaker button is tapped', (
      tester,
    ) async {
      var tapped = false;

      await tester.pumpWidget(
        _wrap(
          CallControlsBar(
            mic: _btn(),
            speaker: _btn(isEnabled: false, onTap: () => tapped = true),
            camera: _btn(),
            onEndCall: () {},
          ),
        ),
      );
      await tester.pump();

      await tester.tap(find.byIcon(Icons.volume_up));
      expect(tapped, isTrue);
    });
  });
}
