// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'vtc_groups_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$VtcGroupsState {

 bool get isLoading; List<VtcGroupListing> get groups;/// Each group's chat, by group id.
 Map<String, VtcGroupChatStatus> get chats;/// Groups with an action under way, by id.
 Set<String> get busy;/// The link to publish for the chat just created, and its group's DID.
 GroupChatLink? get createdLink; String? get createdForGroupDid; VtcGroupsFailure? get failure;/// Why the last create or join did not go ahead.
 VtcGroupChatFailure? get chatFailure;/// Whether the last create or join failed for another reason.
 bool get actionFailed;
/// Create a copy of VtcGroupsState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VtcGroupsStateCopyWith<VtcGroupsState> get copyWith => _$VtcGroupsStateCopyWithImpl<VtcGroupsState>(this as VtcGroupsState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VtcGroupsState&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&const DeepCollectionEquality().equals(other.groups, groups)&&const DeepCollectionEquality().equals(other.chats, chats)&&const DeepCollectionEquality().equals(other.busy, busy)&&(identical(other.createdLink, createdLink) || other.createdLink == createdLink)&&(identical(other.createdForGroupDid, createdForGroupDid) || other.createdForGroupDid == createdForGroupDid)&&(identical(other.failure, failure) || other.failure == failure)&&(identical(other.chatFailure, chatFailure) || other.chatFailure == chatFailure)&&(identical(other.actionFailed, actionFailed) || other.actionFailed == actionFailed));
}


@override
int get hashCode => Object.hash(runtimeType,isLoading,const DeepCollectionEquality().hash(groups),const DeepCollectionEquality().hash(chats),const DeepCollectionEquality().hash(busy),createdLink,createdForGroupDid,failure,chatFailure,actionFailed);

@override
String toString() {
  return 'VtcGroupsState(isLoading: $isLoading, groups: $groups, chats: $chats, busy: $busy, createdLink: $createdLink, createdForGroupDid: $createdForGroupDid, failure: $failure, chatFailure: $chatFailure, actionFailed: $actionFailed)';
}


}

/// @nodoc
abstract mixin class $VtcGroupsStateCopyWith<$Res>  {
  factory $VtcGroupsStateCopyWith(VtcGroupsState value, $Res Function(VtcGroupsState) _then) = _$VtcGroupsStateCopyWithImpl;
@useResult
$Res call({
 bool isLoading, List<VtcGroupListing> groups, Map<String, VtcGroupChatStatus> chats, Set<String> busy, GroupChatLink? createdLink, String? createdForGroupDid, VtcGroupsFailure? failure, VtcGroupChatFailure? chatFailure, bool actionFailed
});




}
/// @nodoc
class _$VtcGroupsStateCopyWithImpl<$Res>
    implements $VtcGroupsStateCopyWith<$Res> {
  _$VtcGroupsStateCopyWithImpl(this._self, this._then);

  final VtcGroupsState _self;
  final $Res Function(VtcGroupsState) _then;

/// Create a copy of VtcGroupsState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? isLoading = null,Object? groups = null,Object? chats = null,Object? busy = null,Object? createdLink = freezed,Object? createdForGroupDid = freezed,Object? failure = freezed,Object? chatFailure = freezed,Object? actionFailed = null,}) {
  return _then(_self.copyWith(
isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,groups: null == groups ? _self.groups : groups // ignore: cast_nullable_to_non_nullable
as List<VtcGroupListing>,chats: null == chats ? _self.chats : chats // ignore: cast_nullable_to_non_nullable
as Map<String, VtcGroupChatStatus>,busy: null == busy ? _self.busy : busy // ignore: cast_nullable_to_non_nullable
as Set<String>,createdLink: freezed == createdLink ? _self.createdLink : createdLink // ignore: cast_nullable_to_non_nullable
as GroupChatLink?,createdForGroupDid: freezed == createdForGroupDid ? _self.createdForGroupDid : createdForGroupDid // ignore: cast_nullable_to_non_nullable
as String?,failure: freezed == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as VtcGroupsFailure?,chatFailure: freezed == chatFailure ? _self.chatFailure : chatFailure // ignore: cast_nullable_to_non_nullable
as VtcGroupChatFailure?,actionFailed: null == actionFailed ? _self.actionFailed : actionFailed // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [VtcGroupsState].
extension VtcGroupsStatePatterns on VtcGroupsState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VtcGroupsState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VtcGroupsState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VtcGroupsState value)  $default,){
final _that = this;
switch (_that) {
case _VtcGroupsState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VtcGroupsState value)?  $default,){
final _that = this;
switch (_that) {
case _VtcGroupsState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool isLoading,  List<VtcGroupListing> groups,  Map<String, VtcGroupChatStatus> chats,  Set<String> busy,  GroupChatLink? createdLink,  String? createdForGroupDid,  VtcGroupsFailure? failure,  VtcGroupChatFailure? chatFailure,  bool actionFailed)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VtcGroupsState() when $default != null:
return $default(_that.isLoading,_that.groups,_that.chats,_that.busy,_that.createdLink,_that.createdForGroupDid,_that.failure,_that.chatFailure,_that.actionFailed);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool isLoading,  List<VtcGroupListing> groups,  Map<String, VtcGroupChatStatus> chats,  Set<String> busy,  GroupChatLink? createdLink,  String? createdForGroupDid,  VtcGroupsFailure? failure,  VtcGroupChatFailure? chatFailure,  bool actionFailed)  $default,) {final _that = this;
switch (_that) {
case _VtcGroupsState():
return $default(_that.isLoading,_that.groups,_that.chats,_that.busy,_that.createdLink,_that.createdForGroupDid,_that.failure,_that.chatFailure,_that.actionFailed);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool isLoading,  List<VtcGroupListing> groups,  Map<String, VtcGroupChatStatus> chats,  Set<String> busy,  GroupChatLink? createdLink,  String? createdForGroupDid,  VtcGroupsFailure? failure,  VtcGroupChatFailure? chatFailure,  bool actionFailed)?  $default,) {final _that = this;
switch (_that) {
case _VtcGroupsState() when $default != null:
return $default(_that.isLoading,_that.groups,_that.chats,_that.busy,_that.createdLink,_that.createdForGroupDid,_that.failure,_that.chatFailure,_that.actionFailed);case _:
  return null;

}
}

}

/// @nodoc


class _VtcGroupsState implements VtcGroupsState {
  const _VtcGroupsState({this.isLoading = true, final  List<VtcGroupListing> groups = const <VtcGroupListing>[], final  Map<String, VtcGroupChatStatus> chats = const <String, VtcGroupChatStatus>{}, final  Set<String> busy = const <String>{}, this.createdLink, this.createdForGroupDid, this.failure, this.chatFailure, this.actionFailed = false}): _groups = groups,_chats = chats,_busy = busy;
  

@override@JsonKey() final  bool isLoading;
 final  List<VtcGroupListing> _groups;
@override@JsonKey() List<VtcGroupListing> get groups {
  if (_groups is EqualUnmodifiableListView) return _groups;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_groups);
}

/// Each group's chat, by group id.
 final  Map<String, VtcGroupChatStatus> _chats;
/// Each group's chat, by group id.
@override@JsonKey() Map<String, VtcGroupChatStatus> get chats {
  if (_chats is EqualUnmodifiableMapView) return _chats;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_chats);
}

/// Groups with an action under way, by id.
 final  Set<String> _busy;
/// Groups with an action under way, by id.
@override@JsonKey() Set<String> get busy {
  if (_busy is EqualUnmodifiableSetView) return _busy;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_busy);
}

/// The link to publish for the chat just created, and its group's DID.
@override final  GroupChatLink? createdLink;
@override final  String? createdForGroupDid;
@override final  VtcGroupsFailure? failure;
/// Why the last create or join did not go ahead.
@override final  VtcGroupChatFailure? chatFailure;
/// Whether the last create or join failed for another reason.
@override@JsonKey() final  bool actionFailed;

/// Create a copy of VtcGroupsState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VtcGroupsStateCopyWith<_VtcGroupsState> get copyWith => __$VtcGroupsStateCopyWithImpl<_VtcGroupsState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _VtcGroupsState&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&const DeepCollectionEquality().equals(other._groups, _groups)&&const DeepCollectionEquality().equals(other._chats, _chats)&&const DeepCollectionEquality().equals(other._busy, _busy)&&(identical(other.createdLink, createdLink) || other.createdLink == createdLink)&&(identical(other.createdForGroupDid, createdForGroupDid) || other.createdForGroupDid == createdForGroupDid)&&(identical(other.failure, failure) || other.failure == failure)&&(identical(other.chatFailure, chatFailure) || other.chatFailure == chatFailure)&&(identical(other.actionFailed, actionFailed) || other.actionFailed == actionFailed));
}


@override
int get hashCode => Object.hash(runtimeType,isLoading,const DeepCollectionEquality().hash(_groups),const DeepCollectionEquality().hash(_chats),const DeepCollectionEquality().hash(_busy),createdLink,createdForGroupDid,failure,chatFailure,actionFailed);

@override
String toString() {
  return 'VtcGroupsState(isLoading: $isLoading, groups: $groups, chats: $chats, busy: $busy, createdLink: $createdLink, createdForGroupDid: $createdForGroupDid, failure: $failure, chatFailure: $chatFailure, actionFailed: $actionFailed)';
}


}

/// @nodoc
abstract mixin class _$VtcGroupsStateCopyWith<$Res> implements $VtcGroupsStateCopyWith<$Res> {
  factory _$VtcGroupsStateCopyWith(_VtcGroupsState value, $Res Function(_VtcGroupsState) _then) = __$VtcGroupsStateCopyWithImpl;
@override @useResult
$Res call({
 bool isLoading, List<VtcGroupListing> groups, Map<String, VtcGroupChatStatus> chats, Set<String> busy, GroupChatLink? createdLink, String? createdForGroupDid, VtcGroupsFailure? failure, VtcGroupChatFailure? chatFailure, bool actionFailed
});




}
/// @nodoc
class __$VtcGroupsStateCopyWithImpl<$Res>
    implements _$VtcGroupsStateCopyWith<$Res> {
  __$VtcGroupsStateCopyWithImpl(this._self, this._then);

  final _VtcGroupsState _self;
  final $Res Function(_VtcGroupsState) _then;

/// Create a copy of VtcGroupsState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? isLoading = null,Object? groups = null,Object? chats = null,Object? busy = null,Object? createdLink = freezed,Object? createdForGroupDid = freezed,Object? failure = freezed,Object? chatFailure = freezed,Object? actionFailed = null,}) {
  return _then(_VtcGroupsState(
isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,groups: null == groups ? _self._groups : groups // ignore: cast_nullable_to_non_nullable
as List<VtcGroupListing>,chats: null == chats ? _self._chats : chats // ignore: cast_nullable_to_non_nullable
as Map<String, VtcGroupChatStatus>,busy: null == busy ? _self._busy : busy // ignore: cast_nullable_to_non_nullable
as Set<String>,createdLink: freezed == createdLink ? _self.createdLink : createdLink // ignore: cast_nullable_to_non_nullable
as GroupChatLink?,createdForGroupDid: freezed == createdForGroupDid ? _self.createdForGroupDid : createdForGroupDid // ignore: cast_nullable_to_non_nullable
as String?,failure: freezed == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as VtcGroupsFailure?,chatFailure: freezed == chatFailure ? _self.chatFailure : chatFailure // ignore: cast_nullable_to_non_nullable
as VtcGroupChatFailure?,actionFailed: null == actionFailed ? _self.actionFailed : actionFailed // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
