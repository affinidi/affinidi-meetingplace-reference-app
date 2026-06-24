import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mpx_flutter_reference_app/infrastructure/loggers/app_logger/app_logger.dart';
import 'package:mpx_flutter_reference_app/infrastructure/services/camera_service/camera_service.dart';

import '../../../fakes/fake_camera_controller.dart';

const _backCamera = CameraDescription(
  name: 'Mock Back Camera',
  lensDirection: CameraLensDirection.back,
  sensorOrientation: 90,
);

const _frontCamera = CameraDescription(
  name: 'Mock Front Camera',
  lensDirection: CameraLensDirection.front,
  sensorOrientation: 90,
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  AppLogger.initialize(
    File('${Directory.systemTemp.path}/camera_service_test.log'),
  );

  group('CameraService.initializeCamera', () {
    ProviderContainer makeContainer({
      required CameraControllerFactory controllerFactory,
      List<CameraDescription> cameras = const [_backCamera],
    }) {
      final container = ProviderContainer(
        overrides: [
          availableCamerasProvider.overrideWith(
            (ref) =>
                () async => cameras,
          ),
          cameraControllerFactoryProvider.overrideWith(
            (ref) => controllerFactory,
          ),
        ],
      );
      addTearDown(container.dispose);
      return container;
    }

    test(
      'reuses the same in-flight initialization for the same lens',
      () async {
        final initializeCompleter = Completer<void>();
        var createdControllers = 0;

        final container = makeContainer(
          controllerFactory:
              (
                description,
                resolutionPreset, {
                enableAudio = true,
                imageFormatGroup,
              }) {
                createdControllers += 1;
                return _DelayedFakeCameraController(
                  description,
                  resolutionPreset,
                  enableAudio: enableAudio,
                  imageFormatGroup: imageFormatGroup,
                  initializeCompleter: initializeCompleter,
                );
              },
        );

        final notifier = container.read(cameraServiceProvider.notifier);

        final firstInitialization = notifier.initializeCamera(
          CameraLensDirection.back,
        );
        final secondInitialization = notifier.initializeCamera(
          CameraLensDirection.back,
        );

        await Future<void>.delayed(Duration.zero);

        expect(createdControllers, 1);

        initializeCompleter.complete();

        final firstController = await firstInitialization;
        final secondController = await secondInitialization;

        expect(firstController, same(secondController));
        expect(
          container.read(cameraServiceProvider).controller,
          same(firstController),
        );
      },
    );

    test('toggleCamera switches to the opposite lens', () async {
      final container = makeContainer(
        cameras: const [_backCamera, _frontCamera],
        controllerFactory:
            (
              description,
              resolutionPreset, {
              enableAudio = true,
              imageFormatGroup,
            }) => FakeCameraController(
              description,
              resolutionPreset,
              enableAudio: enableAudio,
              imageFormatGroup: imageFormatGroup,
            ),
      );

      final notifier = container.read(cameraServiceProvider.notifier);

      final initialController = await notifier.initializeCamera(
        CameraLensDirection.back,
      );

      await notifier.toggleCamera();

      final toggledController = container
          .read(cameraServiceProvider)
          .controller;

      expect(toggledController, isNotNull);
      expect(toggledController, isNot(same(initialController)));
      expect(
        toggledController!.description.lensDirection,
        CameraLensDirection.front,
      );
    });
  });
}

class _DelayedFakeCameraController extends FakeCameraController {
  _DelayedFakeCameraController(
    super.description,
    super.resolutionPreset, {
    super.enableAudio,
    super.imageFormatGroup,
    required this.initializeCompleter,
  });

  final Completer<void> initializeCompleter;

  @override
  Future<void> initialize() async {
    await initializeCompleter.future;
    await super.initialize();
  }
}
