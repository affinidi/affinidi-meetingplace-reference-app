// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tone_patterns.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TonePatterns _$TonePatternsFromJson(Map<String, dynamic> json) =>
    _TonePatterns(
      whenAgreeing: json['whenAgreeing'] as String? ?? '',
      whenDisagreeing: json['whenDisagreeing'] as String? ?? '',
      whenAsking: json['whenAsking'] as String? ?? '',
    );

Map<String, dynamic> _$TonePatternsToJson(_TonePatterns instance) =>
    <String, dynamic>{
      'whenAgreeing': instance.whenAgreeing,
      'whenDisagreeing': instance.whenDisagreeing,
      'whenAsking': instance.whenAsking,
    };
