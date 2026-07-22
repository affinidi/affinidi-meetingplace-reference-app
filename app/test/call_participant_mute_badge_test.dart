import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mpx_flutter_reference_app/presentation/themes/app_custom_colors.dart';
import 'package:mpx_flutter_reference_app/presentation/widgets/call/call_participant_mute_badge.dart';

Future<void> _pumpBadge(WidgetTester tester, Widget child) {
  return tester.pumpWidget(
    MaterialApp(
      theme: ThemeData(
        extensions: const <ThemeExtension<dynamic>>[AppCustomColors()],
      ),
      home: Scaffold(body: Center(child: child)),
    ),
  );
}

void main() {
  group('CallParticipantMuteBadge', () {
    testWidgets('renders black circular mic off badge', (
      WidgetTester tester,
    ) async {
      await _pumpBadge(tester, const CallParticipantMuteBadge());

      expect(find.byIcon(Icons.mic_off), findsOneWidget);

      final badgeContainer = tester.widget<Container>(find.byType(Container));
      final decoration = badgeContainer.decoration as BoxDecoration?;

      expect(decoration?.shape, BoxShape.circle);
      expect(decoration?.color, Colors.black);
    });

    testWidgets('uses the provided size', (WidgetTester tester) async {
      const badgeSize = 32.0;

      await _pumpBadge(tester, const CallParticipantMuteBadge(size: badgeSize));

      final badgeSizeBox = tester.getSize(find.byType(Container));

      expect(badgeSizeBox.width, badgeSize);
      expect(badgeSizeBox.height, badgeSize);
    });

    testWidgets('renders inside a Stack without overflow', (
      WidgetTester tester,
    ) async {
      await _pumpBadge(
        tester,
        const SizedBox(
          width: 300,
          height: 400,
          child: Stack(
            children: [
              Positioned(
                top: 16,
                left: 16,
                child: CallParticipantMuteBadge(size: 32),
              ),
            ],
          ),
        ),
      );

      expect(find.byType(CallParticipantMuteBadge), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
