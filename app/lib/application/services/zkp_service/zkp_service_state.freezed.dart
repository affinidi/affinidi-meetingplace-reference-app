// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'zkp_service_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ZkpProofResult {

 String get proof; String get publicSignals; int get generationTimeMs;
/// Create a copy of ZkpProofResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ZkpProofResultCopyWith<ZkpProofResult> get copyWith => _$ZkpProofResultCopyWithImpl<ZkpProofResult>(this as ZkpProofResult, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ZkpProofResult&&(identical(other.proof, proof) || other.proof == proof)&&(identical(other.publicSignals, publicSignals) || other.publicSignals == publicSignals)&&(identical(other.generationTimeMs, generationTimeMs) || other.generationTimeMs == generationTimeMs));
}


@override
int get hashCode => Object.hash(runtimeType,proof,publicSignals,generationTimeMs);

@override
String toString() {
  return 'ZkpProofResult(proof: $proof, publicSignals: $publicSignals, generationTimeMs: $generationTimeMs)';
}


}

/// @nodoc
abstract mixin class $ZkpProofResultCopyWith<$Res>  {
  factory $ZkpProofResultCopyWith(ZkpProofResult value, $Res Function(ZkpProofResult) _then) = _$ZkpProofResultCopyWithImpl;
@useResult
$Res call({
 String proof, String publicSignals, int generationTimeMs
});




}
/// @nodoc
class _$ZkpProofResultCopyWithImpl<$Res>
    implements $ZkpProofResultCopyWith<$Res> {
  _$ZkpProofResultCopyWithImpl(this._self, this._then);

  final ZkpProofResult _self;
  final $Res Function(ZkpProofResult) _then;

/// Create a copy of ZkpProofResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? proof = null,Object? publicSignals = null,Object? generationTimeMs = null,}) {
  return _then(_self.copyWith(
proof: null == proof ? _self.proof : proof // ignore: cast_nullable_to_non_nullable
as String,publicSignals: null == publicSignals ? _self.publicSignals : publicSignals // ignore: cast_nullable_to_non_nullable
as String,generationTimeMs: null == generationTimeMs ? _self.generationTimeMs : generationTimeMs // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [ZkpProofResult].
extension ZkpProofResultPatterns on ZkpProofResult {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ZkpProofResult value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ZkpProofResult() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ZkpProofResult value)  $default,){
final _that = this;
switch (_that) {
case _ZkpProofResult():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ZkpProofResult value)?  $default,){
final _that = this;
switch (_that) {
case _ZkpProofResult() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String proof,  String publicSignals,  int generationTimeMs)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ZkpProofResult() when $default != null:
return $default(_that.proof,_that.publicSignals,_that.generationTimeMs);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String proof,  String publicSignals,  int generationTimeMs)  $default,) {final _that = this;
switch (_that) {
case _ZkpProofResult():
return $default(_that.proof,_that.publicSignals,_that.generationTimeMs);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String proof,  String publicSignals,  int generationTimeMs)?  $default,) {final _that = this;
switch (_that) {
case _ZkpProofResult() when $default != null:
return $default(_that.proof,_that.publicSignals,_that.generationTimeMs);case _:
  return null;

}
}

}

/// @nodoc


class _ZkpProofResult implements ZkpProofResult {
  const _ZkpProofResult({required this.proof, required this.publicSignals, required this.generationTimeMs});
  

@override final  String proof;
@override final  String publicSignals;
@override final  int generationTimeMs;

/// Create a copy of ZkpProofResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ZkpProofResultCopyWith<_ZkpProofResult> get copyWith => __$ZkpProofResultCopyWithImpl<_ZkpProofResult>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ZkpProofResult&&(identical(other.proof, proof) || other.proof == proof)&&(identical(other.publicSignals, publicSignals) || other.publicSignals == publicSignals)&&(identical(other.generationTimeMs, generationTimeMs) || other.generationTimeMs == generationTimeMs));
}


@override
int get hashCode => Object.hash(runtimeType,proof,publicSignals,generationTimeMs);

@override
String toString() {
  return 'ZkpProofResult(proof: $proof, publicSignals: $publicSignals, generationTimeMs: $generationTimeMs)';
}


}

/// @nodoc
abstract mixin class _$ZkpProofResultCopyWith<$Res> implements $ZkpProofResultCopyWith<$Res> {
  factory _$ZkpProofResultCopyWith(_ZkpProofResult value, $Res Function(_ZkpProofResult) _then) = __$ZkpProofResultCopyWithImpl;
@override @useResult
$Res call({
 String proof, String publicSignals, int generationTimeMs
});




}
/// @nodoc
class __$ZkpProofResultCopyWithImpl<$Res>
    implements _$ZkpProofResultCopyWith<$Res> {
  __$ZkpProofResultCopyWithImpl(this._self, this._then);

  final _ZkpProofResult _self;
  final $Res Function(_ZkpProofResult) _then;

/// Create a copy of ZkpProofResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? proof = null,Object? publicSignals = null,Object? generationTimeMs = null,}) {
  return _then(_ZkpProofResult(
proof: null == proof ? _self.proof : proof // ignore: cast_nullable_to_non_nullable
as String,publicSignals: null == publicSignals ? _self.publicSignals : publicSignals // ignore: cast_nullable_to_non_nullable
as String,generationTimeMs: null == generationTimeMs ? _self.generationTimeMs : generationTimeMs // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc
mixin _$ZkpVerificationResult {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ZkpVerificationResult);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ZkpVerificationResult()';
}


}

/// @nodoc
class $ZkpVerificationResultCopyWith<$Res>  {
$ZkpVerificationResultCopyWith(ZkpVerificationResult _, $Res Function(ZkpVerificationResult) __);
}


/// Adds pattern-matching-related methods to [ZkpVerificationResult].
extension ZkpVerificationResultPatterns on ZkpVerificationResult {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( ZkpVerificationSuccess value)?  success,TResult Function( ZkpVerificationFailure value)?  failure,required TResult orElse(),}){
final _that = this;
switch (_that) {
case ZkpVerificationSuccess() when success != null:
return success(_that);case ZkpVerificationFailure() when failure != null:
return failure(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( ZkpVerificationSuccess value)  success,required TResult Function( ZkpVerificationFailure value)  failure,}){
final _that = this;
switch (_that) {
case ZkpVerificationSuccess():
return success(_that);case ZkpVerificationFailure():
return failure(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( ZkpVerificationSuccess value)?  success,TResult? Function( ZkpVerificationFailure value)?  failure,}){
final _that = this;
switch (_that) {
case ZkpVerificationSuccess() when success != null:
return success(_that);case ZkpVerificationFailure() when failure != null:
return failure(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  success,TResult Function( String error)?  failure,required TResult orElse(),}) {final _that = this;
switch (_that) {
case ZkpVerificationSuccess() when success != null:
return success();case ZkpVerificationFailure() when failure != null:
return failure(_that.error);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  success,required TResult Function( String error)  failure,}) {final _that = this;
switch (_that) {
case ZkpVerificationSuccess():
return success();case ZkpVerificationFailure():
return failure(_that.error);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  success,TResult? Function( String error)?  failure,}) {final _that = this;
switch (_that) {
case ZkpVerificationSuccess() when success != null:
return success();case ZkpVerificationFailure() when failure != null:
return failure(_that.error);case _:
  return null;

}
}

}

/// @nodoc


class ZkpVerificationSuccess extends ZkpVerificationResult {
  const ZkpVerificationSuccess(): super._();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ZkpVerificationSuccess);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ZkpVerificationResult.success()';
}


}




/// @nodoc


class ZkpVerificationFailure extends ZkpVerificationResult {
  const ZkpVerificationFailure(this.error): super._();
  

 final  String error;

/// Create a copy of ZkpVerificationResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ZkpVerificationFailureCopyWith<ZkpVerificationFailure> get copyWith => _$ZkpVerificationFailureCopyWithImpl<ZkpVerificationFailure>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ZkpVerificationFailure&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode => Object.hash(runtimeType,error);

@override
String toString() {
  return 'ZkpVerificationResult.failure(error: $error)';
}


}

/// @nodoc
abstract mixin class $ZkpVerificationFailureCopyWith<$Res> implements $ZkpVerificationResultCopyWith<$Res> {
  factory $ZkpVerificationFailureCopyWith(ZkpVerificationFailure value, $Res Function(ZkpVerificationFailure) _then) = _$ZkpVerificationFailureCopyWithImpl;
@useResult
$Res call({
 String error
});




}
/// @nodoc
class _$ZkpVerificationFailureCopyWithImpl<$Res>
    implements $ZkpVerificationFailureCopyWith<$Res> {
  _$ZkpVerificationFailureCopyWithImpl(this._self, this._then);

  final ZkpVerificationFailure _self;
  final $Res Function(ZkpVerificationFailure) _then;

/// Create a copy of ZkpVerificationResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? error = null,}) {
  return _then(ZkpVerificationFailure(
null == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
