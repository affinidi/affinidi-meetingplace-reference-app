// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'connections_screen_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ConnectionsScreenState {

 bool get isEditMode; List<ConnectionOffer> get connections; List<ConnectionOffer> get selectedConnections; Map<String, Mediator> get connectionMediators; ConnectionsScreenFilter get filter; Identity? get identity;
/// Create a copy of ConnectionsScreenState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ConnectionsScreenStateCopyWith<ConnectionsScreenState> get copyWith => _$ConnectionsScreenStateCopyWithImpl<ConnectionsScreenState>(this as ConnectionsScreenState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ConnectionsScreenState&&(identical(other.isEditMode, isEditMode) || other.isEditMode == isEditMode)&&const DeepCollectionEquality().equals(other.connections, connections)&&const DeepCollectionEquality().equals(other.selectedConnections, selectedConnections)&&const DeepCollectionEquality().equals(other.connectionMediators, connectionMediators)&&(identical(other.filter, filter) || other.filter == filter)&&(identical(other.identity, identity) || other.identity == identity));
}


@override
int get hashCode => Object.hash(runtimeType,isEditMode,const DeepCollectionEquality().hash(connections),const DeepCollectionEquality().hash(selectedConnections),const DeepCollectionEquality().hash(connectionMediators),filter,identity);

@override
String toString() {
  return 'ConnectionsScreenState(isEditMode: $isEditMode, connections: $connections, selectedConnections: $selectedConnections, connectionMediators: $connectionMediators, filter: $filter, identity: $identity)';
}


}

/// @nodoc
abstract mixin class $ConnectionsScreenStateCopyWith<$Res>  {
  factory $ConnectionsScreenStateCopyWith(ConnectionsScreenState value, $Res Function(ConnectionsScreenState) _then) = _$ConnectionsScreenStateCopyWithImpl;
@useResult
$Res call({
 bool isEditMode, List<ConnectionOffer> connections, List<ConnectionOffer> selectedConnections, Map<String, Mediator> connectionMediators, ConnectionsScreenFilter filter, Identity? identity
});


$IdentityCopyWith<$Res>? get identity;

}
/// @nodoc
class _$ConnectionsScreenStateCopyWithImpl<$Res>
    implements $ConnectionsScreenStateCopyWith<$Res> {
  _$ConnectionsScreenStateCopyWithImpl(this._self, this._then);

  final ConnectionsScreenState _self;
  final $Res Function(ConnectionsScreenState) _then;

/// Create a copy of ConnectionsScreenState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? isEditMode = null,Object? connections = null,Object? selectedConnections = null,Object? connectionMediators = null,Object? filter = null,Object? identity = freezed,}) {
  return _then(_self.copyWith(
isEditMode: null == isEditMode ? _self.isEditMode : isEditMode // ignore: cast_nullable_to_non_nullable
as bool,connections: null == connections ? _self.connections : connections // ignore: cast_nullable_to_non_nullable
as List<ConnectionOffer>,selectedConnections: null == selectedConnections ? _self.selectedConnections : selectedConnections // ignore: cast_nullable_to_non_nullable
as List<ConnectionOffer>,connectionMediators: null == connectionMediators ? _self.connectionMediators : connectionMediators // ignore: cast_nullable_to_non_nullable
as Map<String, Mediator>,filter: null == filter ? _self.filter : filter // ignore: cast_nullable_to_non_nullable
as ConnectionsScreenFilter,identity: freezed == identity ? _self.identity : identity // ignore: cast_nullable_to_non_nullable
as Identity?,
  ));
}
/// Create a copy of ConnectionsScreenState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$IdentityCopyWith<$Res>? get identity {
    if (_self.identity == null) {
    return null;
  }

  return $IdentityCopyWith<$Res>(_self.identity!, (value) {
    return _then(_self.copyWith(identity: value));
  });
}
}


/// Adds pattern-matching-related methods to [ConnectionsScreenState].
extension ConnectionsScreenStatePatterns on ConnectionsScreenState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ConnectionsScreenState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ConnectionsScreenState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ConnectionsScreenState value)  $default,){
final _that = this;
switch (_that) {
case _ConnectionsScreenState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ConnectionsScreenState value)?  $default,){
final _that = this;
switch (_that) {
case _ConnectionsScreenState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool isEditMode,  List<ConnectionOffer> connections,  List<ConnectionOffer> selectedConnections,  Map<String, Mediator> connectionMediators,  ConnectionsScreenFilter filter,  Identity? identity)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ConnectionsScreenState() when $default != null:
return $default(_that.isEditMode,_that.connections,_that.selectedConnections,_that.connectionMediators,_that.filter,_that.identity);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool isEditMode,  List<ConnectionOffer> connections,  List<ConnectionOffer> selectedConnections,  Map<String, Mediator> connectionMediators,  ConnectionsScreenFilter filter,  Identity? identity)  $default,) {final _that = this;
switch (_that) {
case _ConnectionsScreenState():
return $default(_that.isEditMode,_that.connections,_that.selectedConnections,_that.connectionMediators,_that.filter,_that.identity);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool isEditMode,  List<ConnectionOffer> connections,  List<ConnectionOffer> selectedConnections,  Map<String, Mediator> connectionMediators,  ConnectionsScreenFilter filter,  Identity? identity)?  $default,) {final _that = this;
switch (_that) {
case _ConnectionsScreenState() when $default != null:
return $default(_that.isEditMode,_that.connections,_that.selectedConnections,_that.connectionMediators,_that.filter,_that.identity);case _:
  return null;

}
}

}

/// @nodoc


class _ConnectionsScreenState extends ConnectionsScreenState {
   _ConnectionsScreenState({this.isEditMode = false, final  List<ConnectionOffer> connections = const [], final  List<ConnectionOffer> selectedConnections = const [], final  Map<String, Mediator> connectionMediators = const {}, this.filter = ConnectionsScreenFilter.all, this.identity}): _connections = connections,_selectedConnections = selectedConnections,_connectionMediators = connectionMediators,super._();
  

@override@JsonKey() final  bool isEditMode;
 final  List<ConnectionOffer> _connections;
@override@JsonKey() List<ConnectionOffer> get connections {
  if (_connections is EqualUnmodifiableListView) return _connections;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_connections);
}

 final  List<ConnectionOffer> _selectedConnections;
@override@JsonKey() List<ConnectionOffer> get selectedConnections {
  if (_selectedConnections is EqualUnmodifiableListView) return _selectedConnections;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_selectedConnections);
}

 final  Map<String, Mediator> _connectionMediators;
@override@JsonKey() Map<String, Mediator> get connectionMediators {
  if (_connectionMediators is EqualUnmodifiableMapView) return _connectionMediators;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_connectionMediators);
}

@override@JsonKey() final  ConnectionsScreenFilter filter;
@override final  Identity? identity;

/// Create a copy of ConnectionsScreenState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ConnectionsScreenStateCopyWith<_ConnectionsScreenState> get copyWith => __$ConnectionsScreenStateCopyWithImpl<_ConnectionsScreenState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ConnectionsScreenState&&(identical(other.isEditMode, isEditMode) || other.isEditMode == isEditMode)&&const DeepCollectionEquality().equals(other._connections, _connections)&&const DeepCollectionEquality().equals(other._selectedConnections, _selectedConnections)&&const DeepCollectionEquality().equals(other._connectionMediators, _connectionMediators)&&(identical(other.filter, filter) || other.filter == filter)&&(identical(other.identity, identity) || other.identity == identity));
}


@override
int get hashCode => Object.hash(runtimeType,isEditMode,const DeepCollectionEquality().hash(_connections),const DeepCollectionEquality().hash(_selectedConnections),const DeepCollectionEquality().hash(_connectionMediators),filter,identity);

@override
String toString() {
  return 'ConnectionsScreenState(isEditMode: $isEditMode, connections: $connections, selectedConnections: $selectedConnections, connectionMediators: $connectionMediators, filter: $filter, identity: $identity)';
}


}

/// @nodoc
abstract mixin class _$ConnectionsScreenStateCopyWith<$Res> implements $ConnectionsScreenStateCopyWith<$Res> {
  factory _$ConnectionsScreenStateCopyWith(_ConnectionsScreenState value, $Res Function(_ConnectionsScreenState) _then) = __$ConnectionsScreenStateCopyWithImpl;
@override @useResult
$Res call({
 bool isEditMode, List<ConnectionOffer> connections, List<ConnectionOffer> selectedConnections, Map<String, Mediator> connectionMediators, ConnectionsScreenFilter filter, Identity? identity
});


@override $IdentityCopyWith<$Res>? get identity;

}
/// @nodoc
class __$ConnectionsScreenStateCopyWithImpl<$Res>
    implements _$ConnectionsScreenStateCopyWith<$Res> {
  __$ConnectionsScreenStateCopyWithImpl(this._self, this._then);

  final _ConnectionsScreenState _self;
  final $Res Function(_ConnectionsScreenState) _then;

/// Create a copy of ConnectionsScreenState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? isEditMode = null,Object? connections = null,Object? selectedConnections = null,Object? connectionMediators = null,Object? filter = null,Object? identity = freezed,}) {
  return _then(_ConnectionsScreenState(
isEditMode: null == isEditMode ? _self.isEditMode : isEditMode // ignore: cast_nullable_to_non_nullable
as bool,connections: null == connections ? _self._connections : connections // ignore: cast_nullable_to_non_nullable
as List<ConnectionOffer>,selectedConnections: null == selectedConnections ? _self._selectedConnections : selectedConnections // ignore: cast_nullable_to_non_nullable
as List<ConnectionOffer>,connectionMediators: null == connectionMediators ? _self._connectionMediators : connectionMediators // ignore: cast_nullable_to_non_nullable
as Map<String, Mediator>,filter: null == filter ? _self.filter : filter // ignore: cast_nullable_to_non_nullable
as ConnectionsScreenFilter,identity: freezed == identity ? _self.identity : identity // ignore: cast_nullable_to_non_nullable
as Identity?,
  ));
}

/// Create a copy of ConnectionsScreenState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$IdentityCopyWith<$Res>? get identity {
    if (_self.identity == null) {
    return null;
  }

  return $IdentityCopyWith<$Res>(_self.identity!, (value) {
    return _then(_self.copyWith(identity: value));
  });
}
}

// dart format on
