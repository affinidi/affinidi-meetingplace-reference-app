import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mpx_flutter_reference_app/infrastructure/loggers/app_logger/app_logger.dart';
import 'package:mpx_flutter_reference_app/presentation/screens/chat/audio_video_call/rules/call_ui_rules.dart';
import 'package:mpx_flutter_reference_app/presentation/widgets/banners/end_call/end_call_banner_controller.dart';
import 'package:mpx_flutter_reference_app/presentation/widgets/banners/end_call/end_call_banner_state.dart';

void main() {
  setUpAll(() {
    AppLogger.initialize(
      File('${Directory.systemTemp.path}/end_call_banner_controller_test.log'),
    );
  });

  ProviderContainer buildContainer() {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    return container;
  }

  group('initial state', () {
    test('is null', () {
      final container = buildContainer();
      expect(container.read(endCallBannerControllerProvider), isNull);
    });
  });

  group('show', () {
    test('sets banner state with the provided values', () {
      final container = buildContainer();
      container
          .read(endCallBannerControllerProvider.notifier)
          .show(
            contactId: 'contact-1',
            peerName: 'Alice',
            endState: CallEndState.missedCall,
            isAudioOnly: true,
          );

      expect(
        container.read(endCallBannerControllerProvider),
        isA<EndCallBannerState>()
            .having((s) => s.contactId, 'contactId', 'contact-1')
            .having((s) => s.peerName, 'peerName', 'Alice')
            .having((s) => s.endState, 'endState', CallEndState.missedCall)
            .having((s) => s.isAudioOnly, 'isAudioOnly', true)
            .having((s) => s.slideOutOffset, 'slideOutOffset', 0.0),
      );
    });

    test('sets declinedCall end state', () {
      final container = buildContainer();
      container
          .read(endCallBannerControllerProvider.notifier)
          .show(
            contactId: 'contact-2',
            peerName: 'Bob',
            endState: CallEndState.declinedCall,
            isAudioOnly: false,
          );

      expect(
        container.read(endCallBannerControllerProvider)?.endState,
        CallEndState.declinedCall,
      );
    });
  });

  group('dismiss', () {
    test('clears the state back to null', () {
      final container = buildContainer();
      final controller = container.read(
        endCallBannerControllerProvider.notifier,
      );

      controller.show(
        contactId: 'contact-1',
        peerName: 'Alice',
        endState: CallEndState.missedCall,
        isAudioOnly: true,
      );
      expect(container.read(endCallBannerControllerProvider), isNotNull);

      controller.dismiss();
      expect(container.read(endCallBannerControllerProvider), isNull);
    });
  });
}
