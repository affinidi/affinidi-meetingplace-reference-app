// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'active_call_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ActiveCallState {

 String get contactId; String get peerName; AudioVideoCallStatus get status; int get callDurationSeconds; bool get isMicEnabled; bool get isAudioOnly; bool get hasHadPeer; bool get isMinimized; bool get isCameraEnabled; AudioVideoCallParticipant? get selfParticipant;
/// Create a copy of ActiveCallState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ActiveCallStateCopyWith<ActiveCallState> get copyWith => _$ActiveCallStateCopyWithImpl<ActiveCallState>(this as ActiveCallState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ActiveCallState&&(identical(other.contactId, contactId) || other.contactId == contactId)&&(identical(other.peerName, peerName) || other.peerName == peerName)&&(identical(other.status, status) || other.status == status)&&(identical(other.callDurationSeconds, callDurationSeconds) || other.callDurationSeconds == callDurationSeconds)&&(identical(other.isMicEnabled, isMicEnabled) || other.isMicEnabled == isMicEnabled)&&(identical(other.isAudioOnly, isAudioOnly) || other.isAudioOnly == isAudioOnly)&&(identical(other.hasHadPeer, hasHadPeer) || other.hasHadPeer == hasHadPeer)&&(identical(other.isMinimized, isMinimized) || other.isMinimized == isMinimized)&&(identical(other.isCameraEnabled, isCameraEnabled) || other.isCameraEnabled == isCameraEnabled)&&(identical(other.selfParticipant, selfParticipant) || other.selfParticipant == selfParticipant));
}


@override
int get hashCode => Object.hash(runtimeType,contactId,peerName,status,callDurationSeconds,isMicEnabled,isAudioOnly,hasHadPeer,isMinimized,isCameraEnabled,selfParticipant);

@override
String toString() {
  return 'ActiveCallState(contactId: $contactId, peerName: $peerName, status: $status, callDurationSeconds: $callDurationSeconds, isMicEnabled: $isMicEnabled, isAudioOnly: $isAudioOnly, hasHadPeer: $hasHadPeer, isMinimized: $isMinimized, isCameraEnabled: $isCameraEnabled, selfParticipant: $selfParticipant)';
}


}

/// @nodoc
abstract mixin class $ActiveCallStateCopyWith<$Res>  {
  factory $ActiveCallStateCopyWith(ActiveCallState value, $Res Function(ActiveCallState) _then) = _$ActiveCallStateCopyWithImpl;
@useResult
$Res call({
 String contactId, String peerName, AudioVideoCallStatus status, int callDurationSeconds, bool isMicEnabled, bool isAudioOnly, bool hasHadPeer, bool isMinimized, bool isCameraEnabled, AudioVideoCallParticipant? selfParticipant
});




}
/// @nodoc
class _$ActiveCallStateCopyWithImpl<$Res>
    implements $ActiveCallStateCopyWith<$Res> {
  _$ActiveCallStateCopyWithImpl(this._self, this._then);

  final ActiveCallState _self;
  final $Res Function(ActiveCallState) _then;

/// Create a copy of ActiveCallState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? contactId = null,Object? peerName = null,Object? status = null,Object? callDurationSeconds = null,Object? isMicEnabled = null,Object? isAudioOnly = null,Object? hasHadPeer = null,Object? isMinimized = null,Object? isCameraEnabled = null,Object? selfParticipant = freezed,}) {
  return _then(_self.copyWith(
contactId: null == contactId ? _self.contactId : contactId // ignore: cast_nullable_to_non_nullable
as String,peerName: null == peerName ? _self.peerName : peerName // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as AudioVideoCallStatus,callDurationSeconds: null == callDurationSeconds ? _self.callDurationSeconds : callDurationSeconds // ignore: cast_nullable_to_non_nullable
as int,isMicEnabled: null == isMicEnabled ? _self.isMicEnabled : isMicEnabled // ignore: cast_nullable_to_non_nullable
as bool,isAudioOnly: null == isAudioOnly ? _self.isAudioOnly : isAudioOnly // ignore: cast_nullable_to_non_nullable
as bool,hasHadPeer: null == hasHadPeer ? _self.hasHadPeer : hasHadPeer // ignore: cast_nullable_to_non_nullable
as bool,isMinimized: null == isMinimized ? _self.isMinimized : isMinimized // ignore: cast_nullable_to_non_nullable
as bool,isCameraEnabled: null == isCameraEnabled ? _self.isCameraEnabled : isCameraEnabled // ignore: cast_nullable_to_non_nullable
as bool,selfParticipant: freezed == selfParticipant ? _self.selfParticipant : selfParticipant // ignore: cast_nullable_to_non_nullable
as AudioVideoCallParticipant?,
  ));
}

}


/// Adds pattern-matching-related methods to [ActiveCallState].
extension ActiveCallStatePatterns on ActiveCallState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ActiveCallState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ActiveCallState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ActiveCallState value)  $default,){
final _that = this;
switch (_that) {
case _ActiveCallState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ActiveCallState value)?  $default,){
final _that = this;
switch (_that) {
case _ActiveCallState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String contactId,  String peerName,  AudioVideoCallStatus status,  int callDurationSeconds,  bool isMicEnabled,  bool isAudioOnly,  bool hasHadPeer,  bool isMinimized,  bool isCameraEnabled,  AudioVideoCallParticipant? selfParticipant)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ActiveCallState() when $default != null:
return $default(_that.contactId,_that.peerName,_that.status,_that.callDurationSeconds,_that.isMicEnabled,_that.isAudioOnly,_that.hasHadPeer,_that.isMinimized,_that.isCameraEnabled,_that.selfParticipant);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String contactId,  String peerName,  AudioVideoCallStatus status,  int callDurationSeconds,  bool isMicEnabled,  bool isAudioOnly,  bool hasHadPeer,  bool isMinimized,  bool isCameraEnabled,  AudioVideoCallParticipant? selfParticipant)  $default,) {final _that = this;
switch (_that) {
case _ActiveCallState():
return $default(_that.contactId,_that.peerName,_that.status,_that.callDurationSeconds,_that.isMicEnabled,_that.isAudioOnly,_that.hasHadPeer,_that.isMinimized,_that.isCameraEnabled,_that.selfParticipant);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String contactId,  String peerName,  AudioVideoCallStatus status,  int callDurationSeconds,  bool isMicEnabled,  bool isAudioOnly,  bool hasHadPeer,  bool isMinimized,  bool isCameraEnabled,  AudioVideoCallParticipant? selfParticipant)?  $default,) {final _that = this;
switch (_that) {
case _ActiveCallState() when $default != null:
return $default(_that.contactId,_that.peerName,_that.status,_that.callDurationSeconds,_that.isMicEnabled,_that.isAudioOnly,_that.hasHadPeer,_that.isMinimized,_that.isCameraEnabled,_that.selfParticipant);case _:
  return null;

}
}

}

/// @nodoc


class _ActiveCallState implements ActiveCallState {
  const _ActiveCallState({required this.contactId, required this.peerName, required this.status, required this.callDurationSeconds, required this.isMicEnabled, required this.isAudioOnly, this.hasHadPeer = false, this.isMinimized = false, this.isCameraEnabled = true, this.selfParticipant});
  

@override final  String contactId;
@override final  String peerName;
@override final  AudioVideoCallStatus status;
@override final  int callDurationSeconds;
@override final  bool isMicEnabled;
@override final  bool isAudioOnly;
@override@JsonKey() final  bool hasHadPeer;
@override@JsonKey() final  bool isMinimized;
@override@JsonKey() final  bool isCameraEnabled;
@override final  AudioVideoCallParticipant? selfParticipant;

/// Create a copy of ActiveCallState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ActiveCallStateCopyWith<_ActiveCallState> get copyWith => __$ActiveCallStateCopyWithImpl<_ActiveCallState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ActiveCallState&&(identical(other.contactId, contactId) || other.contactId == contactId)&&(identical(other.peerName, peerName) || other.peerName == peerName)&&(identical(other.status, status) || other.status == status)&&(identical(other.callDurationSeconds, callDurationSeconds) || other.callDurationSeconds == callDurationSeconds)&&(identical(other.isMicEnabled, isMicEnabled) || other.isMicEnabled == isMicEnabled)&&(identical(other.isAudioOnly, isAudioOnly) || other.isAudioOnly == isAudioOnly)&&(identical(other.hasHadPeer, hasHadPeer) || other.hasHadPeer == hasHadPeer)&&(identical(other.isMinimized, isMinimized) || other.isMinimized == isMinimized)&&(identical(other.isCameraEnabled, isCameraEnabled) || other.isCameraEnabled == isCameraEnabled)&&(identical(other.selfParticipant, selfParticipant) || other.selfParticipant == selfParticipant));
}


@override
int get hashCode => Object.hash(runtimeType,contactId,peerName,status,callDurationSeconds,isMicEnabled,isAudioOnly,hasHadPeer,isMinimized,isCameraEnabled,selfParticipant);

@override
String toString() {
  return 'ActiveCallState(contactId: $contactId, peerName: $peerName, status: $status, callDurationSeconds: $callDurationSeconds, isMicEnabled: $isMicEnabled, isAudioOnly: $isAudioOnly, hasHadPeer: $hasHadPeer, isMinimized: $isMinimized, isCameraEnabled: $isCameraEnabled, selfParticipant: $selfParticipant)';
}


}

/// @nodoc
abstract mixin class _$ActiveCallStateCopyWith<$Res> implements $ActiveCallStateCopyWith<$Res> {
  factory _$ActiveCallStateCopyWith(_ActiveCallState value, $Res Function(_ActiveCallState) _then) = __$ActiveCallStateCopyWithImpl;
@override @useResult
$Res call({
 String contactId, String peerName, AudioVideoCallStatus status, int callDurationSeconds, bool isMicEnabled, bool isAudioOnly, bool hasHadPeer, bool isMinimized, bool isCameraEnabled, AudioVideoCallParticipant? selfParticipant
});




}
/// @nodoc
class __$ActiveCallStateCopyWithImpl<$Res>
    implements _$ActiveCallStateCopyWith<$Res> {
  __$ActiveCallStateCopyWithImpl(this._self, this._then);

  final _ActiveCallState _self;
  final $Res Function(_ActiveCallState) _then;

/// Create a copy of ActiveCallState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? contactId = null,Object? peerName = null,Object? status = null,Object? callDurationSeconds = null,Object? isMicEnabled = null,Object? isAudioOnly = null,Object? hasHadPeer = null,Object? isMinimized = null,Object? isCameraEnabled = null,Object? selfParticipant = freezed,}) {
  return _then(_ActiveCallState(
contactId: null == contactId ? _self.contactId : contactId // ignore: cast_nullable_to_non_nullable
as String,peerName: null == peerName ? _self.peerName : peerName // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as AudioVideoCallStatus,callDurationSeconds: null == callDurationSeconds ? _self.callDurationSeconds : callDurationSeconds // ignore: cast_nullable_to_non_nullable
as int,isMicEnabled: null == isMicEnabled ? _self.isMicEnabled : isMicEnabled // ignore: cast_nullable_to_non_nullable
as bool,isAudioOnly: null == isAudioOnly ? _self.isAudioOnly : isAudioOnly // ignore: cast_nullable_to_non_nullable
as bool,hasHadPeer: null == hasHadPeer ? _self.hasHadPeer : hasHadPeer // ignore: cast_nullable_to_non_nullable
as bool,isMinimized: null == isMinimized ? _self.isMinimized : isMinimized // ignore: cast_nullable_to_non_nullable
as bool,isCameraEnabled: null == isCameraEnabled ? _self.isCameraEnabled : isCameraEnabled // ignore: cast_nullable_to_non_nullable
as bool,selfParticipant: freezed == selfParticipant ? _self.selfParticipant : selfParticipant // ignore: cast_nullable_to_non_nullable
as AudioVideoCallParticipant?,
  ));
}


}

// dart format on
