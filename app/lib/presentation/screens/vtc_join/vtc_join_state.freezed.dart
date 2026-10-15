// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'vtc_join_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$VtcJoinState {

 VtcJoinStep get step; String? get communityName; bool get canApply; bool get admitsAtOnce; bool get wasMember; VtcJoinFailure? get failure;
/// Create a copy of VtcJoinState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VtcJoinStateCopyWith<VtcJoinState> get copyWith => _$VtcJoinStateCopyWithImpl<VtcJoinState>(this as VtcJoinState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VtcJoinState&&(identical(other.step, step) || other.step == step)&&(identical(other.communityName, communityName) || other.communityName == communityName)&&(identical(other.canApply, canApply) || other.canApply == canApply)&&(identical(other.admitsAtOnce, admitsAtOnce) || other.admitsAtOnce == admitsAtOnce)&&(identical(other.wasMember, wasMember) || other.wasMember == wasMember)&&(identical(other.failure, failure) || other.failure == failure));
}


@override
int get hashCode => Object.hash(runtimeType,step,communityName,canApply,admitsAtOnce,wasMember,failure);

@override
String toString() {
  return 'VtcJoinState(step: $step, communityName: $communityName, canApply: $canApply, admitsAtOnce: $admitsAtOnce, wasMember: $wasMember, failure: $failure)';
}


}

/// @nodoc
abstract mixin class $VtcJoinStateCopyWith<$Res>  {
  factory $VtcJoinStateCopyWith(VtcJoinState value, $Res Function(VtcJoinState) _then) = _$VtcJoinStateCopyWithImpl;
@useResult
$Res call({
 VtcJoinStep step, String? communityName, bool canApply, bool admitsAtOnce, bool wasMember, VtcJoinFailure? failure
});




}
/// @nodoc
class _$VtcJoinStateCopyWithImpl<$Res>
    implements $VtcJoinStateCopyWith<$Res> {
  _$VtcJoinStateCopyWithImpl(this._self, this._then);

  final VtcJoinState _self;
  final $Res Function(VtcJoinState) _then;

/// Create a copy of VtcJoinState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? step = null,Object? communityName = freezed,Object? canApply = null,Object? admitsAtOnce = null,Object? wasMember = null,Object? failure = freezed,}) {
  return _then(_self.copyWith(
step: null == step ? _self.step : step // ignore: cast_nullable_to_non_nullable
as VtcJoinStep,communityName: freezed == communityName ? _self.communityName : communityName // ignore: cast_nullable_to_non_nullable
as String?,canApply: null == canApply ? _self.canApply : canApply // ignore: cast_nullable_to_non_nullable
as bool,admitsAtOnce: null == admitsAtOnce ? _self.admitsAtOnce : admitsAtOnce // ignore: cast_nullable_to_non_nullable
as bool,wasMember: null == wasMember ? _self.wasMember : wasMember // ignore: cast_nullable_to_non_nullable
as bool,failure: freezed == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as VtcJoinFailure?,
  ));
}

}


/// Adds pattern-matching-related methods to [VtcJoinState].
extension VtcJoinStatePatterns on VtcJoinState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VtcJoinState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VtcJoinState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VtcJoinState value)  $default,){
final _that = this;
switch (_that) {
case _VtcJoinState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VtcJoinState value)?  $default,){
final _that = this;
switch (_that) {
case _VtcJoinState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( VtcJoinStep step,  String? communityName,  bool canApply,  bool admitsAtOnce,  bool wasMember,  VtcJoinFailure? failure)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VtcJoinState() when $default != null:
return $default(_that.step,_that.communityName,_that.canApply,_that.admitsAtOnce,_that.wasMember,_that.failure);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( VtcJoinStep step,  String? communityName,  bool canApply,  bool admitsAtOnce,  bool wasMember,  VtcJoinFailure? failure)  $default,) {final _that = this;
switch (_that) {
case _VtcJoinState():
return $default(_that.step,_that.communityName,_that.canApply,_that.admitsAtOnce,_that.wasMember,_that.failure);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( VtcJoinStep step,  String? communityName,  bool canApply,  bool admitsAtOnce,  bool wasMember,  VtcJoinFailure? failure)?  $default,) {final _that = this;
switch (_that) {
case _VtcJoinState() when $default != null:
return $default(_that.step,_that.communityName,_that.canApply,_that.admitsAtOnce,_that.wasMember,_that.failure);case _:
  return null;

}
}

}

/// @nodoc


class _VtcJoinState implements VtcJoinState {
   _VtcJoinState({this.step = VtcJoinStep.scanning, this.communityName, this.canApply = false, this.admitsAtOnce = false, this.wasMember = false, this.failure});
  

@override@JsonKey() final  VtcJoinStep step;
@override final  String? communityName;
@override@JsonKey() final  bool canApply;
@override@JsonKey() final  bool admitsAtOnce;
@override@JsonKey() final  bool wasMember;
@override final  VtcJoinFailure? failure;

/// Create a copy of VtcJoinState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VtcJoinStateCopyWith<_VtcJoinState> get copyWith => __$VtcJoinStateCopyWithImpl<_VtcJoinState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _VtcJoinState&&(identical(other.step, step) || other.step == step)&&(identical(other.communityName, communityName) || other.communityName == communityName)&&(identical(other.canApply, canApply) || other.canApply == canApply)&&(identical(other.admitsAtOnce, admitsAtOnce) || other.admitsAtOnce == admitsAtOnce)&&(identical(other.wasMember, wasMember) || other.wasMember == wasMember)&&(identical(other.failure, failure) || other.failure == failure));
}


@override
int get hashCode => Object.hash(runtimeType,step,communityName,canApply,admitsAtOnce,wasMember,failure);

@override
String toString() {
  return 'VtcJoinState(step: $step, communityName: $communityName, canApply: $canApply, admitsAtOnce: $admitsAtOnce, wasMember: $wasMember, failure: $failure)';
}


}

/// @nodoc
abstract mixin class _$VtcJoinStateCopyWith<$Res> implements $VtcJoinStateCopyWith<$Res> {
  factory _$VtcJoinStateCopyWith(_VtcJoinState value, $Res Function(_VtcJoinState) _then) = __$VtcJoinStateCopyWithImpl;
@override @useResult
$Res call({
 VtcJoinStep step, String? communityName, bool canApply, bool admitsAtOnce, bool wasMember, VtcJoinFailure? failure
});




}
/// @nodoc
class __$VtcJoinStateCopyWithImpl<$Res>
    implements _$VtcJoinStateCopyWith<$Res> {
  __$VtcJoinStateCopyWithImpl(this._self, this._then);

  final _VtcJoinState _self;
  final $Res Function(_VtcJoinState) _then;

/// Create a copy of VtcJoinState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? step = null,Object? communityName = freezed,Object? canApply = null,Object? admitsAtOnce = null,Object? wasMember = null,Object? failure = freezed,}) {
  return _then(_VtcJoinState(
step: null == step ? _self.step : step // ignore: cast_nullable_to_non_nullable
as VtcJoinStep,communityName: freezed == communityName ? _self.communityName : communityName // ignore: cast_nullable_to_non_nullable
as String?,canApply: null == canApply ? _self.canApply : canApply // ignore: cast_nullable_to_non_nullable
as bool,admitsAtOnce: null == admitsAtOnce ? _self.admitsAtOnce : admitsAtOnce // ignore: cast_nullable_to_non_nullable
as bool,wasMember: null == wasMember ? _self.wasMember : wasMember // ignore: cast_nullable_to_non_nullable
as bool,failure: freezed == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as VtcJoinFailure?,
  ));
}


}

// dart format on
