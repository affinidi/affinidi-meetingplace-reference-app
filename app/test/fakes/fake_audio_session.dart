import 'package:audio_session/audio_session.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeAudioSession extends Fake implements AudioSession {
  int configureCalls = 0;
  int setActiveCalls = 0;
  bool? lastSetActiveValue;
  AudioSessionConfiguration? lastConfiguration;
  AVAudioSessionSetActiveOptions? lastSetActiveOptions;
  bool setActiveResult = true;

  @override
  Future<void> configure(AudioSessionConfiguration configuration) async {
    configureCalls++;
    lastConfiguration = configuration;
  }

  @override
  Future<bool> setActive(
    bool active, {
    AVAudioSessionSetActiveOptions? avAudioSessionSetActiveOptions,
    AndroidAudioFocusGainType? androidAudioFocusGainType,
    AndroidAudioAttributes? androidAudioAttributes,
    bool? androidWillPauseWhenDucked,
    AudioSessionConfiguration fallbackConfiguration =
        const AudioSessionConfiguration.music(),
  }) async {
    setActiveCalls++;
    lastSetActiveValue = active;
    lastSetActiveOptions = avAudioSessionSetActiveOptions;
    return setActiveResult;
  }
}
