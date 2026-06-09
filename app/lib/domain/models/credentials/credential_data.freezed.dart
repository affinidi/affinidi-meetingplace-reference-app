// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'credential_data.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CredentialData {

 String get identityId; String get w3cCredentialJson; String get issuerName; DateTime get issuedAt; DateTime get expiresAt; String get holderDid;
/// Create a copy of CredentialData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CredentialDataCopyWith<CredentialData> get copyWith => _$CredentialDataCopyWithImpl<CredentialData>(this as CredentialData, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CredentialData&&(identical(other.identityId, identityId) || other.identityId == identityId)&&(identical(other.w3cCredentialJson, w3cCredentialJson) || other.w3cCredentialJson == w3cCredentialJson)&&(identical(other.issuerName, issuerName) || other.issuerName == issuerName)&&(identical(other.issuedAt, issuedAt) || other.issuedAt == issuedAt)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&(identical(other.holderDid, holderDid) || other.holderDid == holderDid));
}


@override
int get hashCode => Object.hash(runtimeType,identityId,w3cCredentialJson,issuerName,issuedAt,expiresAt,holderDid);

@override
String toString() {
  return 'CredentialData(identityId: $identityId, w3cCredentialJson: $w3cCredentialJson, issuerName: $issuerName, issuedAt: $issuedAt, expiresAt: $expiresAt, holderDid: $holderDid)';
}


}

/// @nodoc
abstract mixin class $CredentialDataCopyWith<$Res>  {
  factory $CredentialDataCopyWith(CredentialData value, $Res Function(CredentialData) _then) = _$CredentialDataCopyWithImpl;
@useResult
$Res call({
 String identityId, String w3cCredentialJson, String issuerName, DateTime issuedAt, DateTime expiresAt, String holderDid
});




}
/// @nodoc
class _$CredentialDataCopyWithImpl<$Res>
    implements $CredentialDataCopyWith<$Res> {
  _$CredentialDataCopyWithImpl(this._self, this._then);

  final CredentialData _self;
  final $Res Function(CredentialData) _then;

/// Create a copy of CredentialData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? identityId = null,Object? w3cCredentialJson = null,Object? issuerName = null,Object? issuedAt = null,Object? expiresAt = null,Object? holderDid = null,}) {
  return _then(_self.copyWith(
identityId: null == identityId ? _self.identityId : identityId // ignore: cast_nullable_to_non_nullable
as String,w3cCredentialJson: null == w3cCredentialJson ? _self.w3cCredentialJson : w3cCredentialJson // ignore: cast_nullable_to_non_nullable
as String,issuerName: null == issuerName ? _self.issuerName : issuerName // ignore: cast_nullable_to_non_nullable
as String,issuedAt: null == issuedAt ? _self.issuedAt : issuedAt // ignore: cast_nullable_to_non_nullable
as DateTime,expiresAt: null == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime,holderDid: null == holderDid ? _self.holderDid : holderDid // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [CredentialData].
extension CredentialDataPatterns on CredentialData {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CredentialData value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CredentialData() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CredentialData value)  $default,){
final _that = this;
switch (_that) {
case _CredentialData():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CredentialData value)?  $default,){
final _that = this;
switch (_that) {
case _CredentialData() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String identityId,  String w3cCredentialJson,  String issuerName,  DateTime issuedAt,  DateTime expiresAt,  String holderDid)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CredentialData() when $default != null:
return $default(_that.identityId,_that.w3cCredentialJson,_that.issuerName,_that.issuedAt,_that.expiresAt,_that.holderDid);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String identityId,  String w3cCredentialJson,  String issuerName,  DateTime issuedAt,  DateTime expiresAt,  String holderDid)  $default,) {final _that = this;
switch (_that) {
case _CredentialData():
return $default(_that.identityId,_that.w3cCredentialJson,_that.issuerName,_that.issuedAt,_that.expiresAt,_that.holderDid);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String identityId,  String w3cCredentialJson,  String issuerName,  DateTime issuedAt,  DateTime expiresAt,  String holderDid)?  $default,) {final _that = this;
switch (_that) {
case _CredentialData() when $default != null:
return $default(_that.identityId,_that.w3cCredentialJson,_that.issuerName,_that.issuedAt,_that.expiresAt,_that.holderDid);case _:
  return null;

}
}

}

/// @nodoc


class _CredentialData implements CredentialData {
  const _CredentialData({required this.identityId, required this.w3cCredentialJson, required this.issuerName, required this.issuedAt, required this.expiresAt, required this.holderDid});
  

@override final  String identityId;
@override final  String w3cCredentialJson;
@override final  String issuerName;
@override final  DateTime issuedAt;
@override final  DateTime expiresAt;
@override final  String holderDid;

/// Create a copy of CredentialData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CredentialDataCopyWith<_CredentialData> get copyWith => __$CredentialDataCopyWithImpl<_CredentialData>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CredentialData&&(identical(other.identityId, identityId) || other.identityId == identityId)&&(identical(other.w3cCredentialJson, w3cCredentialJson) || other.w3cCredentialJson == w3cCredentialJson)&&(identical(other.issuerName, issuerName) || other.issuerName == issuerName)&&(identical(other.issuedAt, issuedAt) || other.issuedAt == issuedAt)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&(identical(other.holderDid, holderDid) || other.holderDid == holderDid));
}


@override
int get hashCode => Object.hash(runtimeType,identityId,w3cCredentialJson,issuerName,issuedAt,expiresAt,holderDid);

@override
String toString() {
  return 'CredentialData(identityId: $identityId, w3cCredentialJson: $w3cCredentialJson, issuerName: $issuerName, issuedAt: $issuedAt, expiresAt: $expiresAt, holderDid: $holderDid)';
}


}

/// @nodoc
abstract mixin class _$CredentialDataCopyWith<$Res> implements $CredentialDataCopyWith<$Res> {
  factory _$CredentialDataCopyWith(_CredentialData value, $Res Function(_CredentialData) _then) = __$CredentialDataCopyWithImpl;
@override @useResult
$Res call({
 String identityId, String w3cCredentialJson, String issuerName, DateTime issuedAt, DateTime expiresAt, String holderDid
});




}
/// @nodoc
class __$CredentialDataCopyWithImpl<$Res>
    implements _$CredentialDataCopyWith<$Res> {
  __$CredentialDataCopyWithImpl(this._self, this._then);

  final _CredentialData _self;
  final $Res Function(_CredentialData) _then;

/// Create a copy of CredentialData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? identityId = null,Object? w3cCredentialJson = null,Object? issuerName = null,Object? issuedAt = null,Object? expiresAt = null,Object? holderDid = null,}) {
  return _then(_CredentialData(
identityId: null == identityId ? _self.identityId : identityId // ignore: cast_nullable_to_non_nullable
as String,w3cCredentialJson: null == w3cCredentialJson ? _self.w3cCredentialJson : w3cCredentialJson // ignore: cast_nullable_to_non_nullable
as String,issuerName: null == issuerName ? _self.issuerName : issuerName // ignore: cast_nullable_to_non_nullable
as String,issuedAt: null == issuedAt ? _self.issuedAt : issuedAt // ignore: cast_nullable_to_non_nullable
as DateTime,expiresAt: null == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime,holderDid: null == holderDid ? _self.holderDid : holderDid // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
