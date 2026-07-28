// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'call_participant.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CallParticipant {

 String get id; String get firstName;/// Optional avatar image; when null the sheet shows the person placeholder.
 ImageProvider? get avatar; CallParticipantConnection get connection;/// Ringing state; only meaningful when [connection] is
/// [CallParticipantConnection.notConnected].
 CallRingState get ringState;
/// Create a copy of CallParticipant
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CallParticipantCopyWith<CallParticipant> get copyWith => _$CallParticipantCopyWithImpl<CallParticipant>(this as CallParticipant, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CallParticipant&&(identical(other.id, id) || other.id == id)&&(identical(other.firstName, firstName) || other.firstName == firstName)&&(identical(other.avatar, avatar) || other.avatar == avatar)&&(identical(other.connection, connection) || other.connection == connection)&&(identical(other.ringState, ringState) || other.ringState == ringState));
}


@override
int get hashCode => Object.hash(runtimeType,id,firstName,avatar,connection,ringState);

@override
String toString() {
  return 'CallParticipant(id: $id, firstName: $firstName, avatar: $avatar, connection: $connection, ringState: $ringState)';
}


}

/// @nodoc
abstract mixin class $CallParticipantCopyWith<$Res>  {
  factory $CallParticipantCopyWith(CallParticipant value, $Res Function(CallParticipant) _then) = _$CallParticipantCopyWithImpl;
@useResult
$Res call({
 String id, String firstName, ImageProvider? avatar, CallParticipantConnection connection, CallRingState ringState
});




}
/// @nodoc
class _$CallParticipantCopyWithImpl<$Res>
    implements $CallParticipantCopyWith<$Res> {
  _$CallParticipantCopyWithImpl(this._self, this._then);

  final CallParticipant _self;
  final $Res Function(CallParticipant) _then;

/// Create a copy of CallParticipant
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? firstName = null,Object? avatar = freezed,Object? connection = null,Object? ringState = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,firstName: null == firstName ? _self.firstName : firstName // ignore: cast_nullable_to_non_nullable
as String,avatar: freezed == avatar ? _self.avatar : avatar // ignore: cast_nullable_to_non_nullable
as ImageProvider?,connection: null == connection ? _self.connection : connection // ignore: cast_nullable_to_non_nullable
as CallParticipantConnection,ringState: null == ringState ? _self.ringState : ringState // ignore: cast_nullable_to_non_nullable
as CallRingState,
  ));
}

}


/// Adds pattern-matching-related methods to [CallParticipant].
extension CallParticipantPatterns on CallParticipant {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CallParticipant value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CallParticipant() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CallParticipant value)  $default,){
final _that = this;
switch (_that) {
case _CallParticipant():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CallParticipant value)?  $default,){
final _that = this;
switch (_that) {
case _CallParticipant() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String firstName,  ImageProvider? avatar,  CallParticipantConnection connection,  CallRingState ringState)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CallParticipant() when $default != null:
return $default(_that.id,_that.firstName,_that.avatar,_that.connection,_that.ringState);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String firstName,  ImageProvider? avatar,  CallParticipantConnection connection,  CallRingState ringState)  $default,) {final _that = this;
switch (_that) {
case _CallParticipant():
return $default(_that.id,_that.firstName,_that.avatar,_that.connection,_that.ringState);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String firstName,  ImageProvider? avatar,  CallParticipantConnection connection,  CallRingState ringState)?  $default,) {final _that = this;
switch (_that) {
case _CallParticipant() when $default != null:
return $default(_that.id,_that.firstName,_that.avatar,_that.connection,_that.ringState);case _:
  return null;

}
}

}

/// @nodoc


class _CallParticipant implements CallParticipant {
  const _CallParticipant({required this.id, required this.firstName, this.avatar, required this.connection, this.ringState = CallRingState.idle});
  

@override final  String id;
@override final  String firstName;
/// Optional avatar image; when null the sheet shows the person placeholder.
@override final  ImageProvider? avatar;
@override final  CallParticipantConnection connection;
/// Ringing state; only meaningful when [connection] is
/// [CallParticipantConnection.notConnected].
@override@JsonKey() final  CallRingState ringState;

/// Create a copy of CallParticipant
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CallParticipantCopyWith<_CallParticipant> get copyWith => __$CallParticipantCopyWithImpl<_CallParticipant>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CallParticipant&&(identical(other.id, id) || other.id == id)&&(identical(other.firstName, firstName) || other.firstName == firstName)&&(identical(other.avatar, avatar) || other.avatar == avatar)&&(identical(other.connection, connection) || other.connection == connection)&&(identical(other.ringState, ringState) || other.ringState == ringState));
}


@override
int get hashCode => Object.hash(runtimeType,id,firstName,avatar,connection,ringState);

@override
String toString() {
  return 'CallParticipant(id: $id, firstName: $firstName, avatar: $avatar, connection: $connection, ringState: $ringState)';
}


}

/// @nodoc
abstract mixin class _$CallParticipantCopyWith<$Res> implements $CallParticipantCopyWith<$Res> {
  factory _$CallParticipantCopyWith(_CallParticipant value, $Res Function(_CallParticipant) _then) = __$CallParticipantCopyWithImpl;
@override @useResult
$Res call({
 String id, String firstName, ImageProvider? avatar, CallParticipantConnection connection, CallRingState ringState
});




}
/// @nodoc
class __$CallParticipantCopyWithImpl<$Res>
    implements _$CallParticipantCopyWith<$Res> {
  __$CallParticipantCopyWithImpl(this._self, this._then);

  final _CallParticipant _self;
  final $Res Function(_CallParticipant) _then;

/// Create a copy of CallParticipant
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? firstName = null,Object? avatar = freezed,Object? connection = null,Object? ringState = null,}) {
  return _then(_CallParticipant(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,firstName: null == firstName ? _self.firstName : firstName // ignore: cast_nullable_to_non_nullable
as String,avatar: freezed == avatar ? _self.avatar : avatar // ignore: cast_nullable_to_non_nullable
as ImageProvider?,connection: null == connection ? _self.connection : connection // ignore: cast_nullable_to_non_nullable
as CallParticipantConnection,ringState: null == ringState ? _self.ringState : ringState // ignore: cast_nullable_to_non_nullable
as CallRingState,
  ));
}


}

// dart format on
