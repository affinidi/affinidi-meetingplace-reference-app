// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'push_notification.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PushNotificationData {

 int? get pendingCount;
/// Create a copy of PushNotificationData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PushNotificationDataCopyWith<PushNotificationData> get copyWith => _$PushNotificationDataCopyWithImpl<PushNotificationData>(this as PushNotificationData, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PushNotificationData&&(identical(other.pendingCount, pendingCount) || other.pendingCount == pendingCount));
}


@override
int get hashCode => Object.hash(runtimeType,pendingCount);

@override
String toString() {
  return 'PushNotificationData(pendingCount: $pendingCount)';
}


}

/// @nodoc
abstract mixin class $PushNotificationDataCopyWith<$Res>  {
  factory $PushNotificationDataCopyWith(PushNotificationData value, $Res Function(PushNotificationData) _then) = _$PushNotificationDataCopyWithImpl;
@useResult
$Res call({
 int? pendingCount
});




}
/// @nodoc
class _$PushNotificationDataCopyWithImpl<$Res>
    implements $PushNotificationDataCopyWith<$Res> {
  _$PushNotificationDataCopyWithImpl(this._self, this._then);

  final PushNotificationData _self;
  final $Res Function(PushNotificationData) _then;

/// Create a copy of PushNotificationData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? pendingCount = freezed,}) {
  return _then(_self.copyWith(
pendingCount: freezed == pendingCount ? _self.pendingCount : pendingCount // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [PushNotificationData].
extension PushNotificationDataPatterns on PushNotificationData {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PushNotificationData value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PushNotificationData() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PushNotificationData value)  $default,){
final _that = this;
switch (_that) {
case _PushNotificationData():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PushNotificationData value)?  $default,){
final _that = this;
switch (_that) {
case _PushNotificationData() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int? pendingCount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PushNotificationData() when $default != null:
return $default(_that.pendingCount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int? pendingCount)  $default,) {final _that = this;
switch (_that) {
case _PushNotificationData():
return $default(_that.pendingCount);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int? pendingCount)?  $default,) {final _that = this;
switch (_that) {
case _PushNotificationData() when $default != null:
return $default(_that.pendingCount);case _:
  return null;

}
}

}

/// @nodoc


class _PushNotificationData implements PushNotificationData {
  const _PushNotificationData({this.pendingCount});
  

@override final  int? pendingCount;

/// Create a copy of PushNotificationData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PushNotificationDataCopyWith<_PushNotificationData> get copyWith => __$PushNotificationDataCopyWithImpl<_PushNotificationData>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PushNotificationData&&(identical(other.pendingCount, pendingCount) || other.pendingCount == pendingCount));
}


@override
int get hashCode => Object.hash(runtimeType,pendingCount);

@override
String toString() {
  return 'PushNotificationData(pendingCount: $pendingCount)';
}


}

/// @nodoc
abstract mixin class _$PushNotificationDataCopyWith<$Res> implements $PushNotificationDataCopyWith<$Res> {
  factory _$PushNotificationDataCopyWith(_PushNotificationData value, $Res Function(_PushNotificationData) _then) = __$PushNotificationDataCopyWithImpl;
@override @useResult
$Res call({
 int? pendingCount
});




}
/// @nodoc
class __$PushNotificationDataCopyWithImpl<$Res>
    implements _$PushNotificationDataCopyWith<$Res> {
  __$PushNotificationDataCopyWithImpl(this._self, this._then);

  final _PushNotificationData _self;
  final $Res Function(_PushNotificationData) _then;

/// Create a copy of PushNotificationData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? pendingCount = freezed,}) {
  return _then(_PushNotificationData(
pendingCount: freezed == pendingCount ? _self.pendingCount : pendingCount // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

/// @nodoc
mixin _$PushNotification {

 PushNotificationType get type; PushNotificationData get data;
/// Create a copy of PushNotification
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PushNotificationCopyWith<PushNotification> get copyWith => _$PushNotificationCopyWithImpl<PushNotification>(this as PushNotification, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PushNotification&&(identical(other.type, type) || other.type == type)&&(identical(other.data, data) || other.data == data));
}


@override
int get hashCode => Object.hash(runtimeType,type,data);

@override
String toString() {
  return 'PushNotification(type: $type, data: $data)';
}


}

/// @nodoc
abstract mixin class $PushNotificationCopyWith<$Res>  {
  factory $PushNotificationCopyWith(PushNotification value, $Res Function(PushNotification) _then) = _$PushNotificationCopyWithImpl;
@useResult
$Res call({
 PushNotificationType type, PushNotificationData data
});


$PushNotificationDataCopyWith<$Res> get data;

}
/// @nodoc
class _$PushNotificationCopyWithImpl<$Res>
    implements $PushNotificationCopyWith<$Res> {
  _$PushNotificationCopyWithImpl(this._self, this._then);

  final PushNotification _self;
  final $Res Function(PushNotification) _then;

/// Create a copy of PushNotification
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? type = null,Object? data = null,}) {
  return _then(_self.copyWith(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as PushNotificationType,data: null == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as PushNotificationData,
  ));
}
/// Create a copy of PushNotification
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PushNotificationDataCopyWith<$Res> get data {
  
  return $PushNotificationDataCopyWith<$Res>(_self.data, (value) {
    return _then(_self.copyWith(data: value));
  });
}
}


/// Adds pattern-matching-related methods to [PushNotification].
extension PushNotificationPatterns on PushNotification {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PushNotification value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PushNotification() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PushNotification value)  $default,){
final _that = this;
switch (_that) {
case _PushNotification():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PushNotification value)?  $default,){
final _that = this;
switch (_that) {
case _PushNotification() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( PushNotificationType type,  PushNotificationData data)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PushNotification() when $default != null:
return $default(_that.type,_that.data);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( PushNotificationType type,  PushNotificationData data)  $default,) {final _that = this;
switch (_that) {
case _PushNotification():
return $default(_that.type,_that.data);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( PushNotificationType type,  PushNotificationData data)?  $default,) {final _that = this;
switch (_that) {
case _PushNotification() when $default != null:
return $default(_that.type,_that.data);case _:
  return null;

}
}

}

/// @nodoc


class _PushNotification implements PushNotification {
  const _PushNotification({this.type = PushNotificationType.other, this.data = const PushNotificationData()});
  

@override@JsonKey() final  PushNotificationType type;
@override@JsonKey() final  PushNotificationData data;

/// Create a copy of PushNotification
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PushNotificationCopyWith<_PushNotification> get copyWith => __$PushNotificationCopyWithImpl<_PushNotification>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PushNotification&&(identical(other.type, type) || other.type == type)&&(identical(other.data, data) || other.data == data));
}


@override
int get hashCode => Object.hash(runtimeType,type,data);

@override
String toString() {
  return 'PushNotification(type: $type, data: $data)';
}


}

/// @nodoc
abstract mixin class _$PushNotificationCopyWith<$Res> implements $PushNotificationCopyWith<$Res> {
  factory _$PushNotificationCopyWith(_PushNotification value, $Res Function(_PushNotification) _then) = __$PushNotificationCopyWithImpl;
@override @useResult
$Res call({
 PushNotificationType type, PushNotificationData data
});


@override $PushNotificationDataCopyWith<$Res> get data;

}
/// @nodoc
class __$PushNotificationCopyWithImpl<$Res>
    implements _$PushNotificationCopyWith<$Res> {
  __$PushNotificationCopyWithImpl(this._self, this._then);

  final _PushNotification _self;
  final $Res Function(_PushNotification) _then;

/// Create a copy of PushNotification
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? type = null,Object? data = null,}) {
  return _then(_PushNotification(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as PushNotificationType,data: null == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as PushNotificationData,
  ));
}

/// Create a copy of PushNotification
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PushNotificationDataCopyWith<$Res> get data {
  
  return $PushNotificationDataCopyWith<$Res>(_self.data, (value) {
    return _then(_self.copyWith(data: value));
  });
}
}

// dart format on
