// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'debug_panel_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DebugPanelState {
  List<AppLogEntry> get logs;
  bool get isAtBottom;

  /// Create a copy of DebugPanelState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $DebugPanelStateCopyWith<DebugPanelState> get copyWith =>
      _$DebugPanelStateCopyWithImpl<DebugPanelState>(
          this as DebugPanelState, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is DebugPanelState &&
            const DeepCollectionEquality().equals(other.logs, logs) &&
            (identical(other.isAtBottom, isAtBottom) ||
                other.isAtBottom == isAtBottom));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, const DeepCollectionEquality().hash(logs), isAtBottom);

  @override
  String toString() {
    return 'DebugPanelState(logs: $logs, isAtBottom: $isAtBottom)';
  }
}

/// @nodoc
abstract mixin class $DebugPanelStateCopyWith<$Res> {
  factory $DebugPanelStateCopyWith(
          DebugPanelState value, $Res Function(DebugPanelState) _then) =
      _$DebugPanelStateCopyWithImpl;
  @useResult
  $Res call({List<AppLogEntry> logs, bool isAtBottom});
}

/// @nodoc
class _$DebugPanelStateCopyWithImpl<$Res>
    implements $DebugPanelStateCopyWith<$Res> {
  _$DebugPanelStateCopyWithImpl(this._self, this._then);

  final DebugPanelState _self;
  final $Res Function(DebugPanelState) _then;

  /// Create a copy of DebugPanelState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? logs = null,
    Object? isAtBottom = null,
  }) {
    return _then(_self.copyWith(
      logs: null == logs
          ? _self.logs
          : logs // ignore: cast_nullable_to_non_nullable
              as List<AppLogEntry>,
      isAtBottom: null == isAtBottom
          ? _self.isAtBottom
          : isAtBottom // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// Adds pattern-matching-related methods to [DebugPanelState].
extension DebugPanelStatePatterns on DebugPanelState {
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
    TResult Function(_DebugPanelState value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _DebugPanelState() when $default != null:
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
    TResult Function(_DebugPanelState value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _DebugPanelState():
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
    TResult? Function(_DebugPanelState value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _DebugPanelState() when $default != null:
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
    TResult Function(List<AppLogEntry> logs, bool isAtBottom)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _DebugPanelState() when $default != null:
        return $default(_that.logs, _that.isAtBottom);
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
    TResult Function(List<AppLogEntry> logs, bool isAtBottom) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _DebugPanelState():
        return $default(_that.logs, _that.isAtBottom);
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
    TResult? Function(List<AppLogEntry> logs, bool isAtBottom)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _DebugPanelState() when $default != null:
        return $default(_that.logs, _that.isAtBottom);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _DebugPanelState implements DebugPanelState {
  const _DebugPanelState(
      {final List<AppLogEntry> logs = const [], this.isAtBottom = true})
      : _logs = logs;

  final List<AppLogEntry> _logs;
  @override
  @JsonKey()
  List<AppLogEntry> get logs {
    if (_logs is EqualUnmodifiableListView) return _logs;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_logs);
  }

  @override
  @JsonKey()
  final bool isAtBottom;

  /// Create a copy of DebugPanelState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$DebugPanelStateCopyWith<_DebugPanelState> get copyWith =>
      __$DebugPanelStateCopyWithImpl<_DebugPanelState>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _DebugPanelState &&
            const DeepCollectionEquality().equals(other._logs, _logs) &&
            (identical(other.isAtBottom, isAtBottom) ||
                other.isAtBottom == isAtBottom));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, const DeepCollectionEquality().hash(_logs), isAtBottom);

  @override
  String toString() {
    return 'DebugPanelState(logs: $logs, isAtBottom: $isAtBottom)';
  }
}

/// @nodoc
abstract mixin class _$DebugPanelStateCopyWith<$Res>
    implements $DebugPanelStateCopyWith<$Res> {
  factory _$DebugPanelStateCopyWith(
          _DebugPanelState value, $Res Function(_DebugPanelState) _then) =
      __$DebugPanelStateCopyWithImpl;
  @override
  @useResult
  $Res call({List<AppLogEntry> logs, bool isAtBottom});
}

/// @nodoc
class __$DebugPanelStateCopyWithImpl<$Res>
    implements _$DebugPanelStateCopyWith<$Res> {
  __$DebugPanelStateCopyWithImpl(this._self, this._then);

  final _DebugPanelState _self;
  final $Res Function(_DebugPanelState) _then;

  /// Create a copy of DebugPanelState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? logs = null,
    Object? isAtBottom = null,
  }) {
    return _then(_DebugPanelState(
      logs: null == logs
          ? _self._logs
          : logs // ignore: cast_nullable_to_non_nullable
              as List<AppLogEntry>,
      isAtBottom: null == isAtBottom
          ? _self.isAtBottom
          : isAtBottom // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

// dart format on
