// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'mock_credentials_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$MockCredentialsState {

 bool get isLoading;/// The member's identities on their VTA, primary first.
 List<Identity> get identities;/// Which identities hold each test credential: by template id, then
/// identity DID.
 Map<String, Set<String>> get holders;/// The template being imported, while it is.
 String? get importing; MockCredentialsFailure? get failure;
/// Create a copy of MockCredentialsState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MockCredentialsStateCopyWith<MockCredentialsState> get copyWith => _$MockCredentialsStateCopyWithImpl<MockCredentialsState>(this as MockCredentialsState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MockCredentialsState&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&const DeepCollectionEquality().equals(other.identities, identities)&&const DeepCollectionEquality().equals(other.holders, holders)&&(identical(other.importing, importing) || other.importing == importing)&&(identical(other.failure, failure) || other.failure == failure));
}


@override
int get hashCode => Object.hash(runtimeType,isLoading,const DeepCollectionEquality().hash(identities),const DeepCollectionEquality().hash(holders),importing,failure);

@override
String toString() {
  return 'MockCredentialsState(isLoading: $isLoading, identities: $identities, holders: $holders, importing: $importing, failure: $failure)';
}


}

/// @nodoc
abstract mixin class $MockCredentialsStateCopyWith<$Res>  {
  factory $MockCredentialsStateCopyWith(MockCredentialsState value, $Res Function(MockCredentialsState) _then) = _$MockCredentialsStateCopyWithImpl;
@useResult
$Res call({
 bool isLoading, List<Identity> identities, Map<String, Set<String>> holders, String? importing, MockCredentialsFailure? failure
});




}
/// @nodoc
class _$MockCredentialsStateCopyWithImpl<$Res>
    implements $MockCredentialsStateCopyWith<$Res> {
  _$MockCredentialsStateCopyWithImpl(this._self, this._then);

  final MockCredentialsState _self;
  final $Res Function(MockCredentialsState) _then;

/// Create a copy of MockCredentialsState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? isLoading = null,Object? identities = null,Object? holders = null,Object? importing = freezed,Object? failure = freezed,}) {
  return _then(_self.copyWith(
isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,identities: null == identities ? _self.identities : identities // ignore: cast_nullable_to_non_nullable
as List<Identity>,holders: null == holders ? _self.holders : holders // ignore: cast_nullable_to_non_nullable
as Map<String, Set<String>>,importing: freezed == importing ? _self.importing : importing // ignore: cast_nullable_to_non_nullable
as String?,failure: freezed == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as MockCredentialsFailure?,
  ));
}

}


/// Adds pattern-matching-related methods to [MockCredentialsState].
extension MockCredentialsStatePatterns on MockCredentialsState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MockCredentialsState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MockCredentialsState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MockCredentialsState value)  $default,){
final _that = this;
switch (_that) {
case _MockCredentialsState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MockCredentialsState value)?  $default,){
final _that = this;
switch (_that) {
case _MockCredentialsState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool isLoading,  List<Identity> identities,  Map<String, Set<String>> holders,  String? importing,  MockCredentialsFailure? failure)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MockCredentialsState() when $default != null:
return $default(_that.isLoading,_that.identities,_that.holders,_that.importing,_that.failure);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool isLoading,  List<Identity> identities,  Map<String, Set<String>> holders,  String? importing,  MockCredentialsFailure? failure)  $default,) {final _that = this;
switch (_that) {
case _MockCredentialsState():
return $default(_that.isLoading,_that.identities,_that.holders,_that.importing,_that.failure);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool isLoading,  List<Identity> identities,  Map<String, Set<String>> holders,  String? importing,  MockCredentialsFailure? failure)?  $default,) {final _that = this;
switch (_that) {
case _MockCredentialsState() when $default != null:
return $default(_that.isLoading,_that.identities,_that.holders,_that.importing,_that.failure);case _:
  return null;

}
}

}

/// @nodoc


class _MockCredentialsState implements MockCredentialsState {
   _MockCredentialsState({this.isLoading = true, final  List<Identity> identities = const <Identity>[], final  Map<String, Set<String>> holders = const <String, Set<String>>{}, this.importing, this.failure}): _identities = identities,_holders = holders;
  

@override@JsonKey() final  bool isLoading;
/// The member's identities on their VTA, primary first.
 final  List<Identity> _identities;
/// The member's identities on their VTA, primary first.
@override@JsonKey() List<Identity> get identities {
  if (_identities is EqualUnmodifiableListView) return _identities;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_identities);
}

/// Which identities hold each test credential: by template id, then
/// identity DID.
 final  Map<String, Set<String>> _holders;
/// Which identities hold each test credential: by template id, then
/// identity DID.
@override@JsonKey() Map<String, Set<String>> get holders {
  if (_holders is EqualUnmodifiableMapView) return _holders;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_holders);
}

/// The template being imported, while it is.
@override final  String? importing;
@override final  MockCredentialsFailure? failure;

/// Create a copy of MockCredentialsState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MockCredentialsStateCopyWith<_MockCredentialsState> get copyWith => __$MockCredentialsStateCopyWithImpl<_MockCredentialsState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MockCredentialsState&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&const DeepCollectionEquality().equals(other._identities, _identities)&&const DeepCollectionEquality().equals(other._holders, _holders)&&(identical(other.importing, importing) || other.importing == importing)&&(identical(other.failure, failure) || other.failure == failure));
}


@override
int get hashCode => Object.hash(runtimeType,isLoading,const DeepCollectionEquality().hash(_identities),const DeepCollectionEquality().hash(_holders),importing,failure);

@override
String toString() {
  return 'MockCredentialsState(isLoading: $isLoading, identities: $identities, holders: $holders, importing: $importing, failure: $failure)';
}


}

/// @nodoc
abstract mixin class _$MockCredentialsStateCopyWith<$Res> implements $MockCredentialsStateCopyWith<$Res> {
  factory _$MockCredentialsStateCopyWith(_MockCredentialsState value, $Res Function(_MockCredentialsState) _then) = __$MockCredentialsStateCopyWithImpl;
@override @useResult
$Res call({
 bool isLoading, List<Identity> identities, Map<String, Set<String>> holders, String? importing, MockCredentialsFailure? failure
});




}
/// @nodoc
class __$MockCredentialsStateCopyWithImpl<$Res>
    implements _$MockCredentialsStateCopyWith<$Res> {
  __$MockCredentialsStateCopyWithImpl(this._self, this._then);

  final _MockCredentialsState _self;
  final $Res Function(_MockCredentialsState) _then;

/// Create a copy of MockCredentialsState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? isLoading = null,Object? identities = null,Object? holders = null,Object? importing = freezed,Object? failure = freezed,}) {
  return _then(_MockCredentialsState(
isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,identities: null == identities ? _self._identities : identities // ignore: cast_nullable_to_non_nullable
as List<Identity>,holders: null == holders ? _self._holders : holders // ignore: cast_nullable_to_non_nullable
as Map<String, Set<String>>,importing: freezed == importing ? _self.importing : importing // ignore: cast_nullable_to_non_nullable
as String?,failure: freezed == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as MockCredentialsFailure?,
  ));
}


}

// dart format on
