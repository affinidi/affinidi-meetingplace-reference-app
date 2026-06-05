// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'proof_flow_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ProofFlowState {

 bool get isVerifyingProof; String? get verificationError;/// 32-byte challenge from the peer's liveness check request
 List<int>? get verifierChallengeNonce;
/// Create a copy of ProofFlowState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProofFlowStateCopyWith<ProofFlowState> get copyWith => _$ProofFlowStateCopyWithImpl<ProofFlowState>(this as ProofFlowState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProofFlowState&&(identical(other.isVerifyingProof, isVerifyingProof) || other.isVerifyingProof == isVerifyingProof)&&(identical(other.verificationError, verificationError) || other.verificationError == verificationError)&&const DeepCollectionEquality().equals(other.verifierChallengeNonce, verifierChallengeNonce));
}


@override
int get hashCode => Object.hash(runtimeType,isVerifyingProof,verificationError,const DeepCollectionEquality().hash(verifierChallengeNonce));

@override
String toString() {
  return 'ProofFlowState(isVerifyingProof: $isVerifyingProof, verificationError: $verificationError, verifierChallengeNonce: $verifierChallengeNonce)';
}


}

/// @nodoc
abstract mixin class $ProofFlowStateCopyWith<$Res>  {
  factory $ProofFlowStateCopyWith(ProofFlowState value, $Res Function(ProofFlowState) _then) = _$ProofFlowStateCopyWithImpl;
@useResult
$Res call({
 bool isVerifyingProof, String? verificationError, List<int>? verifierChallengeNonce
});




}
/// @nodoc
class _$ProofFlowStateCopyWithImpl<$Res>
    implements $ProofFlowStateCopyWith<$Res> {
  _$ProofFlowStateCopyWithImpl(this._self, this._then);

  final ProofFlowState _self;
  final $Res Function(ProofFlowState) _then;

/// Create a copy of ProofFlowState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? isVerifyingProof = null,Object? verificationError = freezed,Object? verifierChallengeNonce = freezed,}) {
  return _then(_self.copyWith(
isVerifyingProof: null == isVerifyingProof ? _self.isVerifyingProof : isVerifyingProof // ignore: cast_nullable_to_non_nullable
as bool,verificationError: freezed == verificationError ? _self.verificationError : verificationError // ignore: cast_nullable_to_non_nullable
as String?,verifierChallengeNonce: freezed == verifierChallengeNonce ? _self.verifierChallengeNonce : verifierChallengeNonce // ignore: cast_nullable_to_non_nullable
as List<int>?,
  ));
}

}


/// Adds pattern-matching-related methods to [ProofFlowState].
extension ProofFlowStatePatterns on ProofFlowState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProofFlowState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProofFlowState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProofFlowState value)  $default,){
final _that = this;
switch (_that) {
case _ProofFlowState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProofFlowState value)?  $default,){
final _that = this;
switch (_that) {
case _ProofFlowState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool isVerifyingProof,  String? verificationError,  List<int>? verifierChallengeNonce)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProofFlowState() when $default != null:
return $default(_that.isVerifyingProof,_that.verificationError,_that.verifierChallengeNonce);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool isVerifyingProof,  String? verificationError,  List<int>? verifierChallengeNonce)  $default,) {final _that = this;
switch (_that) {
case _ProofFlowState():
return $default(_that.isVerifyingProof,_that.verificationError,_that.verifierChallengeNonce);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool isVerifyingProof,  String? verificationError,  List<int>? verifierChallengeNonce)?  $default,) {final _that = this;
switch (_that) {
case _ProofFlowState() when $default != null:
return $default(_that.isVerifyingProof,_that.verificationError,_that.verifierChallengeNonce);case _:
  return null;

}
}

}

/// @nodoc


class _ProofFlowState implements ProofFlowState {
  const _ProofFlowState({this.isVerifyingProof = false, this.verificationError, final  List<int>? verifierChallengeNonce}): _verifierChallengeNonce = verifierChallengeNonce;
  

@override@JsonKey() final  bool isVerifyingProof;
@override final  String? verificationError;
/// 32-byte challenge from the peer's liveness check request
 final  List<int>? _verifierChallengeNonce;
/// 32-byte challenge from the peer's liveness check request
@override List<int>? get verifierChallengeNonce {
  final value = _verifierChallengeNonce;
  if (value == null) return null;
  if (_verifierChallengeNonce is EqualUnmodifiableListView) return _verifierChallengeNonce;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}


/// Create a copy of ProofFlowState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProofFlowStateCopyWith<_ProofFlowState> get copyWith => __$ProofFlowStateCopyWithImpl<_ProofFlowState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProofFlowState&&(identical(other.isVerifyingProof, isVerifyingProof) || other.isVerifyingProof == isVerifyingProof)&&(identical(other.verificationError, verificationError) || other.verificationError == verificationError)&&const DeepCollectionEquality().equals(other._verifierChallengeNonce, _verifierChallengeNonce));
}


@override
int get hashCode => Object.hash(runtimeType,isVerifyingProof,verificationError,const DeepCollectionEquality().hash(_verifierChallengeNonce));

@override
String toString() {
  return 'ProofFlowState(isVerifyingProof: $isVerifyingProof, verificationError: $verificationError, verifierChallengeNonce: $verifierChallengeNonce)';
}


}

/// @nodoc
abstract mixin class _$ProofFlowStateCopyWith<$Res> implements $ProofFlowStateCopyWith<$Res> {
  factory _$ProofFlowStateCopyWith(_ProofFlowState value, $Res Function(_ProofFlowState) _then) = __$ProofFlowStateCopyWithImpl;
@override @useResult
$Res call({
 bool isVerifyingProof, String? verificationError, List<int>? verifierChallengeNonce
});




}
/// @nodoc
class __$ProofFlowStateCopyWithImpl<$Res>
    implements _$ProofFlowStateCopyWith<$Res> {
  __$ProofFlowStateCopyWithImpl(this._self, this._then);

  final _ProofFlowState _self;
  final $Res Function(_ProofFlowState) _then;

/// Create a copy of ProofFlowState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? isVerifyingProof = null,Object? verificationError = freezed,Object? verifierChallengeNonce = freezed,}) {
  return _then(_ProofFlowState(
isVerifyingProof: null == isVerifyingProof ? _self.isVerifyingProof : isVerifyingProof // ignore: cast_nullable_to_non_nullable
as bool,verificationError: freezed == verificationError ? _self.verificationError : verificationError // ignore: cast_nullable_to_non_nullable
as String?,verifierChallengeNonce: freezed == verifierChallengeNonce ? _self._verifierChallengeNonce : verifierChallengeNonce // ignore: cast_nullable_to_non_nullable
as List<int>?,
  ));
}


}

// dart format on
