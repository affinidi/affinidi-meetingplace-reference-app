import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../application/services/authentication_service/authentication_service.dart';
import '../../../../infrastructure/configuration/environment.dart';
import 'authentication_screen_state.dart';

part 'authentication_screen_controller.g.dart';

@riverpod
class AuthenticationScreenController extends _$AuthenticationScreenController {
  @override
  AuthenticationScreenState build() {
    ref.listen(
      authenticationServiceProvider,
      (previous, next) {
        if (previous != null && !next.isAuthenticated && !next.isLoading) {
          Future.microtask(() {
            state = state.copyWith(isError: true);
          });
        }
      },
      fireImmediately: true,
    );
    return const AuthenticationScreenState();
  }

  Future<void> initialize(String unlockReason) async {
    if (state.isLoading) return;
    state = state.copyWith(isLoading: true);
    try {
      final extraDelayAtLaunch =
          ref.read(environmentProvider).extraDelayAtLaunchInMilliseconds;
      if (extraDelayAtLaunch > 0) {
        await Future<void>.delayed(Duration(milliseconds: extraDelayAtLaunch));
      }
      await _authenticate(unlockReason);
    } catch (e) {
      state = state.copyWith(isError: true, error: e.toString());
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> retry(String unlockReason) async {
    try {
      state = state.copyWith(isLoading: true, isError: false, error: null);
      await _authenticate(unlockReason);
    } catch (e) {
      state = state.copyWith(isError: true, error: e.toString());
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> _authenticate(String unlockReason) async {
    final authService = ref.read(authenticationServiceProvider.notifier);
    await authService.authenticate(unlockReason);
  }
}
