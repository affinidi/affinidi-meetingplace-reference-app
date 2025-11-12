// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'mediator.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Mediator {
  String get id;
  String get mediatorName;
  String get mediatorDid;
  MediatorType get type;
  MediatorStatus get status;
  DateTime? get createdTime;

  /// Create a copy of Mediator
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $MediatorCopyWith<Mediator> get copyWith =>
      _$MediatorCopyWithImpl<Mediator>(this as Mediator, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is Mediator &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.mediatorName, mediatorName) ||
                other.mediatorName == mediatorName) &&
            (identical(other.mediatorDid, mediatorDid) ||
                other.mediatorDid == mediatorDid) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.createdTime, createdTime) ||
                other.createdTime == createdTime));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, id, mediatorName, mediatorDid, type, status, createdTime);

  @override
  String toString() {
    return 'Mediator(id: $id, mediatorName: $mediatorName, mediatorDid: $mediatorDid, type: $type, status: $status, createdTime: $createdTime)';
  }
}

/// @nodoc
abstract mixin class $MediatorCopyWith<$Res> {
  factory $MediatorCopyWith(Mediator value, $Res Function(Mediator) _then) =
      _$MediatorCopyWithImpl;
  @useResult
  $Res call(
      {String id,
      String mediatorName,
      String mediatorDid,
      MediatorType type,
      MediatorStatus status,
      DateTime? createdTime});
}

/// @nodoc
class _$MediatorCopyWithImpl<$Res> implements $MediatorCopyWith<$Res> {
  _$MediatorCopyWithImpl(this._self, this._then);

  final Mediator _self;
  final $Res Function(Mediator) _then;

  /// Create a copy of Mediator
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? mediatorName = null,
    Object? mediatorDid = null,
    Object? type = null,
    Object? status = null,
    Object? createdTime = freezed,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      mediatorName: null == mediatorName
          ? _self.mediatorName
          : mediatorName // ignore: cast_nullable_to_non_nullable
              as String,
      mediatorDid: null == mediatorDid
          ? _self.mediatorDid
          : mediatorDid // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _self.type
          : type // ignore: cast_nullable_to_non_nullable
              as MediatorType,
      status: null == status
          ? _self.status
          : status // ignore: cast_nullable_to_non_nullable
              as MediatorStatus,
      createdTime: freezed == createdTime
          ? _self.createdTime
          : createdTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// Adds pattern-matching-related methods to [Mediator].
extension MediatorPatterns on Mediator {
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

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_Mediator value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Mediator() when $default != null:
        return $default(_that);
      case _:
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

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_Mediator value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Mediator():
        return $default(_that);
      case _:
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

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_Mediator value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Mediator() when $default != null:
        return $default(_that);
      case _:
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

  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(String id, String mediatorName, String mediatorDid,
            MediatorType type, MediatorStatus status, DateTime? createdTime)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Mediator() when $default != null:
        return $default(_that.id, _that.mediatorName, _that.mediatorDid,
            _that.type, _that.status, _that.createdTime);
      case _:
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

  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(String id, String mediatorName, String mediatorDid,
            MediatorType type, MediatorStatus status, DateTime? createdTime)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Mediator():
        return $default(_that.id, _that.mediatorName, _that.mediatorDid,
            _that.type, _that.status, _that.createdTime);
      case _:
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

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(String id, String mediatorName, String mediatorDid,
            MediatorType type, MediatorStatus status, DateTime? createdTime)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Mediator() when $default != null:
        return $default(_that.id, _that.mediatorName, _that.mediatorDid,
            _that.type, _that.status, _that.createdTime);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _Mediator implements Mediator {
  const _Mediator(
      {required this.id,
      required this.mediatorName,
      required this.mediatorDid,
      required this.type,
      this.status = MediatorStatus.active,
      this.createdTime = null});

  @override
  final String id;
  @override
  final String mediatorName;
  @override
  final String mediatorDid;
  @override
  final MediatorType type;
  @override
  @JsonKey()
  final MediatorStatus status;
  @override
  @JsonKey()
  final DateTime? createdTime;

  /// Create a copy of Mediator
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$MediatorCopyWith<_Mediator> get copyWith =>
      __$MediatorCopyWithImpl<_Mediator>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _Mediator &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.mediatorName, mediatorName) ||
                other.mediatorName == mediatorName) &&
            (identical(other.mediatorDid, mediatorDid) ||
                other.mediatorDid == mediatorDid) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.createdTime, createdTime) ||
                other.createdTime == createdTime));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, id, mediatorName, mediatorDid, type, status, createdTime);

  @override
  String toString() {
    return 'Mediator(id: $id, mediatorName: $mediatorName, mediatorDid: $mediatorDid, type: $type, status: $status, createdTime: $createdTime)';
  }
}

/// @nodoc
abstract mixin class _$MediatorCopyWith<$Res>
    implements $MediatorCopyWith<$Res> {
  factory _$MediatorCopyWith(_Mediator value, $Res Function(_Mediator) _then) =
      __$MediatorCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id,
      String mediatorName,
      String mediatorDid,
      MediatorType type,
      MediatorStatus status,
      DateTime? createdTime});
}

/// @nodoc
class __$MediatorCopyWithImpl<$Res> implements _$MediatorCopyWith<$Res> {
  __$MediatorCopyWithImpl(this._self, this._then);

  final _Mediator _self;
  final $Res Function(_Mediator) _then;

  /// Create a copy of Mediator
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? mediatorName = null,
    Object? mediatorDid = null,
    Object? type = null,
    Object? status = null,
    Object? createdTime = freezed,
  }) {
    return _then(_Mediator(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      mediatorName: null == mediatorName
          ? _self.mediatorName
          : mediatorName // ignore: cast_nullable_to_non_nullable
              as String,
      mediatorDid: null == mediatorDid
          ? _self.mediatorDid
          : mediatorDid // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _self.type
          : type // ignore: cast_nullable_to_non_nullable
              as MediatorType,
      status: null == status
          ? _self.status
          : status // ignore: cast_nullable_to_non_nullable
              as MediatorStatus,
      createdTime: freezed == createdTime
          ? _self.createdTime
          : createdTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

// dart format on
