// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'end_call_banner_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$EndCallBannerState {

 String get contactId; String get peerName; CallEndState get endState; bool get isAudioOnly; double get slideOutOffset;
/// Create a copy of EndCallBannerState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EndCallBannerStateCopyWith<EndCallBannerState> get copyWith => _$EndCallBannerStateCopyWithImpl<EndCallBannerState>(this as EndCallBannerState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EndCallBannerState&&(identical(other.contactId, contactId) || other.contactId == contactId)&&(identical(other.peerName, peerName) || other.peerName == peerName)&&(identical(other.endState, endState) || other.endState == endState)&&(identical(other.isAudioOnly, isAudioOnly) || other.isAudioOnly == isAudioOnly)&&(identical(other.slideOutOffset, slideOutOffset) || other.slideOutOffset == slideOutOffset));
}


@override
int get hashCode => Object.hash(runtimeType,contactId,peerName,endState,isAudioOnly,slideOutOffset);

@override
String toString() {
  return 'EndCallBannerState(contactId: $contactId, peerName: $peerName, endState: $endState, isAudioOnly: $isAudioOnly, slideOutOffset: $slideOutOffset)';
}


}

/// @nodoc
abstract mixin class $EndCallBannerStateCopyWith<$Res>  {
  factory $EndCallBannerStateCopyWith(EndCallBannerState value, $Res Function(EndCallBannerState) _then) = _$EndCallBannerStateCopyWithImpl;
@useResult
$Res call({
 String contactId, String peerName, CallEndState endState, bool isAudioOnly, double slideOutOffset
});




}
/// @nodoc
class _$EndCallBannerStateCopyWithImpl<$Res>
    implements $EndCallBannerStateCopyWith<$Res> {
  _$EndCallBannerStateCopyWithImpl(this._self, this._then);

  final EndCallBannerState _self;
  final $Res Function(EndCallBannerState) _then;

/// Create a copy of EndCallBannerState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? contactId = null,Object? peerName = null,Object? endState = null,Object? isAudioOnly = null,Object? slideOutOffset = null,}) {
  return _then(_self.copyWith(
contactId: null == contactId ? _self.contactId : contactId // ignore: cast_nullable_to_non_nullable
as String,peerName: null == peerName ? _self.peerName : peerName // ignore: cast_nullable_to_non_nullable
as String,endState: null == endState ? _self.endState : endState // ignore: cast_nullable_to_non_nullable
as CallEndState,isAudioOnly: null == isAudioOnly ? _self.isAudioOnly : isAudioOnly // ignore: cast_nullable_to_non_nullable
as bool,slideOutOffset: null == slideOutOffset ? _self.slideOutOffset : slideOutOffset // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [EndCallBannerState].
extension EndCallBannerStatePatterns on EndCallBannerState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EndCallBannerState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EndCallBannerState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EndCallBannerState value)  $default,){
final _that = this;
switch (_that) {
case _EndCallBannerState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EndCallBannerState value)?  $default,){
final _that = this;
switch (_that) {
case _EndCallBannerState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String contactId,  String peerName,  CallEndState endState,  bool isAudioOnly,  double slideOutOffset)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EndCallBannerState() when $default != null:
return $default(_that.contactId,_that.peerName,_that.endState,_that.isAudioOnly,_that.slideOutOffset);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String contactId,  String peerName,  CallEndState endState,  bool isAudioOnly,  double slideOutOffset)  $default,) {final _that = this;
switch (_that) {
case _EndCallBannerState():
return $default(_that.contactId,_that.peerName,_that.endState,_that.isAudioOnly,_that.slideOutOffset);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String contactId,  String peerName,  CallEndState endState,  bool isAudioOnly,  double slideOutOffset)?  $default,) {final _that = this;
switch (_that) {
case _EndCallBannerState() when $default != null:
return $default(_that.contactId,_that.peerName,_that.endState,_that.isAudioOnly,_that.slideOutOffset);case _:
  return null;

}
}

}

/// @nodoc


class _EndCallBannerState implements EndCallBannerState {
  const _EndCallBannerState({required this.contactId, required this.peerName, required this.endState, required this.isAudioOnly, this.slideOutOffset = 0.0});
  

@override final  String contactId;
@override final  String peerName;
@override final  CallEndState endState;
@override final  bool isAudioOnly;
@override@JsonKey() final  double slideOutOffset;

/// Create a copy of EndCallBannerState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EndCallBannerStateCopyWith<_EndCallBannerState> get copyWith => __$EndCallBannerStateCopyWithImpl<_EndCallBannerState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _EndCallBannerState&&(identical(other.contactId, contactId) || other.contactId == contactId)&&(identical(other.peerName, peerName) || other.peerName == peerName)&&(identical(other.endState, endState) || other.endState == endState)&&(identical(other.isAudioOnly, isAudioOnly) || other.isAudioOnly == isAudioOnly)&&(identical(other.slideOutOffset, slideOutOffset) || other.slideOutOffset == slideOutOffset));
}


@override
int get hashCode => Object.hash(runtimeType,contactId,peerName,endState,isAudioOnly,slideOutOffset);

@override
String toString() {
  return 'EndCallBannerState(contactId: $contactId, peerName: $peerName, endState: $endState, isAudioOnly: $isAudioOnly, slideOutOffset: $slideOutOffset)';
}


}

/// @nodoc
abstract mixin class _$EndCallBannerStateCopyWith<$Res> implements $EndCallBannerStateCopyWith<$Res> {
  factory _$EndCallBannerStateCopyWith(_EndCallBannerState value, $Res Function(_EndCallBannerState) _then) = __$EndCallBannerStateCopyWithImpl;
@override @useResult
$Res call({
 String contactId, String peerName, CallEndState endState, bool isAudioOnly, double slideOutOffset
});




}
/// @nodoc
class __$EndCallBannerStateCopyWithImpl<$Res>
    implements _$EndCallBannerStateCopyWith<$Res> {
  __$EndCallBannerStateCopyWithImpl(this._self, this._then);

  final _EndCallBannerState _self;
  final $Res Function(_EndCallBannerState) _then;

/// Create a copy of EndCallBannerState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? contactId = null,Object? peerName = null,Object? endState = null,Object? isAudioOnly = null,Object? slideOutOffset = null,}) {
  return _then(_EndCallBannerState(
contactId: null == contactId ? _self.contactId : contactId // ignore: cast_nullable_to_non_nullable
as String,peerName: null == peerName ? _self.peerName : peerName // ignore: cast_nullable_to_non_nullable
as String,endState: null == endState ? _self.endState : endState // ignore: cast_nullable_to_non_nullable
as CallEndState,isAudioOnly: null == isAudioOnly ? _self.isAudioOnly : isAudioOnly // ignore: cast_nullable_to_non_nullable
as bool,slideOutOffset: null == slideOutOffset ? _self.slideOutOffset : slideOutOffset // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

// dart format on
