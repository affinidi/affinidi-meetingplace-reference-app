import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../screens/chat/audio_video_call/rules/call_ui_rules.dart';

part 'end_call_banner_state.freezed.dart';

@freezed
abstract class EndCallBannerState with _$EndCallBannerState {
  const factory EndCallBannerState({
    required String contactId,
    required String peerName,
    required CallEndState endState,
    required bool isAudioOnly,
    @Default(0.0) double slideOutOffset,
  }) = _EndCallBannerState;
}
