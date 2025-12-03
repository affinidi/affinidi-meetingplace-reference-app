// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'unsent_messages_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$UnsentMessagesServiceState {
  Map<String, String> get unsentMessages;

  /// Create a copy of UnsentMessagesServiceState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $UnsentMessagesServiceStateCopyWith<UnsentMessagesServiceState>
      get copyWith =>
          _$UnsentMessagesServiceStateCopyWithImpl<UnsentMessagesServiceState>(
              this as UnsentMessagesServiceState, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is UnsentMessagesServiceState &&
            const DeepCollectionEquality()
                .equals(other.unsentMessages, unsentMessages));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, const DeepCollectionEquality().hash(unsentMessages));

  @override
  String toString() {
    return 'UnsentMessagesServiceState(unsentMessages: $unsentMessages)';
  }
}

/// @nodoc
abstract mixin class $UnsentMessagesServiceStateCopyWith<$Res> {
  factory $UnsentMessagesServiceStateCopyWith(UnsentMessagesServiceState value,
          $Res Function(UnsentMessagesServiceState) _then) =
      _$UnsentMessagesServiceStateCopyWithImpl;
  @useResult
  $Res call({Map<String, String> unsentMessages});
}

/// @nodoc
class _$UnsentMessagesServiceStateCopyWithImpl<$Res>
    implements $UnsentMessagesServiceStateCopyWith<$Res> {
  _$UnsentMessagesServiceStateCopyWithImpl(this._self, this._then);

  final UnsentMessagesServiceState _self;
  final $Res Function(UnsentMessagesServiceState) _then;

  /// Create a copy of UnsentMessagesServiceState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? unsentMessages = null,
  }) {
    return _then(_self.copyWith(
      unsentMessages: null == unsentMessages
          ? _self.unsentMessages
          : unsentMessages // ignore: cast_nullable_to_non_nullable
              as Map<String, String>,
    ));
  }
}

/// Adds pattern-matching-related methods to [UnsentMessagesServiceState].
extension UnsentMessagesServiceStatePatterns on UnsentMessagesServiceState {
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
    TResult Function(_UnsentMessagesServiceState value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _UnsentMessagesServiceState() when $default != null:
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
    TResult Function(_UnsentMessagesServiceState value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _UnsentMessagesServiceState():
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
    TResult? Function(_UnsentMessagesServiceState value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _UnsentMessagesServiceState() when $default != null:
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
    TResult Function(Map<String, String> unsentMessages)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _UnsentMessagesServiceState() when $default != null:
        return $default(_that.unsentMessages);
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
    TResult Function(Map<String, String> unsentMessages) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _UnsentMessagesServiceState():
        return $default(_that.unsentMessages);
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
    TResult? Function(Map<String, String> unsentMessages)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _UnsentMessagesServiceState() when $default != null:
        return $default(_that.unsentMessages);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _UnsentMessagesServiceState implements UnsentMessagesServiceState {
  const _UnsentMessagesServiceState(
      {final Map<String, String> unsentMessages = const {}})
      : _unsentMessages = unsentMessages;

  final Map<String, String> _unsentMessages;
  @override
  @JsonKey()
  Map<String, String> get unsentMessages {
    if (_unsentMessages is EqualUnmodifiableMapView) return _unsentMessages;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_unsentMessages);
  }

  /// Create a copy of UnsentMessagesServiceState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$UnsentMessagesServiceStateCopyWith<_UnsentMessagesServiceState>
      get copyWith => __$UnsentMessagesServiceStateCopyWithImpl<
          _UnsentMessagesServiceState>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _UnsentMessagesServiceState &&
            const DeepCollectionEquality()
                .equals(other._unsentMessages, _unsentMessages));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, const DeepCollectionEquality().hash(_unsentMessages));

  @override
  String toString() {
    return 'UnsentMessagesServiceState(unsentMessages: $unsentMessages)';
  }
}

/// @nodoc
abstract mixin class _$UnsentMessagesServiceStateCopyWith<$Res>
    implements $UnsentMessagesServiceStateCopyWith<$Res> {
  factory _$UnsentMessagesServiceStateCopyWith(
          _UnsentMessagesServiceState value,
          $Res Function(_UnsentMessagesServiceState) _then) =
      __$UnsentMessagesServiceStateCopyWithImpl;
  @override
  @useResult
  $Res call({Map<String, String> unsentMessages});
}

/// @nodoc
class __$UnsentMessagesServiceStateCopyWithImpl<$Res>
    implements _$UnsentMessagesServiceStateCopyWith<$Res> {
  __$UnsentMessagesServiceStateCopyWithImpl(this._self, this._then);

  final _UnsentMessagesServiceState _self;
  final $Res Function(_UnsentMessagesServiceState) _then;

  /// Create a copy of UnsentMessagesServiceState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? unsentMessages = null,
  }) {
    return _then(_UnsentMessagesServiceState(
      unsentMessages: null == unsentMessages
          ? _self._unsentMessages
          : unsentMessages // ignore: cast_nullable_to_non_nullable
              as Map<String, String>,
    ));
  }
}

// dart format on
