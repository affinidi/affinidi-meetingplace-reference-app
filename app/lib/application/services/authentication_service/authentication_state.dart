import 'package:freezed_annotation/freezed_annotation.dart';

part 'authentication_state.freezed.dart';

@Freezed(fromJson: false, toJson: false)
abstract class AuthenticationState with _$AuthenticationState {
  const factory AuthenticationState({
    @Default(false) bool isAuthenticated,
    @Default(false) bool isLoading,
  }) = _AuthenticationState;
}
