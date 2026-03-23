// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'settings_service_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SettingsServiceState {

 String get selectedMediatorDid; bool get isDebugMode; bool get alreadyOnboarded; bool get shouldShowMeetingPlaceQR; bool get isAutomaticMediaDownloadEnabled;
/// Create a copy of SettingsServiceState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SettingsServiceStateCopyWith<SettingsServiceState> get copyWith => _$SettingsServiceStateCopyWithImpl<SettingsServiceState>(this as SettingsServiceState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SettingsServiceState&&(identical(other.selectedMediatorDid, selectedMediatorDid) || other.selectedMediatorDid == selectedMediatorDid)&&(identical(other.isDebugMode, isDebugMode) || other.isDebugMode == isDebugMode)&&(identical(other.alreadyOnboarded, alreadyOnboarded) || other.alreadyOnboarded == alreadyOnboarded)&&(identical(other.shouldShowMeetingPlaceQR, shouldShowMeetingPlaceQR) || other.shouldShowMeetingPlaceQR == shouldShowMeetingPlaceQR)&&(identical(other.isAutomaticMediaDownloadEnabled, isAutomaticMediaDownloadEnabled) || other.isAutomaticMediaDownloadEnabled == isAutomaticMediaDownloadEnabled));
}


@override
int get hashCode => Object.hash(runtimeType,selectedMediatorDid,isDebugMode,alreadyOnboarded,shouldShowMeetingPlaceQR,isAutomaticMediaDownloadEnabled);

@override
String toString() {
  return 'SettingsServiceState(selectedMediatorDid: $selectedMediatorDid, isDebugMode: $isDebugMode, alreadyOnboarded: $alreadyOnboarded, shouldShowMeetingPlaceQR: $shouldShowMeetingPlaceQR, isAutomaticMediaDownloadEnabled: $isAutomaticMediaDownloadEnabled)';
}


}

/// @nodoc
abstract mixin class $SettingsServiceStateCopyWith<$Res>  {
  factory $SettingsServiceStateCopyWith(SettingsServiceState value, $Res Function(SettingsServiceState) _then) = _$SettingsServiceStateCopyWithImpl;
@useResult
$Res call({
 String selectedMediatorDid, bool isDebugMode, bool alreadyOnboarded, bool shouldShowMeetingPlaceQR, bool isAutomaticMediaDownloadEnabled
});




}
/// @nodoc
class _$SettingsServiceStateCopyWithImpl<$Res>
    implements $SettingsServiceStateCopyWith<$Res> {
  _$SettingsServiceStateCopyWithImpl(this._self, this._then);

  final SettingsServiceState _self;
  final $Res Function(SettingsServiceState) _then;

/// Create a copy of SettingsServiceState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? selectedMediatorDid = null,Object? isDebugMode = null,Object? alreadyOnboarded = null,Object? shouldShowMeetingPlaceQR = null,Object? isAutomaticMediaDownloadEnabled = null,}) {
  return _then(_self.copyWith(
selectedMediatorDid: null == selectedMediatorDid ? _self.selectedMediatorDid : selectedMediatorDid // ignore: cast_nullable_to_non_nullable
as String,isDebugMode: null == isDebugMode ? _self.isDebugMode : isDebugMode // ignore: cast_nullable_to_non_nullable
as bool,alreadyOnboarded: null == alreadyOnboarded ? _self.alreadyOnboarded : alreadyOnboarded // ignore: cast_nullable_to_non_nullable
as bool,shouldShowMeetingPlaceQR: null == shouldShowMeetingPlaceQR ? _self.shouldShowMeetingPlaceQR : shouldShowMeetingPlaceQR // ignore: cast_nullable_to_non_nullable
as bool,isAutomaticMediaDownloadEnabled: null == isAutomaticMediaDownloadEnabled ? _self.isAutomaticMediaDownloadEnabled : isAutomaticMediaDownloadEnabled // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [SettingsServiceState].
extension SettingsServiceStatePatterns on SettingsServiceState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SettingsServiceState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SettingsServiceState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SettingsServiceState value)  $default,){
final _that = this;
switch (_that) {
case _SettingsServiceState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SettingsServiceState value)?  $default,){
final _that = this;
switch (_that) {
case _SettingsServiceState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String selectedMediatorDid,  bool isDebugMode,  bool alreadyOnboarded,  bool shouldShowMeetingPlaceQR,  bool isAutomaticMediaDownloadEnabled)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SettingsServiceState() when $default != null:
return $default(_that.selectedMediatorDid,_that.isDebugMode,_that.alreadyOnboarded,_that.shouldShowMeetingPlaceQR,_that.isAutomaticMediaDownloadEnabled);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String selectedMediatorDid,  bool isDebugMode,  bool alreadyOnboarded,  bool shouldShowMeetingPlaceQR,  bool isAutomaticMediaDownloadEnabled)  $default,) {final _that = this;
switch (_that) {
case _SettingsServiceState():
return $default(_that.selectedMediatorDid,_that.isDebugMode,_that.alreadyOnboarded,_that.shouldShowMeetingPlaceQR,_that.isAutomaticMediaDownloadEnabled);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String selectedMediatorDid,  bool isDebugMode,  bool alreadyOnboarded,  bool shouldShowMeetingPlaceQR,  bool isAutomaticMediaDownloadEnabled)?  $default,) {final _that = this;
switch (_that) {
case _SettingsServiceState() when $default != null:
return $default(_that.selectedMediatorDid,_that.isDebugMode,_that.alreadyOnboarded,_that.shouldShowMeetingPlaceQR,_that.isAutomaticMediaDownloadEnabled);case _:
  return null;

}
}

}

/// @nodoc


class _SettingsServiceState implements SettingsServiceState {
   _SettingsServiceState({required this.selectedMediatorDid, this.isDebugMode = false, required this.alreadyOnboarded, this.shouldShowMeetingPlaceQR = false, this.isAutomaticMediaDownloadEnabled = true});
  

@override final  String selectedMediatorDid;
@override@JsonKey() final  bool isDebugMode;
@override final  bool alreadyOnboarded;
@override@JsonKey() final  bool shouldShowMeetingPlaceQR;
@override@JsonKey() final  bool isAutomaticMediaDownloadEnabled;

/// Create a copy of SettingsServiceState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SettingsServiceStateCopyWith<_SettingsServiceState> get copyWith => __$SettingsServiceStateCopyWithImpl<_SettingsServiceState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SettingsServiceState&&(identical(other.selectedMediatorDid, selectedMediatorDid) || other.selectedMediatorDid == selectedMediatorDid)&&(identical(other.isDebugMode, isDebugMode) || other.isDebugMode == isDebugMode)&&(identical(other.alreadyOnboarded, alreadyOnboarded) || other.alreadyOnboarded == alreadyOnboarded)&&(identical(other.shouldShowMeetingPlaceQR, shouldShowMeetingPlaceQR) || other.shouldShowMeetingPlaceQR == shouldShowMeetingPlaceQR)&&(identical(other.isAutomaticMediaDownloadEnabled, isAutomaticMediaDownloadEnabled) || other.isAutomaticMediaDownloadEnabled == isAutomaticMediaDownloadEnabled));
}


@override
int get hashCode => Object.hash(runtimeType,selectedMediatorDid,isDebugMode,alreadyOnboarded,shouldShowMeetingPlaceQR,isAutomaticMediaDownloadEnabled);

@override
String toString() {
  return 'SettingsServiceState(selectedMediatorDid: $selectedMediatorDid, isDebugMode: $isDebugMode, alreadyOnboarded: $alreadyOnboarded, shouldShowMeetingPlaceQR: $shouldShowMeetingPlaceQR, isAutomaticMediaDownloadEnabled: $isAutomaticMediaDownloadEnabled)';
}


}

/// @nodoc
abstract mixin class _$SettingsServiceStateCopyWith<$Res> implements $SettingsServiceStateCopyWith<$Res> {
  factory _$SettingsServiceStateCopyWith(_SettingsServiceState value, $Res Function(_SettingsServiceState) _then) = __$SettingsServiceStateCopyWithImpl;
@override @useResult
$Res call({
 String selectedMediatorDid, bool isDebugMode, bool alreadyOnboarded, bool shouldShowMeetingPlaceQR, bool isAutomaticMediaDownloadEnabled
});




}
/// @nodoc
class __$SettingsServiceStateCopyWithImpl<$Res>
    implements _$SettingsServiceStateCopyWith<$Res> {
  __$SettingsServiceStateCopyWithImpl(this._self, this._then);

  final _SettingsServiceState _self;
  final $Res Function(_SettingsServiceState) _then;

/// Create a copy of SettingsServiceState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? selectedMediatorDid = null,Object? isDebugMode = null,Object? alreadyOnboarded = null,Object? shouldShowMeetingPlaceQR = null,Object? isAutomaticMediaDownloadEnabled = null,}) {
  return _then(_SettingsServiceState(
selectedMediatorDid: null == selectedMediatorDid ? _self.selectedMediatorDid : selectedMediatorDid // ignore: cast_nullable_to_non_nullable
as String,isDebugMode: null == isDebugMode ? _self.isDebugMode : isDebugMode // ignore: cast_nullable_to_non_nullable
as bool,alreadyOnboarded: null == alreadyOnboarded ? _self.alreadyOnboarded : alreadyOnboarded // ignore: cast_nullable_to_non_nullable
as bool,shouldShowMeetingPlaceQR: null == shouldShowMeetingPlaceQR ? _self.shouldShowMeetingPlaceQR : shouldShowMeetingPlaceQR // ignore: cast_nullable_to_non_nullable
as bool,isAutomaticMediaDownloadEnabled: null == isAutomaticMediaDownloadEnabled ? _self.isAutomaticMediaDownloadEnabled : isAutomaticMediaDownloadEnabled // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
