// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'connections_service_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ConnectionsServiceState {
  List<ConnectionOffer> get connections;
  ConnectionOffer? get selectedOffer;
  ConnectionOffer? get publishedOffer;
  bool? get isCustomPhraseAvailable;

  /// Create a copy of ConnectionsServiceState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ConnectionsServiceStateCopyWith<ConnectionsServiceState> get copyWith =>
      _$ConnectionsServiceStateCopyWithImpl<ConnectionsServiceState>(
          this as ConnectionsServiceState, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is ConnectionsServiceState &&
            const DeepCollectionEquality()
                .equals(other.connections, connections) &&
            (identical(other.selectedOffer, selectedOffer) ||
                other.selectedOffer == selectedOffer) &&
            (identical(other.publishedOffer, publishedOffer) ||
                other.publishedOffer == publishedOffer) &&
            (identical(
                    other.isCustomPhraseAvailable, isCustomPhraseAvailable) ||
                other.isCustomPhraseAvailable == isCustomPhraseAvailable));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(connections),
      selectedOffer,
      publishedOffer,
      isCustomPhraseAvailable);

  @override
  String toString() {
    return 'ConnectionsServiceState(connections: $connections, selectedOffer: $selectedOffer, publishedOffer: $publishedOffer, isCustomPhraseAvailable: $isCustomPhraseAvailable)';
  }
}

/// @nodoc
abstract mixin class $ConnectionsServiceStateCopyWith<$Res> {
  factory $ConnectionsServiceStateCopyWith(ConnectionsServiceState value,
          $Res Function(ConnectionsServiceState) _then) =
      _$ConnectionsServiceStateCopyWithImpl;
  @useResult
  $Res call(
      {List<ConnectionOffer> connections,
      ConnectionOffer? selectedOffer,
      ConnectionOffer? publishedOffer,
      bool? isCustomPhraseAvailable});
}

/// @nodoc
class _$ConnectionsServiceStateCopyWithImpl<$Res>
    implements $ConnectionsServiceStateCopyWith<$Res> {
  _$ConnectionsServiceStateCopyWithImpl(this._self, this._then);

  final ConnectionsServiceState _self;
  final $Res Function(ConnectionsServiceState) _then;

  /// Create a copy of ConnectionsServiceState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? connections = null,
    Object? selectedOffer = freezed,
    Object? publishedOffer = freezed,
    Object? isCustomPhraseAvailable = freezed,
  }) {
    return _then(_self.copyWith(
      connections: null == connections
          ? _self.connections
          : connections // ignore: cast_nullable_to_non_nullable
              as List<ConnectionOffer>,
      selectedOffer: freezed == selectedOffer
          ? _self.selectedOffer
          : selectedOffer // ignore: cast_nullable_to_non_nullable
              as ConnectionOffer?,
      publishedOffer: freezed == publishedOffer
          ? _self.publishedOffer
          : publishedOffer // ignore: cast_nullable_to_non_nullable
              as ConnectionOffer?,
      isCustomPhraseAvailable: freezed == isCustomPhraseAvailable
          ? _self.isCustomPhraseAvailable
          : isCustomPhraseAvailable // ignore: cast_nullable_to_non_nullable
              as bool?,
    ));
  }
}

/// Adds pattern-matching-related methods to [ConnectionsServiceState].
extension ConnectionsServiceStatePatterns on ConnectionsServiceState {
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
    TResult Function(_ConnectionsServiceState value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _ConnectionsServiceState() when $default != null:
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
    TResult Function(_ConnectionsServiceState value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ConnectionsServiceState():
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
    TResult? Function(_ConnectionsServiceState value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ConnectionsServiceState() when $default != null:
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
            List<ConnectionOffer> connections,
            ConnectionOffer? selectedOffer,
            ConnectionOffer? publishedOffer,
            bool? isCustomPhraseAvailable)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _ConnectionsServiceState() when $default != null:
        return $default(_that.connections, _that.selectedOffer,
            _that.publishedOffer, _that.isCustomPhraseAvailable);
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
            List<ConnectionOffer> connections,
            ConnectionOffer? selectedOffer,
            ConnectionOffer? publishedOffer,
            bool? isCustomPhraseAvailable)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ConnectionsServiceState():
        return $default(_that.connections, _that.selectedOffer,
            _that.publishedOffer, _that.isCustomPhraseAvailable);
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
            List<ConnectionOffer> connections,
            ConnectionOffer? selectedOffer,
            ConnectionOffer? publishedOffer,
            bool? isCustomPhraseAvailable)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ConnectionsServiceState() when $default != null:
        return $default(_that.connections, _that.selectedOffer,
            _that.publishedOffer, _that.isCustomPhraseAvailable);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _ConnectionsServiceState extends ConnectionsServiceState {
  _ConnectionsServiceState(
      {final List<ConnectionOffer> connections = const [],
      this.selectedOffer,
      this.publishedOffer,
      this.isCustomPhraseAvailable})
      : _connections = connections,
        super._();

  final List<ConnectionOffer> _connections;
  @override
  @JsonKey()
  List<ConnectionOffer> get connections {
    if (_connections is EqualUnmodifiableListView) return _connections;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_connections);
  }

  @override
  final ConnectionOffer? selectedOffer;
  @override
  final ConnectionOffer? publishedOffer;
  @override
  final bool? isCustomPhraseAvailable;

  /// Create a copy of ConnectionsServiceState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$ConnectionsServiceStateCopyWith<_ConnectionsServiceState> get copyWith =>
      __$ConnectionsServiceStateCopyWithImpl<_ConnectionsServiceState>(
          this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _ConnectionsServiceState &&
            const DeepCollectionEquality()
                .equals(other._connections, _connections) &&
            (identical(other.selectedOffer, selectedOffer) ||
                other.selectedOffer == selectedOffer) &&
            (identical(other.publishedOffer, publishedOffer) ||
                other.publishedOffer == publishedOffer) &&
            (identical(
                    other.isCustomPhraseAvailable, isCustomPhraseAvailable) ||
                other.isCustomPhraseAvailable == isCustomPhraseAvailable));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_connections),
      selectedOffer,
      publishedOffer,
      isCustomPhraseAvailable);

  @override
  String toString() {
    return 'ConnectionsServiceState(connections: $connections, selectedOffer: $selectedOffer, publishedOffer: $publishedOffer, isCustomPhraseAvailable: $isCustomPhraseAvailable)';
  }
}

/// @nodoc
abstract mixin class _$ConnectionsServiceStateCopyWith<$Res>
    implements $ConnectionsServiceStateCopyWith<$Res> {
  factory _$ConnectionsServiceStateCopyWith(_ConnectionsServiceState value,
          $Res Function(_ConnectionsServiceState) _then) =
      __$ConnectionsServiceStateCopyWithImpl;
  @override
  @useResult
  $Res call(
      {List<ConnectionOffer> connections,
      ConnectionOffer? selectedOffer,
      ConnectionOffer? publishedOffer,
      bool? isCustomPhraseAvailable});
}

/// @nodoc
class __$ConnectionsServiceStateCopyWithImpl<$Res>
    implements _$ConnectionsServiceStateCopyWith<$Res> {
  __$ConnectionsServiceStateCopyWithImpl(this._self, this._then);

  final _ConnectionsServiceState _self;
  final $Res Function(_ConnectionsServiceState) _then;

  /// Create a copy of ConnectionsServiceState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? connections = null,
    Object? selectedOffer = freezed,
    Object? publishedOffer = freezed,
    Object? isCustomPhraseAvailable = freezed,
  }) {
    return _then(_ConnectionsServiceState(
      connections: null == connections
          ? _self._connections
          : connections // ignore: cast_nullable_to_non_nullable
              as List<ConnectionOffer>,
      selectedOffer: freezed == selectedOffer
          ? _self.selectedOffer
          : selectedOffer // ignore: cast_nullable_to_non_nullable
              as ConnectionOffer?,
      publishedOffer: freezed == publishedOffer
          ? _self.publishedOffer
          : publishedOffer // ignore: cast_nullable_to_non_nullable
              as ConnectionOffer?,
      isCustomPhraseAvailable: freezed == isCustomPhraseAvailable
          ? _self.isCustomPhraseAvailable
          : isCustomPhraseAvailable // ignore: cast_nullable_to_non_nullable
              as bool?,
    ));
  }
}

// dart format on
