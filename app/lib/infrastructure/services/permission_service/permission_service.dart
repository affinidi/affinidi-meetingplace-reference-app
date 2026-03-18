import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'permission_service.g.dart';

/// A service for checking and requesting permissions.
@riverpod
PermissionService permissionService(Ref ref) {
  return PermissionService();
}

class PermissionService {
  Future<PermissionStatus> getCameraPermissionStatus() async {
    return await Permission.camera.status;
  }

  Future<PermissionStatus> requestCameraPermission() async {
    return await Permission.camera.request();
  }

  Future<PermissionStatus> getMicrophonePermissionStatus() async {
    return await Permission.microphone.status;
  }

  Future<PermissionStatus> requestMicrophonePermission() async {
    return await Permission.microphone.request();
  }
}
