import 'package:mpx_app_core/mpx_app_core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'incoming_call_state_provider.g.dart';

/// Holds the current pending incoming call, or `null` when no call is ringing.
///
/// Written by `AppController` when a new `IncomingAudioVideoCallEvent` arrives.
/// Read by `App` to render the `IncomingCallBanner` on any screen.
/// Cleared when the user accepts or declines via the banner.
@Riverpod(keepAlive: true)
class IncomingCallState extends _$IncomingCallState {
  @override
  IncomingAudioVideoCallEvent? build() => null;

  void set(IncomingAudioVideoCallEvent event) => state = event;

  void clear() => state = null;
}
