// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'vrc_details_screen_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$VrcDetailsScreenState {

 VrcCredentialSubject? get subject; List<String> get credentialTypes;
/// Create a copy of VrcDetailsScreenState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VrcDetailsScreenStateCopyWith<VrcDetailsScreenState> get copyWith => _$VrcDetailsScreenStateCopyWithImpl<VrcDetailsScreenState>(this as VrcDetailsScreenState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VrcDetailsScreenState&&(identical(other.subject, subject) || other.subject == subject)&&const DeepCollectionEquality().equals(other.credentialTypes, credentialTypes));
}


@override
int get hashCode => Object.hash(runtimeType,subject,const DeepCollectionEquality().hash(credentialTypes));

@override
String toString() {
  return 'VrcDetailsScreenState(subject: $subject, credentialTypes: $credentialTypes)';
}


}

/// @nodoc
abstract mixin class $VrcDetailsScreenStateCopyWith<$Res>  {
  factory $VrcDetailsScreenStateCopyWith(VrcDetailsScreenState value, $Res Function(VrcDetailsScreenState) _then) = _$VrcDetailsScreenStateCopyWithImpl;
@useResult
$Res call({
 VrcCredentialSubject? subject, List<String> credentialTypes
});




}
/// @nodoc
class _$VrcDetailsScreenStateCopyWithImpl<$Res>
    implements $VrcDetailsScreenStateCopyWith<$Res> {
  _$VrcDetailsScreenStateCopyWithImpl(this._self, this._then);

  final VrcDetailsScreenState _self;
  final $Res Function(VrcDetailsScreenState) _then;

/// Create a copy of VrcDetailsScreenState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? subject = freezed,Object? credentialTypes = null,}) {
  return _then(_self.copyWith(
subject: freezed == subject ? _self.subject : subject // ignore: cast_nullable_to_non_nullable
as VrcCredentialSubject?,credentialTypes: null == credentialTypes ? _self.credentialTypes : credentialTypes // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [VrcDetailsScreenState].
extension VrcDetailsScreenStatePatterns on VrcDetailsScreenState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VrcDetailsScreenState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VrcDetailsScreenState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VrcDetailsScreenState value)  $default,){
final _that = this;
switch (_that) {
case _VrcDetailsScreenState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VrcDetailsScreenState value)?  $default,){
final _that = this;
switch (_that) {
case _VrcDetailsScreenState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( VrcCredentialSubject? subject,  List<String> credentialTypes)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VrcDetailsScreenState() when $default != null:
return $default(_that.subject,_that.credentialTypes);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( VrcCredentialSubject? subject,  List<String> credentialTypes)  $default,) {final _that = this;
switch (_that) {
case _VrcDetailsScreenState():
return $default(_that.subject,_that.credentialTypes);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( VrcCredentialSubject? subject,  List<String> credentialTypes)?  $default,) {final _that = this;
switch (_that) {
case _VrcDetailsScreenState() when $default != null:
return $default(_that.subject,_that.credentialTypes);case _:
  return null;

}
}

}

/// @nodoc


class _VrcDetailsScreenState implements VrcDetailsScreenState {
   _VrcDetailsScreenState({this.subject, final  List<String> credentialTypes = const []}): _credentialTypes = credentialTypes;
  

@override final  VrcCredentialSubject? subject;
 final  List<String> _credentialTypes;
@override@JsonKey() List<String> get credentialTypes {
  if (_credentialTypes is EqualUnmodifiableListView) return _credentialTypes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_credentialTypes);
}


/// Create a copy of VrcDetailsScreenState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VrcDetailsScreenStateCopyWith<_VrcDetailsScreenState> get copyWith => __$VrcDetailsScreenStateCopyWithImpl<_VrcDetailsScreenState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _VrcDetailsScreenState&&(identical(other.subject, subject) || other.subject == subject)&&const DeepCollectionEquality().equals(other._credentialTypes, _credentialTypes));
}


@override
int get hashCode => Object.hash(runtimeType,subject,const DeepCollectionEquality().hash(_credentialTypes));

@override
String toString() {
  return 'VrcDetailsScreenState(subject: $subject, credentialTypes: $credentialTypes)';
}


}

/// @nodoc
abstract mixin class _$VrcDetailsScreenStateCopyWith<$Res> implements $VrcDetailsScreenStateCopyWith<$Res> {
  factory _$VrcDetailsScreenStateCopyWith(_VrcDetailsScreenState value, $Res Function(_VrcDetailsScreenState) _then) = __$VrcDetailsScreenStateCopyWithImpl;
@override @useResult
$Res call({
 VrcCredentialSubject? subject, List<String> credentialTypes
});




}
/// @nodoc
class __$VrcDetailsScreenStateCopyWithImpl<$Res>
    implements _$VrcDetailsScreenStateCopyWith<$Res> {
  __$VrcDetailsScreenStateCopyWithImpl(this._self, this._then);

  final _VrcDetailsScreenState _self;
  final $Res Function(_VrcDetailsScreenState) _then;

/// Create a copy of VrcDetailsScreenState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? subject = freezed,Object? credentialTypes = null,}) {
  return _then(_VrcDetailsScreenState(
subject: freezed == subject ? _self.subject : subject // ignore: cast_nullable_to_non_nullable
as VrcCredentialSubject?,credentialTypes: null == credentialTypes ? _self._credentialTypes : credentialTypes // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

// dart format on
