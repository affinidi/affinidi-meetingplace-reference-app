// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'qr_code_picker_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$QrCodePickerState {
  bool? get cameraAvailable;

  /// Create a copy of QrCodePickerState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $QrCodePickerStateCopyWith<QrCodePickerState> get copyWith =>
      _$QrCodePickerStateCopyWithImpl<QrCodePickerState>(
          this as QrCodePickerState, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is QrCodePickerState &&
            (identical(other.cameraAvailable, cameraAvailable) ||
                other.cameraAvailable == cameraAvailable));
  }

  @override
  int get hashCode => Object.hash(runtimeType, cameraAvailable);

  @override
  String toString() {
    return 'QrCodePickerState(cameraAvailable: $cameraAvailable)';
  }
}

/// @nodoc
abstract mixin class $QrCodePickerStateCopyWith<$Res> {
  factory $QrCodePickerStateCopyWith(
          QrCodePickerState value, $Res Function(QrCodePickerState) _then) =
      _$QrCodePickerStateCopyWithImpl;
  @useResult
  $Res call({bool? cameraAvailable});
}

/// @nodoc
class _$QrCodePickerStateCopyWithImpl<$Res>
    implements $QrCodePickerStateCopyWith<$Res> {
  _$QrCodePickerStateCopyWithImpl(this._self, this._then);

  final QrCodePickerState _self;
  final $Res Function(QrCodePickerState) _then;

  /// Create a copy of QrCodePickerState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? cameraAvailable = freezed,
  }) {
    return _then(_self.copyWith(
      cameraAvailable: freezed == cameraAvailable
          ? _self.cameraAvailable
          : cameraAvailable // ignore: cast_nullable_to_non_nullable
              as bool?,
    ));
  }
}

/// Adds pattern-matching-related methods to [QrCodePickerState].
extension QrCodePickerStatePatterns on QrCodePickerState {
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
    TResult Function(_QrCodePickerState value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _QrCodePickerState() when $default != null:
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
    TResult Function(_QrCodePickerState value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _QrCodePickerState():
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
    TResult? Function(_QrCodePickerState value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _QrCodePickerState() when $default != null:
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
    TResult Function(bool? cameraAvailable)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _QrCodePickerState() when $default != null:
        return $default(_that.cameraAvailable);
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
    TResult Function(bool? cameraAvailable) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _QrCodePickerState():
        return $default(_that.cameraAvailable);
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
    TResult? Function(bool? cameraAvailable)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _QrCodePickerState() when $default != null:
        return $default(_that.cameraAvailable);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _QrCodePickerState implements QrCodePickerState {
  _QrCodePickerState({this.cameraAvailable});

  @override
  final bool? cameraAvailable;

  /// Create a copy of QrCodePickerState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$QrCodePickerStateCopyWith<_QrCodePickerState> get copyWith =>
      __$QrCodePickerStateCopyWithImpl<_QrCodePickerState>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _QrCodePickerState &&
            (identical(other.cameraAvailable, cameraAvailable) ||
                other.cameraAvailable == cameraAvailable));
  }

  @override
  int get hashCode => Object.hash(runtimeType, cameraAvailable);

  @override
  String toString() {
    return 'QrCodePickerState(cameraAvailable: $cameraAvailable)';
  }
}

/// @nodoc
abstract mixin class _$QrCodePickerStateCopyWith<$Res>
    implements $QrCodePickerStateCopyWith<$Res> {
  factory _$QrCodePickerStateCopyWith(
          _QrCodePickerState value, $Res Function(_QrCodePickerState) _then) =
      __$QrCodePickerStateCopyWithImpl;
  @override
  @useResult
  $Res call({bool? cameraAvailable});
}

/// @nodoc
class __$QrCodePickerStateCopyWithImpl<$Res>
    implements _$QrCodePickerStateCopyWith<$Res> {
  __$QrCodePickerStateCopyWithImpl(this._self, this._then);

  final _QrCodePickerState _self;
  final $Res Function(_QrCodePickerState) _then;

  /// Create a copy of QrCodePickerState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? cameraAvailable = freezed,
  }) {
    return _then(_QrCodePickerState(
      cameraAvailable: freezed == cameraAvailable
          ? _self.cameraAvailable
          : cameraAvailable // ignore: cast_nullable_to_non_nullable
              as bool?,
    ));
  }
}

// dart format on
