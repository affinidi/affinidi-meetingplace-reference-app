import 'package:freezed_annotation/freezed_annotation.dart';

part 'mnemonic_screen_state.freezed.dart';

@Freezed(fromJson: false, toJson: false)
abstract class MnemonicScreenState with _$MnemonicScreenState {
  const factory MnemonicScreenState({
    @Default(false) bool isLoading,
    @Default(false) bool isError,
    String? errorMessage,
  }) = _MnemonicScreenState;
}
