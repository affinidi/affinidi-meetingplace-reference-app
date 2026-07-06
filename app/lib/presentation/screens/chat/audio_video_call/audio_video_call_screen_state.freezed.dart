// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'audio_video_call_screen_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AudioVideoCallScreenState {

 AudioVideoCallStatus get status; bool get isGroupContact; String get peerName; Map<String, ContactCard> get memberContactCards; bool get isAudioOnly; bool get isMicEnabled; bool get isCameraEnabled; bool get isSpeakerEnabled; List<AudioVideoCallParticipant> get participants; int get callDurationSeconds; bool get hasHadPeer; AudioVideoCallSession? get session; AudioVideoCallErrorCode? get errorCode; bool get micPermissionError; bool get cameraPermissionError; CallParticipantChangeEvent? get participantEvent; CallActionFailureEvent? get actionFailure; bool get showControlsBar; int? get focusedParticipantIndex; bool get miniGridExpanded; bool get peerIsCallingBack;
/// Create a copy of AudioVideoCallScreenState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AudioVideoCallScreenStateCopyWith<AudioVideoCallScreenState> get copyWith => _$AudioVideoCallScreenStateCopyWithImpl<AudioVideoCallScreenState>(this as AudioVideoCallScreenState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AudioVideoCallScreenState&&(identical(other.status, status) || other.status == status)&&(identical(other.isGroupContact, isGroupContact) || other.isGroupContact == isGroupContact)&&(identical(other.peerName, peerName) || other.peerName == peerName)&&const DeepCollectionEquality().equals(other.memberContactCards, memberContactCards)&&(identical(other.isAudioOnly, isAudioOnly) || other.isAudioOnly == isAudioOnly)&&(identical(other.isMicEnabled, isMicEnabled) || other.isMicEnabled == isMicEnabled)&&(identical(other.isCameraEnabled, isCameraEnabled) || other.isCameraEnabled == isCameraEnabled)&&(identical(other.isSpeakerEnabled, isSpeakerEnabled) || other.isSpeakerEnabled == isSpeakerEnabled)&&const DeepCollectionEquality().equals(other.participants, participants)&&(identical(other.callDurationSeconds, callDurationSeconds) || other.callDurationSeconds == callDurationSeconds)&&(identical(other.hasHadPeer, hasHadPeer) || other.hasHadPeer == hasHadPeer)&&(identical(other.session, session) || other.session == session)&&(identical(other.errorCode, errorCode) || other.errorCode == errorCode)&&(identical(other.micPermissionError, micPermissionError) || other.micPermissionError == micPermissionError)&&(identical(other.cameraPermissionError, cameraPermissionError) || other.cameraPermissionError == cameraPermissionError)&&(identical(other.participantEvent, participantEvent) || other.participantEvent == participantEvent)&&(identical(other.actionFailure, actionFailure) || other.actionFailure == actionFailure)&&(identical(other.showControlsBar, showControlsBar) || other.showControlsBar == showControlsBar)&&(identical(other.focusedParticipantIndex, focusedParticipantIndex) || other.focusedParticipantIndex == focusedParticipantIndex)&&(identical(other.miniGridExpanded, miniGridExpanded) || other.miniGridExpanded == miniGridExpanded)&&(identical(other.peerIsCallingBack, peerIsCallingBack) || other.peerIsCallingBack == peerIsCallingBack));
}


@override
int get hashCode => Object.hashAll([runtimeType,status,isGroupContact,peerName,const DeepCollectionEquality().hash(memberContactCards),isAudioOnly,isMicEnabled,isCameraEnabled,isSpeakerEnabled,const DeepCollectionEquality().hash(participants),callDurationSeconds,hasHadPeer,session,errorCode,micPermissionError,cameraPermissionError,participantEvent,actionFailure,showControlsBar,focusedParticipantIndex,miniGridExpanded,peerIsCallingBack]);

@override
String toString() {
  return 'AudioVideoCallScreenState(status: $status, isGroupContact: $isGroupContact, peerName: $peerName, memberContactCards: $memberContactCards, isAudioOnly: $isAudioOnly, isMicEnabled: $isMicEnabled, isCameraEnabled: $isCameraEnabled, isSpeakerEnabled: $isSpeakerEnabled, participants: $participants, callDurationSeconds: $callDurationSeconds, hasHadPeer: $hasHadPeer, session: $session, errorCode: $errorCode, micPermissionError: $micPermissionError, cameraPermissionError: $cameraPermissionError, participantEvent: $participantEvent, actionFailure: $actionFailure, showControlsBar: $showControlsBar, focusedParticipantIndex: $focusedParticipantIndex, miniGridExpanded: $miniGridExpanded, peerIsCallingBack: $peerIsCallingBack)';
}


}

/// @nodoc
abstract mixin class $AudioVideoCallScreenStateCopyWith<$Res>  {
  factory $AudioVideoCallScreenStateCopyWith(AudioVideoCallScreenState value, $Res Function(AudioVideoCallScreenState) _then) = _$AudioVideoCallScreenStateCopyWithImpl;
@useResult
$Res call({
 AudioVideoCallStatus status, bool isGroupContact, String peerName, Map<String, ContactCard> memberContactCards, bool isAudioOnly, bool isMicEnabled, bool isCameraEnabled, bool isSpeakerEnabled, List<AudioVideoCallParticipant> participants, int callDurationSeconds, bool hasHadPeer, AudioVideoCallSession? session, AudioVideoCallErrorCode? errorCode, bool micPermissionError, bool cameraPermissionError, CallParticipantChangeEvent? participantEvent, CallActionFailureEvent? actionFailure, bool showControlsBar, int? focusedParticipantIndex, bool miniGridExpanded, bool peerIsCallingBack
});




}
/// @nodoc
class _$AudioVideoCallScreenStateCopyWithImpl<$Res>
    implements $AudioVideoCallScreenStateCopyWith<$Res> {
  _$AudioVideoCallScreenStateCopyWithImpl(this._self, this._then);

  final AudioVideoCallScreenState _self;
  final $Res Function(AudioVideoCallScreenState) _then;

/// Create a copy of AudioVideoCallScreenState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? status = null,Object? isGroupContact = null,Object? peerName = null,Object? memberContactCards = null,Object? isAudioOnly = null,Object? isMicEnabled = null,Object? isCameraEnabled = null,Object? isSpeakerEnabled = null,Object? participants = null,Object? callDurationSeconds = null,Object? hasHadPeer = null,Object? session = freezed,Object? errorCode = freezed,Object? micPermissionError = null,Object? cameraPermissionError = null,Object? participantEvent = freezed,Object? actionFailure = freezed,Object? showControlsBar = null,Object? focusedParticipantIndex = freezed,Object? miniGridExpanded = null,Object? peerIsCallingBack = null,}) {
  return _then(_self.copyWith(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as AudioVideoCallStatus,isGroupContact: null == isGroupContact ? _self.isGroupContact : isGroupContact // ignore: cast_nullable_to_non_nullable
as bool,peerName: null == peerName ? _self.peerName : peerName // ignore: cast_nullable_to_non_nullable
as String,memberContactCards: null == memberContactCards ? _self.memberContactCards : memberContactCards // ignore: cast_nullable_to_non_nullable
as Map<String, ContactCard>,isAudioOnly: null == isAudioOnly ? _self.isAudioOnly : isAudioOnly // ignore: cast_nullable_to_non_nullable
as bool,isMicEnabled: null == isMicEnabled ? _self.isMicEnabled : isMicEnabled // ignore: cast_nullable_to_non_nullable
as bool,isCameraEnabled: null == isCameraEnabled ? _self.isCameraEnabled : isCameraEnabled // ignore: cast_nullable_to_non_nullable
as bool,isSpeakerEnabled: null == isSpeakerEnabled ? _self.isSpeakerEnabled : isSpeakerEnabled // ignore: cast_nullable_to_non_nullable
as bool,participants: null == participants ? _self.participants : participants // ignore: cast_nullable_to_non_nullable
as List<AudioVideoCallParticipant>,callDurationSeconds: null == callDurationSeconds ? _self.callDurationSeconds : callDurationSeconds // ignore: cast_nullable_to_non_nullable
as int,hasHadPeer: null == hasHadPeer ? _self.hasHadPeer : hasHadPeer // ignore: cast_nullable_to_non_nullable
as bool,session: freezed == session ? _self.session : session // ignore: cast_nullable_to_non_nullable
as AudioVideoCallSession?,errorCode: freezed == errorCode ? _self.errorCode : errorCode // ignore: cast_nullable_to_non_nullable
as AudioVideoCallErrorCode?,micPermissionError: null == micPermissionError ? _self.micPermissionError : micPermissionError // ignore: cast_nullable_to_non_nullable
as bool,cameraPermissionError: null == cameraPermissionError ? _self.cameraPermissionError : cameraPermissionError // ignore: cast_nullable_to_non_nullable
as bool,participantEvent: freezed == participantEvent ? _self.participantEvent : participantEvent // ignore: cast_nullable_to_non_nullable
as CallParticipantChangeEvent?,actionFailure: freezed == actionFailure ? _self.actionFailure : actionFailure // ignore: cast_nullable_to_non_nullable
as CallActionFailureEvent?,showControlsBar: null == showControlsBar ? _self.showControlsBar : showControlsBar // ignore: cast_nullable_to_non_nullable
as bool,focusedParticipantIndex: freezed == focusedParticipantIndex ? _self.focusedParticipantIndex : focusedParticipantIndex // ignore: cast_nullable_to_non_nullable
as int?,miniGridExpanded: null == miniGridExpanded ? _self.miniGridExpanded : miniGridExpanded // ignore: cast_nullable_to_non_nullable
as bool,peerIsCallingBack: null == peerIsCallingBack ? _self.peerIsCallingBack : peerIsCallingBack // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [AudioVideoCallScreenState].
extension AudioVideoCallScreenStatePatterns on AudioVideoCallScreenState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AudioVideoCallScreenState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AudioVideoCallScreenState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AudioVideoCallScreenState value)  $default,){
final _that = this;
switch (_that) {
case _AudioVideoCallScreenState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AudioVideoCallScreenState value)?  $default,){
final _that = this;
switch (_that) {
case _AudioVideoCallScreenState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( AudioVideoCallStatus status,  bool isGroupContact,  String peerName,  Map<String, ContactCard> memberContactCards,  bool isAudioOnly,  bool isMicEnabled,  bool isCameraEnabled,  bool isSpeakerEnabled,  List<AudioVideoCallParticipant> participants,  int callDurationSeconds,  bool hasHadPeer,  AudioVideoCallSession? session,  AudioVideoCallErrorCode? errorCode,  bool micPermissionError,  bool cameraPermissionError,  CallParticipantChangeEvent? participantEvent,  CallActionFailureEvent? actionFailure,  bool showControlsBar,  int? focusedParticipantIndex,  bool miniGridExpanded,  bool peerIsCallingBack)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AudioVideoCallScreenState() when $default != null:
return $default(_that.status,_that.isGroupContact,_that.peerName,_that.memberContactCards,_that.isAudioOnly,_that.isMicEnabled,_that.isCameraEnabled,_that.isSpeakerEnabled,_that.participants,_that.callDurationSeconds,_that.hasHadPeer,_that.session,_that.errorCode,_that.micPermissionError,_that.cameraPermissionError,_that.participantEvent,_that.actionFailure,_that.showControlsBar,_that.focusedParticipantIndex,_that.miniGridExpanded,_that.peerIsCallingBack);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( AudioVideoCallStatus status,  bool isGroupContact,  String peerName,  Map<String, ContactCard> memberContactCards,  bool isAudioOnly,  bool isMicEnabled,  bool isCameraEnabled,  bool isSpeakerEnabled,  List<AudioVideoCallParticipant> participants,  int callDurationSeconds,  bool hasHadPeer,  AudioVideoCallSession? session,  AudioVideoCallErrorCode? errorCode,  bool micPermissionError,  bool cameraPermissionError,  CallParticipantChangeEvent? participantEvent,  CallActionFailureEvent? actionFailure,  bool showControlsBar,  int? focusedParticipantIndex,  bool miniGridExpanded,  bool peerIsCallingBack)  $default,) {final _that = this;
switch (_that) {
case _AudioVideoCallScreenState():
return $default(_that.status,_that.isGroupContact,_that.peerName,_that.memberContactCards,_that.isAudioOnly,_that.isMicEnabled,_that.isCameraEnabled,_that.isSpeakerEnabled,_that.participants,_that.callDurationSeconds,_that.hasHadPeer,_that.session,_that.errorCode,_that.micPermissionError,_that.cameraPermissionError,_that.participantEvent,_that.actionFailure,_that.showControlsBar,_that.focusedParticipantIndex,_that.miniGridExpanded,_that.peerIsCallingBack);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( AudioVideoCallStatus status,  bool isGroupContact,  String peerName,  Map<String, ContactCard> memberContactCards,  bool isAudioOnly,  bool isMicEnabled,  bool isCameraEnabled,  bool isSpeakerEnabled,  List<AudioVideoCallParticipant> participants,  int callDurationSeconds,  bool hasHadPeer,  AudioVideoCallSession? session,  AudioVideoCallErrorCode? errorCode,  bool micPermissionError,  bool cameraPermissionError,  CallParticipantChangeEvent? participantEvent,  CallActionFailureEvent? actionFailure,  bool showControlsBar,  int? focusedParticipantIndex,  bool miniGridExpanded,  bool peerIsCallingBack)?  $default,) {final _that = this;
switch (_that) {
case _AudioVideoCallScreenState() when $default != null:
return $default(_that.status,_that.isGroupContact,_that.peerName,_that.memberContactCards,_that.isAudioOnly,_that.isMicEnabled,_that.isCameraEnabled,_that.isSpeakerEnabled,_that.participants,_that.callDurationSeconds,_that.hasHadPeer,_that.session,_that.errorCode,_that.micPermissionError,_that.cameraPermissionError,_that.participantEvent,_that.actionFailure,_that.showControlsBar,_that.focusedParticipantIndex,_that.miniGridExpanded,_that.peerIsCallingBack);case _:
  return null;

}
}

}

/// @nodoc


class _AudioVideoCallScreenState extends AudioVideoCallScreenState {
   _AudioVideoCallScreenState({this.status = AudioVideoCallStatus.idle, this.isGroupContact = false, this.peerName = '', final  Map<String, ContactCard> memberContactCards = const {}, this.isAudioOnly = false, this.isMicEnabled = true, this.isCameraEnabled = true, this.isSpeakerEnabled = false, final  List<AudioVideoCallParticipant> participants = const [], this.callDurationSeconds = 0, this.hasHadPeer = false, this.session, this.errorCode, this.micPermissionError = false, this.cameraPermissionError = false, this.participantEvent, this.actionFailure, this.showControlsBar = true, this.focusedParticipantIndex, this.miniGridExpanded = false, this.peerIsCallingBack = false}): _memberContactCards = memberContactCards,_participants = participants,super._();
  

@override@JsonKey() final  AudioVideoCallStatus status;
@override@JsonKey() final  bool isGroupContact;
@override@JsonKey() final  String peerName;
 final  Map<String, ContactCard> _memberContactCards;
@override@JsonKey() Map<String, ContactCard> get memberContactCards {
  if (_memberContactCards is EqualUnmodifiableMapView) return _memberContactCards;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_memberContactCards);
}

@override@JsonKey() final  bool isAudioOnly;
@override@JsonKey() final  bool isMicEnabled;
@override@JsonKey() final  bool isCameraEnabled;
@override@JsonKey() final  bool isSpeakerEnabled;
 final  List<AudioVideoCallParticipant> _participants;
@override@JsonKey() List<AudioVideoCallParticipant> get participants {
  if (_participants is EqualUnmodifiableListView) return _participants;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_participants);
}

@override@JsonKey() final  int callDurationSeconds;
@override@JsonKey() final  bool hasHadPeer;
@override final  AudioVideoCallSession? session;
@override final  AudioVideoCallErrorCode? errorCode;
@override@JsonKey() final  bool micPermissionError;
@override@JsonKey() final  bool cameraPermissionError;
@override final  CallParticipantChangeEvent? participantEvent;
@override final  CallActionFailureEvent? actionFailure;
@override@JsonKey() final  bool showControlsBar;
@override final  int? focusedParticipantIndex;
@override@JsonKey() final  bool miniGridExpanded;
@override@JsonKey() final  bool peerIsCallingBack;

/// Create a copy of AudioVideoCallScreenState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AudioVideoCallScreenStateCopyWith<_AudioVideoCallScreenState> get copyWith => __$AudioVideoCallScreenStateCopyWithImpl<_AudioVideoCallScreenState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AudioVideoCallScreenState&&(identical(other.status, status) || other.status == status)&&(identical(other.isGroupContact, isGroupContact) || other.isGroupContact == isGroupContact)&&(identical(other.peerName, peerName) || other.peerName == peerName)&&const DeepCollectionEquality().equals(other._memberContactCards, _memberContactCards)&&(identical(other.isAudioOnly, isAudioOnly) || other.isAudioOnly == isAudioOnly)&&(identical(other.isMicEnabled, isMicEnabled) || other.isMicEnabled == isMicEnabled)&&(identical(other.isCameraEnabled, isCameraEnabled) || other.isCameraEnabled == isCameraEnabled)&&(identical(other.isSpeakerEnabled, isSpeakerEnabled) || other.isSpeakerEnabled == isSpeakerEnabled)&&const DeepCollectionEquality().equals(other._participants, _participants)&&(identical(other.callDurationSeconds, callDurationSeconds) || other.callDurationSeconds == callDurationSeconds)&&(identical(other.hasHadPeer, hasHadPeer) || other.hasHadPeer == hasHadPeer)&&(identical(other.session, session) || other.session == session)&&(identical(other.errorCode, errorCode) || other.errorCode == errorCode)&&(identical(other.micPermissionError, micPermissionError) || other.micPermissionError == micPermissionError)&&(identical(other.cameraPermissionError, cameraPermissionError) || other.cameraPermissionError == cameraPermissionError)&&(identical(other.participantEvent, participantEvent) || other.participantEvent == participantEvent)&&(identical(other.actionFailure, actionFailure) || other.actionFailure == actionFailure)&&(identical(other.showControlsBar, showControlsBar) || other.showControlsBar == showControlsBar)&&(identical(other.focusedParticipantIndex, focusedParticipantIndex) || other.focusedParticipantIndex == focusedParticipantIndex)&&(identical(other.miniGridExpanded, miniGridExpanded) || other.miniGridExpanded == miniGridExpanded)&&(identical(other.peerIsCallingBack, peerIsCallingBack) || other.peerIsCallingBack == peerIsCallingBack));
}


@override
int get hashCode => Object.hashAll([runtimeType,status,isGroupContact,peerName,const DeepCollectionEquality().hash(_memberContactCards),isAudioOnly,isMicEnabled,isCameraEnabled,isSpeakerEnabled,const DeepCollectionEquality().hash(_participants),callDurationSeconds,hasHadPeer,session,errorCode,micPermissionError,cameraPermissionError,participantEvent,actionFailure,showControlsBar,focusedParticipantIndex,miniGridExpanded,peerIsCallingBack]);

@override
String toString() {
  return 'AudioVideoCallScreenState(status: $status, isGroupContact: $isGroupContact, peerName: $peerName, memberContactCards: $memberContactCards, isAudioOnly: $isAudioOnly, isMicEnabled: $isMicEnabled, isCameraEnabled: $isCameraEnabled, isSpeakerEnabled: $isSpeakerEnabled, participants: $participants, callDurationSeconds: $callDurationSeconds, hasHadPeer: $hasHadPeer, session: $session, errorCode: $errorCode, micPermissionError: $micPermissionError, cameraPermissionError: $cameraPermissionError, participantEvent: $participantEvent, actionFailure: $actionFailure, showControlsBar: $showControlsBar, focusedParticipantIndex: $focusedParticipantIndex, miniGridExpanded: $miniGridExpanded, peerIsCallingBack: $peerIsCallingBack)';
}


}

/// @nodoc
abstract mixin class _$AudioVideoCallScreenStateCopyWith<$Res> implements $AudioVideoCallScreenStateCopyWith<$Res> {
  factory _$AudioVideoCallScreenStateCopyWith(_AudioVideoCallScreenState value, $Res Function(_AudioVideoCallScreenState) _then) = __$AudioVideoCallScreenStateCopyWithImpl;
@override @useResult
$Res call({
 AudioVideoCallStatus status, bool isGroupContact, String peerName, Map<String, ContactCard> memberContactCards, bool isAudioOnly, bool isMicEnabled, bool isCameraEnabled, bool isSpeakerEnabled, List<AudioVideoCallParticipant> participants, int callDurationSeconds, bool hasHadPeer, AudioVideoCallSession? session, AudioVideoCallErrorCode? errorCode, bool micPermissionError, bool cameraPermissionError, CallParticipantChangeEvent? participantEvent, CallActionFailureEvent? actionFailure, bool showControlsBar, int? focusedParticipantIndex, bool miniGridExpanded, bool peerIsCallingBack
});




}
/// @nodoc
class __$AudioVideoCallScreenStateCopyWithImpl<$Res>
    implements _$AudioVideoCallScreenStateCopyWith<$Res> {
  __$AudioVideoCallScreenStateCopyWithImpl(this._self, this._then);

  final _AudioVideoCallScreenState _self;
  final $Res Function(_AudioVideoCallScreenState) _then;

/// Create a copy of AudioVideoCallScreenState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? status = null,Object? isGroupContact = null,Object? peerName = null,Object? memberContactCards = null,Object? isAudioOnly = null,Object? isMicEnabled = null,Object? isCameraEnabled = null,Object? isSpeakerEnabled = null,Object? participants = null,Object? callDurationSeconds = null,Object? hasHadPeer = null,Object? session = freezed,Object? errorCode = freezed,Object? micPermissionError = null,Object? cameraPermissionError = null,Object? participantEvent = freezed,Object? actionFailure = freezed,Object? showControlsBar = null,Object? focusedParticipantIndex = freezed,Object? miniGridExpanded = null,Object? peerIsCallingBack = null,}) {
  return _then(_AudioVideoCallScreenState(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as AudioVideoCallStatus,isGroupContact: null == isGroupContact ? _self.isGroupContact : isGroupContact // ignore: cast_nullable_to_non_nullable
as bool,peerName: null == peerName ? _self.peerName : peerName // ignore: cast_nullable_to_non_nullable
as String,memberContactCards: null == memberContactCards ? _self._memberContactCards : memberContactCards // ignore: cast_nullable_to_non_nullable
as Map<String, ContactCard>,isAudioOnly: null == isAudioOnly ? _self.isAudioOnly : isAudioOnly // ignore: cast_nullable_to_non_nullable
as bool,isMicEnabled: null == isMicEnabled ? _self.isMicEnabled : isMicEnabled // ignore: cast_nullable_to_non_nullable
as bool,isCameraEnabled: null == isCameraEnabled ? _self.isCameraEnabled : isCameraEnabled // ignore: cast_nullable_to_non_nullable
as bool,isSpeakerEnabled: null == isSpeakerEnabled ? _self.isSpeakerEnabled : isSpeakerEnabled // ignore: cast_nullable_to_non_nullable
as bool,participants: null == participants ? _self._participants : participants // ignore: cast_nullable_to_non_nullable
as List<AudioVideoCallParticipant>,callDurationSeconds: null == callDurationSeconds ? _self.callDurationSeconds : callDurationSeconds // ignore: cast_nullable_to_non_nullable
as int,hasHadPeer: null == hasHadPeer ? _self.hasHadPeer : hasHadPeer // ignore: cast_nullable_to_non_nullable
as bool,session: freezed == session ? _self.session : session // ignore: cast_nullable_to_non_nullable
as AudioVideoCallSession?,errorCode: freezed == errorCode ? _self.errorCode : errorCode // ignore: cast_nullable_to_non_nullable
as AudioVideoCallErrorCode?,micPermissionError: null == micPermissionError ? _self.micPermissionError : micPermissionError // ignore: cast_nullable_to_non_nullable
as bool,cameraPermissionError: null == cameraPermissionError ? _self.cameraPermissionError : cameraPermissionError // ignore: cast_nullable_to_non_nullable
as bool,participantEvent: freezed == participantEvent ? _self.participantEvent : participantEvent // ignore: cast_nullable_to_non_nullable
as CallParticipantChangeEvent?,actionFailure: freezed == actionFailure ? _self.actionFailure : actionFailure // ignore: cast_nullable_to_non_nullable
as CallActionFailureEvent?,showControlsBar: null == showControlsBar ? _self.showControlsBar : showControlsBar // ignore: cast_nullable_to_non_nullable
as bool,focusedParticipantIndex: freezed == focusedParticipantIndex ? _self.focusedParticipantIndex : focusedParticipantIndex // ignore: cast_nullable_to_non_nullable
as int?,miniGridExpanded: null == miniGridExpanded ? _self.miniGridExpanded : miniGridExpanded // ignore: cast_nullable_to_non_nullable
as bool,peerIsCallingBack: null == peerIsCallingBack ? _self.peerIsCallingBack : peerIsCallingBack // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
