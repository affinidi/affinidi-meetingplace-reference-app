import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mpx_flutter_reference_app/presentation/screens/vtc_join/vtc_flow_diagram.dart';
import 'package:mpx_flutter_reference_app/presentation/themes/app_theme.dart';

void main() {
  testWidgets('fits three parties with long names on a narrow phone', (
    tester,
  ) async {
    // The trail's text column on a 320-point-wide phone.
    await tester.binding.setSurfaceSize(const Size(232, 400));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: Scaffold(
          body: Align(
            alignment: Alignment.topLeft,
            child: VtcFlowDiagram(
              nodes: [
                const VtcFlowNode(Icons.shield_outlined, 'Your VTA'),
                const VtcFlowNode(Icons.smartphone, 'This phone'),
                const VtcFlowNode(
                  Icons.groups_outlined,
                  'The Sunday Morning Five-a-side Football Club',
                ),
              ],
              links: ['signs the leave', 'sends it'],
            ),
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    // Read left to right, and small: a circle and one line under it.
    expect(
      tester.getCenter(find.text('Your VTA')).dx,
      lessThan(tester.getCenter(find.text('signs the leave')).dx),
    );
    expect(
      tester.getCenter(find.text('signs the leave')).dx,
      lessThan(tester.getCenter(find.text('This phone')).dx),
    );
    expect(
      tester.getSize(find.byType(VtcFlowDiagram)).height,
      lessThanOrEqualTo(40),
    );
  });
}
