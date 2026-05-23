// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'vrc_credential.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$VrcCredential {

 String get id; String get vc; String get channelId; String get holderIdentityDid; String get issuerIdentityDid; DateTime get issuedAt; DateTime? get verifiedAt;
/// Create a copy of VrcCredential
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VrcCredentialCopyWith<VrcCredential> get copyWith => _$VrcCredentialCopyWithImpl<VrcCredential>(this as VrcCredential, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VrcCredential&&(identical(other.id, id) || other.id == id)&&(identical(other.vc, vc) || other.vc == vc)&&(identical(other.channelId, channelId) || other.channelId == channelId)&&(identical(other.holderIdentityDid, holderIdentityDid) || other.holderIdentityDid == holderIdentityDid)&&(identical(other.issuerIdentityDid, issuerIdentityDid) || other.issuerIdentityDid == issuerIdentityDid)&&(identical(other.issuedAt, issuedAt) || other.issuedAt == issuedAt)&&(identical(other.verifiedAt, verifiedAt) || other.verifiedAt == verifiedAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,vc,channelId,holderIdentityDid,issuerIdentityDid,issuedAt,verifiedAt);

@override
String toString() {
  return 'VrcCredential(id: $id, vc: $vc, channelId: $channelId, holderIdentityDid: $holderIdentityDid, issuerIdentityDid: $issuerIdentityDid, issuedAt: $issuedAt, verifiedAt: $verifiedAt)';
}


}

/// @nodoc
abstract mixin class $VrcCredentialCopyWith<$Res>  {
  factory $VrcCredentialCopyWith(VrcCredential value, $Res Function(VrcCredential) _then) = _$VrcCredentialCopyWithImpl;
@useResult
$Res call({
 String id, String vc, String channelId, String holderIdentityDid, String issuerIdentityDid, DateTime issuedAt, DateTime? verifiedAt
});




}
/// @nodoc
class _$VrcCredentialCopyWithImpl<$Res>
    implements $VrcCredentialCopyWith<$Res> {
  _$VrcCredentialCopyWithImpl(this._self, this._then);

  final VrcCredential _self;
  final $Res Function(VrcCredential) _then;

/// Create a copy of VrcCredential
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? vc = null,Object? channelId = null,Object? holderIdentityDid = null,Object? issuerIdentityDid = null,Object? issuedAt = null,Object? verifiedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,vc: null == vc ? _self.vc : vc // ignore: cast_nullable_to_non_nullable
as String,channelId: null == channelId ? _self.channelId : channelId // ignore: cast_nullable_to_non_nullable
as String,holderIdentityDid: null == holderIdentityDid ? _self.holderIdentityDid : holderIdentityDid // ignore: cast_nullable_to_non_nullable
as String,issuerIdentityDid: null == issuerIdentityDid ? _self.issuerIdentityDid : issuerIdentityDid // ignore: cast_nullable_to_non_nullable
as String,issuedAt: null == issuedAt ? _self.issuedAt : issuedAt // ignore: cast_nullable_to_non_nullable
as DateTime,verifiedAt: freezed == verifiedAt ? _self.verifiedAt : verifiedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [VrcCredential].
extension VrcCredentialPatterns on VrcCredential {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VrcCredential value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VrcCredential() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VrcCredential value)  $default,){
final _that = this;
switch (_that) {
case _VrcCredential():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VrcCredential value)?  $default,){
final _that = this;
switch (_that) {
case _VrcCredential() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String vc,  String channelId,  String holderIdentityDid,  String issuerIdentityDid,  DateTime issuedAt,  DateTime? verifiedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VrcCredential() when $default != null:
return $default(_that.id,_that.vc,_that.channelId,_that.holderIdentityDid,_that.issuerIdentityDid,_that.issuedAt,_that.verifiedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String vc,  String channelId,  String holderIdentityDid,  String issuerIdentityDid,  DateTime issuedAt,  DateTime? verifiedAt)  $default,) {final _that = this;
switch (_that) {
case _VrcCredential():
return $default(_that.id,_that.vc,_that.channelId,_that.holderIdentityDid,_that.issuerIdentityDid,_that.issuedAt,_that.verifiedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String vc,  String channelId,  String holderIdentityDid,  String issuerIdentityDid,  DateTime issuedAt,  DateTime? verifiedAt)?  $default,) {final _that = this;
switch (_that) {
case _VrcCredential() when $default != null:
return $default(_that.id,_that.vc,_that.channelId,_that.holderIdentityDid,_that.issuerIdentityDid,_that.issuedAt,_that.verifiedAt);case _:
  return null;

}
}

}

/// @nodoc


class _VrcCredential implements VrcCredential {
  const _VrcCredential({required this.id, required this.vc, required this.channelId, required this.holderIdentityDid, required this.issuerIdentityDid, required this.issuedAt, this.verifiedAt});
  

@override final  String id;
@override final  String vc;
@override final  String channelId;
@override final  String holderIdentityDid;
@override final  String issuerIdentityDid;
@override final  DateTime issuedAt;
@override final  DateTime? verifiedAt;

/// Create a copy of VrcCredential
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VrcCredentialCopyWith<_VrcCredential> get copyWith => __$VrcCredentialCopyWithImpl<_VrcCredential>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _VrcCredential&&(identical(other.id, id) || other.id == id)&&(identical(other.vc, vc) || other.vc == vc)&&(identical(other.channelId, channelId) || other.channelId == channelId)&&(identical(other.holderIdentityDid, holderIdentityDid) || other.holderIdentityDid == holderIdentityDid)&&(identical(other.issuerIdentityDid, issuerIdentityDid) || other.issuerIdentityDid == issuerIdentityDid)&&(identical(other.issuedAt, issuedAt) || other.issuedAt == issuedAt)&&(identical(other.verifiedAt, verifiedAt) || other.verifiedAt == verifiedAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,vc,channelId,holderIdentityDid,issuerIdentityDid,issuedAt,verifiedAt);

@override
String toString() {
  return 'VrcCredential(id: $id, vc: $vc, channelId: $channelId, holderIdentityDid: $holderIdentityDid, issuerIdentityDid: $issuerIdentityDid, issuedAt: $issuedAt, verifiedAt: $verifiedAt)';
}


}

/// @nodoc
abstract mixin class _$VrcCredentialCopyWith<$Res> implements $VrcCredentialCopyWith<$Res> {
  factory _$VrcCredentialCopyWith(_VrcCredential value, $Res Function(_VrcCredential) _then) = __$VrcCredentialCopyWithImpl;
@override @useResult
$Res call({
 String id, String vc, String channelId, String holderIdentityDid, String issuerIdentityDid, DateTime issuedAt, DateTime? verifiedAt
});




}
/// @nodoc
class __$VrcCredentialCopyWithImpl<$Res>
    implements _$VrcCredentialCopyWith<$Res> {
  __$VrcCredentialCopyWithImpl(this._self, this._then);

  final _VrcCredential _self;
  final $Res Function(_VrcCredential) _then;

/// Create a copy of VrcCredential
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? vc = null,Object? channelId = null,Object? holderIdentityDid = null,Object? issuerIdentityDid = null,Object? issuedAt = null,Object? verifiedAt = freezed,}) {
  return _then(_VrcCredential(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,vc: null == vc ? _self.vc : vc // ignore: cast_nullable_to_non_nullable
as String,channelId: null == channelId ? _self.channelId : channelId // ignore: cast_nullable_to_non_nullable
as String,holderIdentityDid: null == holderIdentityDid ? _self.holderIdentityDid : holderIdentityDid // ignore: cast_nullable_to_non_nullable
as String,issuerIdentityDid: null == issuerIdentityDid ? _self.issuerIdentityDid : issuerIdentityDid // ignore: cast_nullable_to_non_nullable
as String,issuedAt: null == issuedAt ? _self.issuedAt : issuedAt // ignore: cast_nullable_to_non_nullable
as DateTime,verifiedAt: freezed == verifiedAt ? _self.verifiedAt : verifiedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
