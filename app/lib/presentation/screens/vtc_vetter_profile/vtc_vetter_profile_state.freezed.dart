// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'vtc_vetter_profile_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$VtcVetterProfileState {

 VtcVetterProfileStep get step;/// The profile last published, as the community answered.
 VtcVetterProfileRecord? get recorded;/// Whether the profile is being published.
 bool get busy; VtcVetterProfileFailure? get failure;/// What the community would refuse, when [failure] is
/// [VtcVetterProfileFailure.invalid].
 String? get invalidReason;
/// Create a copy of VtcVetterProfileState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VtcVetterProfileStateCopyWith<VtcVetterProfileState> get copyWith => _$VtcVetterProfileStateCopyWithImpl<VtcVetterProfileState>(this as VtcVetterProfileState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VtcVetterProfileState&&(identical(other.step, step) || other.step == step)&&(identical(other.recorded, recorded) || other.recorded == recorded)&&(identical(other.busy, busy) || other.busy == busy)&&(identical(other.failure, failure) || other.failure == failure)&&(identical(other.invalidReason, invalidReason) || other.invalidReason == invalidReason));
}


@override
int get hashCode => Object.hash(runtimeType,step,recorded,busy,failure,invalidReason);

@override
String toString() {
  return 'VtcVetterProfileState(step: $step, recorded: $recorded, busy: $busy, failure: $failure, invalidReason: $invalidReason)';
}


}

/// @nodoc
abstract mixin class $VtcVetterProfileStateCopyWith<$Res>  {
  factory $VtcVetterProfileStateCopyWith(VtcVetterProfileState value, $Res Function(VtcVetterProfileState) _then) = _$VtcVetterProfileStateCopyWithImpl;
@useResult
$Res call({
 VtcVetterProfileStep step, VtcVetterProfileRecord? recorded, bool busy, VtcVetterProfileFailure? failure, String? invalidReason
});




}
/// @nodoc
class _$VtcVetterProfileStateCopyWithImpl<$Res>
    implements $VtcVetterProfileStateCopyWith<$Res> {
  _$VtcVetterProfileStateCopyWithImpl(this._self, this._then);

  final VtcVetterProfileState _self;
  final $Res Function(VtcVetterProfileState) _then;

/// Create a copy of VtcVetterProfileState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? step = null,Object? recorded = freezed,Object? busy = null,Object? failure = freezed,Object? invalidReason = freezed,}) {
  return _then(_self.copyWith(
step: null == step ? _self.step : step // ignore: cast_nullable_to_non_nullable
as VtcVetterProfileStep,recorded: freezed == recorded ? _self.recorded : recorded // ignore: cast_nullable_to_non_nullable
as VtcVetterProfileRecord?,busy: null == busy ? _self.busy : busy // ignore: cast_nullable_to_non_nullable
as bool,failure: freezed == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as VtcVetterProfileFailure?,invalidReason: freezed == invalidReason ? _self.invalidReason : invalidReason // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [VtcVetterProfileState].
extension VtcVetterProfileStatePatterns on VtcVetterProfileState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VtcVetterProfileState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VtcVetterProfileState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VtcVetterProfileState value)  $default,){
final _that = this;
switch (_that) {
case _VtcVetterProfileState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VtcVetterProfileState value)?  $default,){
final _that = this;
switch (_that) {
case _VtcVetterProfileState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( VtcVetterProfileStep step,  VtcVetterProfileRecord? recorded,  bool busy,  VtcVetterProfileFailure? failure,  String? invalidReason)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VtcVetterProfileState() when $default != null:
return $default(_that.step,_that.recorded,_that.busy,_that.failure,_that.invalidReason);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( VtcVetterProfileStep step,  VtcVetterProfileRecord? recorded,  bool busy,  VtcVetterProfileFailure? failure,  String? invalidReason)  $default,) {final _that = this;
switch (_that) {
case _VtcVetterProfileState():
return $default(_that.step,_that.recorded,_that.busy,_that.failure,_that.invalidReason);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( VtcVetterProfileStep step,  VtcVetterProfileRecord? recorded,  bool busy,  VtcVetterProfileFailure? failure,  String? invalidReason)?  $default,) {final _that = this;
switch (_that) {
case _VtcVetterProfileState() when $default != null:
return $default(_that.step,_that.recorded,_that.busy,_that.failure,_that.invalidReason);case _:
  return null;

}
}

}

/// @nodoc


class _VtcVetterProfileState implements VtcVetterProfileState {
   _VtcVetterProfileState({this.step = VtcVetterProfileStep.loading, this.recorded, this.busy = false, this.failure, this.invalidReason});
  

@override@JsonKey() final  VtcVetterProfileStep step;
/// The profile last published, as the community answered.
@override final  VtcVetterProfileRecord? recorded;
/// Whether the profile is being published.
@override@JsonKey() final  bool busy;
@override final  VtcVetterProfileFailure? failure;
/// What the community would refuse, when [failure] is
/// [VtcVetterProfileFailure.invalid].
@override final  String? invalidReason;

/// Create a copy of VtcVetterProfileState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VtcVetterProfileStateCopyWith<_VtcVetterProfileState> get copyWith => __$VtcVetterProfileStateCopyWithImpl<_VtcVetterProfileState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _VtcVetterProfileState&&(identical(other.step, step) || other.step == step)&&(identical(other.recorded, recorded) || other.recorded == recorded)&&(identical(other.busy, busy) || other.busy == busy)&&(identical(other.failure, failure) || other.failure == failure)&&(identical(other.invalidReason, invalidReason) || other.invalidReason == invalidReason));
}


@override
int get hashCode => Object.hash(runtimeType,step,recorded,busy,failure,invalidReason);

@override
String toString() {
  return 'VtcVetterProfileState(step: $step, recorded: $recorded, busy: $busy, failure: $failure, invalidReason: $invalidReason)';
}


}

/// @nodoc
abstract mixin class _$VtcVetterProfileStateCopyWith<$Res> implements $VtcVetterProfileStateCopyWith<$Res> {
  factory _$VtcVetterProfileStateCopyWith(_VtcVetterProfileState value, $Res Function(_VtcVetterProfileState) _then) = __$VtcVetterProfileStateCopyWithImpl;
@override @useResult
$Res call({
 VtcVetterProfileStep step, VtcVetterProfileRecord? recorded, bool busy, VtcVetterProfileFailure? failure, String? invalidReason
});




}
/// @nodoc
class __$VtcVetterProfileStateCopyWithImpl<$Res>
    implements _$VtcVetterProfileStateCopyWith<$Res> {
  __$VtcVetterProfileStateCopyWithImpl(this._self, this._then);

  final _VtcVetterProfileState _self;
  final $Res Function(_VtcVetterProfileState) _then;

/// Create a copy of VtcVetterProfileState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? step = null,Object? recorded = freezed,Object? busy = null,Object? failure = freezed,Object? invalidReason = freezed,}) {
  return _then(_VtcVetterProfileState(
step: null == step ? _self.step : step // ignore: cast_nullable_to_non_nullable
as VtcVetterProfileStep,recorded: freezed == recorded ? _self.recorded : recorded // ignore: cast_nullable_to_non_nullable
as VtcVetterProfileRecord?,busy: null == busy ? _self.busy : busy // ignore: cast_nullable_to_non_nullable
as bool,failure: freezed == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as VtcVetterProfileFailure?,invalidReason: freezed == invalidReason ? _self.invalidReason : invalidReason // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
