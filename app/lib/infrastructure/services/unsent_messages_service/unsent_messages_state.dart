import 'package:freezed_annotation/freezed_annotation.dart';

part 'unsent_messages_state.freezed.dart';

@Freezed(fromJson: false, toJson: false)
abstract class UnsentMessagesServiceState with _$UnsentMessagesServiceState {
  const factory UnsentMessagesServiceState({
    @Default({}) Map<String, String> unsentMessages,
  }) = _UnsentMessagesServiceState;
}
