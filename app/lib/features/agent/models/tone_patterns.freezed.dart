// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'tone_patterns.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TonePatterns {

 String get whenAgreeing; String get whenDisagreeing; String get whenAsking;
/// Create a copy of TonePatterns
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TonePatternsCopyWith<TonePatterns> get copyWith => _$TonePatternsCopyWithImpl<TonePatterns>(this as TonePatterns, _$identity);

  /// Serializes this TonePatterns to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TonePatterns&&(identical(other.whenAgreeing, whenAgreeing) || other.whenAgreeing == whenAgreeing)&&(identical(other.whenDisagreeing, whenDisagreeing) || other.whenDisagreeing == whenDisagreeing)&&(identical(other.whenAsking, whenAsking) || other.whenAsking == whenAsking));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,whenAgreeing,whenDisagreeing,whenAsking);

@override
String toString() {
  return 'TonePatterns(whenAgreeing: $whenAgreeing, whenDisagreeing: $whenDisagreeing, whenAsking: $whenAsking)';
}


}

/// @nodoc
abstract mixin class $TonePatternsCopyWith<$Res>  {
  factory $TonePatternsCopyWith(TonePatterns value, $Res Function(TonePatterns) _then) = _$TonePatternsCopyWithImpl;
@useResult
$Res call({
 String whenAgreeing, String whenDisagreeing, String whenAsking
});




}
/// @nodoc
class _$TonePatternsCopyWithImpl<$Res>
    implements $TonePatternsCopyWith<$Res> {
  _$TonePatternsCopyWithImpl(this._self, this._then);

  final TonePatterns _self;
  final $Res Function(TonePatterns) _then;

/// Create a copy of TonePatterns
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? whenAgreeing = null,Object? whenDisagreeing = null,Object? whenAsking = null,}) {
  return _then(_self.copyWith(
whenAgreeing: null == whenAgreeing ? _self.whenAgreeing : whenAgreeing // ignore: cast_nullable_to_non_nullable
as String,whenDisagreeing: null == whenDisagreeing ? _self.whenDisagreeing : whenDisagreeing // ignore: cast_nullable_to_non_nullable
as String,whenAsking: null == whenAsking ? _self.whenAsking : whenAsking // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [TonePatterns].
extension TonePatternsPatterns on TonePatterns {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TonePatterns value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TonePatterns() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TonePatterns value)  $default,){
final _that = this;
switch (_that) {
case _TonePatterns():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TonePatterns value)?  $default,){
final _that = this;
switch (_that) {
case _TonePatterns() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String whenAgreeing,  String whenDisagreeing,  String whenAsking)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TonePatterns() when $default != null:
return $default(_that.whenAgreeing,_that.whenDisagreeing,_that.whenAsking);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String whenAgreeing,  String whenDisagreeing,  String whenAsking)  $default,) {final _that = this;
switch (_that) {
case _TonePatterns():
return $default(_that.whenAgreeing,_that.whenDisagreeing,_that.whenAsking);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String whenAgreeing,  String whenDisagreeing,  String whenAsking)?  $default,) {final _that = this;
switch (_that) {
case _TonePatterns() when $default != null:
return $default(_that.whenAgreeing,_that.whenDisagreeing,_that.whenAsking);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TonePatterns implements TonePatterns {
  const _TonePatterns({this.whenAgreeing = '', this.whenDisagreeing = '', this.whenAsking = ''});
  factory _TonePatterns.fromJson(Map<String, dynamic> json) => _$TonePatternsFromJson(json);

@override@JsonKey() final  String whenAgreeing;
@override@JsonKey() final  String whenDisagreeing;
@override@JsonKey() final  String whenAsking;

/// Create a copy of TonePatterns
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TonePatternsCopyWith<_TonePatterns> get copyWith => __$TonePatternsCopyWithImpl<_TonePatterns>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TonePatternsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TonePatterns&&(identical(other.whenAgreeing, whenAgreeing) || other.whenAgreeing == whenAgreeing)&&(identical(other.whenDisagreeing, whenDisagreeing) || other.whenDisagreeing == whenDisagreeing)&&(identical(other.whenAsking, whenAsking) || other.whenAsking == whenAsking));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,whenAgreeing,whenDisagreeing,whenAsking);

@override
String toString() {
  return 'TonePatterns(whenAgreeing: $whenAgreeing, whenDisagreeing: $whenDisagreeing, whenAsking: $whenAsking)';
}


}

/// @nodoc
abstract mixin class _$TonePatternsCopyWith<$Res> implements $TonePatternsCopyWith<$Res> {
  factory _$TonePatternsCopyWith(_TonePatterns value, $Res Function(_TonePatterns) _then) = __$TonePatternsCopyWithImpl;
@override @useResult
$Res call({
 String whenAgreeing, String whenDisagreeing, String whenAsking
});




}
/// @nodoc
class __$TonePatternsCopyWithImpl<$Res>
    implements _$TonePatternsCopyWith<$Res> {
  __$TonePatternsCopyWithImpl(this._self, this._then);

  final _TonePatterns _self;
  final $Res Function(_TonePatterns) _then;

/// Create a copy of TonePatterns
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? whenAgreeing = null,Object? whenDisagreeing = null,Object? whenAsking = null,}) {
  return _then(_TonePatterns(
whenAgreeing: null == whenAgreeing ? _self.whenAgreeing : whenAgreeing // ignore: cast_nullable_to_non_nullable
as String,whenDisagreeing: null == whenDisagreeing ? _self.whenDisagreeing : whenDisagreeing // ignore: cast_nullable_to_non_nullable
as String,whenAsking: null == whenAsking ? _self.whenAsking : whenAsking // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
