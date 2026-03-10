// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'accept_offer_screen_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AcceptOfferScreenState {

 ConnectionOffer? get offer; String? get error; Identity? get selectedIdentity; List<Identity> get identities;
/// Create a copy of AcceptOfferScreenState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AcceptOfferScreenStateCopyWith<AcceptOfferScreenState> get copyWith => _$AcceptOfferScreenStateCopyWithImpl<AcceptOfferScreenState>(this as AcceptOfferScreenState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AcceptOfferScreenState&&(identical(other.offer, offer) || other.offer == offer)&&(identical(other.error, error) || other.error == error)&&(identical(other.selectedIdentity, selectedIdentity) || other.selectedIdentity == selectedIdentity)&&const DeepCollectionEquality().equals(other.identities, identities));
}


@override
int get hashCode => Object.hash(runtimeType,offer,error,selectedIdentity,const DeepCollectionEquality().hash(identities));

@override
String toString() {
  return 'AcceptOfferScreenState(offer: $offer, error: $error, selectedIdentity: $selectedIdentity, identities: $identities)';
}


}

/// @nodoc
abstract mixin class $AcceptOfferScreenStateCopyWith<$Res>  {
  factory $AcceptOfferScreenStateCopyWith(AcceptOfferScreenState value, $Res Function(AcceptOfferScreenState) _then) = _$AcceptOfferScreenStateCopyWithImpl;
@useResult
$Res call({
 ConnectionOffer? offer, String? error, Identity? selectedIdentity, List<Identity> identities
});


$IdentityCopyWith<$Res>? get selectedIdentity;

}
/// @nodoc
class _$AcceptOfferScreenStateCopyWithImpl<$Res>
    implements $AcceptOfferScreenStateCopyWith<$Res> {
  _$AcceptOfferScreenStateCopyWithImpl(this._self, this._then);

  final AcceptOfferScreenState _self;
  final $Res Function(AcceptOfferScreenState) _then;

/// Create a copy of AcceptOfferScreenState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? offer = freezed,Object? error = freezed,Object? selectedIdentity = freezed,Object? identities = null,}) {
  return _then(_self.copyWith(
offer: freezed == offer ? _self.offer : offer // ignore: cast_nullable_to_non_nullable
as ConnectionOffer?,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,selectedIdentity: freezed == selectedIdentity ? _self.selectedIdentity : selectedIdentity // ignore: cast_nullable_to_non_nullable
as Identity?,identities: null == identities ? _self.identities : identities // ignore: cast_nullable_to_non_nullable
as List<Identity>,
  ));
}
/// Create a copy of AcceptOfferScreenState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$IdentityCopyWith<$Res>? get selectedIdentity {
    if (_self.selectedIdentity == null) {
    return null;
  }

  return $IdentityCopyWith<$Res>(_self.selectedIdentity!, (value) {
    return _then(_self.copyWith(selectedIdentity: value));
  });
}
}


/// Adds pattern-matching-related methods to [AcceptOfferScreenState].
extension AcceptOfferScreenStatePatterns on AcceptOfferScreenState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AcceptOfferScreenState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AcceptOfferScreenState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AcceptOfferScreenState value)  $default,){
final _that = this;
switch (_that) {
case _AcceptOfferScreenState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AcceptOfferScreenState value)?  $default,){
final _that = this;
switch (_that) {
case _AcceptOfferScreenState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( ConnectionOffer? offer,  String? error,  Identity? selectedIdentity,  List<Identity> identities)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AcceptOfferScreenState() when $default != null:
return $default(_that.offer,_that.error,_that.selectedIdentity,_that.identities);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( ConnectionOffer? offer,  String? error,  Identity? selectedIdentity,  List<Identity> identities)  $default,) {final _that = this;
switch (_that) {
case _AcceptOfferScreenState():
return $default(_that.offer,_that.error,_that.selectedIdentity,_that.identities);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( ConnectionOffer? offer,  String? error,  Identity? selectedIdentity,  List<Identity> identities)?  $default,) {final _that = this;
switch (_that) {
case _AcceptOfferScreenState() when $default != null:
return $default(_that.offer,_that.error,_that.selectedIdentity,_that.identities);case _:
  return null;

}
}

}

/// @nodoc


class _AcceptOfferScreenState implements AcceptOfferScreenState {
   _AcceptOfferScreenState({this.offer, this.error, this.selectedIdentity, final  List<Identity> identities = const []}): _identities = identities;
  

@override final  ConnectionOffer? offer;
@override final  String? error;
@override final  Identity? selectedIdentity;
 final  List<Identity> _identities;
@override@JsonKey() List<Identity> get identities {
  if (_identities is EqualUnmodifiableListView) return _identities;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_identities);
}


/// Create a copy of AcceptOfferScreenState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AcceptOfferScreenStateCopyWith<_AcceptOfferScreenState> get copyWith => __$AcceptOfferScreenStateCopyWithImpl<_AcceptOfferScreenState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AcceptOfferScreenState&&(identical(other.offer, offer) || other.offer == offer)&&(identical(other.error, error) || other.error == error)&&(identical(other.selectedIdentity, selectedIdentity) || other.selectedIdentity == selectedIdentity)&&const DeepCollectionEquality().equals(other._identities, _identities));
}


@override
int get hashCode => Object.hash(runtimeType,offer,error,selectedIdentity,const DeepCollectionEquality().hash(_identities));

@override
String toString() {
  return 'AcceptOfferScreenState(offer: $offer, error: $error, selectedIdentity: $selectedIdentity, identities: $identities)';
}


}

/// @nodoc
abstract mixin class _$AcceptOfferScreenStateCopyWith<$Res> implements $AcceptOfferScreenStateCopyWith<$Res> {
  factory _$AcceptOfferScreenStateCopyWith(_AcceptOfferScreenState value, $Res Function(_AcceptOfferScreenState) _then) = __$AcceptOfferScreenStateCopyWithImpl;
@override @useResult
$Res call({
 ConnectionOffer? offer, String? error, Identity? selectedIdentity, List<Identity> identities
});


@override $IdentityCopyWith<$Res>? get selectedIdentity;

}
/// @nodoc
class __$AcceptOfferScreenStateCopyWithImpl<$Res>
    implements _$AcceptOfferScreenStateCopyWith<$Res> {
  __$AcceptOfferScreenStateCopyWithImpl(this._self, this._then);

  final _AcceptOfferScreenState _self;
  final $Res Function(_AcceptOfferScreenState) _then;

/// Create a copy of AcceptOfferScreenState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? offer = freezed,Object? error = freezed,Object? selectedIdentity = freezed,Object? identities = null,}) {
  return _then(_AcceptOfferScreenState(
offer: freezed == offer ? _self.offer : offer // ignore: cast_nullable_to_non_nullable
as ConnectionOffer?,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,selectedIdentity: freezed == selectedIdentity ? _self.selectedIdentity : selectedIdentity // ignore: cast_nullable_to_non_nullable
as Identity?,identities: null == identities ? _self._identities : identities // ignore: cast_nullable_to_non_nullable
as List<Identity>,
  ));
}

/// Create a copy of AcceptOfferScreenState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$IdentityCopyWith<$Res>? get selectedIdentity {
    if (_self.selectedIdentity == null) {
    return null;
  }

  return $IdentityCopyWith<$Res>(_self.selectedIdentity!, (value) {
    return _then(_self.copyWith(selectedIdentity: value));
  });
}
}

// dart format on
