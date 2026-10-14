// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'vtc_sign_in_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$VtcSignInState {

 VtcSignInStep get step; String? get communityName; String? get website; SignInAudience get audience; String? get personaDid; SignInRequester? get requester; int? get decisionDeadline; SignInFailure? get failure; TriggerLinkUi? get linkProblem; bool get isVtaMissing;
/// Create a copy of VtcSignInState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VtcSignInStateCopyWith<VtcSignInState> get copyWith => _$VtcSignInStateCopyWithImpl<VtcSignInState>(this as VtcSignInState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VtcSignInState&&(identical(other.step, step) || other.step == step)&&(identical(other.communityName, communityName) || other.communityName == communityName)&&(identical(other.website, website) || other.website == website)&&(identical(other.audience, audience) || other.audience == audience)&&(identical(other.personaDid, personaDid) || other.personaDid == personaDid)&&(identical(other.requester, requester) || other.requester == requester)&&(identical(other.decisionDeadline, decisionDeadline) || other.decisionDeadline == decisionDeadline)&&(identical(other.failure, failure) || other.failure == failure)&&(identical(other.linkProblem, linkProblem) || other.linkProblem == linkProblem)&&(identical(other.isVtaMissing, isVtaMissing) || other.isVtaMissing == isVtaMissing));
}


@override
int get hashCode => Object.hash(runtimeType,step,communityName,website,audience,personaDid,requester,decisionDeadline,failure,linkProblem,isVtaMissing);

@override
String toString() {
  return 'VtcSignInState(step: $step, communityName: $communityName, website: $website, audience: $audience, personaDid: $personaDid, requester: $requester, decisionDeadline: $decisionDeadline, failure: $failure, linkProblem: $linkProblem, isVtaMissing: $isVtaMissing)';
}


}

/// @nodoc
abstract mixin class $VtcSignInStateCopyWith<$Res>  {
  factory $VtcSignInStateCopyWith(VtcSignInState value, $Res Function(VtcSignInState) _then) = _$VtcSignInStateCopyWithImpl;
@useResult
$Res call({
 VtcSignInStep step, String? communityName, String? website, SignInAudience audience, String? personaDid, SignInRequester? requester, int? decisionDeadline, SignInFailure? failure, TriggerLinkUi? linkProblem, bool isVtaMissing
});




}
/// @nodoc
class _$VtcSignInStateCopyWithImpl<$Res>
    implements $VtcSignInStateCopyWith<$Res> {
  _$VtcSignInStateCopyWithImpl(this._self, this._then);

  final VtcSignInState _self;
  final $Res Function(VtcSignInState) _then;

/// Create a copy of VtcSignInState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? step = null,Object? communityName = freezed,Object? website = freezed,Object? audience = null,Object? personaDid = freezed,Object? requester = freezed,Object? decisionDeadline = freezed,Object? failure = freezed,Object? linkProblem = freezed,Object? isVtaMissing = null,}) {
  return _then(_self.copyWith(
step: null == step ? _self.step : step // ignore: cast_nullable_to_non_nullable
as VtcSignInStep,communityName: freezed == communityName ? _self.communityName : communityName // ignore: cast_nullable_to_non_nullable
as String?,website: freezed == website ? _self.website : website // ignore: cast_nullable_to_non_nullable
as String?,audience: null == audience ? _self.audience : audience // ignore: cast_nullable_to_non_nullable
as SignInAudience,personaDid: freezed == personaDid ? _self.personaDid : personaDid // ignore: cast_nullable_to_non_nullable
as String?,requester: freezed == requester ? _self.requester : requester // ignore: cast_nullable_to_non_nullable
as SignInRequester?,decisionDeadline: freezed == decisionDeadline ? _self.decisionDeadline : decisionDeadline // ignore: cast_nullable_to_non_nullable
as int?,failure: freezed == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as SignInFailure?,linkProblem: freezed == linkProblem ? _self.linkProblem : linkProblem // ignore: cast_nullable_to_non_nullable
as TriggerLinkUi?,isVtaMissing: null == isVtaMissing ? _self.isVtaMissing : isVtaMissing // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [VtcSignInState].
extension VtcSignInStatePatterns on VtcSignInState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VtcSignInState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VtcSignInState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VtcSignInState value)  $default,){
final _that = this;
switch (_that) {
case _VtcSignInState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VtcSignInState value)?  $default,){
final _that = this;
switch (_that) {
case _VtcSignInState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( VtcSignInStep step,  String? communityName,  String? website,  SignInAudience audience,  String? personaDid,  SignInRequester? requester,  int? decisionDeadline,  SignInFailure? failure,  TriggerLinkUi? linkProblem,  bool isVtaMissing)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VtcSignInState() when $default != null:
return $default(_that.step,_that.communityName,_that.website,_that.audience,_that.personaDid,_that.requester,_that.decisionDeadline,_that.failure,_that.linkProblem,_that.isVtaMissing);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( VtcSignInStep step,  String? communityName,  String? website,  SignInAudience audience,  String? personaDid,  SignInRequester? requester,  int? decisionDeadline,  SignInFailure? failure,  TriggerLinkUi? linkProblem,  bool isVtaMissing)  $default,) {final _that = this;
switch (_that) {
case _VtcSignInState():
return $default(_that.step,_that.communityName,_that.website,_that.audience,_that.personaDid,_that.requester,_that.decisionDeadline,_that.failure,_that.linkProblem,_that.isVtaMissing);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( VtcSignInStep step,  String? communityName,  String? website,  SignInAudience audience,  String? personaDid,  SignInRequester? requester,  int? decisionDeadline,  SignInFailure? failure,  TriggerLinkUi? linkProblem,  bool isVtaMissing)?  $default,) {final _that = this;
switch (_that) {
case _VtcSignInState() when $default != null:
return $default(_that.step,_that.communityName,_that.website,_that.audience,_that.personaDid,_that.requester,_that.decisionDeadline,_that.failure,_that.linkProblem,_that.isVtaMissing);case _:
  return null;

}
}

}

/// @nodoc


class _VtcSignInState implements VtcSignInState {
   _VtcSignInState({this.step = VtcSignInStep.scanning, this.communityName, this.website, this.audience = SignInAudience.member, this.personaDid, this.requester, this.decisionDeadline, this.failure, this.linkProblem, this.isVtaMissing = false});
  

@override@JsonKey() final  VtcSignInStep step;
@override final  String? communityName;
@override final  String? website;
@override@JsonKey() final  SignInAudience audience;
@override final  String? personaDid;
@override final  SignInRequester? requester;
@override final  int? decisionDeadline;
@override final  SignInFailure? failure;
@override final  TriggerLinkUi? linkProblem;
@override@JsonKey() final  bool isVtaMissing;

/// Create a copy of VtcSignInState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VtcSignInStateCopyWith<_VtcSignInState> get copyWith => __$VtcSignInStateCopyWithImpl<_VtcSignInState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _VtcSignInState&&(identical(other.step, step) || other.step == step)&&(identical(other.communityName, communityName) || other.communityName == communityName)&&(identical(other.website, website) || other.website == website)&&(identical(other.audience, audience) || other.audience == audience)&&(identical(other.personaDid, personaDid) || other.personaDid == personaDid)&&(identical(other.requester, requester) || other.requester == requester)&&(identical(other.decisionDeadline, decisionDeadline) || other.decisionDeadline == decisionDeadline)&&(identical(other.failure, failure) || other.failure == failure)&&(identical(other.linkProblem, linkProblem) || other.linkProblem == linkProblem)&&(identical(other.isVtaMissing, isVtaMissing) || other.isVtaMissing == isVtaMissing));
}


@override
int get hashCode => Object.hash(runtimeType,step,communityName,website,audience,personaDid,requester,decisionDeadline,failure,linkProblem,isVtaMissing);

@override
String toString() {
  return 'VtcSignInState(step: $step, communityName: $communityName, website: $website, audience: $audience, personaDid: $personaDid, requester: $requester, decisionDeadline: $decisionDeadline, failure: $failure, linkProblem: $linkProblem, isVtaMissing: $isVtaMissing)';
}


}

/// @nodoc
abstract mixin class _$VtcSignInStateCopyWith<$Res> implements $VtcSignInStateCopyWith<$Res> {
  factory _$VtcSignInStateCopyWith(_VtcSignInState value, $Res Function(_VtcSignInState) _then) = __$VtcSignInStateCopyWithImpl;
@override @useResult
$Res call({
 VtcSignInStep step, String? communityName, String? website, SignInAudience audience, String? personaDid, SignInRequester? requester, int? decisionDeadline, SignInFailure? failure, TriggerLinkUi? linkProblem, bool isVtaMissing
});




}
/// @nodoc
class __$VtcSignInStateCopyWithImpl<$Res>
    implements _$VtcSignInStateCopyWith<$Res> {
  __$VtcSignInStateCopyWithImpl(this._self, this._then);

  final _VtcSignInState _self;
  final $Res Function(_VtcSignInState) _then;

/// Create a copy of VtcSignInState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? step = null,Object? communityName = freezed,Object? website = freezed,Object? audience = null,Object? personaDid = freezed,Object? requester = freezed,Object? decisionDeadline = freezed,Object? failure = freezed,Object? linkProblem = freezed,Object? isVtaMissing = null,}) {
  return _then(_VtcSignInState(
step: null == step ? _self.step : step // ignore: cast_nullable_to_non_nullable
as VtcSignInStep,communityName: freezed == communityName ? _self.communityName : communityName // ignore: cast_nullable_to_non_nullable
as String?,website: freezed == website ? _self.website : website // ignore: cast_nullable_to_non_nullable
as String?,audience: null == audience ? _self.audience : audience // ignore: cast_nullable_to_non_nullable
as SignInAudience,personaDid: freezed == personaDid ? _self.personaDid : personaDid // ignore: cast_nullable_to_non_nullable
as String?,requester: freezed == requester ? _self.requester : requester // ignore: cast_nullable_to_non_nullable
as SignInRequester?,decisionDeadline: freezed == decisionDeadline ? _self.decisionDeadline : decisionDeadline // ignore: cast_nullable_to_non_nullable
as int?,failure: freezed == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as SignInFailure?,linkProblem: freezed == linkProblem ? _self.linkProblem : linkProblem // ignore: cast_nullable_to_non_nullable
as TriggerLinkUi?,isVtaMissing: null == isVtaMissing ? _self.isVtaMissing : isVtaMissing // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
