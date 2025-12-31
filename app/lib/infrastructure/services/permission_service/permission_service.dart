import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'permission_service.g.dart';

/// A service for checking and requesting permissions.
/// This abstraction allows for easier testing by providing a mockable interface.
@riverpod
PermissionService permissionService(Ref ref) {
  return PermissionService();
}

class PermissionService {
  /// Gets the current camera permission status.
  Future<PermissionStatus> getCameraPermissionStatus() async {
    return await Permission.camera.status;
  }

  /// Requests camera permission from the user.
  Future<PermissionStatus> requestCameraPermission() async {
    return await Permission.camera.request();
  }
}
