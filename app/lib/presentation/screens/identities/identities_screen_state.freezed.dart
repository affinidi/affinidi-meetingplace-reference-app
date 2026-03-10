// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'identities_screen_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$IdentitiesScreenState {

 bool get shouldShowFilter; IdentitiesScreenFilter get filter; Identity? get currentIdentity; List<Identity> get identities; bool get shouldSetupPrimaryIdentity;
/// Create a copy of IdentitiesScreenState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$IdentitiesScreenStateCopyWith<IdentitiesScreenState> get copyWith => _$IdentitiesScreenStateCopyWithImpl<IdentitiesScreenState>(this as IdentitiesScreenState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is IdentitiesScreenState&&(identical(other.shouldShowFilter, shouldShowFilter) || other.shouldShowFilter == shouldShowFilter)&&(identical(other.filter, filter) || other.filter == filter)&&(identical(other.currentIdentity, currentIdentity) || other.currentIdentity == currentIdentity)&&const DeepCollectionEquality().equals(other.identities, identities)&&(identical(other.shouldSetupPrimaryIdentity, shouldSetupPrimaryIdentity) || other.shouldSetupPrimaryIdentity == shouldSetupPrimaryIdentity));
}


@override
int get hashCode => Object.hash(runtimeType,shouldShowFilter,filter,currentIdentity,const DeepCollectionEquality().hash(identities),shouldSetupPrimaryIdentity);

@override
String toString() {
  return 'IdentitiesScreenState(shouldShowFilter: $shouldShowFilter, filter: $filter, currentIdentity: $currentIdentity, identities: $identities, shouldSetupPrimaryIdentity: $shouldSetupPrimaryIdentity)';
}


}

/// @nodoc
abstract mixin class $IdentitiesScreenStateCopyWith<$Res>  {
  factory $IdentitiesScreenStateCopyWith(IdentitiesScreenState value, $Res Function(IdentitiesScreenState) _then) = _$IdentitiesScreenStateCopyWithImpl;
@useResult
$Res call({
 bool shouldShowFilter, IdentitiesScreenFilter filter, Identity? currentIdentity, List<Identity> identities, bool shouldSetupPrimaryIdentity
});


$IdentityCopyWith<$Res>? get currentIdentity;

}
/// @nodoc
class _$IdentitiesScreenStateCopyWithImpl<$Res>
    implements $IdentitiesScreenStateCopyWith<$Res> {
  _$IdentitiesScreenStateCopyWithImpl(this._self, this._then);

  final IdentitiesScreenState _self;
  final $Res Function(IdentitiesScreenState) _then;

/// Create a copy of IdentitiesScreenState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? shouldShowFilter = null,Object? filter = null,Object? currentIdentity = freezed,Object? identities = null,Object? shouldSetupPrimaryIdentity = null,}) {
  return _then(_self.copyWith(
shouldShowFilter: null == shouldShowFilter ? _self.shouldShowFilter : shouldShowFilter // ignore: cast_nullable_to_non_nullable
as bool,filter: null == filter ? _self.filter : filter // ignore: cast_nullable_to_non_nullable
as IdentitiesScreenFilter,currentIdentity: freezed == currentIdentity ? _self.currentIdentity : currentIdentity // ignore: cast_nullable_to_non_nullable
as Identity?,identities: null == identities ? _self.identities : identities // ignore: cast_nullable_to_non_nullable
as List<Identity>,shouldSetupPrimaryIdentity: null == shouldSetupPrimaryIdentity ? _self.shouldSetupPrimaryIdentity : shouldSetupPrimaryIdentity // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}
/// Create a copy of IdentitiesScreenState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$IdentityCopyWith<$Res>? get currentIdentity {
    if (_self.currentIdentity == null) {
    return null;
  }

  return $IdentityCopyWith<$Res>(_self.currentIdentity!, (value) {
    return _then(_self.copyWith(currentIdentity: value));
  });
}
}


/// Adds pattern-matching-related methods to [IdentitiesScreenState].
extension IdentitiesScreenStatePatterns on IdentitiesScreenState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _IdentitiesScreenState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _IdentitiesScreenState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _IdentitiesScreenState value)  $default,){
final _that = this;
switch (_that) {
case _IdentitiesScreenState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _IdentitiesScreenState value)?  $default,){
final _that = this;
switch (_that) {
case _IdentitiesScreenState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool shouldShowFilter,  IdentitiesScreenFilter filter,  Identity? currentIdentity,  List<Identity> identities,  bool shouldSetupPrimaryIdentity)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _IdentitiesScreenState() when $default != null:
return $default(_that.shouldShowFilter,_that.filter,_that.currentIdentity,_that.identities,_that.shouldSetupPrimaryIdentity);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool shouldShowFilter,  IdentitiesScreenFilter filter,  Identity? currentIdentity,  List<Identity> identities,  bool shouldSetupPrimaryIdentity)  $default,) {final _that = this;
switch (_that) {
case _IdentitiesScreenState():
return $default(_that.shouldShowFilter,_that.filter,_that.currentIdentity,_that.identities,_that.shouldSetupPrimaryIdentity);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool shouldShowFilter,  IdentitiesScreenFilter filter,  Identity? currentIdentity,  List<Identity> identities,  bool shouldSetupPrimaryIdentity)?  $default,) {final _that = this;
switch (_that) {
case _IdentitiesScreenState() when $default != null:
return $default(_that.shouldShowFilter,_that.filter,_that.currentIdentity,_that.identities,_that.shouldSetupPrimaryIdentity);case _:
  return null;

}
}

}

/// @nodoc


class _IdentitiesScreenState extends IdentitiesScreenState {
   _IdentitiesScreenState({this.shouldShowFilter = false, this.filter = IdentitiesScreenFilter.all, this.currentIdentity, final  List<Identity> identities = const [], this.shouldSetupPrimaryIdentity = false}): _identities = identities,super._();
  

@override@JsonKey() final  bool shouldShowFilter;
@override@JsonKey() final  IdentitiesScreenFilter filter;
@override final  Identity? currentIdentity;
 final  List<Identity> _identities;
@override@JsonKey() List<Identity> get identities {
  if (_identities is EqualUnmodifiableListView) return _identities;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_identities);
}

@override@JsonKey() final  bool shouldSetupPrimaryIdentity;

/// Create a copy of IdentitiesScreenState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$IdentitiesScreenStateCopyWith<_IdentitiesScreenState> get copyWith => __$IdentitiesScreenStateCopyWithImpl<_IdentitiesScreenState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _IdentitiesScreenState&&(identical(other.shouldShowFilter, shouldShowFilter) || other.shouldShowFilter == shouldShowFilter)&&(identical(other.filter, filter) || other.filter == filter)&&(identical(other.currentIdentity, currentIdentity) || other.currentIdentity == currentIdentity)&&const DeepCollectionEquality().equals(other._identities, _identities)&&(identical(other.shouldSetupPrimaryIdentity, shouldSetupPrimaryIdentity) || other.shouldSetupPrimaryIdentity == shouldSetupPrimaryIdentity));
}


@override
int get hashCode => Object.hash(runtimeType,shouldShowFilter,filter,currentIdentity,const DeepCollectionEquality().hash(_identities),shouldSetupPrimaryIdentity);

@override
String toString() {
  return 'IdentitiesScreenState(shouldShowFilter: $shouldShowFilter, filter: $filter, currentIdentity: $currentIdentity, identities: $identities, shouldSetupPrimaryIdentity: $shouldSetupPrimaryIdentity)';
}


}

/// @nodoc
abstract mixin class _$IdentitiesScreenStateCopyWith<$Res> implements $IdentitiesScreenStateCopyWith<$Res> {
  factory _$IdentitiesScreenStateCopyWith(_IdentitiesScreenState value, $Res Function(_IdentitiesScreenState) _then) = __$IdentitiesScreenStateCopyWithImpl;
@override @useResult
$Res call({
 bool shouldShowFilter, IdentitiesScreenFilter filter, Identity? currentIdentity, List<Identity> identities, bool shouldSetupPrimaryIdentity
});


@override $IdentityCopyWith<$Res>? get currentIdentity;

}
/// @nodoc
class __$IdentitiesScreenStateCopyWithImpl<$Res>
    implements _$IdentitiesScreenStateCopyWith<$Res> {
  __$IdentitiesScreenStateCopyWithImpl(this._self, this._then);

  final _IdentitiesScreenState _self;
  final $Res Function(_IdentitiesScreenState) _then;

/// Create a copy of IdentitiesScreenState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? shouldShowFilter = null,Object? filter = null,Object? currentIdentity = freezed,Object? identities = null,Object? shouldSetupPrimaryIdentity = null,}) {
  return _then(_IdentitiesScreenState(
shouldShowFilter: null == shouldShowFilter ? _self.shouldShowFilter : shouldShowFilter // ignore: cast_nullable_to_non_nullable
as bool,filter: null == filter ? _self.filter : filter // ignore: cast_nullable_to_non_nullable
as IdentitiesScreenFilter,currentIdentity: freezed == currentIdentity ? _self.currentIdentity : currentIdentity // ignore: cast_nullable_to_non_nullable
as Identity?,identities: null == identities ? _self._identities : identities // ignore: cast_nullable_to_non_nullable
as List<Identity>,shouldSetupPrimaryIdentity: null == shouldSetupPrimaryIdentity ? _self.shouldSetupPrimaryIdentity : shouldSetupPrimaryIdentity // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of IdentitiesScreenState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$IdentityCopyWith<$Res>? get currentIdentity {
    if (_self.currentIdentity == null) {
    return null;
  }

  return $IdentityCopyWith<$Res>(_self.currentIdentity!, (value) {
    return _then(_self.copyWith(currentIdentity: value));
  });
}
}

// dart format on
