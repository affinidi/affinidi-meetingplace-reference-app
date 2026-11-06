// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'vtc_vetting_desk_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$VtcVettingDeskState {

 VtcVettingDeskStep get step;/// The desk as recorded: tickets and sessions.
 VtcVetterDesk? get desk;/// Whether the member's vetter card is being checked, with the desk
/// already open: it closes again if the card no longer holds.
 bool get checkingCard;/// The member's vetter card for the community, once checked.
 VtcVetterCard? get vetterCard;/// What the community asks of vetting, once read.
 VettingRequirements? get requirements;/// Whether the community's join manifest, which says what it asks of
/// vetting, is being read.
 bool get readingRequirements;/// The details the applicant of each session sent on their card, by
/// request id, once checked. Held in memory only.
 Map<String, List<VettingCardClaim>> get cards;/// The statements the member issued for the community, as their VTA
/// records them, newest first.
 List<IssuedVettingStatement> get issued;/// Whether a step the member asked for is running.
 bool get busy; VtcVettingDeskFailure? get failure;
/// Create a copy of VtcVettingDeskState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VtcVettingDeskStateCopyWith<VtcVettingDeskState> get copyWith => _$VtcVettingDeskStateCopyWithImpl<VtcVettingDeskState>(this as VtcVettingDeskState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VtcVettingDeskState&&(identical(other.step, step) || other.step == step)&&(identical(other.desk, desk) || other.desk == desk)&&(identical(other.checkingCard, checkingCard) || other.checkingCard == checkingCard)&&(identical(other.vetterCard, vetterCard) || other.vetterCard == vetterCard)&&(identical(other.requirements, requirements) || other.requirements == requirements)&&(identical(other.readingRequirements, readingRequirements) || other.readingRequirements == readingRequirements)&&const DeepCollectionEquality().equals(other.cards, cards)&&const DeepCollectionEquality().equals(other.issued, issued)&&(identical(other.busy, busy) || other.busy == busy)&&(identical(other.failure, failure) || other.failure == failure));
}


@override
int get hashCode => Object.hash(runtimeType,step,desk,checkingCard,vetterCard,requirements,readingRequirements,const DeepCollectionEquality().hash(cards),const DeepCollectionEquality().hash(issued),busy,failure);

@override
String toString() {
  return 'VtcVettingDeskState(step: $step, desk: $desk, checkingCard: $checkingCard, vetterCard: $vetterCard, requirements: $requirements, readingRequirements: $readingRequirements, cards: $cards, issued: $issued, busy: $busy, failure: $failure)';
}


}

/// @nodoc
abstract mixin class $VtcVettingDeskStateCopyWith<$Res>  {
  factory $VtcVettingDeskStateCopyWith(VtcVettingDeskState value, $Res Function(VtcVettingDeskState) _then) = _$VtcVettingDeskStateCopyWithImpl;
@useResult
$Res call({
 VtcVettingDeskStep step, VtcVetterDesk? desk, bool checkingCard, VtcVetterCard? vetterCard, VettingRequirements? requirements, bool readingRequirements, Map<String, List<VettingCardClaim>> cards, List<IssuedVettingStatement> issued, bool busy, VtcVettingDeskFailure? failure
});




}
/// @nodoc
class _$VtcVettingDeskStateCopyWithImpl<$Res>
    implements $VtcVettingDeskStateCopyWith<$Res> {
  _$VtcVettingDeskStateCopyWithImpl(this._self, this._then);

  final VtcVettingDeskState _self;
  final $Res Function(VtcVettingDeskState) _then;

/// Create a copy of VtcVettingDeskState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? step = null,Object? desk = freezed,Object? checkingCard = null,Object? vetterCard = freezed,Object? requirements = freezed,Object? readingRequirements = null,Object? cards = null,Object? issued = null,Object? busy = null,Object? failure = freezed,}) {
  return _then(_self.copyWith(
step: null == step ? _self.step : step // ignore: cast_nullable_to_non_nullable
as VtcVettingDeskStep,desk: freezed == desk ? _self.desk : desk // ignore: cast_nullable_to_non_nullable
as VtcVetterDesk?,checkingCard: null == checkingCard ? _self.checkingCard : checkingCard // ignore: cast_nullable_to_non_nullable
as bool,vetterCard: freezed == vetterCard ? _self.vetterCard : vetterCard // ignore: cast_nullable_to_non_nullable
as VtcVetterCard?,requirements: freezed == requirements ? _self.requirements : requirements // ignore: cast_nullable_to_non_nullable
as VettingRequirements?,readingRequirements: null == readingRequirements ? _self.readingRequirements : readingRequirements // ignore: cast_nullable_to_non_nullable
as bool,cards: null == cards ? _self.cards : cards // ignore: cast_nullable_to_non_nullable
as Map<String, List<VettingCardClaim>>,issued: null == issued ? _self.issued : issued // ignore: cast_nullable_to_non_nullable
as List<IssuedVettingStatement>,busy: null == busy ? _self.busy : busy // ignore: cast_nullable_to_non_nullable
as bool,failure: freezed == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as VtcVettingDeskFailure?,
  ));
}

}


/// Adds pattern-matching-related methods to [VtcVettingDeskState].
extension VtcVettingDeskStatePatterns on VtcVettingDeskState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VtcVettingDeskState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VtcVettingDeskState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VtcVettingDeskState value)  $default,){
final _that = this;
switch (_that) {
case _VtcVettingDeskState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VtcVettingDeskState value)?  $default,){
final _that = this;
switch (_that) {
case _VtcVettingDeskState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( VtcVettingDeskStep step,  VtcVetterDesk? desk,  bool checkingCard,  VtcVetterCard? vetterCard,  VettingRequirements? requirements,  bool readingRequirements,  Map<String, List<VettingCardClaim>> cards,  List<IssuedVettingStatement> issued,  bool busy,  VtcVettingDeskFailure? failure)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VtcVettingDeskState() when $default != null:
return $default(_that.step,_that.desk,_that.checkingCard,_that.vetterCard,_that.requirements,_that.readingRequirements,_that.cards,_that.issued,_that.busy,_that.failure);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( VtcVettingDeskStep step,  VtcVetterDesk? desk,  bool checkingCard,  VtcVetterCard? vetterCard,  VettingRequirements? requirements,  bool readingRequirements,  Map<String, List<VettingCardClaim>> cards,  List<IssuedVettingStatement> issued,  bool busy,  VtcVettingDeskFailure? failure)  $default,) {final _that = this;
switch (_that) {
case _VtcVettingDeskState():
return $default(_that.step,_that.desk,_that.checkingCard,_that.vetterCard,_that.requirements,_that.readingRequirements,_that.cards,_that.issued,_that.busy,_that.failure);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( VtcVettingDeskStep step,  VtcVetterDesk? desk,  bool checkingCard,  VtcVetterCard? vetterCard,  VettingRequirements? requirements,  bool readingRequirements,  Map<String, List<VettingCardClaim>> cards,  List<IssuedVettingStatement> issued,  bool busy,  VtcVettingDeskFailure? failure)?  $default,) {final _that = this;
switch (_that) {
case _VtcVettingDeskState() when $default != null:
return $default(_that.step,_that.desk,_that.checkingCard,_that.vetterCard,_that.requirements,_that.readingRequirements,_that.cards,_that.issued,_that.busy,_that.failure);case _:
  return null;

}
}

}

/// @nodoc


class _VtcVettingDeskState extends VtcVettingDeskState {
   _VtcVettingDeskState({this.step = VtcVettingDeskStep.loading, this.desk, this.checkingCard = false, this.vetterCard, this.requirements, this.readingRequirements = true, final  Map<String, List<VettingCardClaim>> cards = const <String, List<VettingCardClaim>>{}, final  List<IssuedVettingStatement> issued = const <IssuedVettingStatement>[], this.busy = false, this.failure}): _cards = cards,_issued = issued,super._();
  

@override@JsonKey() final  VtcVettingDeskStep step;
/// The desk as recorded: tickets and sessions.
@override final  VtcVetterDesk? desk;
/// Whether the member's vetter card is being checked, with the desk
/// already open: it closes again if the card no longer holds.
@override@JsonKey() final  bool checkingCard;
/// The member's vetter card for the community, once checked.
@override final  VtcVetterCard? vetterCard;
/// What the community asks of vetting, once read.
@override final  VettingRequirements? requirements;
/// Whether the community's join manifest, which says what it asks of
/// vetting, is being read.
@override@JsonKey() final  bool readingRequirements;
/// The details the applicant of each session sent on their card, by
/// request id, once checked. Held in memory only.
 final  Map<String, List<VettingCardClaim>> _cards;
/// The details the applicant of each session sent on their card, by
/// request id, once checked. Held in memory only.
@override@JsonKey() Map<String, List<VettingCardClaim>> get cards {
  if (_cards is EqualUnmodifiableMapView) return _cards;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_cards);
}

/// The statements the member issued for the community, as their VTA
/// records them, newest first.
 final  List<IssuedVettingStatement> _issued;
/// The statements the member issued for the community, as their VTA
/// records them, newest first.
@override@JsonKey() List<IssuedVettingStatement> get issued {
  if (_issued is EqualUnmodifiableListView) return _issued;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_issued);
}

/// Whether a step the member asked for is running.
@override@JsonKey() final  bool busy;
@override final  VtcVettingDeskFailure? failure;

/// Create a copy of VtcVettingDeskState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VtcVettingDeskStateCopyWith<_VtcVettingDeskState> get copyWith => __$VtcVettingDeskStateCopyWithImpl<_VtcVettingDeskState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _VtcVettingDeskState&&(identical(other.step, step) || other.step == step)&&(identical(other.desk, desk) || other.desk == desk)&&(identical(other.checkingCard, checkingCard) || other.checkingCard == checkingCard)&&(identical(other.vetterCard, vetterCard) || other.vetterCard == vetterCard)&&(identical(other.requirements, requirements) || other.requirements == requirements)&&(identical(other.readingRequirements, readingRequirements) || other.readingRequirements == readingRequirements)&&const DeepCollectionEquality().equals(other._cards, _cards)&&const DeepCollectionEquality().equals(other._issued, _issued)&&(identical(other.busy, busy) || other.busy == busy)&&(identical(other.failure, failure) || other.failure == failure));
}


@override
int get hashCode => Object.hash(runtimeType,step,desk,checkingCard,vetterCard,requirements,readingRequirements,const DeepCollectionEquality().hash(_cards),const DeepCollectionEquality().hash(_issued),busy,failure);

@override
String toString() {
  return 'VtcVettingDeskState(step: $step, desk: $desk, checkingCard: $checkingCard, vetterCard: $vetterCard, requirements: $requirements, readingRequirements: $readingRequirements, cards: $cards, issued: $issued, busy: $busy, failure: $failure)';
}


}

/// @nodoc
abstract mixin class _$VtcVettingDeskStateCopyWith<$Res> implements $VtcVettingDeskStateCopyWith<$Res> {
  factory _$VtcVettingDeskStateCopyWith(_VtcVettingDeskState value, $Res Function(_VtcVettingDeskState) _then) = __$VtcVettingDeskStateCopyWithImpl;
@override @useResult
$Res call({
 VtcVettingDeskStep step, VtcVetterDesk? desk, bool checkingCard, VtcVetterCard? vetterCard, VettingRequirements? requirements, bool readingRequirements, Map<String, List<VettingCardClaim>> cards, List<IssuedVettingStatement> issued, bool busy, VtcVettingDeskFailure? failure
});




}
/// @nodoc
class __$VtcVettingDeskStateCopyWithImpl<$Res>
    implements _$VtcVettingDeskStateCopyWith<$Res> {
  __$VtcVettingDeskStateCopyWithImpl(this._self, this._then);

  final _VtcVettingDeskState _self;
  final $Res Function(_VtcVettingDeskState) _then;

/// Create a copy of VtcVettingDeskState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? step = null,Object? desk = freezed,Object? checkingCard = null,Object? vetterCard = freezed,Object? requirements = freezed,Object? readingRequirements = null,Object? cards = null,Object? issued = null,Object? busy = null,Object? failure = freezed,}) {
  return _then(_VtcVettingDeskState(
step: null == step ? _self.step : step // ignore: cast_nullable_to_non_nullable
as VtcVettingDeskStep,desk: freezed == desk ? _self.desk : desk // ignore: cast_nullable_to_non_nullable
as VtcVetterDesk?,checkingCard: null == checkingCard ? _self.checkingCard : checkingCard // ignore: cast_nullable_to_non_nullable
as bool,vetterCard: freezed == vetterCard ? _self.vetterCard : vetterCard // ignore: cast_nullable_to_non_nullable
as VtcVetterCard?,requirements: freezed == requirements ? _self.requirements : requirements // ignore: cast_nullable_to_non_nullable
as VettingRequirements?,readingRequirements: null == readingRequirements ? _self.readingRequirements : readingRequirements // ignore: cast_nullable_to_non_nullable
as bool,cards: null == cards ? _self._cards : cards // ignore: cast_nullable_to_non_nullable
as Map<String, List<VettingCardClaim>>,issued: null == issued ? _self._issued : issued // ignore: cast_nullable_to_non_nullable
as List<IssuedVettingStatement>,busy: null == busy ? _self.busy : busy // ignore: cast_nullable_to_non_nullable
as bool,failure: freezed == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as VtcVettingDeskFailure?,
  ));
}


}

// dart format on
