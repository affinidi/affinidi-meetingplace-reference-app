// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'camera_service_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CameraServiceState {
  List<CameraDescription> get cameras;
  bool? get isAvailable;
  CameraController? get controller;
  bool get permissionGranted;

  /// Create a copy of CameraServiceState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $CameraServiceStateCopyWith<CameraServiceState> get copyWith =>
      _$CameraServiceStateCopyWithImpl<CameraServiceState>(
          this as CameraServiceState, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is CameraServiceState &&
            const DeepCollectionEquality().equals(other.cameras, cameras) &&
            (identical(other.isAvailable, isAvailable) ||
                other.isAvailable == isAvailable) &&
            (identical(other.controller, controller) ||
                other.controller == controller) &&
            (identical(other.permissionGranted, permissionGranted) ||
                other.permissionGranted == permissionGranted));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(cameras),
      isAvailable,
      controller,
      permissionGranted);

  @override
  String toString() {
    return 'CameraServiceState(cameras: $cameras, isAvailable: $isAvailable, controller: $controller, permissionGranted: $permissionGranted)';
  }
}

/// @nodoc
abstract mixin class $CameraServiceStateCopyWith<$Res> {
  factory $CameraServiceStateCopyWith(
          CameraServiceState value, $Res Function(CameraServiceState) _then) =
      _$CameraServiceStateCopyWithImpl;
  @useResult
  $Res call(
      {List<CameraDescription> cameras,
      bool? isAvailable,
      CameraController? controller,
      bool permissionGranted});
}

/// @nodoc
class _$CameraServiceStateCopyWithImpl<$Res>
    implements $CameraServiceStateCopyWith<$Res> {
  _$CameraServiceStateCopyWithImpl(this._self, this._then);

  final CameraServiceState _self;
  final $Res Function(CameraServiceState) _then;

  /// Create a copy of CameraServiceState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? cameras = null,
    Object? isAvailable = freezed,
    Object? controller = freezed,
    Object? permissionGranted = null,
  }) {
    return _then(_self.copyWith(
      cameras: null == cameras
          ? _self.cameras
          : cameras // ignore: cast_nullable_to_non_nullable
              as List<CameraDescription>,
      isAvailable: freezed == isAvailable
          ? _self.isAvailable
          : isAvailable // ignore: cast_nullable_to_non_nullable
              as bool?,
      controller: freezed == controller
          ? _self.controller
          : controller // ignore: cast_nullable_to_non_nullable
              as CameraController?,
      permissionGranted: null == permissionGranted
          ? _self.permissionGranted
          : permissionGranted // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// Adds pattern-matching-related methods to [CameraServiceState].
extension CameraServiceStatePatterns on CameraServiceState {
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
    TResult Function(_CameraServiceState value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _CameraServiceState() when $default != null:
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
    TResult Function(_CameraServiceState value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _CameraServiceState():
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
    TResult? Function(_CameraServiceState value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _CameraServiceState() when $default != null:
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
    TResult Function(List<CameraDescription> cameras, bool? isAvailable,
            CameraController? controller, bool permissionGranted)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _CameraServiceState() when $default != null:
        return $default(_that.cameras, _that.isAvailable, _that.controller,
            _that.permissionGranted);
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
    TResult Function(List<CameraDescription> cameras, bool? isAvailable,
            CameraController? controller, bool permissionGranted)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _CameraServiceState():
        return $default(_that.cameras, _that.isAvailable, _that.controller,
            _that.permissionGranted);
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
    TResult? Function(List<CameraDescription> cameras, bool? isAvailable,
            CameraController? controller, bool permissionGranted)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _CameraServiceState() when $default != null:
        return $default(_that.cameras, _that.isAvailable, _that.controller,
            _that.permissionGranted);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _CameraServiceState implements CameraServiceState {
  _CameraServiceState(
      {final List<CameraDescription> cameras = const [],
      this.isAvailable,
      this.controller,
      this.permissionGranted = true})
      : _cameras = cameras;

  final List<CameraDescription> _cameras;
  @override
  @JsonKey()
  List<CameraDescription> get cameras {
    if (_cameras is EqualUnmodifiableListView) return _cameras;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_cameras);
  }

  @override
  final bool? isAvailable;
  @override
  final CameraController? controller;
  @override
  @JsonKey()
  final bool permissionGranted;

  /// Create a copy of CameraServiceState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$CameraServiceStateCopyWith<_CameraServiceState> get copyWith =>
      __$CameraServiceStateCopyWithImpl<_CameraServiceState>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _CameraServiceState &&
            const DeepCollectionEquality().equals(other._cameras, _cameras) &&
            (identical(other.isAvailable, isAvailable) ||
                other.isAvailable == isAvailable) &&
            (identical(other.controller, controller) ||
                other.controller == controller) &&
            (identical(other.permissionGranted, permissionGranted) ||
                other.permissionGranted == permissionGranted));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_cameras),
      isAvailable,
      controller,
      permissionGranted);

  @override
  String toString() {
    return 'CameraServiceState(cameras: $cameras, isAvailable: $isAvailable, controller: $controller, permissionGranted: $permissionGranted)';
  }
}

/// @nodoc
abstract mixin class _$CameraServiceStateCopyWith<$Res>
    implements $CameraServiceStateCopyWith<$Res> {
  factory _$CameraServiceStateCopyWith(
          _CameraServiceState value, $Res Function(_CameraServiceState) _then) =
      __$CameraServiceStateCopyWithImpl;
  @override
  @useResult
  $Res call(
      {List<CameraDescription> cameras,
      bool? isAvailable,
      CameraController? controller,
      bool permissionGranted});
}

/// @nodoc
class __$CameraServiceStateCopyWithImpl<$Res>
    implements _$CameraServiceStateCopyWith<$Res> {
  __$CameraServiceStateCopyWithImpl(this._self, this._then);

  final _CameraServiceState _self;
  final $Res Function(_CameraServiceState) _then;

  /// Create a copy of CameraServiceState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? cameras = null,
    Object? isAvailable = freezed,
    Object? controller = freezed,
    Object? permissionGranted = null,
  }) {
    return _then(_CameraServiceState(
      cameras: null == cameras
          ? _self._cameras
          : cameras // ignore: cast_nullable_to_non_nullable
              as List<CameraDescription>,
      isAvailable: freezed == isAvailable
          ? _self.isAvailable
          : isAvailable // ignore: cast_nullable_to_non_nullable
              as bool?,
      controller: freezed == controller
          ? _self.controller
          : controller // ignore: cast_nullable_to_non_nullable
              as CameraController?,
      permissionGranted: null == permissionGranted
          ? _self.permissionGranted
          : permissionGranted // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

// dart format on
