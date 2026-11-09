import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mpx_flutter_reference_app/l10n/app_localizations.dart';
import 'package:mpx_flutter_reference_app/presentation/screens/chat/audio_video_call/call_controls_bar.dart';
import 'package:mpx_flutter_reference_app/presentation/themes/app_theme.dart';
import 'package:mpx_flutter_reference_app/presentation/themes/tokens/mc_icons.dart';

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

const _gray = Color.fromARGB(255, 37, 39, 42);

Color _containerColor(WidgetTester tester, IconData icon) {
  final container = tester.widget<Container>(
    find
        .ancestor(of: find.byIcon(icon), matching: find.byType(Container))
        .first,
  );
  return (container.decoration as BoxDecoration).color!;
}

void main() {
  group('CallControlsBar colors (Earl rule)', () {
    testWidgets('unmuted mic is grey while camera-on is white', (tester) async {
      await tester.pumpWidget(
        _wrap(
          CallControlsBar(
            mic: _btn(isEnabled: true),
            speaker: _btn(isEnabled: false),
            camera: _btn(isEnabled: true),
            onEndCall: () {},
          ),
        ),
      );
      await tester.pump();

      expect(_containerColor(tester, McIcons.mic), _gray);
      expect(_containerColor(tester, McIcons.video), isNot(_gray));
    });

    testWidgets('muted mic is white with a red icon', (tester) async {
      await tester.pumpWidget(
        _wrap(
          CallControlsBar(
            mic: _btn(isEnabled: false),
            speaker: _btn(isEnabled: false),
            camera: _btn(isEnabled: false),
            onEndCall: () {},
          ),
        ),
      );
      await tester.pump();

      expect(_containerColor(tester, McIcons.micOff), isNot(_gray));
      expect(
        tester.widget<Icon>(find.byIcon(McIcons.micOff)).color,
        Colors.red,
      );
    });

    testWidgets('speaker off is grey and speaker on is white', (tester) async {
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
      expect(_containerColor(tester, McIcons.speaker), _gray);

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
      expect(_containerColor(tester, McIcons.speaker), isNot(_gray));
    });
  });

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

      expect(find.byIcon(McIcons.mic), findsOneWidget);
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

      expect(find.byIcon(McIcons.micOff), findsOneWidget);
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

      expect(find.byIcon(McIcons.video), findsOneWidget);
    });

    testWidgets('hides camera button when camera is null (audio-only)', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(CallControlsBar(mic: _btn(), speaker: _btn(), onEndCall: () {})),
      );
      await tester.pump();

      expect(find.byIcon(McIcons.video), findsNothing);
      expect(find.byIcon(McIcons.videoOff), findsNothing);
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

      await tester.tap(find.byIcon(McIcons.mic));
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

      await tester.tap(find.byIcon(McIcons.video));
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

      await tester.tap(find.byIcon(McIcons.hangUp));
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

      expect(find.byIcon(McIcons.speaker), findsOneWidget);
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

      expect(find.byIcon(McIcons.speaker), findsOneWidget);
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

      expect(find.byIcon(McIcons.speaker), findsOneWidget);
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

      await tester.tap(find.byIcon(McIcons.speaker));
      expect(tapped, isTrue);
    });
  });
}
