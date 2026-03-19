// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'agent_persona.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AgentPersona {

 String get communicationStyle; String get averageMessageLength; bool get usesEmoji; String get formality; List<String> get commonPhrases; List<String> get avoidPhrases; TonePatterns? get tonePatterns; List<String> get topicsDiscussed; List<String> get hardLimits;
/// Create a copy of AgentPersona
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AgentPersonaCopyWith<AgentPersona> get copyWith => _$AgentPersonaCopyWithImpl<AgentPersona>(this as AgentPersona, _$identity);

  /// Serializes this AgentPersona to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AgentPersona&&(identical(other.communicationStyle, communicationStyle) || other.communicationStyle == communicationStyle)&&(identical(other.averageMessageLength, averageMessageLength) || other.averageMessageLength == averageMessageLength)&&(identical(other.usesEmoji, usesEmoji) || other.usesEmoji == usesEmoji)&&(identical(other.formality, formality) || other.formality == formality)&&const DeepCollectionEquality().equals(other.commonPhrases, commonPhrases)&&const DeepCollectionEquality().equals(other.avoidPhrases, avoidPhrases)&&(identical(other.tonePatterns, tonePatterns) || other.tonePatterns == tonePatterns)&&const DeepCollectionEquality().equals(other.topicsDiscussed, topicsDiscussed)&&const DeepCollectionEquality().equals(other.hardLimits, hardLimits));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,communicationStyle,averageMessageLength,usesEmoji,formality,const DeepCollectionEquality().hash(commonPhrases),const DeepCollectionEquality().hash(avoidPhrases),tonePatterns,const DeepCollectionEquality().hash(topicsDiscussed),const DeepCollectionEquality().hash(hardLimits));

@override
String toString() {
  return 'AgentPersona(communicationStyle: $communicationStyle, averageMessageLength: $averageMessageLength, usesEmoji: $usesEmoji, formality: $formality, commonPhrases: $commonPhrases, avoidPhrases: $avoidPhrases, tonePatterns: $tonePatterns, topicsDiscussed: $topicsDiscussed, hardLimits: $hardLimits)';
}


}

/// @nodoc
abstract mixin class $AgentPersonaCopyWith<$Res>  {
  factory $AgentPersonaCopyWith(AgentPersona value, $Res Function(AgentPersona) _then) = _$AgentPersonaCopyWithImpl;
@useResult
$Res call({
 String communicationStyle, String averageMessageLength, bool usesEmoji, String formality, List<String> commonPhrases, List<String> avoidPhrases, TonePatterns? tonePatterns, List<String> topicsDiscussed, List<String> hardLimits
});


$TonePatternsCopyWith<$Res>? get tonePatterns;

}
/// @nodoc
class _$AgentPersonaCopyWithImpl<$Res>
    implements $AgentPersonaCopyWith<$Res> {
  _$AgentPersonaCopyWithImpl(this._self, this._then);

  final AgentPersona _self;
  final $Res Function(AgentPersona) _then;

/// Create a copy of AgentPersona
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? communicationStyle = null,Object? averageMessageLength = null,Object? usesEmoji = null,Object? formality = null,Object? commonPhrases = null,Object? avoidPhrases = null,Object? tonePatterns = freezed,Object? topicsDiscussed = null,Object? hardLimits = null,}) {
  return _then(_self.copyWith(
communicationStyle: null == communicationStyle ? _self.communicationStyle : communicationStyle // ignore: cast_nullable_to_non_nullable
as String,averageMessageLength: null == averageMessageLength ? _self.averageMessageLength : averageMessageLength // ignore: cast_nullable_to_non_nullable
as String,usesEmoji: null == usesEmoji ? _self.usesEmoji : usesEmoji // ignore: cast_nullable_to_non_nullable
as bool,formality: null == formality ? _self.formality : formality // ignore: cast_nullable_to_non_nullable
as String,commonPhrases: null == commonPhrases ? _self.commonPhrases : commonPhrases // ignore: cast_nullable_to_non_nullable
as List<String>,avoidPhrases: null == avoidPhrases ? _self.avoidPhrases : avoidPhrases // ignore: cast_nullable_to_non_nullable
as List<String>,tonePatterns: freezed == tonePatterns ? _self.tonePatterns : tonePatterns // ignore: cast_nullable_to_non_nullable
as TonePatterns?,topicsDiscussed: null == topicsDiscussed ? _self.topicsDiscussed : topicsDiscussed // ignore: cast_nullable_to_non_nullable
as List<String>,hardLimits: null == hardLimits ? _self.hardLimits : hardLimits // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}
/// Create a copy of AgentPersona
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TonePatternsCopyWith<$Res>? get tonePatterns {
    if (_self.tonePatterns == null) {
    return null;
  }

  return $TonePatternsCopyWith<$Res>(_self.tonePatterns!, (value) {
    return _then(_self.copyWith(tonePatterns: value));
  });
}
}


/// Adds pattern-matching-related methods to [AgentPersona].
extension AgentPersonaPatterns on AgentPersona {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AgentPersona value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AgentPersona() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AgentPersona value)  $default,){
final _that = this;
switch (_that) {
case _AgentPersona():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AgentPersona value)?  $default,){
final _that = this;
switch (_that) {
case _AgentPersona() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String communicationStyle,  String averageMessageLength,  bool usesEmoji,  String formality,  List<String> commonPhrases,  List<String> avoidPhrases,  TonePatterns? tonePatterns,  List<String> topicsDiscussed,  List<String> hardLimits)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AgentPersona() when $default != null:
return $default(_that.communicationStyle,_that.averageMessageLength,_that.usesEmoji,_that.formality,_that.commonPhrases,_that.avoidPhrases,_that.tonePatterns,_that.topicsDiscussed,_that.hardLimits);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String communicationStyle,  String averageMessageLength,  bool usesEmoji,  String formality,  List<String> commonPhrases,  List<String> avoidPhrases,  TonePatterns? tonePatterns,  List<String> topicsDiscussed,  List<String> hardLimits)  $default,) {final _that = this;
switch (_that) {
case _AgentPersona():
return $default(_that.communicationStyle,_that.averageMessageLength,_that.usesEmoji,_that.formality,_that.commonPhrases,_that.avoidPhrases,_that.tonePatterns,_that.topicsDiscussed,_that.hardLimits);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String communicationStyle,  String averageMessageLength,  bool usesEmoji,  String formality,  List<String> commonPhrases,  List<String> avoidPhrases,  TonePatterns? tonePatterns,  List<String> topicsDiscussed,  List<String> hardLimits)?  $default,) {final _that = this;
switch (_that) {
case _AgentPersona() when $default != null:
return $default(_that.communicationStyle,_that.averageMessageLength,_that.usesEmoji,_that.formality,_that.commonPhrases,_that.avoidPhrases,_that.tonePatterns,_that.topicsDiscussed,_that.hardLimits);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AgentPersona implements AgentPersona {
  const _AgentPersona({this.communicationStyle = '', this.averageMessageLength = 'medium', this.usesEmoji = false, this.formality = 'mixed', final  List<String> commonPhrases = const [], final  List<String> avoidPhrases = const [], this.tonePatterns, final  List<String> topicsDiscussed = const [], final  List<String> hardLimits = const []}): _commonPhrases = commonPhrases,_avoidPhrases = avoidPhrases,_topicsDiscussed = topicsDiscussed,_hardLimits = hardLimits;
  factory _AgentPersona.fromJson(Map<String, dynamic> json) => _$AgentPersonaFromJson(json);

@override@JsonKey() final  String communicationStyle;
@override@JsonKey() final  String averageMessageLength;
@override@JsonKey() final  bool usesEmoji;
@override@JsonKey() final  String formality;
 final  List<String> _commonPhrases;
@override@JsonKey() List<String> get commonPhrases {
  if (_commonPhrases is EqualUnmodifiableListView) return _commonPhrases;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_commonPhrases);
}

 final  List<String> _avoidPhrases;
@override@JsonKey() List<String> get avoidPhrases {
  if (_avoidPhrases is EqualUnmodifiableListView) return _avoidPhrases;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_avoidPhrases);
}

@override final  TonePatterns? tonePatterns;
 final  List<String> _topicsDiscussed;
@override@JsonKey() List<String> get topicsDiscussed {
  if (_topicsDiscussed is EqualUnmodifiableListView) return _topicsDiscussed;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_topicsDiscussed);
}

 final  List<String> _hardLimits;
@override@JsonKey() List<String> get hardLimits {
  if (_hardLimits is EqualUnmodifiableListView) return _hardLimits;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_hardLimits);
}


/// Create a copy of AgentPersona
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AgentPersonaCopyWith<_AgentPersona> get copyWith => __$AgentPersonaCopyWithImpl<_AgentPersona>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AgentPersonaToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AgentPersona&&(identical(other.communicationStyle, communicationStyle) || other.communicationStyle == communicationStyle)&&(identical(other.averageMessageLength, averageMessageLength) || other.averageMessageLength == averageMessageLength)&&(identical(other.usesEmoji, usesEmoji) || other.usesEmoji == usesEmoji)&&(identical(other.formality, formality) || other.formality == formality)&&const DeepCollectionEquality().equals(other._commonPhrases, _commonPhrases)&&const DeepCollectionEquality().equals(other._avoidPhrases, _avoidPhrases)&&(identical(other.tonePatterns, tonePatterns) || other.tonePatterns == tonePatterns)&&const DeepCollectionEquality().equals(other._topicsDiscussed, _topicsDiscussed)&&const DeepCollectionEquality().equals(other._hardLimits, _hardLimits));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,communicationStyle,averageMessageLength,usesEmoji,formality,const DeepCollectionEquality().hash(_commonPhrases),const DeepCollectionEquality().hash(_avoidPhrases),tonePatterns,const DeepCollectionEquality().hash(_topicsDiscussed),const DeepCollectionEquality().hash(_hardLimits));

@override
String toString() {
  return 'AgentPersona(communicationStyle: $communicationStyle, averageMessageLength: $averageMessageLength, usesEmoji: $usesEmoji, formality: $formality, commonPhrases: $commonPhrases, avoidPhrases: $avoidPhrases, tonePatterns: $tonePatterns, topicsDiscussed: $topicsDiscussed, hardLimits: $hardLimits)';
}


}

/// @nodoc
abstract mixin class _$AgentPersonaCopyWith<$Res> implements $AgentPersonaCopyWith<$Res> {
  factory _$AgentPersonaCopyWith(_AgentPersona value, $Res Function(_AgentPersona) _then) = __$AgentPersonaCopyWithImpl;
@override @useResult
$Res call({
 String communicationStyle, String averageMessageLength, bool usesEmoji, String formality, List<String> commonPhrases, List<String> avoidPhrases, TonePatterns? tonePatterns, List<String> topicsDiscussed, List<String> hardLimits
});


@override $TonePatternsCopyWith<$Res>? get tonePatterns;

}
/// @nodoc
class __$AgentPersonaCopyWithImpl<$Res>
    implements _$AgentPersonaCopyWith<$Res> {
  __$AgentPersonaCopyWithImpl(this._self, this._then);

  final _AgentPersona _self;
  final $Res Function(_AgentPersona) _then;

/// Create a copy of AgentPersona
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? communicationStyle = null,Object? averageMessageLength = null,Object? usesEmoji = null,Object? formality = null,Object? commonPhrases = null,Object? avoidPhrases = null,Object? tonePatterns = freezed,Object? topicsDiscussed = null,Object? hardLimits = null,}) {
  return _then(_AgentPersona(
communicationStyle: null == communicationStyle ? _self.communicationStyle : communicationStyle // ignore: cast_nullable_to_non_nullable
as String,averageMessageLength: null == averageMessageLength ? _self.averageMessageLength : averageMessageLength // ignore: cast_nullable_to_non_nullable
as String,usesEmoji: null == usesEmoji ? _self.usesEmoji : usesEmoji // ignore: cast_nullable_to_non_nullable
as bool,formality: null == formality ? _self.formality : formality // ignore: cast_nullable_to_non_nullable
as String,commonPhrases: null == commonPhrases ? _self._commonPhrases : commonPhrases // ignore: cast_nullable_to_non_nullable
as List<String>,avoidPhrases: null == avoidPhrases ? _self._avoidPhrases : avoidPhrases // ignore: cast_nullable_to_non_nullable
as List<String>,tonePatterns: freezed == tonePatterns ? _self.tonePatterns : tonePatterns // ignore: cast_nullable_to_non_nullable
as TonePatterns?,topicsDiscussed: null == topicsDiscussed ? _self._topicsDiscussed : topicsDiscussed // ignore: cast_nullable_to_non_nullable
as List<String>,hardLimits: null == hardLimits ? _self._hardLimits : hardLimits // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

/// Create a copy of AgentPersona
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TonePatternsCopyWith<$Res>? get tonePatterns {
    if (_self.tonePatterns == null) {
    return null;
  }

  return $TonePatternsCopyWith<$Res>(_self.tonePatterns!, (value) {
    return _then(_self.copyWith(tonePatterns: value));
  });
}
}

// dart format on
