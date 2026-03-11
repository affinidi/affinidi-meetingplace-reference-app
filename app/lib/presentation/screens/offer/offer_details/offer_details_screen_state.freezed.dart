// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'offer_details_screen_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$OfferDetailsScreenState {

 ConnectionOffer? get offer; Identity? get publisherIdentity; String? get groupDid; bool get isUsingPrimaryIdentity; bool get isDebugMode; bool get showQrIcon; bool get showQrView;
/// Create a copy of OfferDetailsScreenState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OfferDetailsScreenStateCopyWith<OfferDetailsScreenState> get copyWith => _$OfferDetailsScreenStateCopyWithImpl<OfferDetailsScreenState>(this as OfferDetailsScreenState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OfferDetailsScreenState&&(identical(other.offer, offer) || other.offer == offer)&&(identical(other.publisherIdentity, publisherIdentity) || other.publisherIdentity == publisherIdentity)&&(identical(other.groupDid, groupDid) || other.groupDid == groupDid)&&(identical(other.isUsingPrimaryIdentity, isUsingPrimaryIdentity) || other.isUsingPrimaryIdentity == isUsingPrimaryIdentity)&&(identical(other.isDebugMode, isDebugMode) || other.isDebugMode == isDebugMode)&&(identical(other.showQrIcon, showQrIcon) || other.showQrIcon == showQrIcon)&&(identical(other.showQrView, showQrView) || other.showQrView == showQrView));
}


@override
int get hashCode => Object.hash(runtimeType,offer,publisherIdentity,groupDid,isUsingPrimaryIdentity,isDebugMode,showQrIcon,showQrView);

@override
String toString() {
  return 'OfferDetailsScreenState(offer: $offer, publisherIdentity: $publisherIdentity, groupDid: $groupDid, isUsingPrimaryIdentity: $isUsingPrimaryIdentity, isDebugMode: $isDebugMode, showQrIcon: $showQrIcon, showQrView: $showQrView)';
}


}

/// @nodoc
abstract mixin class $OfferDetailsScreenStateCopyWith<$Res>  {
  factory $OfferDetailsScreenStateCopyWith(OfferDetailsScreenState value, $Res Function(OfferDetailsScreenState) _then) = _$OfferDetailsScreenStateCopyWithImpl;
@useResult
$Res call({
 ConnectionOffer? offer, Identity? publisherIdentity, String? groupDid, bool isUsingPrimaryIdentity, bool isDebugMode, bool showQrIcon, bool showQrView
});


$IdentityCopyWith<$Res>? get publisherIdentity;

}
/// @nodoc
class _$OfferDetailsScreenStateCopyWithImpl<$Res>
    implements $OfferDetailsScreenStateCopyWith<$Res> {
  _$OfferDetailsScreenStateCopyWithImpl(this._self, this._then);

  final OfferDetailsScreenState _self;
  final $Res Function(OfferDetailsScreenState) _then;

/// Create a copy of OfferDetailsScreenState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? offer = freezed,Object? publisherIdentity = freezed,Object? groupDid = freezed,Object? isUsingPrimaryIdentity = null,Object? isDebugMode = null,Object? showQrIcon = null,Object? showQrView = null,}) {
  return _then(_self.copyWith(
offer: freezed == offer ? _self.offer : offer // ignore: cast_nullable_to_non_nullable
as ConnectionOffer?,publisherIdentity: freezed == publisherIdentity ? _self.publisherIdentity : publisherIdentity // ignore: cast_nullable_to_non_nullable
as Identity?,groupDid: freezed == groupDid ? _self.groupDid : groupDid // ignore: cast_nullable_to_non_nullable
as String?,isUsingPrimaryIdentity: null == isUsingPrimaryIdentity ? _self.isUsingPrimaryIdentity : isUsingPrimaryIdentity // ignore: cast_nullable_to_non_nullable
as bool,isDebugMode: null == isDebugMode ? _self.isDebugMode : isDebugMode // ignore: cast_nullable_to_non_nullable
as bool,showQrIcon: null == showQrIcon ? _self.showQrIcon : showQrIcon // ignore: cast_nullable_to_non_nullable
as bool,showQrView: null == showQrView ? _self.showQrView : showQrView // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}
/// Create a copy of OfferDetailsScreenState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$IdentityCopyWith<$Res>? get publisherIdentity {
    if (_self.publisherIdentity == null) {
    return null;
  }

  return $IdentityCopyWith<$Res>(_self.publisherIdentity!, (value) {
    return _then(_self.copyWith(publisherIdentity: value));
  });
}
}


/// Adds pattern-matching-related methods to [OfferDetailsScreenState].
extension OfferDetailsScreenStatePatterns on OfferDetailsScreenState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OfferDetailsScreenState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OfferDetailsScreenState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OfferDetailsScreenState value)  $default,){
final _that = this;
switch (_that) {
case _OfferDetailsScreenState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OfferDetailsScreenState value)?  $default,){
final _that = this;
switch (_that) {
case _OfferDetailsScreenState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( ConnectionOffer? offer,  Identity? publisherIdentity,  String? groupDid,  bool isUsingPrimaryIdentity,  bool isDebugMode,  bool showQrIcon,  bool showQrView)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OfferDetailsScreenState() when $default != null:
return $default(_that.offer,_that.publisherIdentity,_that.groupDid,_that.isUsingPrimaryIdentity,_that.isDebugMode,_that.showQrIcon,_that.showQrView);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( ConnectionOffer? offer,  Identity? publisherIdentity,  String? groupDid,  bool isUsingPrimaryIdentity,  bool isDebugMode,  bool showQrIcon,  bool showQrView)  $default,) {final _that = this;
switch (_that) {
case _OfferDetailsScreenState():
return $default(_that.offer,_that.publisherIdentity,_that.groupDid,_that.isUsingPrimaryIdentity,_that.isDebugMode,_that.showQrIcon,_that.showQrView);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( ConnectionOffer? offer,  Identity? publisherIdentity,  String? groupDid,  bool isUsingPrimaryIdentity,  bool isDebugMode,  bool showQrIcon,  bool showQrView)?  $default,) {final _that = this;
switch (_that) {
case _OfferDetailsScreenState() when $default != null:
return $default(_that.offer,_that.publisherIdentity,_that.groupDid,_that.isUsingPrimaryIdentity,_that.isDebugMode,_that.showQrIcon,_that.showQrView);case _:
  return null;

}
}

}

/// @nodoc


class _OfferDetailsScreenState implements OfferDetailsScreenState {
   _OfferDetailsScreenState({this.offer, this.publisherIdentity, this.groupDid, this.isUsingPrimaryIdentity = false, this.isDebugMode = false, this.showQrIcon = false, this.showQrView = false});
  

@override final  ConnectionOffer? offer;
@override final  Identity? publisherIdentity;
@override final  String? groupDid;
@override@JsonKey() final  bool isUsingPrimaryIdentity;
@override@JsonKey() final  bool isDebugMode;
@override@JsonKey() final  bool showQrIcon;
@override@JsonKey() final  bool showQrView;

/// Create a copy of OfferDetailsScreenState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OfferDetailsScreenStateCopyWith<_OfferDetailsScreenState> get copyWith => __$OfferDetailsScreenStateCopyWithImpl<_OfferDetailsScreenState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OfferDetailsScreenState&&(identical(other.offer, offer) || other.offer == offer)&&(identical(other.publisherIdentity, publisherIdentity) || other.publisherIdentity == publisherIdentity)&&(identical(other.groupDid, groupDid) || other.groupDid == groupDid)&&(identical(other.isUsingPrimaryIdentity, isUsingPrimaryIdentity) || other.isUsingPrimaryIdentity == isUsingPrimaryIdentity)&&(identical(other.isDebugMode, isDebugMode) || other.isDebugMode == isDebugMode)&&(identical(other.showQrIcon, showQrIcon) || other.showQrIcon == showQrIcon)&&(identical(other.showQrView, showQrView) || other.showQrView == showQrView));
}


@override
int get hashCode => Object.hash(runtimeType,offer,publisherIdentity,groupDid,isUsingPrimaryIdentity,isDebugMode,showQrIcon,showQrView);

@override
String toString() {
  return 'OfferDetailsScreenState(offer: $offer, publisherIdentity: $publisherIdentity, groupDid: $groupDid, isUsingPrimaryIdentity: $isUsingPrimaryIdentity, isDebugMode: $isDebugMode, showQrIcon: $showQrIcon, showQrView: $showQrView)';
}


}

/// @nodoc
abstract mixin class _$OfferDetailsScreenStateCopyWith<$Res> implements $OfferDetailsScreenStateCopyWith<$Res> {
  factory _$OfferDetailsScreenStateCopyWith(_OfferDetailsScreenState value, $Res Function(_OfferDetailsScreenState) _then) = __$OfferDetailsScreenStateCopyWithImpl;
@override @useResult
$Res call({
 ConnectionOffer? offer, Identity? publisherIdentity, String? groupDid, bool isUsingPrimaryIdentity, bool isDebugMode, bool showQrIcon, bool showQrView
});


@override $IdentityCopyWith<$Res>? get publisherIdentity;

}
/// @nodoc
class __$OfferDetailsScreenStateCopyWithImpl<$Res>
    implements _$OfferDetailsScreenStateCopyWith<$Res> {
  __$OfferDetailsScreenStateCopyWithImpl(this._self, this._then);

  final _OfferDetailsScreenState _self;
  final $Res Function(_OfferDetailsScreenState) _then;

/// Create a copy of OfferDetailsScreenState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? offer = freezed,Object? publisherIdentity = freezed,Object? groupDid = freezed,Object? isUsingPrimaryIdentity = null,Object? isDebugMode = null,Object? showQrIcon = null,Object? showQrView = null,}) {
  return _then(_OfferDetailsScreenState(
offer: freezed == offer ? _self.offer : offer // ignore: cast_nullable_to_non_nullable
as ConnectionOffer?,publisherIdentity: freezed == publisherIdentity ? _self.publisherIdentity : publisherIdentity // ignore: cast_nullable_to_non_nullable
as Identity?,groupDid: freezed == groupDid ? _self.groupDid : groupDid // ignore: cast_nullable_to_non_nullable
as String?,isUsingPrimaryIdentity: null == isUsingPrimaryIdentity ? _self.isUsingPrimaryIdentity : isUsingPrimaryIdentity // ignore: cast_nullable_to_non_nullable
as bool,isDebugMode: null == isDebugMode ? _self.isDebugMode : isDebugMode // ignore: cast_nullable_to_non_nullable
as bool,showQrIcon: null == showQrIcon ? _self.showQrIcon : showQrIcon // ignore: cast_nullable_to_non_nullable
as bool,showQrView: null == showQrView ? _self.showQrView : showQrView // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of OfferDetailsScreenState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$IdentityCopyWith<$Res>? get publisherIdentity {
    if (_self.publisherIdentity == null) {
    return null;
  }

  return $IdentityCopyWith<$Res>(_self.publisherIdentity!, (value) {
    return _then(_self.copyWith(publisherIdentity: value));
  });
}
}

// dart format on
