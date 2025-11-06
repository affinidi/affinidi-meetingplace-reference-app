// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'identities_service_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$IdentitiesServiceState {
  Identity? get currentIdentity;
  List<Identity> get identities;
  String? get errorMessage;

  /// Create a copy of IdentitiesServiceState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $IdentitiesServiceStateCopyWith<IdentitiesServiceState> get copyWith =>
      _$IdentitiesServiceStateCopyWithImpl<IdentitiesServiceState>(
          this as IdentitiesServiceState, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is IdentitiesServiceState &&
            (identical(other.currentIdentity, currentIdentity) ||
                other.currentIdentity == currentIdentity) &&
            const DeepCollectionEquality()
                .equals(other.identities, identities) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage));
  }

  @override
  int get hashCode => Object.hash(runtimeType, currentIdentity,
      const DeepCollectionEquality().hash(identities), errorMessage);

  @override
  String toString() {
    return 'IdentitiesServiceState(currentIdentity: $currentIdentity, identities: $identities, errorMessage: $errorMessage)';
  }
}

/// @nodoc
abstract mixin class $IdentitiesServiceStateCopyWith<$Res> {
  factory $IdentitiesServiceStateCopyWith(IdentitiesServiceState value,
          $Res Function(IdentitiesServiceState) _then) =
      _$IdentitiesServiceStateCopyWithImpl;
  @useResult
  $Res call(
      {Identity? currentIdentity,
      List<Identity> identities,
      String? errorMessage});

  $IdentityCopyWith<$Res>? get currentIdentity;
}

/// @nodoc
class _$IdentitiesServiceStateCopyWithImpl<$Res>
    implements $IdentitiesServiceStateCopyWith<$Res> {
  _$IdentitiesServiceStateCopyWithImpl(this._self, this._then);

  final IdentitiesServiceState _self;
  final $Res Function(IdentitiesServiceState) _then;

  /// Create a copy of IdentitiesServiceState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? currentIdentity = freezed,
    Object? identities = null,
    Object? errorMessage = freezed,
  }) {
    return _then(_self.copyWith(
      currentIdentity: freezed == currentIdentity
          ? _self.currentIdentity
          : currentIdentity // ignore: cast_nullable_to_non_nullable
              as Identity?,
      identities: null == identities
          ? _self.identities
          : identities // ignore: cast_nullable_to_non_nullable
              as List<Identity>,
      errorMessage: freezed == errorMessage
          ? _self.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }

  /// Create a copy of IdentitiesServiceState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $IdentityCopyWith<$Res>? get currentIdentity {
    if (_self.currentIdentity == null) {
      return null;
    }

    return $IdentityCopyWith<$Res>(_self.currentIdentity!, (value) {
      return _then(_self.copyWith(currentIdentity: value));
    });
  }
}

/// Adds pattern-matching-related methods to [IdentitiesServiceState].
extension IdentitiesServiceStatePatterns on IdentitiesServiceState {
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
    TResult Function(_IdentitiesServiceState value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _IdentitiesServiceState() when $default != null:
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
    TResult Function(_IdentitiesServiceState value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _IdentitiesServiceState():
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
    TResult? Function(_IdentitiesServiceState value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _IdentitiesServiceState() when $default != null:
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
    TResult Function(Identity? currentIdentity, List<Identity> identities,
            String? errorMessage)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _IdentitiesServiceState() when $default != null:
        return $default(
            _that.currentIdentity, _that.identities, _that.errorMessage);
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
    TResult Function(Identity? currentIdentity, List<Identity> identities,
            String? errorMessage)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _IdentitiesServiceState():
        return $default(
            _that.currentIdentity, _that.identities, _that.errorMessage);
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
    TResult? Function(Identity? currentIdentity, List<Identity> identities,
            String? errorMessage)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _IdentitiesServiceState() when $default != null:
        return $default(
            _that.currentIdentity, _that.identities, _that.errorMessage);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _IdentitiesServiceState extends IdentitiesServiceState {
  _IdentitiesServiceState(
      {this.currentIdentity,
      final List<Identity> identities = const [],
      this.errorMessage})
      : _identities = identities,
        super._();

  @override
  final Identity? currentIdentity;
  final List<Identity> _identities;
  @override
  @JsonKey()
  List<Identity> get identities {
    if (_identities is EqualUnmodifiableListView) return _identities;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_identities);
  }

  @override
  final String? errorMessage;

  /// Create a copy of IdentitiesServiceState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$IdentitiesServiceStateCopyWith<_IdentitiesServiceState> get copyWith =>
      __$IdentitiesServiceStateCopyWithImpl<_IdentitiesServiceState>(
          this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _IdentitiesServiceState &&
            (identical(other.currentIdentity, currentIdentity) ||
                other.currentIdentity == currentIdentity) &&
            const DeepCollectionEquality()
                .equals(other._identities, _identities) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage));
  }

  @override
  int get hashCode => Object.hash(runtimeType, currentIdentity,
      const DeepCollectionEquality().hash(_identities), errorMessage);

  @override
  String toString() {
    return 'IdentitiesServiceState(currentIdentity: $currentIdentity, identities: $identities, errorMessage: $errorMessage)';
  }
}

/// @nodoc
abstract mixin class _$IdentitiesServiceStateCopyWith<$Res>
    implements $IdentitiesServiceStateCopyWith<$Res> {
  factory _$IdentitiesServiceStateCopyWith(_IdentitiesServiceState value,
          $Res Function(_IdentitiesServiceState) _then) =
      __$IdentitiesServiceStateCopyWithImpl;
  @override
  @useResult
  $Res call(
      {Identity? currentIdentity,
      List<Identity> identities,
      String? errorMessage});

  @override
  $IdentityCopyWith<$Res>? get currentIdentity;
}

/// @nodoc
class __$IdentitiesServiceStateCopyWithImpl<$Res>
    implements _$IdentitiesServiceStateCopyWith<$Res> {
  __$IdentitiesServiceStateCopyWithImpl(this._self, this._then);

  final _IdentitiesServiceState _self;
  final $Res Function(_IdentitiesServiceState) _then;

  /// Create a copy of IdentitiesServiceState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? currentIdentity = freezed,
    Object? identities = null,
    Object? errorMessage = freezed,
  }) {
    return _then(_IdentitiesServiceState(
      currentIdentity: freezed == currentIdentity
          ? _self.currentIdentity
          : currentIdentity // ignore: cast_nullable_to_non_nullable
              as Identity?,
      identities: null == identities
          ? _self._identities
          : identities // ignore: cast_nullable_to_non_nullable
              as List<Identity>,
      errorMessage: freezed == errorMessage
          ? _self.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }

  /// Create a copy of IdentitiesServiceState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $IdentityCopyWith<$Res>? get currentIdentity {
    if (_self.currentIdentity == null) {
      return null;
    }

    return $IdentityCopyWith<$Res>(_self.currentIdentity!, (value) {
      return _then(_self.copyWith(currentIdentity: value));
    });
  }
}

// dart format on
