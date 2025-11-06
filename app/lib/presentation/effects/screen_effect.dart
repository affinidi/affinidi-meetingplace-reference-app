import 'package:meeting_place_chat/meeting_place_chat.dart';

class ScreenEffect {
  factory ScreenEffect.confetti() => const ScreenEffect._(
        type: Effect.confetti,
        duration: Duration(seconds: 5),
      );

  factory ScreenEffect.balloons() => const ScreenEffect._(
        type: Effect.balloons,
        duration: Duration(seconds: 4),
      );

  const ScreenEffect._({
    required this.type,
    required this.duration,
  });

  final Effect type;
  final Duration duration;
}
