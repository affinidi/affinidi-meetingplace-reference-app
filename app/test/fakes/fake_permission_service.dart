import 'package:mpx_flutter_reference_app/infrastructure/services/permission_service/permission_service.dart';
import 'package:permission_handler/permission_handler.dart';

class FakePermissionService extends PermissionService {
  FakePermissionService({
    this.cameraPermissionStatus = PermissionStatus.granted,
    this.microphonePermissionStatus = PermissionStatus.granted,
  });

  final PermissionStatus cameraPermissionStatus;
  final PermissionStatus microphonePermissionStatus;

  @override
  Future<PermissionStatus> getCameraPermissionStatus() async {
    return cameraPermissionStatus;
  }

  @override
  Future<PermissionStatus> requestCameraPermission() async {
    return cameraPermissionStatus;
  }

  @override
  Future<PermissionStatus> getMicrophonePermissionStatus() async {
    return microphonePermissionStatus;
  }

  @override
  Future<PermissionStatus> requestMicrophonePermission() async {
    return microphonePermissionStatus;
  }
}
