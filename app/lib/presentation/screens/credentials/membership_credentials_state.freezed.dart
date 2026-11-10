// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'membership_credentials_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$MembershipCredentialsState {

/// Whether there is nothing to show yet: no cards kept on this phone,
/// and the VTA not read.
 bool get isLoading;/// Whether the cards are being read from the VTA again.
 bool get isSyncing;/// The member's membership cards: held on their VTA, then left.
 List<VtcMembershipEntry> get entries;/// The cards the groups of the member's communities issued, as last read
/// from the VTA.
 List<VtcGroupCard> get groupCards;/// When the cards were read from the VTA.
 DateTime? get readAt;/// What each card's community said of it, by [VtcMembershipEntry.key]
/// or [VtcGroupCard.key]; none while it is being checked.
 Map<String, VtcCardStatus> get statuses;/// The cards being checked with their community right now.
 Set<String> get checking; MembershipCredentialsFailure? get failure;
/// Create a copy of MembershipCredentialsState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MembershipCredentialsStateCopyWith<MembershipCredentialsState> get copyWith => _$MembershipCredentialsStateCopyWithImpl<MembershipCredentialsState>(this as MembershipCredentialsState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MembershipCredentialsState&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.isSyncing, isSyncing) || other.isSyncing == isSyncing)&&const DeepCollectionEquality().equals(other.entries, entries)&&const DeepCollectionEquality().equals(other.groupCards, groupCards)&&(identical(other.readAt, readAt) || other.readAt == readAt)&&const DeepCollectionEquality().equals(other.statuses, statuses)&&const DeepCollectionEquality().equals(other.checking, checking)&&(identical(other.failure, failure) || other.failure == failure));
}


@override
int get hashCode => Object.hash(runtimeType,isLoading,isSyncing,const DeepCollectionEquality().hash(entries),const DeepCollectionEquality().hash(groupCards),readAt,const DeepCollectionEquality().hash(statuses),const DeepCollectionEquality().hash(checking),failure);

@override
String toString() {
  return 'MembershipCredentialsState(isLoading: $isLoading, isSyncing: $isSyncing, entries: $entries, groupCards: $groupCards, readAt: $readAt, statuses: $statuses, checking: $checking, failure: $failure)';
}


}

/// @nodoc
abstract mixin class $MembershipCredentialsStateCopyWith<$Res>  {
  factory $MembershipCredentialsStateCopyWith(MembershipCredentialsState value, $Res Function(MembershipCredentialsState) _then) = _$MembershipCredentialsStateCopyWithImpl;
@useResult
$Res call({
 bool isLoading, bool isSyncing, List<VtcMembershipEntry> entries, List<VtcGroupCard> groupCards, DateTime? readAt, Map<String, VtcCardStatus> statuses, Set<String> checking, MembershipCredentialsFailure? failure
});




}
/// @nodoc
class _$MembershipCredentialsStateCopyWithImpl<$Res>
    implements $MembershipCredentialsStateCopyWith<$Res> {
  _$MembershipCredentialsStateCopyWithImpl(this._self, this._then);

  final MembershipCredentialsState _self;
  final $Res Function(MembershipCredentialsState) _then;

/// Create a copy of MembershipCredentialsState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? isLoading = null,Object? isSyncing = null,Object? entries = null,Object? groupCards = null,Object? readAt = freezed,Object? statuses = null,Object? checking = null,Object? failure = freezed,}) {
  return _then(_self.copyWith(
isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,isSyncing: null == isSyncing ? _self.isSyncing : isSyncing // ignore: cast_nullable_to_non_nullable
as bool,entries: null == entries ? _self.entries : entries // ignore: cast_nullable_to_non_nullable
as List<VtcMembershipEntry>,groupCards: null == groupCards ? _self.groupCards : groupCards // ignore: cast_nullable_to_non_nullable
as List<VtcGroupCard>,readAt: freezed == readAt ? _self.readAt : readAt // ignore: cast_nullable_to_non_nullable
as DateTime?,statuses: null == statuses ? _self.statuses : statuses // ignore: cast_nullable_to_non_nullable
as Map<String, VtcCardStatus>,checking: null == checking ? _self.checking : checking // ignore: cast_nullable_to_non_nullable
as Set<String>,failure: freezed == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as MembershipCredentialsFailure?,
  ));
}

}


/// Adds pattern-matching-related methods to [MembershipCredentialsState].
extension MembershipCredentialsStatePatterns on MembershipCredentialsState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MembershipCredentialsState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MembershipCredentialsState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MembershipCredentialsState value)  $default,){
final _that = this;
switch (_that) {
case _MembershipCredentialsState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MembershipCredentialsState value)?  $default,){
final _that = this;
switch (_that) {
case _MembershipCredentialsState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool isLoading,  bool isSyncing,  List<VtcMembershipEntry> entries,  List<VtcGroupCard> groupCards,  DateTime? readAt,  Map<String, VtcCardStatus> statuses,  Set<String> checking,  MembershipCredentialsFailure? failure)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MembershipCredentialsState() when $default != null:
return $default(_that.isLoading,_that.isSyncing,_that.entries,_that.groupCards,_that.readAt,_that.statuses,_that.checking,_that.failure);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool isLoading,  bool isSyncing,  List<VtcMembershipEntry> entries,  List<VtcGroupCard> groupCards,  DateTime? readAt,  Map<String, VtcCardStatus> statuses,  Set<String> checking,  MembershipCredentialsFailure? failure)  $default,) {final _that = this;
switch (_that) {
case _MembershipCredentialsState():
return $default(_that.isLoading,_that.isSyncing,_that.entries,_that.groupCards,_that.readAt,_that.statuses,_that.checking,_that.failure);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool isLoading,  bool isSyncing,  List<VtcMembershipEntry> entries,  List<VtcGroupCard> groupCards,  DateTime? readAt,  Map<String, VtcCardStatus> statuses,  Set<String> checking,  MembershipCredentialsFailure? failure)?  $default,) {final _that = this;
switch (_that) {
case _MembershipCredentialsState() when $default != null:
return $default(_that.isLoading,_that.isSyncing,_that.entries,_that.groupCards,_that.readAt,_that.statuses,_that.checking,_that.failure);case _:
  return null;

}
}

}

/// @nodoc


class _MembershipCredentialsState implements MembershipCredentialsState {
   _MembershipCredentialsState({this.isLoading = true, this.isSyncing = false, final  List<VtcMembershipEntry> entries = const <VtcMembershipEntry>[], final  List<VtcGroupCard> groupCards = const <VtcGroupCard>[], this.readAt, final  Map<String, VtcCardStatus> statuses = const <String, VtcCardStatus>{}, final  Set<String> checking = const <String>{}, this.failure}): _entries = entries,_groupCards = groupCards,_statuses = statuses,_checking = checking;
  

/// Whether there is nothing to show yet: no cards kept on this phone,
/// and the VTA not read.
@override@JsonKey() final  bool isLoading;
/// Whether the cards are being read from the VTA again.
@override@JsonKey() final  bool isSyncing;
/// The member's membership cards: held on their VTA, then left.
 final  List<VtcMembershipEntry> _entries;
/// The member's membership cards: held on their VTA, then left.
@override@JsonKey() List<VtcMembershipEntry> get entries {
  if (_entries is EqualUnmodifiableListView) return _entries;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_entries);
}

/// The cards the groups of the member's communities issued, as last read
/// from the VTA.
 final  List<VtcGroupCard> _groupCards;
/// The cards the groups of the member's communities issued, as last read
/// from the VTA.
@override@JsonKey() List<VtcGroupCard> get groupCards {
  if (_groupCards is EqualUnmodifiableListView) return _groupCards;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_groupCards);
}

/// When the cards were read from the VTA.
@override final  DateTime? readAt;
/// What each card's community said of it, by [VtcMembershipEntry.key]
/// or [VtcGroupCard.key]; none while it is being checked.
 final  Map<String, VtcCardStatus> _statuses;
/// What each card's community said of it, by [VtcMembershipEntry.key]
/// or [VtcGroupCard.key]; none while it is being checked.
@override@JsonKey() Map<String, VtcCardStatus> get statuses {
  if (_statuses is EqualUnmodifiableMapView) return _statuses;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_statuses);
}

/// The cards being checked with their community right now.
 final  Set<String> _checking;
/// The cards being checked with their community right now.
@override@JsonKey() Set<String> get checking {
  if (_checking is EqualUnmodifiableSetView) return _checking;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_checking);
}

@override final  MembershipCredentialsFailure? failure;

/// Create a copy of MembershipCredentialsState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MembershipCredentialsStateCopyWith<_MembershipCredentialsState> get copyWith => __$MembershipCredentialsStateCopyWithImpl<_MembershipCredentialsState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MembershipCredentialsState&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.isSyncing, isSyncing) || other.isSyncing == isSyncing)&&const DeepCollectionEquality().equals(other._entries, _entries)&&const DeepCollectionEquality().equals(other._groupCards, _groupCards)&&(identical(other.readAt, readAt) || other.readAt == readAt)&&const DeepCollectionEquality().equals(other._statuses, _statuses)&&const DeepCollectionEquality().equals(other._checking, _checking)&&(identical(other.failure, failure) || other.failure == failure));
}


@override
int get hashCode => Object.hash(runtimeType,isLoading,isSyncing,const DeepCollectionEquality().hash(_entries),const DeepCollectionEquality().hash(_groupCards),readAt,const DeepCollectionEquality().hash(_statuses),const DeepCollectionEquality().hash(_checking),failure);

@override
String toString() {
  return 'MembershipCredentialsState(isLoading: $isLoading, isSyncing: $isSyncing, entries: $entries, groupCards: $groupCards, readAt: $readAt, statuses: $statuses, checking: $checking, failure: $failure)';
}


}

/// @nodoc
abstract mixin class _$MembershipCredentialsStateCopyWith<$Res> implements $MembershipCredentialsStateCopyWith<$Res> {
  factory _$MembershipCredentialsStateCopyWith(_MembershipCredentialsState value, $Res Function(_MembershipCredentialsState) _then) = __$MembershipCredentialsStateCopyWithImpl;
@override @useResult
$Res call({
 bool isLoading, bool isSyncing, List<VtcMembershipEntry> entries, List<VtcGroupCard> groupCards, DateTime? readAt, Map<String, VtcCardStatus> statuses, Set<String> checking, MembershipCredentialsFailure? failure
});




}
/// @nodoc
class __$MembershipCredentialsStateCopyWithImpl<$Res>
    implements _$MembershipCredentialsStateCopyWith<$Res> {
  __$MembershipCredentialsStateCopyWithImpl(this._self, this._then);

  final _MembershipCredentialsState _self;
  final $Res Function(_MembershipCredentialsState) _then;

/// Create a copy of MembershipCredentialsState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? isLoading = null,Object? isSyncing = null,Object? entries = null,Object? groupCards = null,Object? readAt = freezed,Object? statuses = null,Object? checking = null,Object? failure = freezed,}) {
  return _then(_MembershipCredentialsState(
isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,isSyncing: null == isSyncing ? _self.isSyncing : isSyncing // ignore: cast_nullable_to_non_nullable
as bool,entries: null == entries ? _self._entries : entries // ignore: cast_nullable_to_non_nullable
as List<VtcMembershipEntry>,groupCards: null == groupCards ? _self._groupCards : groupCards // ignore: cast_nullable_to_non_nullable
as List<VtcGroupCard>,readAt: freezed == readAt ? _self.readAt : readAt // ignore: cast_nullable_to_non_nullable
as DateTime?,statuses: null == statuses ? _self._statuses : statuses // ignore: cast_nullable_to_non_nullable
as Map<String, VtcCardStatus>,checking: null == checking ? _self._checking : checking // ignore: cast_nullable_to_non_nullable
as Set<String>,failure: freezed == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as MembershipCredentialsFailure?,
  ));
}


}

// dart format on
