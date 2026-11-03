// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'vta_link_screen_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$VtaLinkScreenState {

 VtaLinkState get link; bool get isBusy; VtaLinkFailure? get failure;
/// Create a copy of VtaLinkScreenState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VtaLinkScreenStateCopyWith<VtaLinkScreenState> get copyWith => _$VtaLinkScreenStateCopyWithImpl<VtaLinkScreenState>(this as VtaLinkScreenState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VtaLinkScreenState&&(identical(other.link, link) || other.link == link)&&(identical(other.isBusy, isBusy) || other.isBusy == isBusy)&&(identical(other.failure, failure) || other.failure == failure));
}


@override
int get hashCode => Object.hash(runtimeType,link,isBusy,failure);

@override
String toString() {
  return 'VtaLinkScreenState(link: $link, isBusy: $isBusy, failure: $failure)';
}


}

/// @nodoc
abstract mixin class $VtaLinkScreenStateCopyWith<$Res>  {
  factory $VtaLinkScreenStateCopyWith(VtaLinkScreenState value, $Res Function(VtaLinkScreenState) _then) = _$VtaLinkScreenStateCopyWithImpl;
@useResult
$Res call({
 VtaLinkState link, bool isBusy, VtaLinkFailure? failure
});




}
/// @nodoc
class _$VtaLinkScreenStateCopyWithImpl<$Res>
    implements $VtaLinkScreenStateCopyWith<$Res> {
  _$VtaLinkScreenStateCopyWithImpl(this._self, this._then);

  final VtaLinkScreenState _self;
  final $Res Function(VtaLinkScreenState) _then;

/// Create a copy of VtaLinkScreenState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? link = null,Object? isBusy = null,Object? failure = freezed,}) {
  return _then(_self.copyWith(
link: null == link ? _self.link : link // ignore: cast_nullable_to_non_nullable
as VtaLinkState,isBusy: null == isBusy ? _self.isBusy : isBusy // ignore: cast_nullable_to_non_nullable
as bool,failure: freezed == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as VtaLinkFailure?,
  ));
}

}


/// Adds pattern-matching-related methods to [VtaLinkScreenState].
extension VtaLinkScreenStatePatterns on VtaLinkScreenState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VtaLinkScreenState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VtaLinkScreenState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VtaLinkScreenState value)  $default,){
final _that = this;
switch (_that) {
case _VtaLinkScreenState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VtaLinkScreenState value)?  $default,){
final _that = this;
switch (_that) {
case _VtaLinkScreenState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( VtaLinkState link,  bool isBusy,  VtaLinkFailure? failure)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VtaLinkScreenState() when $default != null:
return $default(_that.link,_that.isBusy,_that.failure);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( VtaLinkState link,  bool isBusy,  VtaLinkFailure? failure)  $default,) {final _that = this;
switch (_that) {
case _VtaLinkScreenState():
return $default(_that.link,_that.isBusy,_that.failure);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( VtaLinkState link,  bool isBusy,  VtaLinkFailure? failure)?  $default,) {final _that = this;
switch (_that) {
case _VtaLinkScreenState() when $default != null:
return $default(_that.link,_that.isBusy,_that.failure);case _:
  return null;

}
}

}

/// @nodoc


class _VtaLinkScreenState implements VtaLinkScreenState {
   _VtaLinkScreenState({this.link = const VtaLinkState(), this.isBusy = false, this.failure});
  

@override@JsonKey() final  VtaLinkState link;
@override@JsonKey() final  bool isBusy;
@override final  VtaLinkFailure? failure;

/// Create a copy of VtaLinkScreenState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VtaLinkScreenStateCopyWith<_VtaLinkScreenState> get copyWith => __$VtaLinkScreenStateCopyWithImpl<_VtaLinkScreenState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _VtaLinkScreenState&&(identical(other.link, link) || other.link == link)&&(identical(other.isBusy, isBusy) || other.isBusy == isBusy)&&(identical(other.failure, failure) || other.failure == failure));
}


@override
int get hashCode => Object.hash(runtimeType,link,isBusy,failure);

@override
String toString() {
  return 'VtaLinkScreenState(link: $link, isBusy: $isBusy, failure: $failure)';
}


}

/// @nodoc
abstract mixin class _$VtaLinkScreenStateCopyWith<$Res> implements $VtaLinkScreenStateCopyWith<$Res> {
  factory _$VtaLinkScreenStateCopyWith(_VtaLinkScreenState value, $Res Function(_VtaLinkScreenState) _then) = __$VtaLinkScreenStateCopyWithImpl;
@override @useResult
$Res call({
 VtaLinkState link, bool isBusy, VtaLinkFailure? failure
});




}
/// @nodoc
class __$VtaLinkScreenStateCopyWithImpl<$Res>
    implements _$VtaLinkScreenStateCopyWith<$Res> {
  __$VtaLinkScreenStateCopyWithImpl(this._self, this._then);

  final _VtaLinkScreenState _self;
  final $Res Function(_VtaLinkScreenState) _then;

/// Create a copy of VtaLinkScreenState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? link = null,Object? isBusy = null,Object? failure = freezed,}) {
  return _then(_VtaLinkScreenState(
link: null == link ? _self.link : link // ignore: cast_nullable_to_non_nullable
as VtaLinkState,isBusy: null == isBusy ? _self.isBusy : isBusy // ignore: cast_nullable_to_non_nullable
as bool,failure: freezed == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as VtaLinkFailure?,
  ));
}


}

// dart format on
