// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'mnemonic_screen_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$MnemonicScreenState {

 bool get isLoading; bool get isError; String? get errorMessage;
/// Create a copy of MnemonicScreenState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MnemonicScreenStateCopyWith<MnemonicScreenState> get copyWith => _$MnemonicScreenStateCopyWithImpl<MnemonicScreenState>(this as MnemonicScreenState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MnemonicScreenState&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.isError, isError) || other.isError == isError)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}


@override
int get hashCode => Object.hash(runtimeType,isLoading,isError,errorMessage);

@override
String toString() {
  return 'MnemonicScreenState(isLoading: $isLoading, isError: $isError, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class $MnemonicScreenStateCopyWith<$Res>  {
  factory $MnemonicScreenStateCopyWith(MnemonicScreenState value, $Res Function(MnemonicScreenState) _then) = _$MnemonicScreenStateCopyWithImpl;
@useResult
$Res call({
 bool isLoading, bool isError, String? errorMessage
});




}
/// @nodoc
class _$MnemonicScreenStateCopyWithImpl<$Res>
    implements $MnemonicScreenStateCopyWith<$Res> {
  _$MnemonicScreenStateCopyWithImpl(this._self, this._then);

  final MnemonicScreenState _self;
  final $Res Function(MnemonicScreenState) _then;

/// Create a copy of MnemonicScreenState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? isLoading = null,Object? isError = null,Object? errorMessage = freezed,}) {
  return _then(_self.copyWith(
isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,isError: null == isError ? _self.isError : isError // ignore: cast_nullable_to_non_nullable
as bool,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [MnemonicScreenState].
extension MnemonicScreenStatePatterns on MnemonicScreenState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MnemonicScreenState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MnemonicScreenState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MnemonicScreenState value)  $default,){
final _that = this;
switch (_that) {
case _MnemonicScreenState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MnemonicScreenState value)?  $default,){
final _that = this;
switch (_that) {
case _MnemonicScreenState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool isLoading,  bool isError,  String? errorMessage)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MnemonicScreenState() when $default != null:
return $default(_that.isLoading,_that.isError,_that.errorMessage);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool isLoading,  bool isError,  String? errorMessage)  $default,) {final _that = this;
switch (_that) {
case _MnemonicScreenState():
return $default(_that.isLoading,_that.isError,_that.errorMessage);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool isLoading,  bool isError,  String? errorMessage)?  $default,) {final _that = this;
switch (_that) {
case _MnemonicScreenState() when $default != null:
return $default(_that.isLoading,_that.isError,_that.errorMessage);case _:
  return null;

}
}

}

/// @nodoc


class _MnemonicScreenState implements MnemonicScreenState {
  const _MnemonicScreenState({this.isLoading = false, this.isError = false, this.errorMessage});
  

@override@JsonKey() final  bool isLoading;
@override@JsonKey() final  bool isError;
@override final  String? errorMessage;

/// Create a copy of MnemonicScreenState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MnemonicScreenStateCopyWith<_MnemonicScreenState> get copyWith => __$MnemonicScreenStateCopyWithImpl<_MnemonicScreenState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MnemonicScreenState&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.isError, isError) || other.isError == isError)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}


@override
int get hashCode => Object.hash(runtimeType,isLoading,isError,errorMessage);

@override
String toString() {
  return 'MnemonicScreenState(isLoading: $isLoading, isError: $isError, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class _$MnemonicScreenStateCopyWith<$Res> implements $MnemonicScreenStateCopyWith<$Res> {
  factory _$MnemonicScreenStateCopyWith(_MnemonicScreenState value, $Res Function(_MnemonicScreenState) _then) = __$MnemonicScreenStateCopyWithImpl;
@override @useResult
$Res call({
 bool isLoading, bool isError, String? errorMessage
});




}
/// @nodoc
class __$MnemonicScreenStateCopyWithImpl<$Res>
    implements _$MnemonicScreenStateCopyWith<$Res> {
  __$MnemonicScreenStateCopyWithImpl(this._self, this._then);

  final _MnemonicScreenState _self;
  final $Res Function(_MnemonicScreenState) _then;

/// Create a copy of MnemonicScreenState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? isLoading = null,Object? isError = null,Object? errorMessage = freezed,}) {
  return _then(_MnemonicScreenState(
isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,isError: null == isError ? _self.isError : isError // ignore: cast_nullable_to_non_nullable
as bool,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
