// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'deployment_result.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DeploymentResult {

 String get vcId; String get agentDid; String get systemPromptHash; int get trainedOnMessages;
/// Create a copy of DeploymentResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DeploymentResultCopyWith<DeploymentResult> get copyWith => _$DeploymentResultCopyWithImpl<DeploymentResult>(this as DeploymentResult, _$identity);

  /// Serializes this DeploymentResult to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DeploymentResult&&(identical(other.vcId, vcId) || other.vcId == vcId)&&(identical(other.agentDid, agentDid) || other.agentDid == agentDid)&&(identical(other.systemPromptHash, systemPromptHash) || other.systemPromptHash == systemPromptHash)&&(identical(other.trainedOnMessages, trainedOnMessages) || other.trainedOnMessages == trainedOnMessages));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,vcId,agentDid,systemPromptHash,trainedOnMessages);

@override
String toString() {
  return 'DeploymentResult(vcId: $vcId, agentDid: $agentDid, systemPromptHash: $systemPromptHash, trainedOnMessages: $trainedOnMessages)';
}


}

/// @nodoc
abstract mixin class $DeploymentResultCopyWith<$Res>  {
  factory $DeploymentResultCopyWith(DeploymentResult value, $Res Function(DeploymentResult) _then) = _$DeploymentResultCopyWithImpl;
@useResult
$Res call({
 String vcId, String agentDid, String systemPromptHash, int trainedOnMessages
});




}
/// @nodoc
class _$DeploymentResultCopyWithImpl<$Res>
    implements $DeploymentResultCopyWith<$Res> {
  _$DeploymentResultCopyWithImpl(this._self, this._then);

  final DeploymentResult _self;
  final $Res Function(DeploymentResult) _then;

/// Create a copy of DeploymentResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? vcId = null,Object? agentDid = null,Object? systemPromptHash = null,Object? trainedOnMessages = null,}) {
  return _then(_self.copyWith(
vcId: null == vcId ? _self.vcId : vcId // ignore: cast_nullable_to_non_nullable
as String,agentDid: null == agentDid ? _self.agentDid : agentDid // ignore: cast_nullable_to_non_nullable
as String,systemPromptHash: null == systemPromptHash ? _self.systemPromptHash : systemPromptHash // ignore: cast_nullable_to_non_nullable
as String,trainedOnMessages: null == trainedOnMessages ? _self.trainedOnMessages : trainedOnMessages // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [DeploymentResult].
extension DeploymentResultPatterns on DeploymentResult {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DeploymentResult value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DeploymentResult() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DeploymentResult value)  $default,){
final _that = this;
switch (_that) {
case _DeploymentResult():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DeploymentResult value)?  $default,){
final _that = this;
switch (_that) {
case _DeploymentResult() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String vcId,  String agentDid,  String systemPromptHash,  int trainedOnMessages)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DeploymentResult() when $default != null:
return $default(_that.vcId,_that.agentDid,_that.systemPromptHash,_that.trainedOnMessages);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String vcId,  String agentDid,  String systemPromptHash,  int trainedOnMessages)  $default,) {final _that = this;
switch (_that) {
case _DeploymentResult():
return $default(_that.vcId,_that.agentDid,_that.systemPromptHash,_that.trainedOnMessages);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String vcId,  String agentDid,  String systemPromptHash,  int trainedOnMessages)?  $default,) {final _that = this;
switch (_that) {
case _DeploymentResult() when $default != null:
return $default(_that.vcId,_that.agentDid,_that.systemPromptHash,_that.trainedOnMessages);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DeploymentResult implements DeploymentResult {
  const _DeploymentResult({required this.vcId, required this.agentDid, required this.systemPromptHash, required this.trainedOnMessages});
  factory _DeploymentResult.fromJson(Map<String, dynamic> json) => _$DeploymentResultFromJson(json);

@override final  String vcId;
@override final  String agentDid;
@override final  String systemPromptHash;
@override final  int trainedOnMessages;

/// Create a copy of DeploymentResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DeploymentResultCopyWith<_DeploymentResult> get copyWith => __$DeploymentResultCopyWithImpl<_DeploymentResult>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DeploymentResultToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DeploymentResult&&(identical(other.vcId, vcId) || other.vcId == vcId)&&(identical(other.agentDid, agentDid) || other.agentDid == agentDid)&&(identical(other.systemPromptHash, systemPromptHash) || other.systemPromptHash == systemPromptHash)&&(identical(other.trainedOnMessages, trainedOnMessages) || other.trainedOnMessages == trainedOnMessages));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,vcId,agentDid,systemPromptHash,trainedOnMessages);

@override
String toString() {
  return 'DeploymentResult(vcId: $vcId, agentDid: $agentDid, systemPromptHash: $systemPromptHash, trainedOnMessages: $trainedOnMessages)';
}


}

/// @nodoc
abstract mixin class _$DeploymentResultCopyWith<$Res> implements $DeploymentResultCopyWith<$Res> {
  factory _$DeploymentResultCopyWith(_DeploymentResult value, $Res Function(_DeploymentResult) _then) = __$DeploymentResultCopyWithImpl;
@override @useResult
$Res call({
 String vcId, String agentDid, String systemPromptHash, int trainedOnMessages
});




}
/// @nodoc
class __$DeploymentResultCopyWithImpl<$Res>
    implements _$DeploymentResultCopyWith<$Res> {
  __$DeploymentResultCopyWithImpl(this._self, this._then);

  final _DeploymentResult _self;
  final $Res Function(_DeploymentResult) _then;

/// Create a copy of DeploymentResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? vcId = null,Object? agentDid = null,Object? systemPromptHash = null,Object? trainedOnMessages = null,}) {
  return _then(_DeploymentResult(
vcId: null == vcId ? _self.vcId : vcId // ignore: cast_nullable_to_non_nullable
as String,agentDid: null == agentDid ? _self.agentDid : agentDid // ignore: cast_nullable_to_non_nullable
as String,systemPromptHash: null == systemPromptHash ? _self.systemPromptHash : systemPromptHash // ignore: cast_nullable_to_non_nullable
as String,trainedOnMessages: null == trainedOnMessages ? _self.trainedOnMessages : trainedOnMessages // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
