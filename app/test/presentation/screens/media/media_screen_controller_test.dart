import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mpx_flutter_reference_app/infrastructure/loggers/app_logger/app_logger.dart';
import 'package:mpx_flutter_reference_app/infrastructure/services/camera_service/camera_service.dart';
import 'package:mpx_flutter_reference_app/infrastructure/services/permission_service/permission_service.dart';
import 'package:mpx_flutter_reference_app/navigation/navigator.dart'
    as app_navigator;
import 'package:mpx_flutter_reference_app/presentation/screens/media/media_screen/media_screen.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../fakes/fake_camera_controller.dart';
import '../../../fakes/fake_permission_service.dart';

const _backCamera = CameraDescription(
  name: 'Mock Back Camera',
  lensDirection: CameraLensDirection.back,
  sensorOrientation: 90,
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  AppLogger.initialize(
    File('${Directory.systemTemp.path}/media_screen_controller_test.log'),
  );

  final testNavigator = app_navigator.Navigator(
    GoRouter(
      routes: [
        GoRoute(path: '/', builder: (context, state) => const SizedBox()),
      ],
    ),
  );

  testWidgets(
    'disposing media screen closes and clears the shared camera',
    (tester) async {
      var disposeCount = 0;

      final container = ProviderContainer(
        overrides: [
          availableCamerasProvider.overrideWith(
            (ref) =>
                () async => const [_backCamera],
          ),
          cameraControllerFactoryProvider.overrideWith(
            (ref) =>
                (
                  description,
                  resolutionPreset, {
                  enableAudio = true,
                  imageFormatGroup,
                }) => _TrackingFakeCameraController(
                  description,
                  resolutionPreset,
                  enableAudio: enableAudio,
                  imageFormatGroup: imageFormatGroup,
                  onDispose: () => disposeCount += 1,
                ),
          ),
          permissionServiceProvider.overrideWith(
            (ref) => FakePermissionService(
              cameraPermissionStatus: PermissionStatus.granted,
            ),
          ),
          app_navigator.navigatorProvider.overrideWithValue(testNavigator),
        ],
      );
      addTearDown(container.dispose);

      await container
          .read(cameraServiceProvider.notifier)
          .initializeCamera(CameraLensDirection.back);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: MediaScreen(
              cameraLensDirection: CameraLensDirection.back,
              useCamera: true,
              useChatSemantics: false,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(container.read(cameraServiceProvider).controller, isNotNull);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();

      expect(container.read(cameraServiceProvider).controller, isNull);
      expect(disposeCount, 1);
    },
    variant: TargetPlatformVariant.only(TargetPlatform.android),
  );
}

class _TrackingFakeCameraController extends FakeCameraController {
  _TrackingFakeCameraController(
    super.description,
    super.resolutionPreset, {
    super.enableAudio,
    super.imageFormatGroup,
    required this.onDispose,
  });

  final void Function() onDispose;

  @override
  Future<void> dispose() async {
    onDispose();
    await super.dispose();
  }
}
