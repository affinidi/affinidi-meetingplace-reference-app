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

 VtcJoinStep get step; String? get communityName; bool get canApply; bool get admitsAtOnce; bool get wasMember;/// The ways into the community, in its order.
 List<VtcJoinWay> get ways;/// The profile details the community asks for.
 List<JoinAttributeRequest> get requestedDetails;/// Whether the community lists new members in its directory, or null
/// when it does not say.
 bool? get listsNewMembers;/// Whether the member opted in to the member directory. Off by default.
 bool get listInDirectory;/// The identities on the member's VTA to join with, as DIDs.
 List<String> get identityChoices; VtcJoinFailure? get failure;
/// Create a copy of VtcJoinState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VtcJoinStateCopyWith<VtcJoinState> get copyWith => _$VtcJoinStateCopyWithImpl<VtcJoinState>(this as VtcJoinState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VtcJoinState&&(identical(other.step, step) || other.step == step)&&(identical(other.communityName, communityName) || other.communityName == communityName)&&(identical(other.canApply, canApply) || other.canApply == canApply)&&(identical(other.admitsAtOnce, admitsAtOnce) || other.admitsAtOnce == admitsAtOnce)&&(identical(other.wasMember, wasMember) || other.wasMember == wasMember)&&const DeepCollectionEquality().equals(other.ways, ways)&&const DeepCollectionEquality().equals(other.requestedDetails, requestedDetails)&&(identical(other.listsNewMembers, listsNewMembers) || other.listsNewMembers == listsNewMembers)&&(identical(other.listInDirectory, listInDirectory) || other.listInDirectory == listInDirectory)&&const DeepCollectionEquality().equals(other.identityChoices, identityChoices)&&(identical(other.failure, failure) || other.failure == failure));
}


@override
int get hashCode => Object.hash(runtimeType,step,communityName,canApply,admitsAtOnce,wasMember,const DeepCollectionEquality().hash(ways),const DeepCollectionEquality().hash(requestedDetails),listsNewMembers,listInDirectory,const DeepCollectionEquality().hash(identityChoices),failure);

@override
String toString() {
  return 'VtcJoinState(step: $step, communityName: $communityName, canApply: $canApply, admitsAtOnce: $admitsAtOnce, wasMember: $wasMember, ways: $ways, requestedDetails: $requestedDetails, listsNewMembers: $listsNewMembers, listInDirectory: $listInDirectory, identityChoices: $identityChoices, failure: $failure)';
}


}

/// @nodoc
abstract mixin class $VtcJoinStateCopyWith<$Res>  {
  factory $VtcJoinStateCopyWith(VtcJoinState value, $Res Function(VtcJoinState) _then) = _$VtcJoinStateCopyWithImpl;
@useResult
$Res call({
 VtcJoinStep step, String? communityName, bool canApply, bool admitsAtOnce, bool wasMember, List<VtcJoinWay> ways, List<JoinAttributeRequest> requestedDetails, bool? listsNewMembers, bool listInDirectory, List<String> identityChoices, VtcJoinFailure? failure
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
@pragma('vm:prefer-inline') @override $Res call({Object? step = null,Object? communityName = freezed,Object? canApply = null,Object? admitsAtOnce = null,Object? wasMember = null,Object? ways = null,Object? requestedDetails = null,Object? listsNewMembers = freezed,Object? listInDirectory = null,Object? identityChoices = null,Object? failure = freezed,}) {
  return _then(_self.copyWith(
step: null == step ? _self.step : step // ignore: cast_nullable_to_non_nullable
as VtcJoinStep,communityName: freezed == communityName ? _self.communityName : communityName // ignore: cast_nullable_to_non_nullable
as String?,canApply: null == canApply ? _self.canApply : canApply // ignore: cast_nullable_to_non_nullable
as bool,admitsAtOnce: null == admitsAtOnce ? _self.admitsAtOnce : admitsAtOnce // ignore: cast_nullable_to_non_nullable
as bool,wasMember: null == wasMember ? _self.wasMember : wasMember // ignore: cast_nullable_to_non_nullable
as bool,ways: null == ways ? _self.ways : ways // ignore: cast_nullable_to_non_nullable
as List<VtcJoinWay>,requestedDetails: null == requestedDetails ? _self.requestedDetails : requestedDetails // ignore: cast_nullable_to_non_nullable
as List<JoinAttributeRequest>,listsNewMembers: freezed == listsNewMembers ? _self.listsNewMembers : listsNewMembers // ignore: cast_nullable_to_non_nullable
as bool?,listInDirectory: null == listInDirectory ? _self.listInDirectory : listInDirectory // ignore: cast_nullable_to_non_nullable
as bool,identityChoices: null == identityChoices ? _self.identityChoices : identityChoices // ignore: cast_nullable_to_non_nullable
as List<String>,failure: freezed == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( VtcJoinStep step,  String? communityName,  bool canApply,  bool admitsAtOnce,  bool wasMember,  List<VtcJoinWay> ways,  List<JoinAttributeRequest> requestedDetails,  bool? listsNewMembers,  bool listInDirectory,  List<String> identityChoices,  VtcJoinFailure? failure)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VtcJoinState() when $default != null:
return $default(_that.step,_that.communityName,_that.canApply,_that.admitsAtOnce,_that.wasMember,_that.ways,_that.requestedDetails,_that.listsNewMembers,_that.listInDirectory,_that.identityChoices,_that.failure);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( VtcJoinStep step,  String? communityName,  bool canApply,  bool admitsAtOnce,  bool wasMember,  List<VtcJoinWay> ways,  List<JoinAttributeRequest> requestedDetails,  bool? listsNewMembers,  bool listInDirectory,  List<String> identityChoices,  VtcJoinFailure? failure)  $default,) {final _that = this;
switch (_that) {
case _VtcJoinState():
return $default(_that.step,_that.communityName,_that.canApply,_that.admitsAtOnce,_that.wasMember,_that.ways,_that.requestedDetails,_that.listsNewMembers,_that.listInDirectory,_that.identityChoices,_that.failure);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( VtcJoinStep step,  String? communityName,  bool canApply,  bool admitsAtOnce,  bool wasMember,  List<VtcJoinWay> ways,  List<JoinAttributeRequest> requestedDetails,  bool? listsNewMembers,  bool listInDirectory,  List<String> identityChoices,  VtcJoinFailure? failure)?  $default,) {final _that = this;
switch (_that) {
case _VtcJoinState() when $default != null:
return $default(_that.step,_that.communityName,_that.canApply,_that.admitsAtOnce,_that.wasMember,_that.ways,_that.requestedDetails,_that.listsNewMembers,_that.listInDirectory,_that.identityChoices,_that.failure);case _:
  return null;

}
}

}

/// @nodoc


class _VtcJoinState implements VtcJoinState {
   _VtcJoinState({this.step = VtcJoinStep.scanning, this.communityName, this.canApply = false, this.admitsAtOnce = false, this.wasMember = false, final  List<VtcJoinWay> ways = const <VtcJoinWay>[], final  List<JoinAttributeRequest> requestedDetails = const <JoinAttributeRequest>[], this.listsNewMembers, this.listInDirectory = false, final  List<String> identityChoices = const <String>[], this.failure}): _ways = ways,_requestedDetails = requestedDetails,_identityChoices = identityChoices;
  

@override@JsonKey() final  VtcJoinStep step;
@override final  String? communityName;
@override@JsonKey() final  bool canApply;
@override@JsonKey() final  bool admitsAtOnce;
@override@JsonKey() final  bool wasMember;
/// The ways into the community, in its order.
 final  List<VtcJoinWay> _ways;
/// The ways into the community, in its order.
@override@JsonKey() List<VtcJoinWay> get ways {
  if (_ways is EqualUnmodifiableListView) return _ways;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_ways);
}

/// The profile details the community asks for.
 final  List<JoinAttributeRequest> _requestedDetails;
/// The profile details the community asks for.
@override@JsonKey() List<JoinAttributeRequest> get requestedDetails {
  if (_requestedDetails is EqualUnmodifiableListView) return _requestedDetails;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_requestedDetails);
}

/// Whether the community lists new members in its directory, or null
/// when it does not say.
@override final  bool? listsNewMembers;
/// Whether the member opted in to the member directory. Off by default.
@override@JsonKey() final  bool listInDirectory;
/// The identities on the member's VTA to join with, as DIDs.
 final  List<String> _identityChoices;
/// The identities on the member's VTA to join with, as DIDs.
@override@JsonKey() List<String> get identityChoices {
  if (_identityChoices is EqualUnmodifiableListView) return _identityChoices;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_identityChoices);
}

@override final  VtcJoinFailure? failure;

/// Create a copy of VtcJoinState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VtcJoinStateCopyWith<_VtcJoinState> get copyWith => __$VtcJoinStateCopyWithImpl<_VtcJoinState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _VtcJoinState&&(identical(other.step, step) || other.step == step)&&(identical(other.communityName, communityName) || other.communityName == communityName)&&(identical(other.canApply, canApply) || other.canApply == canApply)&&(identical(other.admitsAtOnce, admitsAtOnce) || other.admitsAtOnce == admitsAtOnce)&&(identical(other.wasMember, wasMember) || other.wasMember == wasMember)&&const DeepCollectionEquality().equals(other._ways, _ways)&&const DeepCollectionEquality().equals(other._requestedDetails, _requestedDetails)&&(identical(other.listsNewMembers, listsNewMembers) || other.listsNewMembers == listsNewMembers)&&(identical(other.listInDirectory, listInDirectory) || other.listInDirectory == listInDirectory)&&const DeepCollectionEquality().equals(other._identityChoices, _identityChoices)&&(identical(other.failure, failure) || other.failure == failure));
}


@override
int get hashCode => Object.hash(runtimeType,step,communityName,canApply,admitsAtOnce,wasMember,const DeepCollectionEquality().hash(_ways),const DeepCollectionEquality().hash(_requestedDetails),listsNewMembers,listInDirectory,const DeepCollectionEquality().hash(_identityChoices),failure);

@override
String toString() {
  return 'VtcJoinState(step: $step, communityName: $communityName, canApply: $canApply, admitsAtOnce: $admitsAtOnce, wasMember: $wasMember, ways: $ways, requestedDetails: $requestedDetails, listsNewMembers: $listsNewMembers, listInDirectory: $listInDirectory, identityChoices: $identityChoices, failure: $failure)';
}


}

/// @nodoc
abstract mixin class _$VtcJoinStateCopyWith<$Res> implements $VtcJoinStateCopyWith<$Res> {
  factory _$VtcJoinStateCopyWith(_VtcJoinState value, $Res Function(_VtcJoinState) _then) = __$VtcJoinStateCopyWithImpl;
@override @useResult
$Res call({
 VtcJoinStep step, String? communityName, bool canApply, bool admitsAtOnce, bool wasMember, List<VtcJoinWay> ways, List<JoinAttributeRequest> requestedDetails, bool? listsNewMembers, bool listInDirectory, List<String> identityChoices, VtcJoinFailure? failure
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
@override @pragma('vm:prefer-inline') $Res call({Object? step = null,Object? communityName = freezed,Object? canApply = null,Object? admitsAtOnce = null,Object? wasMember = null,Object? ways = null,Object? requestedDetails = null,Object? listsNewMembers = freezed,Object? listInDirectory = null,Object? identityChoices = null,Object? failure = freezed,}) {
  return _then(_VtcJoinState(
step: null == step ? _self.step : step // ignore: cast_nullable_to_non_nullable
as VtcJoinStep,communityName: freezed == communityName ? _self.communityName : communityName // ignore: cast_nullable_to_non_nullable
as String?,canApply: null == canApply ? _self.canApply : canApply // ignore: cast_nullable_to_non_nullable
as bool,admitsAtOnce: null == admitsAtOnce ? _self.admitsAtOnce : admitsAtOnce // ignore: cast_nullable_to_non_nullable
as bool,wasMember: null == wasMember ? _self.wasMember : wasMember // ignore: cast_nullable_to_non_nullable
as bool,ways: null == ways ? _self._ways : ways // ignore: cast_nullable_to_non_nullable
as List<VtcJoinWay>,requestedDetails: null == requestedDetails ? _self._requestedDetails : requestedDetails // ignore: cast_nullable_to_non_nullable
as List<JoinAttributeRequest>,listsNewMembers: freezed == listsNewMembers ? _self.listsNewMembers : listsNewMembers // ignore: cast_nullable_to_non_nullable
as bool?,listInDirectory: null == listInDirectory ? _self.listInDirectory : listInDirectory // ignore: cast_nullable_to_non_nullable
as bool,identityChoices: null == identityChoices ? _self._identityChoices : identityChoices // ignore: cast_nullable_to_non_nullable
as List<String>,failure: freezed == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as VtcJoinFailure?,
  ));
}


}

// dart format on
