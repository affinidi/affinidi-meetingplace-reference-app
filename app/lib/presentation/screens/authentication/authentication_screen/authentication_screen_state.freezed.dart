// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'authentication_screen_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AuthenticationScreenState {
  bool get isLoading;
  bool get isError;
  String? get error;

  /// Create a copy of AuthenticationScreenState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $AuthenticationScreenStateCopyWith<AuthenticationScreenState> get copyWith =>
      _$AuthenticationScreenStateCopyWithImpl<AuthenticationScreenState>(
          this as AuthenticationScreenState, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is AuthenticationScreenState &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.isError, isError) || other.isError == isError) &&
            (identical(other.error, error) || other.error == error));
  }

  @override
  int get hashCode => Object.hash(runtimeType, isLoading, isError, error);

  @override
  String toString() {
    return 'AuthenticationScreenState(isLoading: $isLoading, isError: $isError, error: $error)';
  }
}

/// @nodoc
abstract mixin class $AuthenticationScreenStateCopyWith<$Res> {
  factory $AuthenticationScreenStateCopyWith(AuthenticationScreenState value,
          $Res Function(AuthenticationScreenState) _then) =
      _$AuthenticationScreenStateCopyWithImpl;
  @useResult
  $Res call({bool isLoading, bool isError, String? error});
}

/// @nodoc
class _$AuthenticationScreenStateCopyWithImpl<$Res>
    implements $AuthenticationScreenStateCopyWith<$Res> {
  _$AuthenticationScreenStateCopyWithImpl(this._self, this._then);

  final AuthenticationScreenState _self;
  final $Res Function(AuthenticationScreenState) _then;

  /// Create a copy of AuthenticationScreenState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isLoading = null,
    Object? isError = null,
    Object? error = freezed,
  }) {
    return _then(_self.copyWith(
      isLoading: null == isLoading
          ? _self.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      isError: null == isError
          ? _self.isError
          : isError // ignore: cast_nullable_to_non_nullable
              as bool,
      error: freezed == error
          ? _self.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// Adds pattern-matching-related methods to [AuthenticationScreenState].
extension AuthenticationScreenStatePatterns on AuthenticationScreenState {
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
    TResult Function(_AuthenticationScreenState value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _AuthenticationScreenState() when $default != null:
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
    TResult Function(_AuthenticationScreenState value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _AuthenticationScreenState():
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
    TResult? Function(_AuthenticationScreenState value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _AuthenticationScreenState() when $default != null:
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
    TResult Function(bool isLoading, bool isError, String? error)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _AuthenticationScreenState() when $default != null:
        return $default(_that.isLoading, _that.isError, _that.error);
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
    TResult Function(bool isLoading, bool isError, String? error) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _AuthenticationScreenState():
        return $default(_that.isLoading, _that.isError, _that.error);
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
    TResult? Function(bool isLoading, bool isError, String? error)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _AuthenticationScreenState() when $default != null:
        return $default(_that.isLoading, _that.isError, _that.error);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _AuthenticationScreenState implements AuthenticationScreenState {
  const _AuthenticationScreenState(
      {this.isLoading = false, this.isError = false, this.error});

  @override
  @JsonKey()
  final bool isLoading;
  @override
  @JsonKey()
  final bool isError;
  @override
  final String? error;

  /// Create a copy of AuthenticationScreenState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$AuthenticationScreenStateCopyWith<_AuthenticationScreenState>
      get copyWith =>
          __$AuthenticationScreenStateCopyWithImpl<_AuthenticationScreenState>(
              this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _AuthenticationScreenState &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.isError, isError) || other.isError == isError) &&
            (identical(other.error, error) || other.error == error));
  }

  @override
  int get hashCode => Object.hash(runtimeType, isLoading, isError, error);

  @override
  String toString() {
    return 'AuthenticationScreenState(isLoading: $isLoading, isError: $isError, error: $error)';
  }
}

/// @nodoc
abstract mixin class _$AuthenticationScreenStateCopyWith<$Res>
    implements $AuthenticationScreenStateCopyWith<$Res> {
  factory _$AuthenticationScreenStateCopyWith(_AuthenticationScreenState value,
          $Res Function(_AuthenticationScreenState) _then) =
      __$AuthenticationScreenStateCopyWithImpl;
  @override
  @useResult
  $Res call({bool isLoading, bool isError, String? error});
}

/// @nodoc
class __$AuthenticationScreenStateCopyWithImpl<$Res>
    implements _$AuthenticationScreenStateCopyWith<$Res> {
  __$AuthenticationScreenStateCopyWithImpl(this._self, this._then);

  final _AuthenticationScreenState _self;
  final $Res Function(_AuthenticationScreenState) _then;

  /// Create a copy of AuthenticationScreenState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? isLoading = null,
    Object? isError = null,
    Object? error = freezed,
  }) {
    return _then(_AuthenticationScreenState(
      isLoading: null == isLoading
          ? _self.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      isError: null == isError
          ? _self.isError
          : isError // ignore: cast_nullable_to_non_nullable
              as bool,
      error: freezed == error
          ? _self.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

// dart format on
