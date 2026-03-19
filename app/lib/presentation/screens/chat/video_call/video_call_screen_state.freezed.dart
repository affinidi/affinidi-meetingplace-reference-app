// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'video_call_screen_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$VideoCallScreenState {

 VideoCallStatus get status; List<Participant> get participants; bool get isMicEnabled; bool get isCameraEnabled; Object? get error; String? get matrixEventMessage;
/// Create a copy of VideoCallScreenState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VideoCallScreenStateCopyWith<VideoCallScreenState> get copyWith => _$VideoCallScreenStateCopyWithImpl<VideoCallScreenState>(this as VideoCallScreenState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VideoCallScreenState&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other.participants, participants)&&(identical(other.isMicEnabled, isMicEnabled) || other.isMicEnabled == isMicEnabled)&&(identical(other.isCameraEnabled, isCameraEnabled) || other.isCameraEnabled == isCameraEnabled)&&const DeepCollectionEquality().equals(other.error, error)&&(identical(other.matrixEventMessage, matrixEventMessage) || other.matrixEventMessage == matrixEventMessage));
}


@override
int get hashCode => Object.hash(runtimeType,status,const DeepCollectionEquality().hash(participants),isMicEnabled,isCameraEnabled,const DeepCollectionEquality().hash(error),matrixEventMessage);

@override
String toString() {
  return 'VideoCallScreenState(status: $status, participants: $participants, isMicEnabled: $isMicEnabled, isCameraEnabled: $isCameraEnabled, error: $error, matrixEventMessage: $matrixEventMessage)';
}


}

/// @nodoc
abstract mixin class $VideoCallScreenStateCopyWith<$Res>  {
  factory $VideoCallScreenStateCopyWith(VideoCallScreenState value, $Res Function(VideoCallScreenState) _then) = _$VideoCallScreenStateCopyWithImpl;
@useResult
$Res call({
 VideoCallStatus status, List<Participant> participants, bool isMicEnabled, bool isCameraEnabled, Object? error, String? matrixEventMessage
});




}
/// @nodoc
class _$VideoCallScreenStateCopyWithImpl<$Res>
    implements $VideoCallScreenStateCopyWith<$Res> {
  _$VideoCallScreenStateCopyWithImpl(this._self, this._then);

  final VideoCallScreenState _self;
  final $Res Function(VideoCallScreenState) _then;

/// Create a copy of VideoCallScreenState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? status = null,Object? participants = null,Object? isMicEnabled = null,Object? isCameraEnabled = null,Object? error = freezed,Object? matrixEventMessage = freezed,}) {
  return _then(_self.copyWith(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as VideoCallStatus,participants: null == participants ? _self.participants : participants // ignore: cast_nullable_to_non_nullable
as List<Participant>,isMicEnabled: null == isMicEnabled ? _self.isMicEnabled : isMicEnabled // ignore: cast_nullable_to_non_nullable
as bool,isCameraEnabled: null == isCameraEnabled ? _self.isCameraEnabled : isCameraEnabled // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error ,matrixEventMessage: freezed == matrixEventMessage ? _self.matrixEventMessage : matrixEventMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [VideoCallScreenState].
extension VideoCallScreenStatePatterns on VideoCallScreenState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VideoCallScreenState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VideoCallScreenState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VideoCallScreenState value)  $default,){
final _that = this;
switch (_that) {
case _VideoCallScreenState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VideoCallScreenState value)?  $default,){
final _that = this;
switch (_that) {
case _VideoCallScreenState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( VideoCallStatus status,  List<Participant> participants,  bool isMicEnabled,  bool isCameraEnabled,  Object? error,  String? matrixEventMessage)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VideoCallScreenState() when $default != null:
return $default(_that.status,_that.participants,_that.isMicEnabled,_that.isCameraEnabled,_that.error,_that.matrixEventMessage);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( VideoCallStatus status,  List<Participant> participants,  bool isMicEnabled,  bool isCameraEnabled,  Object? error,  String? matrixEventMessage)  $default,) {final _that = this;
switch (_that) {
case _VideoCallScreenState():
return $default(_that.status,_that.participants,_that.isMicEnabled,_that.isCameraEnabled,_that.error,_that.matrixEventMessage);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( VideoCallStatus status,  List<Participant> participants,  bool isMicEnabled,  bool isCameraEnabled,  Object? error,  String? matrixEventMessage)?  $default,) {final _that = this;
switch (_that) {
case _VideoCallScreenState() when $default != null:
return $default(_that.status,_that.participants,_that.isMicEnabled,_that.isCameraEnabled,_that.error,_that.matrixEventMessage);case _:
  return null;

}
}

}

/// @nodoc


class _VideoCallScreenState extends VideoCallScreenState {
  const _VideoCallScreenState({this.status = VideoCallStatus.idle, final  List<Participant> participants = const [], this.isMicEnabled = false, this.isCameraEnabled = false, this.error, this.matrixEventMessage}): _participants = participants,super._();
  

@override@JsonKey() final  VideoCallStatus status;
 final  List<Participant> _participants;
@override@JsonKey() List<Participant> get participants {
  if (_participants is EqualUnmodifiableListView) return _participants;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_participants);
}

@override@JsonKey() final  bool isMicEnabled;
@override@JsonKey() final  bool isCameraEnabled;
@override final  Object? error;
@override final  String? matrixEventMessage;

/// Create a copy of VideoCallScreenState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VideoCallScreenStateCopyWith<_VideoCallScreenState> get copyWith => __$VideoCallScreenStateCopyWithImpl<_VideoCallScreenState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _VideoCallScreenState&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other._participants, _participants)&&(identical(other.isMicEnabled, isMicEnabled) || other.isMicEnabled == isMicEnabled)&&(identical(other.isCameraEnabled, isCameraEnabled) || other.isCameraEnabled == isCameraEnabled)&&const DeepCollectionEquality().equals(other.error, error)&&(identical(other.matrixEventMessage, matrixEventMessage) || other.matrixEventMessage == matrixEventMessage));
}


@override
int get hashCode => Object.hash(runtimeType,status,const DeepCollectionEquality().hash(_participants),isMicEnabled,isCameraEnabled,const DeepCollectionEquality().hash(error),matrixEventMessage);

@override
String toString() {
  return 'VideoCallScreenState(status: $status, participants: $participants, isMicEnabled: $isMicEnabled, isCameraEnabled: $isCameraEnabled, error: $error, matrixEventMessage: $matrixEventMessage)';
}


}

/// @nodoc
abstract mixin class _$VideoCallScreenStateCopyWith<$Res> implements $VideoCallScreenStateCopyWith<$Res> {
  factory _$VideoCallScreenStateCopyWith(_VideoCallScreenState value, $Res Function(_VideoCallScreenState) _then) = __$VideoCallScreenStateCopyWithImpl;
@override @useResult
$Res call({
 VideoCallStatus status, List<Participant> participants, bool isMicEnabled, bool isCameraEnabled, Object? error, String? matrixEventMessage
});




}
/// @nodoc
class __$VideoCallScreenStateCopyWithImpl<$Res>
    implements _$VideoCallScreenStateCopyWith<$Res> {
  __$VideoCallScreenStateCopyWithImpl(this._self, this._then);

  final _VideoCallScreenState _self;
  final $Res Function(_VideoCallScreenState) _then;

/// Create a copy of VideoCallScreenState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? status = null,Object? participants = null,Object? isMicEnabled = null,Object? isCameraEnabled = null,Object? error = freezed,Object? matrixEventMessage = freezed,}) {
  return _then(_VideoCallScreenState(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as VideoCallStatus,participants: null == participants ? _self._participants : participants // ignore: cast_nullable_to_non_nullable
as List<Participant>,isMicEnabled: null == isMicEnabled ? _self.isMicEnabled : isMicEnabled // ignore: cast_nullable_to_non_nullable
as bool,isCameraEnabled: null == isCameraEnabled ? _self.isCameraEnabled : isCameraEnabled // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error ,matrixEventMessage: freezed == matrixEventMessage ? _self.matrixEventMessage : matrixEventMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
