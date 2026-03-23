import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meeting_place_chat/meeting_place_chat.dart' as chat_sdk;
import 'package:mpx_flutter_reference_app/navigation/routes/route_paths.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'fakes/fake_identities.dart';
import 'utils/app.dart';

void main() {
  group('Settings screen automatic media download', () {
    const switchKey = Key('automaticMediaDownloadSwitch');

    setUp(_enableAutomaticDownload);

    testWidgets('restores the persisted value and reapplies it', (
      tester,
    ) async {
      await navigateToLocation(
        tester,
        RoutePaths.settings,
        identities: [FakeIdentities.primaryIdentity],
        automaticMediaDownloadEnabled: false,
      );
      await tester.pumpAndSettle();

      expect(_isAutomaticDownloadEnabled(), isFalse);
      expect(_switchValue(tester, switchKey), isFalse);
    });

    testWidgets('toggling the switch updates sdk state and persistence', (
      tester,
    ) async {
      await navigateToLocation(
        tester,
        RoutePaths.settings,
        identities: [FakeIdentities.primaryIdentity],
        automaticMediaDownloadEnabled: true,
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(switchKey));
      await tester.pumpAndSettle();

      final sharedPreferences = await SharedPreferences.getInstance();

      expect(_isAutomaticDownloadEnabled(), isFalse);
      expect(sharedPreferences.getBool('automaticMediaDownload'), isFalse);
      expect(_switchValue(tester, switchKey), isFalse);
    });
  });
}

bool _switchValue(WidgetTester tester, Key switchKey) {
  final widget = tester.widget(find.byKey(switchKey));
  if (widget is Switch) {
    return widget.value;
  }
  if (widget is CupertinoSwitch) {
    return widget.value;
  }

  throw StateError('Unsupported switch widget: ${widget.runtimeType}');
}

bool _isAutomaticDownloadEnabled() {
  return chat_sdk.ChatSDK.isAutomaticDownloadEnabled();
}

void _enableAutomaticDownload() {
  chat_sdk.ChatSDK.enableAutomaticDownload();
}
