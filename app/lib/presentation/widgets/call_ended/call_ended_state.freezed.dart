// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'call_ended_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CallEndedState {

 String get contactId; String get peerName; int get callDurationSeconds; bool get isAudioOnly;
/// Create a copy of CallEndedState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CallEndedStateCopyWith<CallEndedState> get copyWith => _$CallEndedStateCopyWithImpl<CallEndedState>(this as CallEndedState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CallEndedState&&(identical(other.contactId, contactId) || other.contactId == contactId)&&(identical(other.peerName, peerName) || other.peerName == peerName)&&(identical(other.callDurationSeconds, callDurationSeconds) || other.callDurationSeconds == callDurationSeconds)&&(identical(other.isAudioOnly, isAudioOnly) || other.isAudioOnly == isAudioOnly));
}


@override
int get hashCode => Object.hash(runtimeType,contactId,peerName,callDurationSeconds,isAudioOnly);

@override
String toString() {
  return 'CallEndedState(contactId: $contactId, peerName: $peerName, callDurationSeconds: $callDurationSeconds, isAudioOnly: $isAudioOnly)';
}


}

/// @nodoc
abstract mixin class $CallEndedStateCopyWith<$Res>  {
  factory $CallEndedStateCopyWith(CallEndedState value, $Res Function(CallEndedState) _then) = _$CallEndedStateCopyWithImpl;
@useResult
$Res call({
 String contactId, String peerName, int callDurationSeconds, bool isAudioOnly
});




}
/// @nodoc
class _$CallEndedStateCopyWithImpl<$Res>
    implements $CallEndedStateCopyWith<$Res> {
  _$CallEndedStateCopyWithImpl(this._self, this._then);

  final CallEndedState _self;
  final $Res Function(CallEndedState) _then;

/// Create a copy of CallEndedState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? contactId = null,Object? peerName = null,Object? callDurationSeconds = null,Object? isAudioOnly = null,}) {
  return _then(_self.copyWith(
contactId: null == contactId ? _self.contactId : contactId // ignore: cast_nullable_to_non_nullable
as String,peerName: null == peerName ? _self.peerName : peerName // ignore: cast_nullable_to_non_nullable
as String,callDurationSeconds: null == callDurationSeconds ? _self.callDurationSeconds : callDurationSeconds // ignore: cast_nullable_to_non_nullable
as int,isAudioOnly: null == isAudioOnly ? _self.isAudioOnly : isAudioOnly // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [CallEndedState].
extension CallEndedStatePatterns on CallEndedState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CallEndedState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CallEndedState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CallEndedState value)  $default,){
final _that = this;
switch (_that) {
case _CallEndedState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CallEndedState value)?  $default,){
final _that = this;
switch (_that) {
case _CallEndedState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String contactId,  String peerName,  int callDurationSeconds,  bool isAudioOnly)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CallEndedState() when $default != null:
return $default(_that.contactId,_that.peerName,_that.callDurationSeconds,_that.isAudioOnly);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String contactId,  String peerName,  int callDurationSeconds,  bool isAudioOnly)  $default,) {final _that = this;
switch (_that) {
case _CallEndedState():
return $default(_that.contactId,_that.peerName,_that.callDurationSeconds,_that.isAudioOnly);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String contactId,  String peerName,  int callDurationSeconds,  bool isAudioOnly)?  $default,) {final _that = this;
switch (_that) {
case _CallEndedState() when $default != null:
return $default(_that.contactId,_that.peerName,_that.callDurationSeconds,_that.isAudioOnly);case _:
  return null;

}
}

}

/// @nodoc


class _CallEndedState implements CallEndedState {
  const _CallEndedState({required this.contactId, required this.peerName, required this.callDurationSeconds, required this.isAudioOnly});
  

@override final  String contactId;
@override final  String peerName;
@override final  int callDurationSeconds;
@override final  bool isAudioOnly;

/// Create a copy of CallEndedState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CallEndedStateCopyWith<_CallEndedState> get copyWith => __$CallEndedStateCopyWithImpl<_CallEndedState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CallEndedState&&(identical(other.contactId, contactId) || other.contactId == contactId)&&(identical(other.peerName, peerName) || other.peerName == peerName)&&(identical(other.callDurationSeconds, callDurationSeconds) || other.callDurationSeconds == callDurationSeconds)&&(identical(other.isAudioOnly, isAudioOnly) || other.isAudioOnly == isAudioOnly));
}


@override
int get hashCode => Object.hash(runtimeType,contactId,peerName,callDurationSeconds,isAudioOnly);

@override
String toString() {
  return 'CallEndedState(contactId: $contactId, peerName: $peerName, callDurationSeconds: $callDurationSeconds, isAudioOnly: $isAudioOnly)';
}


}

/// @nodoc
abstract mixin class _$CallEndedStateCopyWith<$Res> implements $CallEndedStateCopyWith<$Res> {
  factory _$CallEndedStateCopyWith(_CallEndedState value, $Res Function(_CallEndedState) _then) = __$CallEndedStateCopyWithImpl;
@override @useResult
$Res call({
 String contactId, String peerName, int callDurationSeconds, bool isAudioOnly
});




}
/// @nodoc
class __$CallEndedStateCopyWithImpl<$Res>
    implements _$CallEndedStateCopyWith<$Res> {
  __$CallEndedStateCopyWithImpl(this._self, this._then);

  final _CallEndedState _self;
  final $Res Function(_CallEndedState) _then;

/// Create a copy of CallEndedState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? contactId = null,Object? peerName = null,Object? callDurationSeconds = null,Object? isAudioOnly = null,}) {
  return _then(_CallEndedState(
contactId: null == contactId ? _self.contactId : contactId // ignore: cast_nullable_to_non_nullable
as String,peerName: null == peerName ? _self.peerName : peerName // ignore: cast_nullable_to_non_nullable
as String,callDurationSeconds: null == callDurationSeconds ? _self.callDurationSeconds : callDurationSeconds // ignore: cast_nullable_to_non_nullable
as int,isAudioOnly: null == isAudioOnly ? _self.isAudioOnly : isAudioOnly // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
