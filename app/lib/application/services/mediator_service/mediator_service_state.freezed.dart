// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'mediator_service_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MediatorServiceState {
  List<Mediator> get mediators;

  /// Create a copy of MediatorServiceState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $MediatorServiceStateCopyWith<MediatorServiceState> get copyWith =>
      _$MediatorServiceStateCopyWithImpl<MediatorServiceState>(
          this as MediatorServiceState, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is MediatorServiceState &&
            const DeepCollectionEquality().equals(other.mediators, mediators));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(mediators));

  @override
  String toString() {
    return 'MediatorServiceState(mediators: $mediators)';
  }
}

/// @nodoc
abstract mixin class $MediatorServiceStateCopyWith<$Res> {
  factory $MediatorServiceStateCopyWith(MediatorServiceState value,
          $Res Function(MediatorServiceState) _then) =
      _$MediatorServiceStateCopyWithImpl;
  @useResult
  $Res call({List<Mediator> mediators});
}

/// @nodoc
class _$MediatorServiceStateCopyWithImpl<$Res>
    implements $MediatorServiceStateCopyWith<$Res> {
  _$MediatorServiceStateCopyWithImpl(this._self, this._then);

  final MediatorServiceState _self;
  final $Res Function(MediatorServiceState) _then;

  /// Create a copy of MediatorServiceState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? mediators = null,
  }) {
    return _then(_self.copyWith(
      mediators: null == mediators
          ? _self.mediators
          : mediators // ignore: cast_nullable_to_non_nullable
              as List<Mediator>,
    ));
  }
}

/// Adds pattern-matching-related methods to [MediatorServiceState].
extension MediatorServiceStatePatterns on MediatorServiceState {
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
    TResult Function(_MediatorServiceState value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _MediatorServiceState() when $default != null:
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
    TResult Function(_MediatorServiceState value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _MediatorServiceState():
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
    TResult? Function(_MediatorServiceState value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _MediatorServiceState() when $default != null:
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
    TResult Function(List<Mediator> mediators)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _MediatorServiceState() when $default != null:
        return $default(_that.mediators);
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
    TResult Function(List<Mediator> mediators) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _MediatorServiceState():
        return $default(_that.mediators);
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
    TResult? Function(List<Mediator> mediators)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _MediatorServiceState() when $default != null:
        return $default(_that.mediators);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _MediatorServiceState implements MediatorServiceState {
  _MediatorServiceState({final List<Mediator> mediators = const []})
      : _mediators = mediators;

  final List<Mediator> _mediators;
  @override
  @JsonKey()
  List<Mediator> get mediators {
    if (_mediators is EqualUnmodifiableListView) return _mediators;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_mediators);
  }

  /// Create a copy of MediatorServiceState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$MediatorServiceStateCopyWith<_MediatorServiceState> get copyWith =>
      __$MediatorServiceStateCopyWithImpl<_MediatorServiceState>(
          this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _MediatorServiceState &&
            const DeepCollectionEquality()
                .equals(other._mediators, _mediators));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(_mediators));

  @override
  String toString() {
    return 'MediatorServiceState(mediators: $mediators)';
  }
}

/// @nodoc
abstract mixin class _$MediatorServiceStateCopyWith<$Res>
    implements $MediatorServiceStateCopyWith<$Res> {
  factory _$MediatorServiceStateCopyWith(_MediatorServiceState value,
          $Res Function(_MediatorServiceState) _then) =
      __$MediatorServiceStateCopyWithImpl;
  @override
  @useResult
  $Res call({List<Mediator> mediators});
}

/// @nodoc
class __$MediatorServiceStateCopyWithImpl<$Res>
    implements _$MediatorServiceStateCopyWith<$Res> {
  __$MediatorServiceStateCopyWithImpl(this._self, this._then);

  final _MediatorServiceState _self;
  final $Res Function(_MediatorServiceState) _then;

  /// Create a copy of MediatorServiceState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? mediators = null,
  }) {
    return _then(_MediatorServiceState(
      mediators: null == mediators
          ? _self._mediators
          : mediators // ignore: cast_nullable_to_non_nullable
              as List<Mediator>,
    ));
  }
}

// dart format on
