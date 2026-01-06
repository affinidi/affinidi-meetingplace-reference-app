// ignore_for_file: depend_on_referenced_packages

import 'package:local_auth/local_auth.dart';
import 'package:local_auth_android/src/auth_messages_android.dart';
import 'package:local_auth_darwin/types/auth_messages_ios.dart';
import 'package:local_auth_platform_interface/types/auth_messages.dart';
import 'package:local_auth_windows/types/auth_messages_windows.dart';

class FakeLocalAuthentication implements LocalAuthentication {
  FakeLocalAuthentication({required bool isAuthenticated})
      : _isAuthenticated = isAuthenticated;

  final bool _isAuthenticated;

  @override
  Future<bool> authenticate({
    required String localizedReason,
    Iterable<AuthMessages> authMessages = const <AuthMessages>[
      IOSAuthMessages(),
      AndroidAuthMessages(),
      WindowsAuthMessages(),
    ],
    AuthenticationOptions options = const AuthenticationOptions(),
  }) {
    return Future.value(_isAuthenticated);
  }

  @override
  Future<bool> get canCheckBiometrics async => true;

  @override
  Future<bool> isDeviceSupported() async => true;

  @override
  dynamic noSuchMethod(Invocation invocation) {
    throw UnimplementedError();
  }
}
