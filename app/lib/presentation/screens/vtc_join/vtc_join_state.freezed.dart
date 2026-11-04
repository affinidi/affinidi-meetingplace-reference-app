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

 VtcJoinStep get step;/// The scanned community's DID, once its code was read.
 String? get communityDid; String? get communityName;/// The community's logo, from its manifest or else its profile.
 Uri? get logoUrl;/// What the community is about, from its profile.
 String? get description;/// The community's website and contact address, from its profile.
 Uri? get website; String? get contactEmail;/// What the community's member directory would disclose about a member,
/// or null when it offers none.
 DirectoryDisclosure? get directoryDisclosure; bool get canApply; bool get wasMember;/// The ways into the community, in its order.
 List<VtcJoinWay> get ways;/// The id of the way in the member applies under, or null when this app
/// can apply under none.
 String? get chosenWayId;/// The join manifest exactly as the community sent it, for the member
/// to read.
 Map<String, dynamic> get manifest;/// The profile details the community asks for.
 List<JoinAttributeRequest> get requestedDetails;/// Whether the community lists new members in its directory, or null
/// when it does not say.
 bool? get listsNewMembers;/// Whether the member opted in to the member directory. Off by default.
 bool get listInDirectory;/// The identities on the member's VTA to join with, as DIDs.
 List<String> get identityChoices;/// Each identity in [identityChoices], by its DID.
 Map<String, Identity> get identities;/// The profile details the member is asked to approve sharing.
 List<VtcJoinDetail> get details;/// The open application as the VTA signed it and the community answered
/// it, or null when this phone did not send it.
 TrustTaskReceipt? get submitReceipt;/// Whether the community's administrators put the open application off.
 bool get deferred;/// When this phone last asked the community about the open application.
 DateTime? get lastCheckedAt;/// The community's reason for turning the application down, if given.
 String? get denialReason; VtcJoinFailure? get failure;
/// Create a copy of VtcJoinState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VtcJoinStateCopyWith<VtcJoinState> get copyWith => _$VtcJoinStateCopyWithImpl<VtcJoinState>(this as VtcJoinState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VtcJoinState&&(identical(other.step, step) || other.step == step)&&(identical(other.communityDid, communityDid) || other.communityDid == communityDid)&&(identical(other.communityName, communityName) || other.communityName == communityName)&&(identical(other.logoUrl, logoUrl) || other.logoUrl == logoUrl)&&(identical(other.description, description) || other.description == description)&&(identical(other.website, website) || other.website == website)&&(identical(other.contactEmail, contactEmail) || other.contactEmail == contactEmail)&&(identical(other.directoryDisclosure, directoryDisclosure) || other.directoryDisclosure == directoryDisclosure)&&(identical(other.canApply, canApply) || other.canApply == canApply)&&(identical(other.wasMember, wasMember) || other.wasMember == wasMember)&&const DeepCollectionEquality().equals(other.ways, ways)&&(identical(other.chosenWayId, chosenWayId) || other.chosenWayId == chosenWayId)&&const DeepCollectionEquality().equals(other.manifest, manifest)&&const DeepCollectionEquality().equals(other.requestedDetails, requestedDetails)&&(identical(other.listsNewMembers, listsNewMembers) || other.listsNewMembers == listsNewMembers)&&(identical(other.listInDirectory, listInDirectory) || other.listInDirectory == listInDirectory)&&const DeepCollectionEquality().equals(other.identityChoices, identityChoices)&&const DeepCollectionEquality().equals(other.identities, identities)&&const DeepCollectionEquality().equals(other.details, details)&&(identical(other.submitReceipt, submitReceipt) || other.submitReceipt == submitReceipt)&&(identical(other.deferred, deferred) || other.deferred == deferred)&&(identical(other.lastCheckedAt, lastCheckedAt) || other.lastCheckedAt == lastCheckedAt)&&(identical(other.denialReason, denialReason) || other.denialReason == denialReason)&&(identical(other.failure, failure) || other.failure == failure));
}


@override
int get hashCode => Object.hashAll([runtimeType,step,communityDid,communityName,logoUrl,description,website,contactEmail,directoryDisclosure,canApply,wasMember,const DeepCollectionEquality().hash(ways),chosenWayId,const DeepCollectionEquality().hash(manifest),const DeepCollectionEquality().hash(requestedDetails),listsNewMembers,listInDirectory,const DeepCollectionEquality().hash(identityChoices),const DeepCollectionEquality().hash(identities),const DeepCollectionEquality().hash(details),submitReceipt,deferred,lastCheckedAt,denialReason,failure]);

@override
String toString() {
  return 'VtcJoinState(step: $step, communityDid: $communityDid, communityName: $communityName, logoUrl: $logoUrl, description: $description, website: $website, contactEmail: $contactEmail, directoryDisclosure: $directoryDisclosure, canApply: $canApply, wasMember: $wasMember, ways: $ways, chosenWayId: $chosenWayId, manifest: $manifest, requestedDetails: $requestedDetails, listsNewMembers: $listsNewMembers, listInDirectory: $listInDirectory, identityChoices: $identityChoices, identities: $identities, details: $details, submitReceipt: $submitReceipt, deferred: $deferred, lastCheckedAt: $lastCheckedAt, denialReason: $denialReason, failure: $failure)';
}


}

/// @nodoc
abstract mixin class $VtcJoinStateCopyWith<$Res>  {
  factory $VtcJoinStateCopyWith(VtcJoinState value, $Res Function(VtcJoinState) _then) = _$VtcJoinStateCopyWithImpl;
@useResult
$Res call({
 VtcJoinStep step, String? communityDid, String? communityName, Uri? logoUrl, String? description, Uri? website, String? contactEmail, DirectoryDisclosure? directoryDisclosure, bool canApply, bool wasMember, List<VtcJoinWay> ways, String? chosenWayId, Map<String, dynamic> manifest, List<JoinAttributeRequest> requestedDetails, bool? listsNewMembers, bool listInDirectory, List<String> identityChoices, Map<String, Identity> identities, List<VtcJoinDetail> details, TrustTaskReceipt? submitReceipt, bool deferred, DateTime? lastCheckedAt, String? denialReason, VtcJoinFailure? failure
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
@pragma('vm:prefer-inline') @override $Res call({Object? step = null,Object? communityDid = freezed,Object? communityName = freezed,Object? logoUrl = freezed,Object? description = freezed,Object? website = freezed,Object? contactEmail = freezed,Object? directoryDisclosure = freezed,Object? canApply = null,Object? wasMember = null,Object? ways = null,Object? chosenWayId = freezed,Object? manifest = null,Object? requestedDetails = null,Object? listsNewMembers = freezed,Object? listInDirectory = null,Object? identityChoices = null,Object? identities = null,Object? details = null,Object? submitReceipt = freezed,Object? deferred = null,Object? lastCheckedAt = freezed,Object? denialReason = freezed,Object? failure = freezed,}) {
  return _then(_self.copyWith(
step: null == step ? _self.step : step // ignore: cast_nullable_to_non_nullable
as VtcJoinStep,communityDid: freezed == communityDid ? _self.communityDid : communityDid // ignore: cast_nullable_to_non_nullable
as String?,communityName: freezed == communityName ? _self.communityName : communityName // ignore: cast_nullable_to_non_nullable
as String?,logoUrl: freezed == logoUrl ? _self.logoUrl : logoUrl // ignore: cast_nullable_to_non_nullable
as Uri?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,website: freezed == website ? _self.website : website // ignore: cast_nullable_to_non_nullable
as Uri?,contactEmail: freezed == contactEmail ? _self.contactEmail : contactEmail // ignore: cast_nullable_to_non_nullable
as String?,directoryDisclosure: freezed == directoryDisclosure ? _self.directoryDisclosure : directoryDisclosure // ignore: cast_nullable_to_non_nullable
as DirectoryDisclosure?,canApply: null == canApply ? _self.canApply : canApply // ignore: cast_nullable_to_non_nullable
as bool,wasMember: null == wasMember ? _self.wasMember : wasMember // ignore: cast_nullable_to_non_nullable
as bool,ways: null == ways ? _self.ways : ways // ignore: cast_nullable_to_non_nullable
as List<VtcJoinWay>,chosenWayId: freezed == chosenWayId ? _self.chosenWayId : chosenWayId // ignore: cast_nullable_to_non_nullable
as String?,manifest: null == manifest ? _self.manifest : manifest // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,requestedDetails: null == requestedDetails ? _self.requestedDetails : requestedDetails // ignore: cast_nullable_to_non_nullable
as List<JoinAttributeRequest>,listsNewMembers: freezed == listsNewMembers ? _self.listsNewMembers : listsNewMembers // ignore: cast_nullable_to_non_nullable
as bool?,listInDirectory: null == listInDirectory ? _self.listInDirectory : listInDirectory // ignore: cast_nullable_to_non_nullable
as bool,identityChoices: null == identityChoices ? _self.identityChoices : identityChoices // ignore: cast_nullable_to_non_nullable
as List<String>,identities: null == identities ? _self.identities : identities // ignore: cast_nullable_to_non_nullable
as Map<String, Identity>,details: null == details ? _self.details : details // ignore: cast_nullable_to_non_nullable
as List<VtcJoinDetail>,submitReceipt: freezed == submitReceipt ? _self.submitReceipt : submitReceipt // ignore: cast_nullable_to_non_nullable
as TrustTaskReceipt?,deferred: null == deferred ? _self.deferred : deferred // ignore: cast_nullable_to_non_nullable
as bool,lastCheckedAt: freezed == lastCheckedAt ? _self.lastCheckedAt : lastCheckedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,denialReason: freezed == denialReason ? _self.denialReason : denialReason // ignore: cast_nullable_to_non_nullable
as String?,failure: freezed == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( VtcJoinStep step,  String? communityDid,  String? communityName,  Uri? logoUrl,  String? description,  Uri? website,  String? contactEmail,  DirectoryDisclosure? directoryDisclosure,  bool canApply,  bool wasMember,  List<VtcJoinWay> ways,  String? chosenWayId,  Map<String, dynamic> manifest,  List<JoinAttributeRequest> requestedDetails,  bool? listsNewMembers,  bool listInDirectory,  List<String> identityChoices,  Map<String, Identity> identities,  List<VtcJoinDetail> details,  TrustTaskReceipt? submitReceipt,  bool deferred,  DateTime? lastCheckedAt,  String? denialReason,  VtcJoinFailure? failure)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VtcJoinState() when $default != null:
return $default(_that.step,_that.communityDid,_that.communityName,_that.logoUrl,_that.description,_that.website,_that.contactEmail,_that.directoryDisclosure,_that.canApply,_that.wasMember,_that.ways,_that.chosenWayId,_that.manifest,_that.requestedDetails,_that.listsNewMembers,_that.listInDirectory,_that.identityChoices,_that.identities,_that.details,_that.submitReceipt,_that.deferred,_that.lastCheckedAt,_that.denialReason,_that.failure);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( VtcJoinStep step,  String? communityDid,  String? communityName,  Uri? logoUrl,  String? description,  Uri? website,  String? contactEmail,  DirectoryDisclosure? directoryDisclosure,  bool canApply,  bool wasMember,  List<VtcJoinWay> ways,  String? chosenWayId,  Map<String, dynamic> manifest,  List<JoinAttributeRequest> requestedDetails,  bool? listsNewMembers,  bool listInDirectory,  List<String> identityChoices,  Map<String, Identity> identities,  List<VtcJoinDetail> details,  TrustTaskReceipt? submitReceipt,  bool deferred,  DateTime? lastCheckedAt,  String? denialReason,  VtcJoinFailure? failure)  $default,) {final _that = this;
switch (_that) {
case _VtcJoinState():
return $default(_that.step,_that.communityDid,_that.communityName,_that.logoUrl,_that.description,_that.website,_that.contactEmail,_that.directoryDisclosure,_that.canApply,_that.wasMember,_that.ways,_that.chosenWayId,_that.manifest,_that.requestedDetails,_that.listsNewMembers,_that.listInDirectory,_that.identityChoices,_that.identities,_that.details,_that.submitReceipt,_that.deferred,_that.lastCheckedAt,_that.denialReason,_that.failure);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( VtcJoinStep step,  String? communityDid,  String? communityName,  Uri? logoUrl,  String? description,  Uri? website,  String? contactEmail,  DirectoryDisclosure? directoryDisclosure,  bool canApply,  bool wasMember,  List<VtcJoinWay> ways,  String? chosenWayId,  Map<String, dynamic> manifest,  List<JoinAttributeRequest> requestedDetails,  bool? listsNewMembers,  bool listInDirectory,  List<String> identityChoices,  Map<String, Identity> identities,  List<VtcJoinDetail> details,  TrustTaskReceipt? submitReceipt,  bool deferred,  DateTime? lastCheckedAt,  String? denialReason,  VtcJoinFailure? failure)?  $default,) {final _that = this;
switch (_that) {
case _VtcJoinState() when $default != null:
return $default(_that.step,_that.communityDid,_that.communityName,_that.logoUrl,_that.description,_that.website,_that.contactEmail,_that.directoryDisclosure,_that.canApply,_that.wasMember,_that.ways,_that.chosenWayId,_that.manifest,_that.requestedDetails,_that.listsNewMembers,_that.listInDirectory,_that.identityChoices,_that.identities,_that.details,_that.submitReceipt,_that.deferred,_that.lastCheckedAt,_that.denialReason,_that.failure);case _:
  return null;

}
}

}

/// @nodoc


class _VtcJoinState implements VtcJoinState {
   _VtcJoinState({this.step = VtcJoinStep.scanning, this.communityDid, this.communityName, this.logoUrl, this.description, this.website, this.contactEmail, this.directoryDisclosure, this.canApply = false, this.wasMember = false, final  List<VtcJoinWay> ways = const <VtcJoinWay>[], this.chosenWayId, final  Map<String, dynamic> manifest = const <String, dynamic>{}, final  List<JoinAttributeRequest> requestedDetails = const <JoinAttributeRequest>[], this.listsNewMembers, this.listInDirectory = false, final  List<String> identityChoices = const <String>[], final  Map<String, Identity> identities = const <String, Identity>{}, final  List<VtcJoinDetail> details = const <VtcJoinDetail>[], this.submitReceipt, this.deferred = false, this.lastCheckedAt, this.denialReason, this.failure}): _ways = ways,_manifest = manifest,_requestedDetails = requestedDetails,_identityChoices = identityChoices,_identities = identities,_details = details;
  

@override@JsonKey() final  VtcJoinStep step;
/// The scanned community's DID, once its code was read.
@override final  String? communityDid;
@override final  String? communityName;
/// The community's logo, from its manifest or else its profile.
@override final  Uri? logoUrl;
/// What the community is about, from its profile.
@override final  String? description;
/// The community's website and contact address, from its profile.
@override final  Uri? website;
@override final  String? contactEmail;
/// What the community's member directory would disclose about a member,
/// or null when it offers none.
@override final  DirectoryDisclosure? directoryDisclosure;
@override@JsonKey() final  bool canApply;
@override@JsonKey() final  bool wasMember;
/// The ways into the community, in its order.
 final  List<VtcJoinWay> _ways;
/// The ways into the community, in its order.
@override@JsonKey() List<VtcJoinWay> get ways {
  if (_ways is EqualUnmodifiableListView) return _ways;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_ways);
}

/// The id of the way in the member applies under, or null when this app
/// can apply under none.
@override final  String? chosenWayId;
/// The join manifest exactly as the community sent it, for the member
/// to read.
 final  Map<String, dynamic> _manifest;
/// The join manifest exactly as the community sent it, for the member
/// to read.
@override@JsonKey() Map<String, dynamic> get manifest {
  if (_manifest is EqualUnmodifiableMapView) return _manifest;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_manifest);
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

/// Each identity in [identityChoices], by its DID.
 final  Map<String, Identity> _identities;
/// Each identity in [identityChoices], by its DID.
@override@JsonKey() Map<String, Identity> get identities {
  if (_identities is EqualUnmodifiableMapView) return _identities;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_identities);
}

/// The profile details the member is asked to approve sharing.
 final  List<VtcJoinDetail> _details;
/// The profile details the member is asked to approve sharing.
@override@JsonKey() List<VtcJoinDetail> get details {
  if (_details is EqualUnmodifiableListView) return _details;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_details);
}

/// The open application as the VTA signed it and the community answered
/// it, or null when this phone did not send it.
@override final  TrustTaskReceipt? submitReceipt;
/// Whether the community's administrators put the open application off.
@override@JsonKey() final  bool deferred;
/// When this phone last asked the community about the open application.
@override final  DateTime? lastCheckedAt;
/// The community's reason for turning the application down, if given.
@override final  String? denialReason;
@override final  VtcJoinFailure? failure;

/// Create a copy of VtcJoinState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VtcJoinStateCopyWith<_VtcJoinState> get copyWith => __$VtcJoinStateCopyWithImpl<_VtcJoinState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _VtcJoinState&&(identical(other.step, step) || other.step == step)&&(identical(other.communityDid, communityDid) || other.communityDid == communityDid)&&(identical(other.communityName, communityName) || other.communityName == communityName)&&(identical(other.logoUrl, logoUrl) || other.logoUrl == logoUrl)&&(identical(other.description, description) || other.description == description)&&(identical(other.website, website) || other.website == website)&&(identical(other.contactEmail, contactEmail) || other.contactEmail == contactEmail)&&(identical(other.directoryDisclosure, directoryDisclosure) || other.directoryDisclosure == directoryDisclosure)&&(identical(other.canApply, canApply) || other.canApply == canApply)&&(identical(other.wasMember, wasMember) || other.wasMember == wasMember)&&const DeepCollectionEquality().equals(other._ways, _ways)&&(identical(other.chosenWayId, chosenWayId) || other.chosenWayId == chosenWayId)&&const DeepCollectionEquality().equals(other._manifest, _manifest)&&const DeepCollectionEquality().equals(other._requestedDetails, _requestedDetails)&&(identical(other.listsNewMembers, listsNewMembers) || other.listsNewMembers == listsNewMembers)&&(identical(other.listInDirectory, listInDirectory) || other.listInDirectory == listInDirectory)&&const DeepCollectionEquality().equals(other._identityChoices, _identityChoices)&&const DeepCollectionEquality().equals(other._identities, _identities)&&const DeepCollectionEquality().equals(other._details, _details)&&(identical(other.submitReceipt, submitReceipt) || other.submitReceipt == submitReceipt)&&(identical(other.deferred, deferred) || other.deferred == deferred)&&(identical(other.lastCheckedAt, lastCheckedAt) || other.lastCheckedAt == lastCheckedAt)&&(identical(other.denialReason, denialReason) || other.denialReason == denialReason)&&(identical(other.failure, failure) || other.failure == failure));
}


@override
int get hashCode => Object.hashAll([runtimeType,step,communityDid,communityName,logoUrl,description,website,contactEmail,directoryDisclosure,canApply,wasMember,const DeepCollectionEquality().hash(_ways),chosenWayId,const DeepCollectionEquality().hash(_manifest),const DeepCollectionEquality().hash(_requestedDetails),listsNewMembers,listInDirectory,const DeepCollectionEquality().hash(_identityChoices),const DeepCollectionEquality().hash(_identities),const DeepCollectionEquality().hash(_details),submitReceipt,deferred,lastCheckedAt,denialReason,failure]);

@override
String toString() {
  return 'VtcJoinState(step: $step, communityDid: $communityDid, communityName: $communityName, logoUrl: $logoUrl, description: $description, website: $website, contactEmail: $contactEmail, directoryDisclosure: $directoryDisclosure, canApply: $canApply, wasMember: $wasMember, ways: $ways, chosenWayId: $chosenWayId, manifest: $manifest, requestedDetails: $requestedDetails, listsNewMembers: $listsNewMembers, listInDirectory: $listInDirectory, identityChoices: $identityChoices, identities: $identities, details: $details, submitReceipt: $submitReceipt, deferred: $deferred, lastCheckedAt: $lastCheckedAt, denialReason: $denialReason, failure: $failure)';
}


}

/// @nodoc
abstract mixin class _$VtcJoinStateCopyWith<$Res> implements $VtcJoinStateCopyWith<$Res> {
  factory _$VtcJoinStateCopyWith(_VtcJoinState value, $Res Function(_VtcJoinState) _then) = __$VtcJoinStateCopyWithImpl;
@override @useResult
$Res call({
 VtcJoinStep step, String? communityDid, String? communityName, Uri? logoUrl, String? description, Uri? website, String? contactEmail, DirectoryDisclosure? directoryDisclosure, bool canApply, bool wasMember, List<VtcJoinWay> ways, String? chosenWayId, Map<String, dynamic> manifest, List<JoinAttributeRequest> requestedDetails, bool? listsNewMembers, bool listInDirectory, List<String> identityChoices, Map<String, Identity> identities, List<VtcJoinDetail> details, TrustTaskReceipt? submitReceipt, bool deferred, DateTime? lastCheckedAt, String? denialReason, VtcJoinFailure? failure
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
@override @pragma('vm:prefer-inline') $Res call({Object? step = null,Object? communityDid = freezed,Object? communityName = freezed,Object? logoUrl = freezed,Object? description = freezed,Object? website = freezed,Object? contactEmail = freezed,Object? directoryDisclosure = freezed,Object? canApply = null,Object? wasMember = null,Object? ways = null,Object? chosenWayId = freezed,Object? manifest = null,Object? requestedDetails = null,Object? listsNewMembers = freezed,Object? listInDirectory = null,Object? identityChoices = null,Object? identities = null,Object? details = null,Object? submitReceipt = freezed,Object? deferred = null,Object? lastCheckedAt = freezed,Object? denialReason = freezed,Object? failure = freezed,}) {
  return _then(_VtcJoinState(
step: null == step ? _self.step : step // ignore: cast_nullable_to_non_nullable
as VtcJoinStep,communityDid: freezed == communityDid ? _self.communityDid : communityDid // ignore: cast_nullable_to_non_nullable
as String?,communityName: freezed == communityName ? _self.communityName : communityName // ignore: cast_nullable_to_non_nullable
as String?,logoUrl: freezed == logoUrl ? _self.logoUrl : logoUrl // ignore: cast_nullable_to_non_nullable
as Uri?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,website: freezed == website ? _self.website : website // ignore: cast_nullable_to_non_nullable
as Uri?,contactEmail: freezed == contactEmail ? _self.contactEmail : contactEmail // ignore: cast_nullable_to_non_nullable
as String?,directoryDisclosure: freezed == directoryDisclosure ? _self.directoryDisclosure : directoryDisclosure // ignore: cast_nullable_to_non_nullable
as DirectoryDisclosure?,canApply: null == canApply ? _self.canApply : canApply // ignore: cast_nullable_to_non_nullable
as bool,wasMember: null == wasMember ? _self.wasMember : wasMember // ignore: cast_nullable_to_non_nullable
as bool,ways: null == ways ? _self._ways : ways // ignore: cast_nullable_to_non_nullable
as List<VtcJoinWay>,chosenWayId: freezed == chosenWayId ? _self.chosenWayId : chosenWayId // ignore: cast_nullable_to_non_nullable
as String?,manifest: null == manifest ? _self._manifest : manifest // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,requestedDetails: null == requestedDetails ? _self._requestedDetails : requestedDetails // ignore: cast_nullable_to_non_nullable
as List<JoinAttributeRequest>,listsNewMembers: freezed == listsNewMembers ? _self.listsNewMembers : listsNewMembers // ignore: cast_nullable_to_non_nullable
as bool?,listInDirectory: null == listInDirectory ? _self.listInDirectory : listInDirectory // ignore: cast_nullable_to_non_nullable
as bool,identityChoices: null == identityChoices ? _self._identityChoices : identityChoices // ignore: cast_nullable_to_non_nullable
as List<String>,identities: null == identities ? _self._identities : identities // ignore: cast_nullable_to_non_nullable
as Map<String, Identity>,details: null == details ? _self._details : details // ignore: cast_nullable_to_non_nullable
as List<VtcJoinDetail>,submitReceipt: freezed == submitReceipt ? _self.submitReceipt : submitReceipt // ignore: cast_nullable_to_non_nullable
as TrustTaskReceipt?,deferred: null == deferred ? _self.deferred : deferred // ignore: cast_nullable_to_non_nullable
as bool,lastCheckedAt: freezed == lastCheckedAt ? _self.lastCheckedAt : lastCheckedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,denialReason: freezed == denialReason ? _self.denialReason : denialReason // ignore: cast_nullable_to_non_nullable
as String?,failure: freezed == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as VtcJoinFailure?,
  ));
}


}

// dart format on
