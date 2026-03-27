// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'agent_readiness_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AgentReadinessState {

 int get scorePercent; String get statusLabel; bool get isReady; int get messagesObserved; bool get isDeployed; int get conversationsObserved; List<String> get whatsMissing; int get feedbackUpCount; int get feedbackDownCount; DateTime? get lastAnalysedAt; AgentPersona? get persona;
/// Create a copy of AgentReadinessState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AgentReadinessStateCopyWith<AgentReadinessState> get copyWith => _$AgentReadinessStateCopyWithImpl<AgentReadinessState>(this as AgentReadinessState, _$identity);

  /// Serializes this AgentReadinessState to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AgentReadinessState&&(identical(other.scorePercent, scorePercent) || other.scorePercent == scorePercent)&&(identical(other.statusLabel, statusLabel) || other.statusLabel == statusLabel)&&(identical(other.isReady, isReady) || other.isReady == isReady)&&(identical(other.messagesObserved, messagesObserved) || other.messagesObserved == messagesObserved)&&(identical(other.isDeployed, isDeployed) || other.isDeployed == isDeployed)&&(identical(other.conversationsObserved, conversationsObserved) || other.conversationsObserved == conversationsObserved)&&const DeepCollectionEquality().equals(other.whatsMissing, whatsMissing)&&(identical(other.feedbackUpCount, feedbackUpCount) || other.feedbackUpCount == feedbackUpCount)&&(identical(other.feedbackDownCount, feedbackDownCount) || other.feedbackDownCount == feedbackDownCount)&&(identical(other.lastAnalysedAt, lastAnalysedAt) || other.lastAnalysedAt == lastAnalysedAt)&&(identical(other.persona, persona) || other.persona == persona));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,scorePercent,statusLabel,isReady,messagesObserved,isDeployed,conversationsObserved,const DeepCollectionEquality().hash(whatsMissing),feedbackUpCount,feedbackDownCount,lastAnalysedAt,persona);

@override
String toString() {
  return 'AgentReadinessState(scorePercent: $scorePercent, statusLabel: $statusLabel, isReady: $isReady, messagesObserved: $messagesObserved, isDeployed: $isDeployed, conversationsObserved: $conversationsObserved, whatsMissing: $whatsMissing, feedbackUpCount: $feedbackUpCount, feedbackDownCount: $feedbackDownCount, lastAnalysedAt: $lastAnalysedAt, persona: $persona)';
}


}

/// @nodoc
abstract mixin class $AgentReadinessStateCopyWith<$Res>  {
  factory $AgentReadinessStateCopyWith(AgentReadinessState value, $Res Function(AgentReadinessState) _then) = _$AgentReadinessStateCopyWithImpl;
@useResult
$Res call({
 int scorePercent, String statusLabel, bool isReady, int messagesObserved, bool isDeployed, int conversationsObserved, List<String> whatsMissing, int feedbackUpCount, int feedbackDownCount, DateTime? lastAnalysedAt, AgentPersona? persona
});


$AgentPersonaCopyWith<$Res>? get persona;

}
/// @nodoc
class _$AgentReadinessStateCopyWithImpl<$Res>
    implements $AgentReadinessStateCopyWith<$Res> {
  _$AgentReadinessStateCopyWithImpl(this._self, this._then);

  final AgentReadinessState _self;
  final $Res Function(AgentReadinessState) _then;

/// Create a copy of AgentReadinessState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? scorePercent = null,Object? statusLabel = null,Object? isReady = null,Object? messagesObserved = null,Object? isDeployed = null,Object? conversationsObserved = null,Object? whatsMissing = null,Object? feedbackUpCount = null,Object? feedbackDownCount = null,Object? lastAnalysedAt = freezed,Object? persona = freezed,}) {
  return _then(_self.copyWith(
scorePercent: null == scorePercent ? _self.scorePercent : scorePercent // ignore: cast_nullable_to_non_nullable
as int,statusLabel: null == statusLabel ? _self.statusLabel : statusLabel // ignore: cast_nullable_to_non_nullable
as String,isReady: null == isReady ? _self.isReady : isReady // ignore: cast_nullable_to_non_nullable
as bool,messagesObserved: null == messagesObserved ? _self.messagesObserved : messagesObserved // ignore: cast_nullable_to_non_nullable
as int,isDeployed: null == isDeployed ? _self.isDeployed : isDeployed // ignore: cast_nullable_to_non_nullable
as bool,conversationsObserved: null == conversationsObserved ? _self.conversationsObserved : conversationsObserved // ignore: cast_nullable_to_non_nullable
as int,whatsMissing: null == whatsMissing ? _self.whatsMissing : whatsMissing // ignore: cast_nullable_to_non_nullable
as List<String>,feedbackUpCount: null == feedbackUpCount ? _self.feedbackUpCount : feedbackUpCount // ignore: cast_nullable_to_non_nullable
as int,feedbackDownCount: null == feedbackDownCount ? _self.feedbackDownCount : feedbackDownCount // ignore: cast_nullable_to_non_nullable
as int,lastAnalysedAt: freezed == lastAnalysedAt ? _self.lastAnalysedAt : lastAnalysedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,persona: freezed == persona ? _self.persona : persona // ignore: cast_nullable_to_non_nullable
as AgentPersona?,
  ));
}
/// Create a copy of AgentReadinessState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AgentPersonaCopyWith<$Res>? get persona {
    if (_self.persona == null) {
    return null;
  }

  return $AgentPersonaCopyWith<$Res>(_self.persona!, (value) {
    return _then(_self.copyWith(persona: value));
  });
}
}


/// Adds pattern-matching-related methods to [AgentReadinessState].
extension AgentReadinessStatePatterns on AgentReadinessState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AgentReadinessState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AgentReadinessState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AgentReadinessState value)  $default,){
final _that = this;
switch (_that) {
case _AgentReadinessState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AgentReadinessState value)?  $default,){
final _that = this;
switch (_that) {
case _AgentReadinessState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int scorePercent,  String statusLabel,  bool isReady,  int messagesObserved,  bool isDeployed,  int conversationsObserved,  List<String> whatsMissing,  int feedbackUpCount,  int feedbackDownCount,  DateTime? lastAnalysedAt,  AgentPersona? persona)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AgentReadinessState() when $default != null:
return $default(_that.scorePercent,_that.statusLabel,_that.isReady,_that.messagesObserved,_that.isDeployed,_that.conversationsObserved,_that.whatsMissing,_that.feedbackUpCount,_that.feedbackDownCount,_that.lastAnalysedAt,_that.persona);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int scorePercent,  String statusLabel,  bool isReady,  int messagesObserved,  bool isDeployed,  int conversationsObserved,  List<String> whatsMissing,  int feedbackUpCount,  int feedbackDownCount,  DateTime? lastAnalysedAt,  AgentPersona? persona)  $default,) {final _that = this;
switch (_that) {
case _AgentReadinessState():
return $default(_that.scorePercent,_that.statusLabel,_that.isReady,_that.messagesObserved,_that.isDeployed,_that.conversationsObserved,_that.whatsMissing,_that.feedbackUpCount,_that.feedbackDownCount,_that.lastAnalysedAt,_that.persona);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int scorePercent,  String statusLabel,  bool isReady,  int messagesObserved,  bool isDeployed,  int conversationsObserved,  List<String> whatsMissing,  int feedbackUpCount,  int feedbackDownCount,  DateTime? lastAnalysedAt,  AgentPersona? persona)?  $default,) {final _that = this;
switch (_that) {
case _AgentReadinessState() when $default != null:
return $default(_that.scorePercent,_that.statusLabel,_that.isReady,_that.messagesObserved,_that.isDeployed,_that.conversationsObserved,_that.whatsMissing,_that.feedbackUpCount,_that.feedbackDownCount,_that.lastAnalysedAt,_that.persona);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AgentReadinessState implements AgentReadinessState {
  const _AgentReadinessState({required this.scorePercent, required this.statusLabel, required this.isReady, required this.messagesObserved, this.isDeployed = false, this.conversationsObserved = 0, final  List<String> whatsMissing = const [], this.feedbackUpCount = 0, this.feedbackDownCount = 0, this.lastAnalysedAt, this.persona}): _whatsMissing = whatsMissing;
  factory _AgentReadinessState.fromJson(Map<String, dynamic> json) => _$AgentReadinessStateFromJson(json);

@override final  int scorePercent;
@override final  String statusLabel;
@override final  bool isReady;
@override final  int messagesObserved;
@override@JsonKey() final  bool isDeployed;
@override@JsonKey() final  int conversationsObserved;
 final  List<String> _whatsMissing;
@override@JsonKey() List<String> get whatsMissing {
  if (_whatsMissing is EqualUnmodifiableListView) return _whatsMissing;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_whatsMissing);
}

@override@JsonKey() final  int feedbackUpCount;
@override@JsonKey() final  int feedbackDownCount;
@override final  DateTime? lastAnalysedAt;
@override final  AgentPersona? persona;

/// Create a copy of AgentReadinessState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AgentReadinessStateCopyWith<_AgentReadinessState> get copyWith => __$AgentReadinessStateCopyWithImpl<_AgentReadinessState>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AgentReadinessStateToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AgentReadinessState&&(identical(other.scorePercent, scorePercent) || other.scorePercent == scorePercent)&&(identical(other.statusLabel, statusLabel) || other.statusLabel == statusLabel)&&(identical(other.isReady, isReady) || other.isReady == isReady)&&(identical(other.messagesObserved, messagesObserved) || other.messagesObserved == messagesObserved)&&(identical(other.isDeployed, isDeployed) || other.isDeployed == isDeployed)&&(identical(other.conversationsObserved, conversationsObserved) || other.conversationsObserved == conversationsObserved)&&const DeepCollectionEquality().equals(other._whatsMissing, _whatsMissing)&&(identical(other.feedbackUpCount, feedbackUpCount) || other.feedbackUpCount == feedbackUpCount)&&(identical(other.feedbackDownCount, feedbackDownCount) || other.feedbackDownCount == feedbackDownCount)&&(identical(other.lastAnalysedAt, lastAnalysedAt) || other.lastAnalysedAt == lastAnalysedAt)&&(identical(other.persona, persona) || other.persona == persona));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,scorePercent,statusLabel,isReady,messagesObserved,isDeployed,conversationsObserved,const DeepCollectionEquality().hash(_whatsMissing),feedbackUpCount,feedbackDownCount,lastAnalysedAt,persona);

@override
String toString() {
  return 'AgentReadinessState(scorePercent: $scorePercent, statusLabel: $statusLabel, isReady: $isReady, messagesObserved: $messagesObserved, isDeployed: $isDeployed, conversationsObserved: $conversationsObserved, whatsMissing: $whatsMissing, feedbackUpCount: $feedbackUpCount, feedbackDownCount: $feedbackDownCount, lastAnalysedAt: $lastAnalysedAt, persona: $persona)';
}


}

/// @nodoc
abstract mixin class _$AgentReadinessStateCopyWith<$Res> implements $AgentReadinessStateCopyWith<$Res> {
  factory _$AgentReadinessStateCopyWith(_AgentReadinessState value, $Res Function(_AgentReadinessState) _then) = __$AgentReadinessStateCopyWithImpl;
@override @useResult
$Res call({
 int scorePercent, String statusLabel, bool isReady, int messagesObserved, bool isDeployed, int conversationsObserved, List<String> whatsMissing, int feedbackUpCount, int feedbackDownCount, DateTime? lastAnalysedAt, AgentPersona? persona
});


@override $AgentPersonaCopyWith<$Res>? get persona;

}
/// @nodoc
class __$AgentReadinessStateCopyWithImpl<$Res>
    implements _$AgentReadinessStateCopyWith<$Res> {
  __$AgentReadinessStateCopyWithImpl(this._self, this._then);

  final _AgentReadinessState _self;
  final $Res Function(_AgentReadinessState) _then;

/// Create a copy of AgentReadinessState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? scorePercent = null,Object? statusLabel = null,Object? isReady = null,Object? messagesObserved = null,Object? isDeployed = null,Object? conversationsObserved = null,Object? whatsMissing = null,Object? feedbackUpCount = null,Object? feedbackDownCount = null,Object? lastAnalysedAt = freezed,Object? persona = freezed,}) {
  return _then(_AgentReadinessState(
scorePercent: null == scorePercent ? _self.scorePercent : scorePercent // ignore: cast_nullable_to_non_nullable
as int,statusLabel: null == statusLabel ? _self.statusLabel : statusLabel // ignore: cast_nullable_to_non_nullable
as String,isReady: null == isReady ? _self.isReady : isReady // ignore: cast_nullable_to_non_nullable
as bool,messagesObserved: null == messagesObserved ? _self.messagesObserved : messagesObserved // ignore: cast_nullable_to_non_nullable
as int,isDeployed: null == isDeployed ? _self.isDeployed : isDeployed // ignore: cast_nullable_to_non_nullable
as bool,conversationsObserved: null == conversationsObserved ? _self.conversationsObserved : conversationsObserved // ignore: cast_nullable_to_non_nullable
as int,whatsMissing: null == whatsMissing ? _self._whatsMissing : whatsMissing // ignore: cast_nullable_to_non_nullable
as List<String>,feedbackUpCount: null == feedbackUpCount ? _self.feedbackUpCount : feedbackUpCount // ignore: cast_nullable_to_non_nullable
as int,feedbackDownCount: null == feedbackDownCount ? _self.feedbackDownCount : feedbackDownCount // ignore: cast_nullable_to_non_nullable
as int,lastAnalysedAt: freezed == lastAnalysedAt ? _self.lastAnalysedAt : lastAnalysedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,persona: freezed == persona ? _self.persona : persona // ignore: cast_nullable_to_non_nullable
as AgentPersona?,
  ));
}

/// Create a copy of AgentReadinessState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AgentPersonaCopyWith<$Res>? get persona {
    if (_self.persona == null) {
    return null;
  }

  return $AgentPersonaCopyWith<$Res>(_self.persona!, (value) {
    return _then(_self.copyWith(persona: value));
  });
}
}

// dart format on
