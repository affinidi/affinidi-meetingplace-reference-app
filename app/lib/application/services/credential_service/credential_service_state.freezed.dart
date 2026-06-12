// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'credential_service_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CredentialServiceState {

 Map<String, LivenessCredentialRecord> get credentialsByIdentityId; Map<String, SessionCredentialMaterial> get sessionMaterialByIdentityId; CredentialData? get latestCredential;
/// Create a copy of CredentialServiceState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CredentialServiceStateCopyWith<CredentialServiceState> get copyWith => _$CredentialServiceStateCopyWithImpl<CredentialServiceState>(this as CredentialServiceState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CredentialServiceState&&const DeepCollectionEquality().equals(other.credentialsByIdentityId, credentialsByIdentityId)&&const DeepCollectionEquality().equals(other.sessionMaterialByIdentityId, sessionMaterialByIdentityId)&&(identical(other.latestCredential, latestCredential) || other.latestCredential == latestCredential));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(credentialsByIdentityId),const DeepCollectionEquality().hash(sessionMaterialByIdentityId),latestCredential);

@override
String toString() {
  return 'CredentialServiceState(credentialsByIdentityId: $credentialsByIdentityId, sessionMaterialByIdentityId: $sessionMaterialByIdentityId, latestCredential: $latestCredential)';
}


}

/// @nodoc
abstract mixin class $CredentialServiceStateCopyWith<$Res>  {
  factory $CredentialServiceStateCopyWith(CredentialServiceState value, $Res Function(CredentialServiceState) _then) = _$CredentialServiceStateCopyWithImpl;
@useResult
$Res call({
 Map<String, LivenessCredentialRecord> credentialsByIdentityId, Map<String, SessionCredentialMaterial> sessionMaterialByIdentityId, CredentialData? latestCredential
});


$CredentialDataCopyWith<$Res>? get latestCredential;

}
/// @nodoc
class _$CredentialServiceStateCopyWithImpl<$Res>
    implements $CredentialServiceStateCopyWith<$Res> {
  _$CredentialServiceStateCopyWithImpl(this._self, this._then);

  final CredentialServiceState _self;
  final $Res Function(CredentialServiceState) _then;

/// Create a copy of CredentialServiceState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? credentialsByIdentityId = null,Object? sessionMaterialByIdentityId = null,Object? latestCredential = freezed,}) {
  return _then(_self.copyWith(
credentialsByIdentityId: null == credentialsByIdentityId ? _self.credentialsByIdentityId : credentialsByIdentityId // ignore: cast_nullable_to_non_nullable
as Map<String, LivenessCredentialRecord>,sessionMaterialByIdentityId: null == sessionMaterialByIdentityId ? _self.sessionMaterialByIdentityId : sessionMaterialByIdentityId // ignore: cast_nullable_to_non_nullable
as Map<String, SessionCredentialMaterial>,latestCredential: freezed == latestCredential ? _self.latestCredential : latestCredential // ignore: cast_nullable_to_non_nullable
as CredentialData?,
  ));
}
/// Create a copy of CredentialServiceState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CredentialDataCopyWith<$Res>? get latestCredential {
    if (_self.latestCredential == null) {
    return null;
  }

  return $CredentialDataCopyWith<$Res>(_self.latestCredential!, (value) {
    return _then(_self.copyWith(latestCredential: value));
  });
}
}


/// Adds pattern-matching-related methods to [CredentialServiceState].
extension CredentialServiceStatePatterns on CredentialServiceState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CredentialServiceState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CredentialServiceState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CredentialServiceState value)  $default,){
final _that = this;
switch (_that) {
case _CredentialServiceState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CredentialServiceState value)?  $default,){
final _that = this;
switch (_that) {
case _CredentialServiceState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Map<String, LivenessCredentialRecord> credentialsByIdentityId,  Map<String, SessionCredentialMaterial> sessionMaterialByIdentityId,  CredentialData? latestCredential)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CredentialServiceState() when $default != null:
return $default(_that.credentialsByIdentityId,_that.sessionMaterialByIdentityId,_that.latestCredential);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Map<String, LivenessCredentialRecord> credentialsByIdentityId,  Map<String, SessionCredentialMaterial> sessionMaterialByIdentityId,  CredentialData? latestCredential)  $default,) {final _that = this;
switch (_that) {
case _CredentialServiceState():
return $default(_that.credentialsByIdentityId,_that.sessionMaterialByIdentityId,_that.latestCredential);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Map<String, LivenessCredentialRecord> credentialsByIdentityId,  Map<String, SessionCredentialMaterial> sessionMaterialByIdentityId,  CredentialData? latestCredential)?  $default,) {final _that = this;
switch (_that) {
case _CredentialServiceState() when $default != null:
return $default(_that.credentialsByIdentityId,_that.sessionMaterialByIdentityId,_that.latestCredential);case _:
  return null;

}
}

}

/// @nodoc


class _CredentialServiceState implements CredentialServiceState {
  const _CredentialServiceState({final  Map<String, LivenessCredentialRecord> credentialsByIdentityId = const {}, final  Map<String, SessionCredentialMaterial> sessionMaterialByIdentityId = const {}, this.latestCredential}): _credentialsByIdentityId = credentialsByIdentityId,_sessionMaterialByIdentityId = sessionMaterialByIdentityId;
  

 final  Map<String, LivenessCredentialRecord> _credentialsByIdentityId;
@override@JsonKey() Map<String, LivenessCredentialRecord> get credentialsByIdentityId {
  if (_credentialsByIdentityId is EqualUnmodifiableMapView) return _credentialsByIdentityId;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_credentialsByIdentityId);
}

 final  Map<String, SessionCredentialMaterial> _sessionMaterialByIdentityId;
@override@JsonKey() Map<String, SessionCredentialMaterial> get sessionMaterialByIdentityId {
  if (_sessionMaterialByIdentityId is EqualUnmodifiableMapView) return _sessionMaterialByIdentityId;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_sessionMaterialByIdentityId);
}

@override final  CredentialData? latestCredential;

/// Create a copy of CredentialServiceState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CredentialServiceStateCopyWith<_CredentialServiceState> get copyWith => __$CredentialServiceStateCopyWithImpl<_CredentialServiceState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CredentialServiceState&&const DeepCollectionEquality().equals(other._credentialsByIdentityId, _credentialsByIdentityId)&&const DeepCollectionEquality().equals(other._sessionMaterialByIdentityId, _sessionMaterialByIdentityId)&&(identical(other.latestCredential, latestCredential) || other.latestCredential == latestCredential));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_credentialsByIdentityId),const DeepCollectionEquality().hash(_sessionMaterialByIdentityId),latestCredential);

@override
String toString() {
  return 'CredentialServiceState(credentialsByIdentityId: $credentialsByIdentityId, sessionMaterialByIdentityId: $sessionMaterialByIdentityId, latestCredential: $latestCredential)';
}


}

/// @nodoc
abstract mixin class _$CredentialServiceStateCopyWith<$Res> implements $CredentialServiceStateCopyWith<$Res> {
  factory _$CredentialServiceStateCopyWith(_CredentialServiceState value, $Res Function(_CredentialServiceState) _then) = __$CredentialServiceStateCopyWithImpl;
@override @useResult
$Res call({
 Map<String, LivenessCredentialRecord> credentialsByIdentityId, Map<String, SessionCredentialMaterial> sessionMaterialByIdentityId, CredentialData? latestCredential
});


@override $CredentialDataCopyWith<$Res>? get latestCredential;

}
/// @nodoc
class __$CredentialServiceStateCopyWithImpl<$Res>
    implements _$CredentialServiceStateCopyWith<$Res> {
  __$CredentialServiceStateCopyWithImpl(this._self, this._then);

  final _CredentialServiceState _self;
  final $Res Function(_CredentialServiceState) _then;

/// Create a copy of CredentialServiceState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? credentialsByIdentityId = null,Object? sessionMaterialByIdentityId = null,Object? latestCredential = freezed,}) {
  return _then(_CredentialServiceState(
credentialsByIdentityId: null == credentialsByIdentityId ? _self._credentialsByIdentityId : credentialsByIdentityId // ignore: cast_nullable_to_non_nullable
as Map<String, LivenessCredentialRecord>,sessionMaterialByIdentityId: null == sessionMaterialByIdentityId ? _self._sessionMaterialByIdentityId : sessionMaterialByIdentityId // ignore: cast_nullable_to_non_nullable
as Map<String, SessionCredentialMaterial>,latestCredential: freezed == latestCredential ? _self.latestCredential : latestCredential // ignore: cast_nullable_to_non_nullable
as CredentialData?,
  ));
}

/// Create a copy of CredentialServiceState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CredentialDataCopyWith<$Res>? get latestCredential {
    if (_self.latestCredential == null) {
    return null;
  }

  return $CredentialDataCopyWith<$Res>(_self.latestCredential!, (value) {
    return _then(_self.copyWith(latestCredential: value));
  });
}
}

// dart format on
