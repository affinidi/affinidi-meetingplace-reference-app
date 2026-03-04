// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'oob_scan_qr_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$OobScanQrState {
  bool get isProcessing;
  String? get errorMessage;
  String? get scannedCode;

  /// Create a copy of OobScanQrState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $OobScanQrStateCopyWith<OobScanQrState> get copyWith =>
      _$OobScanQrStateCopyWithImpl<OobScanQrState>(
          this as OobScanQrState, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is OobScanQrState &&
            (identical(other.isProcessing, isProcessing) ||
                other.isProcessing == isProcessing) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage) &&
            (identical(other.scannedCode, scannedCode) ||
                other.scannedCode == scannedCode));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, isProcessing, errorMessage, scannedCode);

  @override
  String toString() {
    return 'OobScanQrState(isProcessing: $isProcessing, errorMessage: $errorMessage, scannedCode: $scannedCode)';
  }
}

/// @nodoc
abstract mixin class $OobScanQrStateCopyWith<$Res> {
  factory $OobScanQrStateCopyWith(
          OobScanQrState value, $Res Function(OobScanQrState) _then) =
      _$OobScanQrStateCopyWithImpl;
  @useResult
  $Res call({bool isProcessing, String? errorMessage, String? scannedCode});
}

/// @nodoc
class _$OobScanQrStateCopyWithImpl<$Res>
    implements $OobScanQrStateCopyWith<$Res> {
  _$OobScanQrStateCopyWithImpl(this._self, this._then);

  final OobScanQrState _self;
  final $Res Function(OobScanQrState) _then;

  /// Create a copy of OobScanQrState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isProcessing = null,
    Object? errorMessage = freezed,
    Object? scannedCode = freezed,
  }) {
    return _then(_self.copyWith(
      isProcessing: null == isProcessing
          ? _self.isProcessing
          : isProcessing // ignore: cast_nullable_to_non_nullable
              as bool,
      errorMessage: freezed == errorMessage
          ? _self.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String?,
      scannedCode: freezed == scannedCode
          ? _self.scannedCode
          : scannedCode // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// Adds pattern-matching-related methods to [OobScanQrState].
extension OobScanQrStatePatterns on OobScanQrState {
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
    TResult Function(_OobScanQrState value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _OobScanQrState() when $default != null:
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
    TResult Function(_OobScanQrState value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _OobScanQrState():
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
    TResult? Function(_OobScanQrState value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _OobScanQrState() when $default != null:
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
    TResult Function(
            bool isProcessing, String? errorMessage, String? scannedCode)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _OobScanQrState() when $default != null:
        return $default(
            _that.isProcessing, _that.errorMessage, _that.scannedCode);
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
    TResult Function(
            bool isProcessing, String? errorMessage, String? scannedCode)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _OobScanQrState():
        return $default(
            _that.isProcessing, _that.errorMessage, _that.scannedCode);
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
    TResult? Function(
            bool isProcessing, String? errorMessage, String? scannedCode)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _OobScanQrState() when $default != null:
        return $default(
            _that.isProcessing, _that.errorMessage, _that.scannedCode);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _OobScanQrState implements OobScanQrState {
  _OobScanQrState(
      {this.isProcessing = false, this.errorMessage, this.scannedCode});

  @override
  @JsonKey()
  final bool isProcessing;
  @override
  final String? errorMessage;
  @override
  final String? scannedCode;

  /// Create a copy of OobScanQrState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$OobScanQrStateCopyWith<_OobScanQrState> get copyWith =>
      __$OobScanQrStateCopyWithImpl<_OobScanQrState>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _OobScanQrState &&
            (identical(other.isProcessing, isProcessing) ||
                other.isProcessing == isProcessing) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage) &&
            (identical(other.scannedCode, scannedCode) ||
                other.scannedCode == scannedCode));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, isProcessing, errorMessage, scannedCode);

  @override
  String toString() {
    return 'OobScanQrState(isProcessing: $isProcessing, errorMessage: $errorMessage, scannedCode: $scannedCode)';
  }
}

/// @nodoc
abstract mixin class _$OobScanQrStateCopyWith<$Res>
    implements $OobScanQrStateCopyWith<$Res> {
  factory _$OobScanQrStateCopyWith(
          _OobScanQrState value, $Res Function(_OobScanQrState) _then) =
      __$OobScanQrStateCopyWithImpl;
  @override
  @useResult
  $Res call({bool isProcessing, String? errorMessage, String? scannedCode});
}

/// @nodoc
class __$OobScanQrStateCopyWithImpl<$Res>
    implements _$OobScanQrStateCopyWith<$Res> {
  __$OobScanQrStateCopyWithImpl(this._self, this._then);

  final _OobScanQrState _self;
  final $Res Function(_OobScanQrState) _then;

  /// Create a copy of OobScanQrState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? isProcessing = null,
    Object? errorMessage = freezed,
    Object? scannedCode = freezed,
  }) {
    return _then(_OobScanQrState(
      isProcessing: null == isProcessing
          ? _self.isProcessing
          : isProcessing // ignore: cast_nullable_to_non_nullable
              as bool,
      errorMessage: freezed == errorMessage
          ? _self.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String?,
      scannedCode: freezed == scannedCode
          ? _self.scannedCode
          : scannedCode // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

// dart format on
