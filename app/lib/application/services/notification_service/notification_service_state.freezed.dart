// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'notification_service_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$NotificationServiceState {

 Map<NotificationCounterType, int> get counters;
/// Create a copy of NotificationServiceState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NotificationServiceStateCopyWith<NotificationServiceState> get copyWith => _$NotificationServiceStateCopyWithImpl<NotificationServiceState>(this as NotificationServiceState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NotificationServiceState&&const DeepCollectionEquality().equals(other.counters, counters));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(counters));

@override
String toString() {
  return 'NotificationServiceState(counters: $counters)';
}


}

/// @nodoc
abstract mixin class $NotificationServiceStateCopyWith<$Res>  {
  factory $NotificationServiceStateCopyWith(NotificationServiceState value, $Res Function(NotificationServiceState) _then) = _$NotificationServiceStateCopyWithImpl;
@useResult
$Res call({
 Map<NotificationCounterType, int> counters
});




}
/// @nodoc
class _$NotificationServiceStateCopyWithImpl<$Res>
    implements $NotificationServiceStateCopyWith<$Res> {
  _$NotificationServiceStateCopyWithImpl(this._self, this._then);

  final NotificationServiceState _self;
  final $Res Function(NotificationServiceState) _then;

/// Create a copy of NotificationServiceState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? counters = null,}) {
  return _then(_self.copyWith(
counters: null == counters ? _self.counters : counters // ignore: cast_nullable_to_non_nullable
as Map<NotificationCounterType, int>,
  ));
}

}


/// Adds pattern-matching-related methods to [NotificationServiceState].
extension NotificationServiceStatePatterns on NotificationServiceState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _NotificationServiceState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _NotificationServiceState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _NotificationServiceState value)  $default,){
final _that = this;
switch (_that) {
case _NotificationServiceState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _NotificationServiceState value)?  $default,){
final _that = this;
switch (_that) {
case _NotificationServiceState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Map<NotificationCounterType, int> counters)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _NotificationServiceState() when $default != null:
return $default(_that.counters);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Map<NotificationCounterType, int> counters)  $default,) {final _that = this;
switch (_that) {
case _NotificationServiceState():
return $default(_that.counters);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Map<NotificationCounterType, int> counters)?  $default,) {final _that = this;
switch (_that) {
case _NotificationServiceState() when $default != null:
return $default(_that.counters);case _:
  return null;

}
}

}

/// @nodoc


class _NotificationServiceState implements NotificationServiceState {
   _NotificationServiceState({final  Map<NotificationCounterType, int> counters = const {NotificationCounterType.contacts : 0, NotificationCounterType.connections : 0, NotificationCounterType.identities : 0}}): _counters = counters;
  

 final  Map<NotificationCounterType, int> _counters;
@override@JsonKey() Map<NotificationCounterType, int> get counters {
  if (_counters is EqualUnmodifiableMapView) return _counters;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_counters);
}


/// Create a copy of NotificationServiceState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NotificationServiceStateCopyWith<_NotificationServiceState> get copyWith => __$NotificationServiceStateCopyWithImpl<_NotificationServiceState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _NotificationServiceState&&const DeepCollectionEquality().equals(other._counters, _counters));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_counters));

@override
String toString() {
  return 'NotificationServiceState(counters: $counters)';
}


}

/// @nodoc
abstract mixin class _$NotificationServiceStateCopyWith<$Res> implements $NotificationServiceStateCopyWith<$Res> {
  factory _$NotificationServiceStateCopyWith(_NotificationServiceState value, $Res Function(_NotificationServiceState) _then) = __$NotificationServiceStateCopyWithImpl;
@override @useResult
$Res call({
 Map<NotificationCounterType, int> counters
});




}
/// @nodoc
class __$NotificationServiceStateCopyWithImpl<$Res>
    implements _$NotificationServiceStateCopyWith<$Res> {
  __$NotificationServiceStateCopyWithImpl(this._self, this._then);

  final _NotificationServiceState _self;
  final $Res Function(_NotificationServiceState) _then;

/// Create a copy of NotificationServiceState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? counters = null,}) {
  return _then(_NotificationServiceState(
counters: null == counters ? _self._counters : counters // ignore: cast_nullable_to_non_nullable
as Map<NotificationCounterType, int>,
  ));
}


}

// dart format on
