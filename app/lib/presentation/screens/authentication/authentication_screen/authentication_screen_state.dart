import 'package:freezed_annotation/freezed_annotation.dart';

part 'authentication_screen_state.freezed.dart';

@Freezed(fromJson: false, toJson: false)
abstract class AuthenticationScreenState with _$AuthenticationScreenState {
  const factory AuthenticationScreenState({
    @Default(false) bool isLoading,
    @Default(false) bool isError,
    String? error,
  }) = _AuthenticationScreenState;
}
