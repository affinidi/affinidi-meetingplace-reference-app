// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'find_offer_screen_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$FindOfferScreenState {
  Identity? get identity;

  /// Create a copy of FindOfferScreenState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $FindOfferScreenStateCopyWith<FindOfferScreenState> get copyWith =>
      _$FindOfferScreenStateCopyWithImpl<FindOfferScreenState>(
          this as FindOfferScreenState, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is FindOfferScreenState &&
            (identical(other.identity, identity) ||
                other.identity == identity));
  }

  @override
  int get hashCode => Object.hash(runtimeType, identity);

  @override
  String toString() {
    return 'FindOfferScreenState(identity: $identity)';
  }
}

/// @nodoc
abstract mixin class $FindOfferScreenStateCopyWith<$Res> {
  factory $FindOfferScreenStateCopyWith(FindOfferScreenState value,
          $Res Function(FindOfferScreenState) _then) =
      _$FindOfferScreenStateCopyWithImpl;
  @useResult
  $Res call({Identity? identity});

  $IdentityCopyWith<$Res>? get identity;
}

/// @nodoc
class _$FindOfferScreenStateCopyWithImpl<$Res>
    implements $FindOfferScreenStateCopyWith<$Res> {
  _$FindOfferScreenStateCopyWithImpl(this._self, this._then);

  final FindOfferScreenState _self;
  final $Res Function(FindOfferScreenState) _then;

  /// Create a copy of FindOfferScreenState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? identity = freezed,
  }) {
    return _then(_self.copyWith(
      identity: freezed == identity
          ? _self.identity
          : identity // ignore: cast_nullable_to_non_nullable
              as Identity?,
    ));
  }

  /// Create a copy of FindOfferScreenState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $IdentityCopyWith<$Res>? get identity {
    if (_self.identity == null) {
      return null;
    }

    return $IdentityCopyWith<$Res>(_self.identity!, (value) {
      return _then(_self.copyWith(identity: value));
    });
  }
}

/// Adds pattern-matching-related methods to [FindOfferScreenState].
extension FindOfferScreenStatePatterns on FindOfferScreenState {
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
    TResult Function(_FindOfferScreenState value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _FindOfferScreenState() when $default != null:
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
    TResult Function(_FindOfferScreenState value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _FindOfferScreenState():
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
    TResult? Function(_FindOfferScreenState value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _FindOfferScreenState() when $default != null:
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
    TResult Function(Identity? identity)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _FindOfferScreenState() when $default != null:
        return $default(_that.identity);
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
    TResult Function(Identity? identity) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _FindOfferScreenState():
        return $default(_that.identity);
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
    TResult? Function(Identity? identity)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _FindOfferScreenState() when $default != null:
        return $default(_that.identity);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _FindOfferScreenState implements FindOfferScreenState {
  _FindOfferScreenState({this.identity});

  @override
  final Identity? identity;

  /// Create a copy of FindOfferScreenState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$FindOfferScreenStateCopyWith<_FindOfferScreenState> get copyWith =>
      __$FindOfferScreenStateCopyWithImpl<_FindOfferScreenState>(
          this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _FindOfferScreenState &&
            (identical(other.identity, identity) ||
                other.identity == identity));
  }

  @override
  int get hashCode => Object.hash(runtimeType, identity);

  @override
  String toString() {
    return 'FindOfferScreenState(identity: $identity)';
  }
}

/// @nodoc
abstract mixin class _$FindOfferScreenStateCopyWith<$Res>
    implements $FindOfferScreenStateCopyWith<$Res> {
  factory _$FindOfferScreenStateCopyWith(_FindOfferScreenState value,
          $Res Function(_FindOfferScreenState) _then) =
      __$FindOfferScreenStateCopyWithImpl;
  @override
  @useResult
  $Res call({Identity? identity});

  @override
  $IdentityCopyWith<$Res>? get identity;
}

/// @nodoc
class __$FindOfferScreenStateCopyWithImpl<$Res>
    implements _$FindOfferScreenStateCopyWith<$Res> {
  __$FindOfferScreenStateCopyWithImpl(this._self, this._then);

  final _FindOfferScreenState _self;
  final $Res Function(_FindOfferScreenState) _then;

  /// Create a copy of FindOfferScreenState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? identity = freezed,
  }) {
    return _then(_FindOfferScreenState(
      identity: freezed == identity
          ? _self.identity
          : identity // ignore: cast_nullable_to_non_nullable
              as Identity?,
    ));
  }

  /// Create a copy of FindOfferScreenState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $IdentityCopyWith<$Res>? get identity {
    if (_self.identity == null) {
      return null;
    }

    return $IdentityCopyWith<$Res>(_self.identity!, (value) {
      return _then(_self.copyWith(identity: value));
    });
  }
}

// dart format on
