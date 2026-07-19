// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'group_audio_call_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$GroupAudioCallParticipant {

 String get displayName; bool get isMuted; bool get isSelf;
/// Create a copy of GroupAudioCallParticipant
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GroupAudioCallParticipantCopyWith<GroupAudioCallParticipant> get copyWith => _$GroupAudioCallParticipantCopyWithImpl<GroupAudioCallParticipant>(this as GroupAudioCallParticipant, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GroupAudioCallParticipant&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.isMuted, isMuted) || other.isMuted == isMuted)&&(identical(other.isSelf, isSelf) || other.isSelf == isSelf));
}


@override
int get hashCode => Object.hash(runtimeType,displayName,isMuted,isSelf);

@override
String toString() {
  return 'GroupAudioCallParticipant(displayName: $displayName, isMuted: $isMuted, isSelf: $isSelf)';
}


}

/// @nodoc
abstract mixin class $GroupAudioCallParticipantCopyWith<$Res>  {
  factory $GroupAudioCallParticipantCopyWith(GroupAudioCallParticipant value, $Res Function(GroupAudioCallParticipant) _then) = _$GroupAudioCallParticipantCopyWithImpl;
@useResult
$Res call({
 String displayName, bool isMuted, bool isSelf
});




}
/// @nodoc
class _$GroupAudioCallParticipantCopyWithImpl<$Res>
    implements $GroupAudioCallParticipantCopyWith<$Res> {
  _$GroupAudioCallParticipantCopyWithImpl(this._self, this._then);

  final GroupAudioCallParticipant _self;
  final $Res Function(GroupAudioCallParticipant) _then;

/// Create a copy of GroupAudioCallParticipant
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? displayName = null,Object? isMuted = null,Object? isSelf = null,}) {
  return _then(_self.copyWith(
displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,isMuted: null == isMuted ? _self.isMuted : isMuted // ignore: cast_nullable_to_non_nullable
as bool,isSelf: null == isSelf ? _self.isSelf : isSelf // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [GroupAudioCallParticipant].
extension GroupAudioCallParticipantPatterns on GroupAudioCallParticipant {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GroupAudioCallParticipant value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GroupAudioCallParticipant() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GroupAudioCallParticipant value)  $default,){
final _that = this;
switch (_that) {
case _GroupAudioCallParticipant():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GroupAudioCallParticipant value)?  $default,){
final _that = this;
switch (_that) {
case _GroupAudioCallParticipant() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String displayName,  bool isMuted,  bool isSelf)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GroupAudioCallParticipant() when $default != null:
return $default(_that.displayName,_that.isMuted,_that.isSelf);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String displayName,  bool isMuted,  bool isSelf)  $default,) {final _that = this;
switch (_that) {
case _GroupAudioCallParticipant():
return $default(_that.displayName,_that.isMuted,_that.isSelf);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String displayName,  bool isMuted,  bool isSelf)?  $default,) {final _that = this;
switch (_that) {
case _GroupAudioCallParticipant() when $default != null:
return $default(_that.displayName,_that.isMuted,_that.isSelf);case _:
  return null;

}
}

}

/// @nodoc


class _GroupAudioCallParticipant extends GroupAudioCallParticipant {
  const _GroupAudioCallParticipant({required this.displayName, required this.isMuted, required this.isSelf}): super._();
  

@override final  String displayName;
@override final  bool isMuted;
@override final  bool isSelf;

/// Create a copy of GroupAudioCallParticipant
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GroupAudioCallParticipantCopyWith<_GroupAudioCallParticipant> get copyWith => __$GroupAudioCallParticipantCopyWithImpl<_GroupAudioCallParticipant>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GroupAudioCallParticipant&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.isMuted, isMuted) || other.isMuted == isMuted)&&(identical(other.isSelf, isSelf) || other.isSelf == isSelf));
}


@override
int get hashCode => Object.hash(runtimeType,displayName,isMuted,isSelf);

@override
String toString() {
  return 'GroupAudioCallParticipant(displayName: $displayName, isMuted: $isMuted, isSelf: $isSelf)';
}


}

/// @nodoc
abstract mixin class _$GroupAudioCallParticipantCopyWith<$Res> implements $GroupAudioCallParticipantCopyWith<$Res> {
  factory _$GroupAudioCallParticipantCopyWith(_GroupAudioCallParticipant value, $Res Function(_GroupAudioCallParticipant) _then) = __$GroupAudioCallParticipantCopyWithImpl;
@override @useResult
$Res call({
 String displayName, bool isMuted, bool isSelf
});




}
/// @nodoc
class __$GroupAudioCallParticipantCopyWithImpl<$Res>
    implements _$GroupAudioCallParticipantCopyWith<$Res> {
  __$GroupAudioCallParticipantCopyWithImpl(this._self, this._then);

  final _GroupAudioCallParticipant _self;
  final $Res Function(_GroupAudioCallParticipant) _then;

/// Create a copy of GroupAudioCallParticipant
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? displayName = null,Object? isMuted = null,Object? isSelf = null,}) {
  return _then(_GroupAudioCallParticipant(
displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,isMuted: null == isMuted ? _self.isMuted : isMuted // ignore: cast_nullable_to_non_nullable
as bool,isSelf: null == isSelf ? _self.isSelf : isSelf // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc
mixin _$GroupAudioCallState {

/// Participants currently in the call (self + remotes).
 List<GroupAudioCallParticipant> get participants;/// Whether the call is in ringing state (waiting for first join).
 bool get isRinging;/// Time when the first peer joined (null if none yet).
 DateTime? get firstJoinedAt;/// Error message if something went wrong (null if no error).
 String? get errorMessage;/// Whether controls (mute button) should be visible.
 bool get showControls;
/// Create a copy of GroupAudioCallState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GroupAudioCallStateCopyWith<GroupAudioCallState> get copyWith => _$GroupAudioCallStateCopyWithImpl<GroupAudioCallState>(this as GroupAudioCallState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GroupAudioCallState&&const DeepCollectionEquality().equals(other.participants, participants)&&(identical(other.isRinging, isRinging) || other.isRinging == isRinging)&&(identical(other.firstJoinedAt, firstJoinedAt) || other.firstJoinedAt == firstJoinedAt)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&(identical(other.showControls, showControls) || other.showControls == showControls));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(participants),isRinging,firstJoinedAt,errorMessage,showControls);

@override
String toString() {
  return 'GroupAudioCallState(participants: $participants, isRinging: $isRinging, firstJoinedAt: $firstJoinedAt, errorMessage: $errorMessage, showControls: $showControls)';
}


}

/// @nodoc
abstract mixin class $GroupAudioCallStateCopyWith<$Res>  {
  factory $GroupAudioCallStateCopyWith(GroupAudioCallState value, $Res Function(GroupAudioCallState) _then) = _$GroupAudioCallStateCopyWithImpl;
@useResult
$Res call({
 List<GroupAudioCallParticipant> participants, bool isRinging, DateTime? firstJoinedAt, String? errorMessage, bool showControls
});




}
/// @nodoc
class _$GroupAudioCallStateCopyWithImpl<$Res>
    implements $GroupAudioCallStateCopyWith<$Res> {
  _$GroupAudioCallStateCopyWithImpl(this._self, this._then);

  final GroupAudioCallState _self;
  final $Res Function(GroupAudioCallState) _then;

/// Create a copy of GroupAudioCallState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? participants = null,Object? isRinging = null,Object? firstJoinedAt = freezed,Object? errorMessage = freezed,Object? showControls = null,}) {
  return _then(_self.copyWith(
participants: null == participants ? _self.participants : participants // ignore: cast_nullable_to_non_nullable
as List<GroupAudioCallParticipant>,isRinging: null == isRinging ? _self.isRinging : isRinging // ignore: cast_nullable_to_non_nullable
as bool,firstJoinedAt: freezed == firstJoinedAt ? _self.firstJoinedAt : firstJoinedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,showControls: null == showControls ? _self.showControls : showControls // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [GroupAudioCallState].
extension GroupAudioCallStatePatterns on GroupAudioCallState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GroupAudioCallState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GroupAudioCallState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GroupAudioCallState value)  $default,){
final _that = this;
switch (_that) {
case _GroupAudioCallState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GroupAudioCallState value)?  $default,){
final _that = this;
switch (_that) {
case _GroupAudioCallState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<GroupAudioCallParticipant> participants,  bool isRinging,  DateTime? firstJoinedAt,  String? errorMessage,  bool showControls)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GroupAudioCallState() when $default != null:
return $default(_that.participants,_that.isRinging,_that.firstJoinedAt,_that.errorMessage,_that.showControls);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<GroupAudioCallParticipant> participants,  bool isRinging,  DateTime? firstJoinedAt,  String? errorMessage,  bool showControls)  $default,) {final _that = this;
switch (_that) {
case _GroupAudioCallState():
return $default(_that.participants,_that.isRinging,_that.firstJoinedAt,_that.errorMessage,_that.showControls);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<GroupAudioCallParticipant> participants,  bool isRinging,  DateTime? firstJoinedAt,  String? errorMessage,  bool showControls)?  $default,) {final _that = this;
switch (_that) {
case _GroupAudioCallState() when $default != null:
return $default(_that.participants,_that.isRinging,_that.firstJoinedAt,_that.errorMessage,_that.showControls);case _:
  return null;

}
}

}

/// @nodoc


class _GroupAudioCallState extends GroupAudioCallState {
  const _GroupAudioCallState({required final  List<GroupAudioCallParticipant> participants, required this.isRinging, this.firstJoinedAt, this.errorMessage, required this.showControls}): _participants = participants,super._();
  

/// Participants currently in the call (self + remotes).
 final  List<GroupAudioCallParticipant> _participants;
/// Participants currently in the call (self + remotes).
@override List<GroupAudioCallParticipant> get participants {
  if (_participants is EqualUnmodifiableListView) return _participants;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_participants);
}

/// Whether the call is in ringing state (waiting for first join).
@override final  bool isRinging;
/// Time when the first peer joined (null if none yet).
@override final  DateTime? firstJoinedAt;
/// Error message if something went wrong (null if no error).
@override final  String? errorMessage;
/// Whether controls (mute button) should be visible.
@override final  bool showControls;

/// Create a copy of GroupAudioCallState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GroupAudioCallStateCopyWith<_GroupAudioCallState> get copyWith => __$GroupAudioCallStateCopyWithImpl<_GroupAudioCallState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GroupAudioCallState&&const DeepCollectionEquality().equals(other._participants, _participants)&&(identical(other.isRinging, isRinging) || other.isRinging == isRinging)&&(identical(other.firstJoinedAt, firstJoinedAt) || other.firstJoinedAt == firstJoinedAt)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&(identical(other.showControls, showControls) || other.showControls == showControls));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_participants),isRinging,firstJoinedAt,errorMessage,showControls);

@override
String toString() {
  return 'GroupAudioCallState(participants: $participants, isRinging: $isRinging, firstJoinedAt: $firstJoinedAt, errorMessage: $errorMessage, showControls: $showControls)';
}


}

/// @nodoc
abstract mixin class _$GroupAudioCallStateCopyWith<$Res> implements $GroupAudioCallStateCopyWith<$Res> {
  factory _$GroupAudioCallStateCopyWith(_GroupAudioCallState value, $Res Function(_GroupAudioCallState) _then) = __$GroupAudioCallStateCopyWithImpl;
@override @useResult
$Res call({
 List<GroupAudioCallParticipant> participants, bool isRinging, DateTime? firstJoinedAt, String? errorMessage, bool showControls
});




}
/// @nodoc
class __$GroupAudioCallStateCopyWithImpl<$Res>
    implements _$GroupAudioCallStateCopyWith<$Res> {
  __$GroupAudioCallStateCopyWithImpl(this._self, this._then);

  final _GroupAudioCallState _self;
  final $Res Function(_GroupAudioCallState) _then;

/// Create a copy of GroupAudioCallState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? participants = null,Object? isRinging = null,Object? firstJoinedAt = freezed,Object? errorMessage = freezed,Object? showControls = null,}) {
  return _then(_GroupAudioCallState(
participants: null == participants ? _self._participants : participants // ignore: cast_nullable_to_non_nullable
as List<GroupAudioCallParticipant>,isRinging: null == isRinging ? _self.isRinging : isRinging // ignore: cast_nullable_to_non_nullable
as bool,firstJoinedAt: freezed == firstJoinedAt ? _self.firstJoinedAt : firstJoinedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,showControls: null == showControls ? _self.showControls : showControls // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
