// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'connection_details_screen_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ConnectionDetailsScreenState {

 Contact? get contact; Channel? get channel; ConnectionOffer? get connection; Identity? get identity; Group? get group; Map<String, int> get memberPowerLevels; bool get showDeletedMembers; String get mediatorName; bool get isDebugMode; bool get showMnemonic; bool get showQrIcon; bool get showQrView;
/// Create a copy of ConnectionDetailsScreenState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ConnectionDetailsScreenStateCopyWith<ConnectionDetailsScreenState> get copyWith => _$ConnectionDetailsScreenStateCopyWithImpl<ConnectionDetailsScreenState>(this as ConnectionDetailsScreenState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ConnectionDetailsScreenState&&(identical(other.contact, contact) || other.contact == contact)&&(identical(other.channel, channel) || other.channel == channel)&&(identical(other.connection, connection) || other.connection == connection)&&(identical(other.identity, identity) || other.identity == identity)&&(identical(other.group, group) || other.group == group)&&const DeepCollectionEquality().equals(other.memberPowerLevels, memberPowerLevels)&&(identical(other.showDeletedMembers, showDeletedMembers) || other.showDeletedMembers == showDeletedMembers)&&(identical(other.mediatorName, mediatorName) || other.mediatorName == mediatorName)&&(identical(other.isDebugMode, isDebugMode) || other.isDebugMode == isDebugMode)&&(identical(other.showMnemonic, showMnemonic) || other.showMnemonic == showMnemonic)&&(identical(other.showQrIcon, showQrIcon) || other.showQrIcon == showQrIcon)&&(identical(other.showQrView, showQrView) || other.showQrView == showQrView));
}


@override
int get hashCode => Object.hash(runtimeType,contact,channel,connection,identity,group,const DeepCollectionEquality().hash(memberPowerLevels),showDeletedMembers,mediatorName,isDebugMode,showMnemonic,showQrIcon,showQrView);

@override
String toString() {
  return 'ConnectionDetailsScreenState(contact: $contact, channel: $channel, connection: $connection, identity: $identity, group: $group, memberPowerLevels: $memberPowerLevels, showDeletedMembers: $showDeletedMembers, mediatorName: $mediatorName, isDebugMode: $isDebugMode, showMnemonic: $showMnemonic, showQrIcon: $showQrIcon, showQrView: $showQrView)';
}


}

/// @nodoc
abstract mixin class $ConnectionDetailsScreenStateCopyWith<$Res>  {
  factory $ConnectionDetailsScreenStateCopyWith(ConnectionDetailsScreenState value, $Res Function(ConnectionDetailsScreenState) _then) = _$ConnectionDetailsScreenStateCopyWithImpl;
@useResult
$Res call({
 Contact? contact, Channel? channel, ConnectionOffer? connection, Identity? identity, Group? group, Map<String, int> memberPowerLevels, bool showDeletedMembers, String mediatorName, bool isDebugMode, bool showMnemonic, bool showQrIcon, bool showQrView
});


$IdentityCopyWith<$Res>? get identity;

}
/// @nodoc
class _$ConnectionDetailsScreenStateCopyWithImpl<$Res>
    implements $ConnectionDetailsScreenStateCopyWith<$Res> {
  _$ConnectionDetailsScreenStateCopyWithImpl(this._self, this._then);

  final ConnectionDetailsScreenState _self;
  final $Res Function(ConnectionDetailsScreenState) _then;

/// Create a copy of ConnectionDetailsScreenState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? contact = freezed,Object? channel = freezed,Object? connection = freezed,Object? identity = freezed,Object? group = freezed,Object? memberPowerLevels = null,Object? showDeletedMembers = null,Object? mediatorName = null,Object? isDebugMode = null,Object? showMnemonic = null,Object? showQrIcon = null,Object? showQrView = null,}) {
  return _then(_self.copyWith(
contact: freezed == contact ? _self.contact : contact // ignore: cast_nullable_to_non_nullable
as Contact?,channel: freezed == channel ? _self.channel : channel // ignore: cast_nullable_to_non_nullable
as Channel?,connection: freezed == connection ? _self.connection : connection // ignore: cast_nullable_to_non_nullable
as ConnectionOffer?,identity: freezed == identity ? _self.identity : identity // ignore: cast_nullable_to_non_nullable
as Identity?,group: freezed == group ? _self.group : group // ignore: cast_nullable_to_non_nullable
as Group?,memberPowerLevels: null == memberPowerLevels ? _self.memberPowerLevels : memberPowerLevels // ignore: cast_nullable_to_non_nullable
as Map<String, int>,showDeletedMembers: null == showDeletedMembers ? _self.showDeletedMembers : showDeletedMembers // ignore: cast_nullable_to_non_nullable
as bool,mediatorName: null == mediatorName ? _self.mediatorName : mediatorName // ignore: cast_nullable_to_non_nullable
as String,isDebugMode: null == isDebugMode ? _self.isDebugMode : isDebugMode // ignore: cast_nullable_to_non_nullable
as bool,showMnemonic: null == showMnemonic ? _self.showMnemonic : showMnemonic // ignore: cast_nullable_to_non_nullable
as bool,showQrIcon: null == showQrIcon ? _self.showQrIcon : showQrIcon // ignore: cast_nullable_to_non_nullable
as bool,showQrView: null == showQrView ? _self.showQrView : showQrView // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}
/// Create a copy of ConnectionDetailsScreenState
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


/// Adds pattern-matching-related methods to [ConnectionDetailsScreenState].
extension ConnectionDetailsScreenStatePatterns on ConnectionDetailsScreenState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ConnectionDetailsScreenState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ConnectionDetailsScreenState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ConnectionDetailsScreenState value)  $default,){
final _that = this;
switch (_that) {
case _ConnectionDetailsScreenState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ConnectionDetailsScreenState value)?  $default,){
final _that = this;
switch (_that) {
case _ConnectionDetailsScreenState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Contact? contact,  Channel? channel,  ConnectionOffer? connection,  Identity? identity,  Group? group,  Map<String, int> memberPowerLevels,  bool showDeletedMembers,  String mediatorName,  bool isDebugMode,  bool showMnemonic,  bool showQrIcon,  bool showQrView)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ConnectionDetailsScreenState() when $default != null:
return $default(_that.contact,_that.channel,_that.connection,_that.identity,_that.group,_that.memberPowerLevels,_that.showDeletedMembers,_that.mediatorName,_that.isDebugMode,_that.showMnemonic,_that.showQrIcon,_that.showQrView);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Contact? contact,  Channel? channel,  ConnectionOffer? connection,  Identity? identity,  Group? group,  Map<String, int> memberPowerLevels,  bool showDeletedMembers,  String mediatorName,  bool isDebugMode,  bool showMnemonic,  bool showQrIcon,  bool showQrView)  $default,) {final _that = this;
switch (_that) {
case _ConnectionDetailsScreenState():
return $default(_that.contact,_that.channel,_that.connection,_that.identity,_that.group,_that.memberPowerLevels,_that.showDeletedMembers,_that.mediatorName,_that.isDebugMode,_that.showMnemonic,_that.showQrIcon,_that.showQrView);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Contact? contact,  Channel? channel,  ConnectionOffer? connection,  Identity? identity,  Group? group,  Map<String, int> memberPowerLevels,  bool showDeletedMembers,  String mediatorName,  bool isDebugMode,  bool showMnemonic,  bool showQrIcon,  bool showQrView)?  $default,) {final _that = this;
switch (_that) {
case _ConnectionDetailsScreenState() when $default != null:
return $default(_that.contact,_that.channel,_that.connection,_that.identity,_that.group,_that.memberPowerLevels,_that.showDeletedMembers,_that.mediatorName,_that.isDebugMode,_that.showMnemonic,_that.showQrIcon,_that.showQrView);case _:
  return null;

}
}

}

/// @nodoc


class _ConnectionDetailsScreenState extends ConnectionDetailsScreenState {
  _ConnectionDetailsScreenState({this.contact, this.channel, this.connection, this.identity, this.group, final  Map<String, int> memberPowerLevels = const <String, int>{}, this.showDeletedMembers = false, this.mediatorName = '', this.isDebugMode = false, this.showMnemonic = false, this.showQrIcon = false, this.showQrView = false}): _memberPowerLevels = memberPowerLevels,super._();
  

@override final  Contact? contact;
@override final  Channel? channel;
@override final  ConnectionOffer? connection;
@override final  Identity? identity;
@override final  Group? group;
 final  Map<String, int> _memberPowerLevels;
@override@JsonKey() Map<String, int> get memberPowerLevels {
  if (_memberPowerLevels is EqualUnmodifiableMapView) return _memberPowerLevels;
  return EqualUnmodifiableMapView(_memberPowerLevels);
}
@override@JsonKey() final  bool showDeletedMembers;
@override@JsonKey() final  String mediatorName;
@override@JsonKey() final  bool isDebugMode;
@override@JsonKey() final  bool showMnemonic;
@override@JsonKey() final  bool showQrIcon;
@override@JsonKey() final  bool showQrView;

/// Create a copy of ConnectionDetailsScreenState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ConnectionDetailsScreenStateCopyWith<_ConnectionDetailsScreenState> get copyWith => __$ConnectionDetailsScreenStateCopyWithImpl<_ConnectionDetailsScreenState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ConnectionDetailsScreenState&&(identical(other.contact, contact) || other.contact == contact)&&(identical(other.channel, channel) || other.channel == channel)&&(identical(other.connection, connection) || other.connection == connection)&&(identical(other.identity, identity) || other.identity == identity)&&(identical(other.group, group) || other.group == group)&&const DeepCollectionEquality().equals(other._memberPowerLevels, _memberPowerLevels)&&(identical(other.showDeletedMembers, showDeletedMembers) || other.showDeletedMembers == showDeletedMembers)&&(identical(other.mediatorName, mediatorName) || other.mediatorName == mediatorName)&&(identical(other.isDebugMode, isDebugMode) || other.isDebugMode == isDebugMode)&&(identical(other.showMnemonic, showMnemonic) || other.showMnemonic == showMnemonic)&&(identical(other.showQrIcon, showQrIcon) || other.showQrIcon == showQrIcon)&&(identical(other.showQrView, showQrView) || other.showQrView == showQrView));
}


@override
int get hashCode => Object.hash(runtimeType,contact,channel,connection,identity,group,const DeepCollectionEquality().hash(_memberPowerLevels),showDeletedMembers,mediatorName,isDebugMode,showMnemonic,showQrIcon,showQrView);

@override
String toString() {
  return 'ConnectionDetailsScreenState(contact: $contact, channel: $channel, connection: $connection, identity: $identity, group: $group, memberPowerLevels: $memberPowerLevels, showDeletedMembers: $showDeletedMembers, mediatorName: $mediatorName, isDebugMode: $isDebugMode, showMnemonic: $showMnemonic, showQrIcon: $showQrIcon, showQrView: $showQrView)';
}


}

/// @nodoc
abstract mixin class _$ConnectionDetailsScreenStateCopyWith<$Res> implements $ConnectionDetailsScreenStateCopyWith<$Res> {
  factory _$ConnectionDetailsScreenStateCopyWith(_ConnectionDetailsScreenState value, $Res Function(_ConnectionDetailsScreenState) _then) = __$ConnectionDetailsScreenStateCopyWithImpl;
@override @useResult
$Res call({
 Contact? contact, Channel? channel, ConnectionOffer? connection, Identity? identity, Group? group, Map<String, int> memberPowerLevels, bool showDeletedMembers, String mediatorName, bool isDebugMode, bool showMnemonic, bool showQrIcon, bool showQrView
});


@override $IdentityCopyWith<$Res>? get identity;

}
/// @nodoc
class __$ConnectionDetailsScreenStateCopyWithImpl<$Res>
    implements _$ConnectionDetailsScreenStateCopyWith<$Res> {
  __$ConnectionDetailsScreenStateCopyWithImpl(this._self, this._then);

  final _ConnectionDetailsScreenState _self;
  final $Res Function(_ConnectionDetailsScreenState) _then;

/// Create a copy of ConnectionDetailsScreenState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? contact = freezed,Object? channel = freezed,Object? connection = freezed,Object? identity = freezed,Object? group = freezed,Object? memberPowerLevels = null,Object? showDeletedMembers = null,Object? mediatorName = null,Object? isDebugMode = null,Object? showMnemonic = null,Object? showQrIcon = null,Object? showQrView = null,}) {
  return _then(_ConnectionDetailsScreenState(
contact: freezed == contact ? _self.contact : contact // ignore: cast_nullable_to_non_nullable
as Contact?,channel: freezed == channel ? _self.channel : channel // ignore: cast_nullable_to_non_nullable
as Channel?,connection: freezed == connection ? _self.connection : connection // ignore: cast_nullable_to_non_nullable
as ConnectionOffer?,identity: freezed == identity ? _self.identity : identity // ignore: cast_nullable_to_non_nullable
as Identity?,group: freezed == group ? _self.group : group // ignore: cast_nullable_to_non_nullable
as Group?,memberPowerLevels: null == memberPowerLevels ? _self.memberPowerLevels : memberPowerLevels // ignore: cast_nullable_to_non_nullable
as Map<String, int>,showDeletedMembers: null == showDeletedMembers ? _self.showDeletedMembers : showDeletedMembers // ignore: cast_nullable_to_non_nullable
as bool,mediatorName: null == mediatorName ? _self.mediatorName : mediatorName // ignore: cast_nullable_to_non_nullable
as String,isDebugMode: null == isDebugMode ? _self.isDebugMode : isDebugMode // ignore: cast_nullable_to_non_nullable
as bool,showMnemonic: null == showMnemonic ? _self.showMnemonic : showMnemonic // ignore: cast_nullable_to_non_nullable
as bool,showQrIcon: null == showQrIcon ? _self.showQrIcon : showQrIcon // ignore: cast_nullable_to_non_nullable
as bool,showQrView: null == showQrView ? _self.showQrView : showQrView // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of ConnectionDetailsScreenState
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
