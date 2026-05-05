// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'r_cards_screen_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$RCardsScreenState {

 RCardsScreenFilter get filter; List<ReceivedRCard> get cards; bool get isSearchActive; bool get hasFilterApplied;
/// Create a copy of RCardsScreenState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RCardsScreenStateCopyWith<RCardsScreenState> get copyWith => _$RCardsScreenStateCopyWithImpl<RCardsScreenState>(this as RCardsScreenState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RCardsScreenState&&(identical(other.filter, filter) || other.filter == filter)&&const DeepCollectionEquality().equals(other.cards, cards)&&(identical(other.isSearchActive, isSearchActive) || other.isSearchActive == isSearchActive)&&(identical(other.hasFilterApplied, hasFilterApplied) || other.hasFilterApplied == hasFilterApplied));
}


@override
int get hashCode => Object.hash(runtimeType,filter,const DeepCollectionEquality().hash(cards),isSearchActive,hasFilterApplied);

@override
String toString() {
  return 'RCardsScreenState(filter: $filter, cards: $cards, isSearchActive: $isSearchActive, hasFilterApplied: $hasFilterApplied)';
}


}

/// @nodoc
abstract mixin class $RCardsScreenStateCopyWith<$Res>  {
  factory $RCardsScreenStateCopyWith(RCardsScreenState value, $Res Function(RCardsScreenState) _then) = _$RCardsScreenStateCopyWithImpl;
@useResult
$Res call({
 RCardsScreenFilter filter, List<ReceivedRCard> cards, bool isSearchActive, bool hasFilterApplied
});




}
/// @nodoc
class _$RCardsScreenStateCopyWithImpl<$Res>
    implements $RCardsScreenStateCopyWith<$Res> {
  _$RCardsScreenStateCopyWithImpl(this._self, this._then);

  final RCardsScreenState _self;
  final $Res Function(RCardsScreenState) _then;

/// Create a copy of RCardsScreenState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? filter = null,Object? cards = null,Object? isSearchActive = null,Object? hasFilterApplied = null,}) {
  return _then(_self.copyWith(
filter: null == filter ? _self.filter : filter // ignore: cast_nullable_to_non_nullable
as RCardsScreenFilter,cards: null == cards ? _self.cards : cards // ignore: cast_nullable_to_non_nullable
as List<ReceivedRCard>,isSearchActive: null == isSearchActive ? _self.isSearchActive : isSearchActive // ignore: cast_nullable_to_non_nullable
as bool,hasFilterApplied: null == hasFilterApplied ? _self.hasFilterApplied : hasFilterApplied // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [RCardsScreenState].
extension RCardsScreenStatePatterns on RCardsScreenState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RCardsScreenState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RCardsScreenState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RCardsScreenState value)  $default,){
final _that = this;
switch (_that) {
case _RCardsScreenState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RCardsScreenState value)?  $default,){
final _that = this;
switch (_that) {
case _RCardsScreenState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( RCardsScreenFilter filter,  List<ReceivedRCard> cards,  bool isSearchActive,  bool hasFilterApplied)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RCardsScreenState() when $default != null:
return $default(_that.filter,_that.cards,_that.isSearchActive,_that.hasFilterApplied);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( RCardsScreenFilter filter,  List<ReceivedRCard> cards,  bool isSearchActive,  bool hasFilterApplied)  $default,) {final _that = this;
switch (_that) {
case _RCardsScreenState():
return $default(_that.filter,_that.cards,_that.isSearchActive,_that.hasFilterApplied);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( RCardsScreenFilter filter,  List<ReceivedRCard> cards,  bool isSearchActive,  bool hasFilterApplied)?  $default,) {final _that = this;
switch (_that) {
case _RCardsScreenState() when $default != null:
return $default(_that.filter,_that.cards,_that.isSearchActive,_that.hasFilterApplied);case _:
  return null;

}
}

}

/// @nodoc


class _RCardsScreenState implements RCardsScreenState {
   _RCardsScreenState({this.filter = RCardsScreenFilter.all, final  List<ReceivedRCard> cards = const [], this.isSearchActive = false, this.hasFilterApplied = false}): _cards = cards;
  

@override@JsonKey() final  RCardsScreenFilter filter;
 final  List<ReceivedRCard> _cards;
@override@JsonKey() List<ReceivedRCard> get cards {
  if (_cards is EqualUnmodifiableListView) return _cards;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_cards);
}

@override@JsonKey() final  bool isSearchActive;
@override@JsonKey() final  bool hasFilterApplied;

/// Create a copy of RCardsScreenState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RCardsScreenStateCopyWith<_RCardsScreenState> get copyWith => __$RCardsScreenStateCopyWithImpl<_RCardsScreenState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RCardsScreenState&&(identical(other.filter, filter) || other.filter == filter)&&const DeepCollectionEquality().equals(other._cards, _cards)&&(identical(other.isSearchActive, isSearchActive) || other.isSearchActive == isSearchActive)&&(identical(other.hasFilterApplied, hasFilterApplied) || other.hasFilterApplied == hasFilterApplied));
}


@override
int get hashCode => Object.hash(runtimeType,filter,const DeepCollectionEquality().hash(_cards),isSearchActive,hasFilterApplied);

@override
String toString() {
  return 'RCardsScreenState(filter: $filter, cards: $cards, isSearchActive: $isSearchActive, hasFilterApplied: $hasFilterApplied)';
}


}

/// @nodoc
abstract mixin class _$RCardsScreenStateCopyWith<$Res> implements $RCardsScreenStateCopyWith<$Res> {
  factory _$RCardsScreenStateCopyWith(_RCardsScreenState value, $Res Function(_RCardsScreenState) _then) = __$RCardsScreenStateCopyWithImpl;
@override @useResult
$Res call({
 RCardsScreenFilter filter, List<ReceivedRCard> cards, bool isSearchActive, bool hasFilterApplied
});




}
/// @nodoc
class __$RCardsScreenStateCopyWithImpl<$Res>
    implements _$RCardsScreenStateCopyWith<$Res> {
  __$RCardsScreenStateCopyWithImpl(this._self, this._then);

  final _RCardsScreenState _self;
  final $Res Function(_RCardsScreenState) _then;

/// Create a copy of RCardsScreenState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? filter = null,Object? cards = null,Object? isSearchActive = null,Object? hasFilterApplied = null,}) {
  return _then(_RCardsScreenState(
filter: null == filter ? _self.filter : filter // ignore: cast_nullable_to_non_nullable
as RCardsScreenFilter,cards: null == cards ? _self._cards : cards // ignore: cast_nullable_to_non_nullable
as List<ReceivedRCard>,isSearchActive: null == isSearchActive ? _self.isSearchActive : isSearchActive // ignore: cast_nullable_to_non_nullable
as bool,hasFilterApplied: null == hasFilterApplied ? _self.hasFilterApplied : hasFilterApplied // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
