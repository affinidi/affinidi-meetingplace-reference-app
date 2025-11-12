// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'control_plane_service_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ControlPlaneServiceState {
  bool get isProcessing;
  bool? get isDeviceTokenRegistered;

  /// Create a copy of ControlPlaneServiceState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ControlPlaneServiceStateCopyWith<ControlPlaneServiceState> get copyWith =>
      _$ControlPlaneServiceStateCopyWithImpl<ControlPlaneServiceState>(
          this as ControlPlaneServiceState, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is ControlPlaneServiceState &&
            (identical(other.isProcessing, isProcessing) ||
                other.isProcessing == isProcessing) &&
            (identical(
                    other.isDeviceTokenRegistered, isDeviceTokenRegistered) ||
                other.isDeviceTokenRegistered == isDeviceTokenRegistered));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, isProcessing, isDeviceTokenRegistered);

  @override
  String toString() {
    return 'ControlPlaneServiceState(isProcessing: $isProcessing, isDeviceTokenRegistered: $isDeviceTokenRegistered)';
  }
}

/// @nodoc
abstract mixin class $ControlPlaneServiceStateCopyWith<$Res> {
  factory $ControlPlaneServiceStateCopyWith(ControlPlaneServiceState value,
          $Res Function(ControlPlaneServiceState) _then) =
      _$ControlPlaneServiceStateCopyWithImpl;
  @useResult
  $Res call({bool isProcessing, bool? isDeviceTokenRegistered});
}

/// @nodoc
class _$ControlPlaneServiceStateCopyWithImpl<$Res>
    implements $ControlPlaneServiceStateCopyWith<$Res> {
  _$ControlPlaneServiceStateCopyWithImpl(this._self, this._then);

  final ControlPlaneServiceState _self;
  final $Res Function(ControlPlaneServiceState) _then;

  /// Create a copy of ControlPlaneServiceState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isProcessing = null,
    Object? isDeviceTokenRegistered = freezed,
  }) {
    return _then(_self.copyWith(
      isProcessing: null == isProcessing
          ? _self.isProcessing
          : isProcessing // ignore: cast_nullable_to_non_nullable
              as bool,
      isDeviceTokenRegistered: freezed == isDeviceTokenRegistered
          ? _self.isDeviceTokenRegistered
          : isDeviceTokenRegistered // ignore: cast_nullable_to_non_nullable
              as bool?,
    ));
  }
}

/// Adds pattern-matching-related methods to [ControlPlaneServiceState].
extension ControlPlaneServiceStatePatterns on ControlPlaneServiceState {
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
    TResult Function(_ControlPlaneServiceState value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _ControlPlaneServiceState() when $default != null:
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
    TResult Function(_ControlPlaneServiceState value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ControlPlaneServiceState():
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
    TResult? Function(_ControlPlaneServiceState value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ControlPlaneServiceState() when $default != null:
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
    TResult Function(bool isProcessing, bool? isDeviceTokenRegistered)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _ControlPlaneServiceState() when $default != null:
        return $default(_that.isProcessing, _that.isDeviceTokenRegistered);
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
    TResult Function(bool isProcessing, bool? isDeviceTokenRegistered) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ControlPlaneServiceState():
        return $default(_that.isProcessing, _that.isDeviceTokenRegistered);
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
    TResult? Function(bool isProcessing, bool? isDeviceTokenRegistered)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ControlPlaneServiceState() when $default != null:
        return $default(_that.isProcessing, _that.isDeviceTokenRegistered);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _ControlPlaneServiceState implements ControlPlaneServiceState {
  const _ControlPlaneServiceState(
      {this.isProcessing = false, this.isDeviceTokenRegistered});

  @override
  @JsonKey()
  final bool isProcessing;
  @override
  final bool? isDeviceTokenRegistered;

  /// Create a copy of ControlPlaneServiceState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$ControlPlaneServiceStateCopyWith<_ControlPlaneServiceState> get copyWith =>
      __$ControlPlaneServiceStateCopyWithImpl<_ControlPlaneServiceState>(
          this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _ControlPlaneServiceState &&
            (identical(other.isProcessing, isProcessing) ||
                other.isProcessing == isProcessing) &&
            (identical(
                    other.isDeviceTokenRegistered, isDeviceTokenRegistered) ||
                other.isDeviceTokenRegistered == isDeviceTokenRegistered));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, isProcessing, isDeviceTokenRegistered);

  @override
  String toString() {
    return 'ControlPlaneServiceState(isProcessing: $isProcessing, isDeviceTokenRegistered: $isDeviceTokenRegistered)';
  }
}

/// @nodoc
abstract mixin class _$ControlPlaneServiceStateCopyWith<$Res>
    implements $ControlPlaneServiceStateCopyWith<$Res> {
  factory _$ControlPlaneServiceStateCopyWith(_ControlPlaneServiceState value,
          $Res Function(_ControlPlaneServiceState) _then) =
      __$ControlPlaneServiceStateCopyWithImpl;
  @override
  @useResult
  $Res call({bool isProcessing, bool? isDeviceTokenRegistered});
}

/// @nodoc
class __$ControlPlaneServiceStateCopyWithImpl<$Res>
    implements _$ControlPlaneServiceStateCopyWith<$Res> {
  __$ControlPlaneServiceStateCopyWithImpl(this._self, this._then);

  final _ControlPlaneServiceState _self;
  final $Res Function(_ControlPlaneServiceState) _then;

  /// Create a copy of ControlPlaneServiceState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? isProcessing = null,
    Object? isDeviceTokenRegistered = freezed,
  }) {
    return _then(_ControlPlaneServiceState(
      isProcessing: null == isProcessing
          ? _self.isProcessing
          : isProcessing // ignore: cast_nullable_to_non_nullable
              as bool,
      isDeviceTokenRegistered: freezed == isDeviceTokenRegistered
          ? _self.isDeviceTokenRegistered
          : isDeviceTokenRegistered // ignore: cast_nullable_to_non_nullable
              as bool?,
    ));
  }
}

// dart format on
