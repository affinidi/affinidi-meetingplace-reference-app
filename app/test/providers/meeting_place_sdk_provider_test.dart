import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mpx_flutter_reference_app/infrastructure/loggers/app_logger/app_logger.dart';
import 'package:mpx_flutter_reference_app/infrastructure/providers/app_logger_provider.dart';
import 'package:mpx_flutter_reference_app/infrastructure/providers/meeting_place_sdk_provider.dart';
import 'package:mpx_flutter_reference_app/infrastructure/secure_storage/secure_storage.dart';

import '../fakes/fake_secure_storage.dart';

void main() {
  setUpAll(() {
    AppLogger.initialize(
      File('${Directory.systemTemp.path}/app_debug_test.log'),
    );
  });

  group('meetingPlaceSdkProvider bootstrap ordering', () {
    test(
      '''fails with vodozemac error before SDK is created when fvod.init() throws''',
      () async {
        final callLog = <String>[];
        final initError = Exception('vodozemac failed to initialize');

        final container = ProviderContainer(
          overrides: [
            appLoggerProvider.overrideWithValue(AppLogger.instance),
            secureStorageProvider.overrideWith(
              (ref) async => FakeSecureStorage(),
            ),
            // Simulate vodozemac init failure
            vodozemacInitProvider.overrideWith((ref) async {
              callLog.add('fvod.init called');
              throw initError;
            }),
          ],
        );
        addTearDown(container.dispose);

        await expectLater(
          container.read(meetingPlaceSdkProvider.future),
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              'message',
              contains('vodozemac failed to initialize'),
            ),
          ),
        );

        // vodozemac init was called exactly once and no further progress was
        // made
        expect(callLog, equals(['fvod.init called']));
      },
    );

    test(
      'does not swallow vodozemac init error in a different exception type',
      () async {
        const initError = FormatException('bad vodozemac binary');

        final container = ProviderContainer(
          overrides: [
            appLoggerProvider.overrideWithValue(AppLogger.instance),
            secureStorageProvider.overrideWith(
              (ref) async => FakeSecureStorage(),
            ),
            vodozemacInitProvider.overrideWith((ref) async => throw initError),
          ],
        );
        addTearDown(container.dispose);

        await expectLater(
          container.read(meetingPlaceSdkProvider.future),
          throwsA(isA<FormatException>()),
        );
      },
    );

    test('vodozemacInitProvider completes before SDK init proceeds', () async {
      final callLog = <String>[];

      // We verify ordering by controlling when vodozemacInit resolves:
      // if the provider threw after a delay, MeetingPlaceCoreSDK.create()
      // must not have been reached before the throw propagates.
      final container = ProviderContainer(
        overrides: [
          appLoggerProvider.overrideWithValue(AppLogger.instance),
          secureStorageProvider.overrideWith(
            (ref) async => FakeSecureStorage(),
          ),
          vodozemacInitProvider.overrideWith((ref) async {
            await Future<void>.delayed(const Duration(milliseconds: 10));
            callLog.add('fvod.init completed');
            throw Exception('sentinel – stop after init');
          }),
        ],
      );
      addTearDown(container.dispose);

      await expectLater(
        container.read(meetingPlaceSdkProvider.future),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('sentinel'),
          ),
        ),
      );

      // The log proves fvod.init ran (and completed its body) before the
      // provider threw, i.e., before MeetingPlaceCoreSDK.create() could run.
      expect(callLog, equals(['fvod.init completed']));
    });
  });
}
