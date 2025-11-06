// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'oob_share_qr_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$OobShareQrState {
  String? get qrData;
  Channel? get latestChannel;

  /// Create a copy of OobShareQrState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $OobShareQrStateCopyWith<OobShareQrState> get copyWith =>
      _$OobShareQrStateCopyWithImpl<OobShareQrState>(
          this as OobShareQrState, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is OobShareQrState &&
            (identical(other.qrData, qrData) || other.qrData == qrData) &&
            (identical(other.latestChannel, latestChannel) ||
                other.latestChannel == latestChannel));
  }

  @override
  int get hashCode => Object.hash(runtimeType, qrData, latestChannel);

  @override
  String toString() {
    return 'OobShareQrState(qrData: $qrData, latestChannel: $latestChannel)';
  }
}

/// @nodoc
abstract mixin class $OobShareQrStateCopyWith<$Res> {
  factory $OobShareQrStateCopyWith(
          OobShareQrState value, $Res Function(OobShareQrState) _then) =
      _$OobShareQrStateCopyWithImpl;
  @useResult
  $Res call({String? qrData, Channel? latestChannel});
}

/// @nodoc
class _$OobShareQrStateCopyWithImpl<$Res>
    implements $OobShareQrStateCopyWith<$Res> {
  _$OobShareQrStateCopyWithImpl(this._self, this._then);

  final OobShareQrState _self;
  final $Res Function(OobShareQrState) _then;

  /// Create a copy of OobShareQrState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? qrData = freezed,
    Object? latestChannel = freezed,
  }) {
    return _then(_self.copyWith(
      qrData: freezed == qrData
          ? _self.qrData
          : qrData // ignore: cast_nullable_to_non_nullable
              as String?,
      latestChannel: freezed == latestChannel
          ? _self.latestChannel
          : latestChannel // ignore: cast_nullable_to_non_nullable
              as Channel?,
    ));
  }
}

/// Adds pattern-matching-related methods to [OobShareQrState].
extension OobShareQrStatePatterns on OobShareQrState {
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
    TResult Function(_OobShareQrState value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _OobShareQrState() when $default != null:
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
    TResult Function(_OobShareQrState value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _OobShareQrState():
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
    TResult? Function(_OobShareQrState value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _OobShareQrState() when $default != null:
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
    TResult Function(String? qrData, Channel? latestChannel)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _OobShareQrState() when $default != null:
        return $default(_that.qrData, _that.latestChannel);
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
    TResult Function(String? qrData, Channel? latestChannel) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _OobShareQrState():
        return $default(_that.qrData, _that.latestChannel);
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
    TResult? Function(String? qrData, Channel? latestChannel)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _OobShareQrState() when $default != null:
        return $default(_that.qrData, _that.latestChannel);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _OobShareQrState implements OobShareQrState {
  _OobShareQrState({this.qrData, this.latestChannel});

  @override
  final String? qrData;
  @override
  final Channel? latestChannel;

  /// Create a copy of OobShareQrState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$OobShareQrStateCopyWith<_OobShareQrState> get copyWith =>
      __$OobShareQrStateCopyWithImpl<_OobShareQrState>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _OobShareQrState &&
            (identical(other.qrData, qrData) || other.qrData == qrData) &&
            (identical(other.latestChannel, latestChannel) ||
                other.latestChannel == latestChannel));
  }

  @override
  int get hashCode => Object.hash(runtimeType, qrData, latestChannel);

  @override
  String toString() {
    return 'OobShareQrState(qrData: $qrData, latestChannel: $latestChannel)';
  }
}

/// @nodoc
abstract mixin class _$OobShareQrStateCopyWith<$Res>
    implements $OobShareQrStateCopyWith<$Res> {
  factory _$OobShareQrStateCopyWith(
          _OobShareQrState value, $Res Function(_OobShareQrState) _then) =
      __$OobShareQrStateCopyWithImpl;
  @override
  @useResult
  $Res call({String? qrData, Channel? latestChannel});
}

/// @nodoc
class __$OobShareQrStateCopyWithImpl<$Res>
    implements _$OobShareQrStateCopyWith<$Res> {
  __$OobShareQrStateCopyWithImpl(this._self, this._then);

  final _OobShareQrState _self;
  final $Res Function(_OobShareQrState) _then;

  /// Create a copy of OobShareQrState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? qrData = freezed,
    Object? latestChannel = freezed,
  }) {
    return _then(_OobShareQrState(
      qrData: freezed == qrData
          ? _self.qrData
          : qrData // ignore: cast_nullable_to_non_nullable
              as String?,
      latestChannel: freezed == latestChannel
          ? _self.latestChannel
          : latestChannel // ignore: cast_nullable_to_non_nullable
              as Channel?,
    ));
  }
}

// dart format on
