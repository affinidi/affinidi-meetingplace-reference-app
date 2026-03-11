// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'oob_service_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$OOBServiceState {

 Contact? get lastAcceptedContact; bool get isConnectionEstablished; bool get isLoading; String? get error; ConnectionOffer? get currentOobOffer; Channel? get lastConnectionChannel;
/// Create a copy of OOBServiceState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OOBServiceStateCopyWith<OOBServiceState> get copyWith => _$OOBServiceStateCopyWithImpl<OOBServiceState>(this as OOBServiceState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OOBServiceState&&(identical(other.lastAcceptedContact, lastAcceptedContact) || other.lastAcceptedContact == lastAcceptedContact)&&(identical(other.isConnectionEstablished, isConnectionEstablished) || other.isConnectionEstablished == isConnectionEstablished)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.error, error) || other.error == error)&&(identical(other.currentOobOffer, currentOobOffer) || other.currentOobOffer == currentOobOffer)&&(identical(other.lastConnectionChannel, lastConnectionChannel) || other.lastConnectionChannel == lastConnectionChannel));
}


@override
int get hashCode => Object.hash(runtimeType,lastAcceptedContact,isConnectionEstablished,isLoading,error,currentOobOffer,lastConnectionChannel);

@override
String toString() {
  return 'OOBServiceState(lastAcceptedContact: $lastAcceptedContact, isConnectionEstablished: $isConnectionEstablished, isLoading: $isLoading, error: $error, currentOobOffer: $currentOobOffer, lastConnectionChannel: $lastConnectionChannel)';
}


}

/// @nodoc
abstract mixin class $OOBServiceStateCopyWith<$Res>  {
  factory $OOBServiceStateCopyWith(OOBServiceState value, $Res Function(OOBServiceState) _then) = _$OOBServiceStateCopyWithImpl;
@useResult
$Res call({
 Contact? lastAcceptedContact, bool isConnectionEstablished, bool isLoading, String? error, ConnectionOffer? currentOobOffer, Channel? lastConnectionChannel
});




}
/// @nodoc
class _$OOBServiceStateCopyWithImpl<$Res>
    implements $OOBServiceStateCopyWith<$Res> {
  _$OOBServiceStateCopyWithImpl(this._self, this._then);

  final OOBServiceState _self;
  final $Res Function(OOBServiceState) _then;

/// Create a copy of OOBServiceState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? lastAcceptedContact = freezed,Object? isConnectionEstablished = null,Object? isLoading = null,Object? error = freezed,Object? currentOobOffer = freezed,Object? lastConnectionChannel = freezed,}) {
  return _then(_self.copyWith(
lastAcceptedContact: freezed == lastAcceptedContact ? _self.lastAcceptedContact : lastAcceptedContact // ignore: cast_nullable_to_non_nullable
as Contact?,isConnectionEstablished: null == isConnectionEstablished ? _self.isConnectionEstablished : isConnectionEstablished // ignore: cast_nullable_to_non_nullable
as bool,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,currentOobOffer: freezed == currentOobOffer ? _self.currentOobOffer : currentOobOffer // ignore: cast_nullable_to_non_nullable
as ConnectionOffer?,lastConnectionChannel: freezed == lastConnectionChannel ? _self.lastConnectionChannel : lastConnectionChannel // ignore: cast_nullable_to_non_nullable
as Channel?,
  ));
}

}


/// Adds pattern-matching-related methods to [OOBServiceState].
extension OOBServiceStatePatterns on OOBServiceState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OOBServiceState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OOBServiceState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OOBServiceState value)  $default,){
final _that = this;
switch (_that) {
case _OOBServiceState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OOBServiceState value)?  $default,){
final _that = this;
switch (_that) {
case _OOBServiceState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Contact? lastAcceptedContact,  bool isConnectionEstablished,  bool isLoading,  String? error,  ConnectionOffer? currentOobOffer,  Channel? lastConnectionChannel)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OOBServiceState() when $default != null:
return $default(_that.lastAcceptedContact,_that.isConnectionEstablished,_that.isLoading,_that.error,_that.currentOobOffer,_that.lastConnectionChannel);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Contact? lastAcceptedContact,  bool isConnectionEstablished,  bool isLoading,  String? error,  ConnectionOffer? currentOobOffer,  Channel? lastConnectionChannel)  $default,) {final _that = this;
switch (_that) {
case _OOBServiceState():
return $default(_that.lastAcceptedContact,_that.isConnectionEstablished,_that.isLoading,_that.error,_that.currentOobOffer,_that.lastConnectionChannel);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Contact? lastAcceptedContact,  bool isConnectionEstablished,  bool isLoading,  String? error,  ConnectionOffer? currentOobOffer,  Channel? lastConnectionChannel)?  $default,) {final _that = this;
switch (_that) {
case _OOBServiceState() when $default != null:
return $default(_that.lastAcceptedContact,_that.isConnectionEstablished,_that.isLoading,_that.error,_that.currentOobOffer,_that.lastConnectionChannel);case _:
  return null;

}
}

}

/// @nodoc


class _OOBServiceState implements OOBServiceState {
   _OOBServiceState({this.lastAcceptedContact, this.isConnectionEstablished = false, this.isLoading = false, this.error, this.currentOobOffer, this.lastConnectionChannel});
  

@override final  Contact? lastAcceptedContact;
@override@JsonKey() final  bool isConnectionEstablished;
@override@JsonKey() final  bool isLoading;
@override final  String? error;
@override final  ConnectionOffer? currentOobOffer;
@override final  Channel? lastConnectionChannel;

/// Create a copy of OOBServiceState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OOBServiceStateCopyWith<_OOBServiceState> get copyWith => __$OOBServiceStateCopyWithImpl<_OOBServiceState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OOBServiceState&&(identical(other.lastAcceptedContact, lastAcceptedContact) || other.lastAcceptedContact == lastAcceptedContact)&&(identical(other.isConnectionEstablished, isConnectionEstablished) || other.isConnectionEstablished == isConnectionEstablished)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.error, error) || other.error == error)&&(identical(other.currentOobOffer, currentOobOffer) || other.currentOobOffer == currentOobOffer)&&(identical(other.lastConnectionChannel, lastConnectionChannel) || other.lastConnectionChannel == lastConnectionChannel));
}


@override
int get hashCode => Object.hash(runtimeType,lastAcceptedContact,isConnectionEstablished,isLoading,error,currentOobOffer,lastConnectionChannel);

@override
String toString() {
  return 'OOBServiceState(lastAcceptedContact: $lastAcceptedContact, isConnectionEstablished: $isConnectionEstablished, isLoading: $isLoading, error: $error, currentOobOffer: $currentOobOffer, lastConnectionChannel: $lastConnectionChannel)';
}


}

/// @nodoc
abstract mixin class _$OOBServiceStateCopyWith<$Res> implements $OOBServiceStateCopyWith<$Res> {
  factory _$OOBServiceStateCopyWith(_OOBServiceState value, $Res Function(_OOBServiceState) _then) = __$OOBServiceStateCopyWithImpl;
@override @useResult
$Res call({
 Contact? lastAcceptedContact, bool isConnectionEstablished, bool isLoading, String? error, ConnectionOffer? currentOobOffer, Channel? lastConnectionChannel
});




}
/// @nodoc
class __$OOBServiceStateCopyWithImpl<$Res>
    implements _$OOBServiceStateCopyWith<$Res> {
  __$OOBServiceStateCopyWithImpl(this._self, this._then);

  final _OOBServiceState _self;
  final $Res Function(_OOBServiceState) _then;

/// Create a copy of OOBServiceState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? lastAcceptedContact = freezed,Object? isConnectionEstablished = null,Object? isLoading = null,Object? error = freezed,Object? currentOobOffer = freezed,Object? lastConnectionChannel = freezed,}) {
  return _then(_OOBServiceState(
lastAcceptedContact: freezed == lastAcceptedContact ? _self.lastAcceptedContact : lastAcceptedContact // ignore: cast_nullable_to_non_nullable
as Contact?,isConnectionEstablished: null == isConnectionEstablished ? _self.isConnectionEstablished : isConnectionEstablished // ignore: cast_nullable_to_non_nullable
as bool,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,currentOobOffer: freezed == currentOobOffer ? _self.currentOobOffer : currentOobOffer // ignore: cast_nullable_to_non_nullable
as ConnectionOffer?,lastConnectionChannel: freezed == lastConnectionChannel ? _self.lastConnectionChannel : lastConnectionChannel // ignore: cast_nullable_to_non_nullable
as Channel?,
  ));
}


}

// dart format on
