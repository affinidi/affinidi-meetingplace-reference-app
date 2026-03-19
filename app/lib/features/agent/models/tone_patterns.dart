import 'package:freezed_annotation/freezed_annotation.dart';

part 'tone_patterns.freezed.dart';
part 'tone_patterns.g.dart';

@freezed
abstract class TonePatterns with _$TonePatterns {
  const factory TonePatterns({
    @Default('') String whenAgreeing,
    @Default('') String whenDisagreeing,
    @Default('') String whenAsking,
  }) = _TonePatterns;

  factory TonePatterns.fromJson(Map<String, dynamic> json) =>
      _$TonePatternsFromJson(json);
}
