// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'identity_form_screen_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$IdentityFormScreenState {
  Identity get identity;
  bool get canSave;
  bool get canDelete;
  bool get hasEnteredAnyInfo;
  bool get hasSaved;
  bool get hasDeleted;
  bool get isAliasMirroringFirstName;
  Set<String> get showingErrorFields;

  /// Create a copy of IdentityFormScreenState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $IdentityFormScreenStateCopyWith<IdentityFormScreenState> get copyWith =>
      _$IdentityFormScreenStateCopyWithImpl<IdentityFormScreenState>(
          this as IdentityFormScreenState, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is IdentityFormScreenState &&
            (identical(other.identity, identity) ||
                other.identity == identity) &&
            (identical(other.canSave, canSave) || other.canSave == canSave) &&
            (identical(other.canDelete, canDelete) ||
                other.canDelete == canDelete) &&
            (identical(other.hasEnteredAnyInfo, hasEnteredAnyInfo) ||
                other.hasEnteredAnyInfo == hasEnteredAnyInfo) &&
            (identical(other.hasSaved, hasSaved) ||
                other.hasSaved == hasSaved) &&
            (identical(other.hasDeleted, hasDeleted) ||
                other.hasDeleted == hasDeleted) &&
            (identical(other.isAliasMirroringFirstName,
                    isAliasMirroringFirstName) ||
                other.isAliasMirroringFirstName == isAliasMirroringFirstName) &&
            const DeepCollectionEquality()
                .equals(other.showingErrorFields, showingErrorFields));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      identity,
      canSave,
      canDelete,
      hasEnteredAnyInfo,
      hasSaved,
      hasDeleted,
      isAliasMirroringFirstName,
      const DeepCollectionEquality().hash(showingErrorFields));

  @override
  String toString() {
    return 'IdentityFormScreenState(identity: $identity, canSave: $canSave, canDelete: $canDelete, hasEnteredAnyInfo: $hasEnteredAnyInfo, hasSaved: $hasSaved, hasDeleted: $hasDeleted, isAliasMirroringFirstName: $isAliasMirroringFirstName, showingErrorFields: $showingErrorFields)';
  }
}

/// @nodoc
abstract mixin class $IdentityFormScreenStateCopyWith<$Res> {
  factory $IdentityFormScreenStateCopyWith(IdentityFormScreenState value,
          $Res Function(IdentityFormScreenState) _then) =
      _$IdentityFormScreenStateCopyWithImpl;
  @useResult
  $Res call(
      {Identity identity,
      bool canSave,
      bool canDelete,
      bool hasEnteredAnyInfo,
      bool hasSaved,
      bool hasDeleted,
      bool isAliasMirroringFirstName,
      Set<String> showingErrorFields});

  $IdentityCopyWith<$Res> get identity;
}

/// @nodoc
class _$IdentityFormScreenStateCopyWithImpl<$Res>
    implements $IdentityFormScreenStateCopyWith<$Res> {
  _$IdentityFormScreenStateCopyWithImpl(this._self, this._then);

  final IdentityFormScreenState _self;
  final $Res Function(IdentityFormScreenState) _then;

  /// Create a copy of IdentityFormScreenState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? identity = null,
    Object? canSave = null,
    Object? canDelete = null,
    Object? hasEnteredAnyInfo = null,
    Object? hasSaved = null,
    Object? hasDeleted = null,
    Object? isAliasMirroringFirstName = null,
    Object? showingErrorFields = null,
  }) {
    return _then(_self.copyWith(
      identity: null == identity
          ? _self.identity
          : identity // ignore: cast_nullable_to_non_nullable
              as Identity,
      canSave: null == canSave
          ? _self.canSave
          : canSave // ignore: cast_nullable_to_non_nullable
              as bool,
      canDelete: null == canDelete
          ? _self.canDelete
          : canDelete // ignore: cast_nullable_to_non_nullable
              as bool,
      hasEnteredAnyInfo: null == hasEnteredAnyInfo
          ? _self.hasEnteredAnyInfo
          : hasEnteredAnyInfo // ignore: cast_nullable_to_non_nullable
              as bool,
      hasSaved: null == hasSaved
          ? _self.hasSaved
          : hasSaved // ignore: cast_nullable_to_non_nullable
              as bool,
      hasDeleted: null == hasDeleted
          ? _self.hasDeleted
          : hasDeleted // ignore: cast_nullable_to_non_nullable
              as bool,
      isAliasMirroringFirstName: null == isAliasMirroringFirstName
          ? _self.isAliasMirroringFirstName
          : isAliasMirroringFirstName // ignore: cast_nullable_to_non_nullable
              as bool,
      showingErrorFields: null == showingErrorFields
          ? _self.showingErrorFields
          : showingErrorFields // ignore: cast_nullable_to_non_nullable
              as Set<String>,
    ));
  }

  /// Create a copy of IdentityFormScreenState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $IdentityCopyWith<$Res> get identity {
    return $IdentityCopyWith<$Res>(_self.identity, (value) {
      return _then(_self.copyWith(identity: value));
    });
  }
}

/// Adds pattern-matching-related methods to [IdentityFormScreenState].
extension IdentityFormScreenStatePatterns on IdentityFormScreenState {
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
    TResult Function(_IdentityFormScreenState value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _IdentityFormScreenState() when $default != null:
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
    TResult Function(_IdentityFormScreenState value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _IdentityFormScreenState():
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
    TResult? Function(_IdentityFormScreenState value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _IdentityFormScreenState() when $default != null:
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
            Identity identity,
            bool canSave,
            bool canDelete,
            bool hasEnteredAnyInfo,
            bool hasSaved,
            bool hasDeleted,
            bool isAliasMirroringFirstName,
            Set<String> showingErrorFields)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _IdentityFormScreenState() when $default != null:
        return $default(
            _that.identity,
            _that.canSave,
            _that.canDelete,
            _that.hasEnteredAnyInfo,
            _that.hasSaved,
            _that.hasDeleted,
            _that.isAliasMirroringFirstName,
            _that.showingErrorFields);
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
            Identity identity,
            bool canSave,
            bool canDelete,
            bool hasEnteredAnyInfo,
            bool hasSaved,
            bool hasDeleted,
            bool isAliasMirroringFirstName,
            Set<String> showingErrorFields)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _IdentityFormScreenState():
        return $default(
            _that.identity,
            _that.canSave,
            _that.canDelete,
            _that.hasEnteredAnyInfo,
            _that.hasSaved,
            _that.hasDeleted,
            _that.isAliasMirroringFirstName,
            _that.showingErrorFields);
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
            Identity identity,
            bool canSave,
            bool canDelete,
            bool hasEnteredAnyInfo,
            bool hasSaved,
            bool hasDeleted,
            bool isAliasMirroringFirstName,
            Set<String> showingErrorFields)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _IdentityFormScreenState() when $default != null:
        return $default(
            _that.identity,
            _that.canSave,
            _that.canDelete,
            _that.hasEnteredAnyInfo,
            _that.hasSaved,
            _that.hasDeleted,
            _that.isAliasMirroringFirstName,
            _that.showingErrorFields);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _IdentityFormScreenState implements IdentityFormScreenState {
  _IdentityFormScreenState(
      {required this.identity,
      this.canSave = true,
      this.canDelete = true,
      this.hasEnteredAnyInfo = false,
      this.hasSaved = false,
      this.hasDeleted = false,
      this.isAliasMirroringFirstName = true,
      final Set<String> showingErrorFields = const {}})
      : _showingErrorFields = showingErrorFields;

  @override
  final Identity identity;
  @override
  @JsonKey()
  final bool canSave;
  @override
  @JsonKey()
  final bool canDelete;
  @override
  @JsonKey()
  final bool hasEnteredAnyInfo;
  @override
  @JsonKey()
  final bool hasSaved;
  @override
  @JsonKey()
  final bool hasDeleted;
  @override
  @JsonKey()
  final bool isAliasMirroringFirstName;
  final Set<String> _showingErrorFields;
  @override
  @JsonKey()
  Set<String> get showingErrorFields {
    if (_showingErrorFields is EqualUnmodifiableSetView)
      return _showingErrorFields;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableSetView(_showingErrorFields);
  }

  /// Create a copy of IdentityFormScreenState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$IdentityFormScreenStateCopyWith<_IdentityFormScreenState> get copyWith =>
      __$IdentityFormScreenStateCopyWithImpl<_IdentityFormScreenState>(
          this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _IdentityFormScreenState &&
            (identical(other.identity, identity) ||
                other.identity == identity) &&
            (identical(other.canSave, canSave) || other.canSave == canSave) &&
            (identical(other.canDelete, canDelete) ||
                other.canDelete == canDelete) &&
            (identical(other.hasEnteredAnyInfo, hasEnteredAnyInfo) ||
                other.hasEnteredAnyInfo == hasEnteredAnyInfo) &&
            (identical(other.hasSaved, hasSaved) ||
                other.hasSaved == hasSaved) &&
            (identical(other.hasDeleted, hasDeleted) ||
                other.hasDeleted == hasDeleted) &&
            (identical(other.isAliasMirroringFirstName,
                    isAliasMirroringFirstName) ||
                other.isAliasMirroringFirstName == isAliasMirroringFirstName) &&
            const DeepCollectionEquality()
                .equals(other._showingErrorFields, _showingErrorFields));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      identity,
      canSave,
      canDelete,
      hasEnteredAnyInfo,
      hasSaved,
      hasDeleted,
      isAliasMirroringFirstName,
      const DeepCollectionEquality().hash(_showingErrorFields));

  @override
  String toString() {
    return 'IdentityFormScreenState(identity: $identity, canSave: $canSave, canDelete: $canDelete, hasEnteredAnyInfo: $hasEnteredAnyInfo, hasSaved: $hasSaved, hasDeleted: $hasDeleted, isAliasMirroringFirstName: $isAliasMirroringFirstName, showingErrorFields: $showingErrorFields)';
  }
}

/// @nodoc
abstract mixin class _$IdentityFormScreenStateCopyWith<$Res>
    implements $IdentityFormScreenStateCopyWith<$Res> {
  factory _$IdentityFormScreenStateCopyWith(_IdentityFormScreenState value,
          $Res Function(_IdentityFormScreenState) _then) =
      __$IdentityFormScreenStateCopyWithImpl;
  @override
  @useResult
  $Res call(
      {Identity identity,
      bool canSave,
      bool canDelete,
      bool hasEnteredAnyInfo,
      bool hasSaved,
      bool hasDeleted,
      bool isAliasMirroringFirstName,
      Set<String> showingErrorFields});

  @override
  $IdentityCopyWith<$Res> get identity;
}

/// @nodoc
class __$IdentityFormScreenStateCopyWithImpl<$Res>
    implements _$IdentityFormScreenStateCopyWith<$Res> {
  __$IdentityFormScreenStateCopyWithImpl(this._self, this._then);

  final _IdentityFormScreenState _self;
  final $Res Function(_IdentityFormScreenState) _then;

  /// Create a copy of IdentityFormScreenState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? identity = null,
    Object? canSave = null,
    Object? canDelete = null,
    Object? hasEnteredAnyInfo = null,
    Object? hasSaved = null,
    Object? hasDeleted = null,
    Object? isAliasMirroringFirstName = null,
    Object? showingErrorFields = null,
  }) {
    return _then(_IdentityFormScreenState(
      identity: null == identity
          ? _self.identity
          : identity // ignore: cast_nullable_to_non_nullable
              as Identity,
      canSave: null == canSave
          ? _self.canSave
          : canSave // ignore: cast_nullable_to_non_nullable
              as bool,
      canDelete: null == canDelete
          ? _self.canDelete
          : canDelete // ignore: cast_nullable_to_non_nullable
              as bool,
      hasEnteredAnyInfo: null == hasEnteredAnyInfo
          ? _self.hasEnteredAnyInfo
          : hasEnteredAnyInfo // ignore: cast_nullable_to_non_nullable
              as bool,
      hasSaved: null == hasSaved
          ? _self.hasSaved
          : hasSaved // ignore: cast_nullable_to_non_nullable
              as bool,
      hasDeleted: null == hasDeleted
          ? _self.hasDeleted
          : hasDeleted // ignore: cast_nullable_to_non_nullable
              as bool,
      isAliasMirroringFirstName: null == isAliasMirroringFirstName
          ? _self.isAliasMirroringFirstName
          : isAliasMirroringFirstName // ignore: cast_nullable_to_non_nullable
              as bool,
      showingErrorFields: null == showingErrorFields
          ? _self._showingErrorFields
          : showingErrorFields // ignore: cast_nullable_to_non_nullable
              as Set<String>,
    ));
  }

  /// Create a copy of IdentityFormScreenState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $IdentityCopyWith<$Res> get identity {
    return $IdentityCopyWith<$Res>(_self.identity, (value) {
      return _then(_self.copyWith(identity: value));
    });
  }
}

// dart format on
