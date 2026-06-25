import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mpx_flutter_reference_app/infrastructure/loggers/app_logger/app_logger.dart';
import 'package:mpx_flutter_reference_app/infrastructure/services/camera_service/camera_service.dart';
import 'package:mpx_flutter_reference_app/infrastructure/services/permission_service/permission_service.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../fakes/fake_camera_controller.dart';
import '../../../fakes/fake_permission_service.dart';

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

    test(
      'supersedes an in-flight initialization for a different lens',
      () async {
        final backInitializeCompleter = Completer<void>();
        final frontInitializeCompleter = Completer<void>();
        var backControllerDisposed = false;
        var createdControllers = 0;

        final container = makeContainer(
          cameras: const [_backCamera, _frontCamera],
          controllerFactory:
              (
                description,
                resolutionPreset, {
                enableAudio = true,
                imageFormatGroup,
              }) {
                createdControllers += 1;
                return _TrackedDelayedFakeCameraController(
                  description,
                  resolutionPreset,
                  enableAudio: enableAudio,
                  imageFormatGroup: imageFormatGroup,
                  initializeCompleter:
                      description.lensDirection == CameraLensDirection.back
                      ? backInitializeCompleter
                      : frontInitializeCompleter,
                  onDispose: () {
                    if (description.lensDirection == CameraLensDirection.back) {
                      backControllerDisposed = true;
                    }
                  },
                );
              },
        );

        final notifier = container.read(cameraServiceProvider.notifier);

        final backInitialization = notifier.initializeCamera(
          CameraLensDirection.back,
        );
        final frontInitialization = notifier.initializeCamera(
          CameraLensDirection.front,
        );

        await Future<void>.delayed(Duration.zero);
        expect(createdControllers, 1);

        backInitializeCompleter.complete();

        await expectLater(
          backInitialization,
          throwsA(
            isA<CameraException>().having(
              (error) => error.code,
              'code',
              'CameraInitializationSuperseded',
            ),
          ),
        );
        expect(backControllerDisposed, isTrue);

        await Future<void>.delayed(Duration.zero);
        expect(createdControllers, 2);

        frontInitializeCompleter.complete();

        final frontController = await frontInitialization;

        expect(
          frontController.description.lensDirection,
          CameraLensDirection.front,
        );
        expect(
          container.read(cameraServiceProvider).controller,
          same(frontController),
        );
      },
    );

    test('disposes the controller when initialization fails', () async {
      var disposed = false;

      final container = makeContainer(
        controllerFactory:
            (
              description,
              resolutionPreset, {
              enableAudio = true,
              imageFormatGroup,
            }) => _FailingFakeCameraController(
              description,
              resolutionPreset,
              enableAudio: enableAudio,
              imageFormatGroup: imageFormatGroup,
              onDispose: () => disposed = true,
            ),
      );

      await expectLater(
        container
            .read(cameraServiceProvider.notifier)
            .initializeCamera(CameraLensDirection.back),
        throwsA(isA<CameraException>()),
      );

      expect(disposed, isTrue);
      expect(container.read(cameraServiceProvider).controller, isNull);
    });

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

    test(
      'coalesces concurrent permission requests for the same camera',
      () async {
        final requestCompleter = Completer<PermissionStatus>();
        var requestInFlight = false;
        var permissionRequestCount = 0;

        final permissionService = FakePermissionService(
          cameraPermissionStatus: PermissionStatus.denied,
          onRequestCameraPermission: () {
            permissionRequestCount += 1;

            if (requestInFlight) {
              throw PlatformException(
                code: 'ERROR_ALREADY_REQUESTING_PERMISSIONS',
                message:
                    '''A request for permissions is already running, please wait for it to finish before doing another request.''',
              );
            }

            requestInFlight = true;

            return requestCompleter.future.whenComplete(() {
              requestInFlight = false;
            });
          },
        );

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
                  }) => FakeCameraController(
                    description,
                    resolutionPreset,
                    enableAudio: enableAudio,
                    imageFormatGroup: imageFormatGroup,
                  ),
            ),
            permissionServiceProvider.overrideWith((ref) => permissionService),
          ],
        );
        addTearDown(container.dispose);

        final notifier = container.read(cameraServiceProvider.notifier);

        final firstEnsureReady = notifier.ensureCameraReady(
          direction: CameraLensDirection.back,
        );

        await Future<void>.delayed(Duration.zero);

        final secondEnsureReady = notifier.ensureCameraReady(
          direction: CameraLensDirection.back,
        );

        requestCompleter.complete(PermissionStatus.granted);

        await expectLater(firstEnsureReady, completion(isTrue));
        await expectLater(secondEnsureReady, completion(isTrue));

        expect(permissionRequestCount, 1);
      },
    );
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

class _TrackedDelayedFakeCameraController extends _DelayedFakeCameraController {
  _TrackedDelayedFakeCameraController(
    super.description,
    super.resolutionPreset, {
    super.enableAudio,
    super.imageFormatGroup,
    required super.initializeCompleter,
    required this.onDispose,
  });

  final void Function() onDispose;

  @override
  Future<void> dispose() async {
    onDispose();
    await super.dispose();
  }
}

class _FailingFakeCameraController extends FakeCameraController {
  _FailingFakeCameraController(
    super.description,
    super.resolutionPreset, {
    super.enableAudio,
    super.imageFormatGroup,
    required this.onDispose,
  });

  final void Function() onDispose;

  @override
  Future<void> initialize() async {
    throw CameraException(
      'InitializationFailed',
      'Camera controller failed to initialize.',
    );
  }

  @override
  Future<void> dispose() async {
    onDispose();
    await super.dispose();
  }
}
