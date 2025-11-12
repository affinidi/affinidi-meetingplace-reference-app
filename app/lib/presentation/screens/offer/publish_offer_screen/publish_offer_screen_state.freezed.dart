// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'publish_offer_screen_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PublishOfferScreenState {
  PublishOfferFormData get formData;
  Map<String, String> get availableMediators;
  List<Identity> get identities;
  Identity? get selectedIdentity;

  /// Create a copy of PublishOfferScreenState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $PublishOfferScreenStateCopyWith<PublishOfferScreenState> get copyWith =>
      _$PublishOfferScreenStateCopyWithImpl<PublishOfferScreenState>(
          this as PublishOfferScreenState, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is PublishOfferScreenState &&
            (identical(other.formData, formData) ||
                other.formData == formData) &&
            const DeepCollectionEquality()
                .equals(other.availableMediators, availableMediators) &&
            const DeepCollectionEquality()
                .equals(other.identities, identities) &&
            (identical(other.selectedIdentity, selectedIdentity) ||
                other.selectedIdentity == selectedIdentity));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      formData,
      const DeepCollectionEquality().hash(availableMediators),
      const DeepCollectionEquality().hash(identities),
      selectedIdentity);

  @override
  String toString() {
    return 'PublishOfferScreenState(formData: $formData, availableMediators: $availableMediators, identities: $identities, selectedIdentity: $selectedIdentity)';
  }
}

/// @nodoc
abstract mixin class $PublishOfferScreenStateCopyWith<$Res> {
  factory $PublishOfferScreenStateCopyWith(PublishOfferScreenState value,
          $Res Function(PublishOfferScreenState) _then) =
      _$PublishOfferScreenStateCopyWithImpl;
  @useResult
  $Res call(
      {PublishOfferFormData formData,
      Map<String, String> availableMediators,
      List<Identity> identities,
      Identity? selectedIdentity});

  $PublishOfferFormDataCopyWith<$Res> get formData;
  $IdentityCopyWith<$Res>? get selectedIdentity;
}

/// @nodoc
class _$PublishOfferScreenStateCopyWithImpl<$Res>
    implements $PublishOfferScreenStateCopyWith<$Res> {
  _$PublishOfferScreenStateCopyWithImpl(this._self, this._then);

  final PublishOfferScreenState _self;
  final $Res Function(PublishOfferScreenState) _then;

  /// Create a copy of PublishOfferScreenState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? formData = null,
    Object? availableMediators = null,
    Object? identities = null,
    Object? selectedIdentity = freezed,
  }) {
    return _then(_self.copyWith(
      formData: null == formData
          ? _self.formData
          : formData // ignore: cast_nullable_to_non_nullable
              as PublishOfferFormData,
      availableMediators: null == availableMediators
          ? _self.availableMediators
          : availableMediators // ignore: cast_nullable_to_non_nullable
              as Map<String, String>,
      identities: null == identities
          ? _self.identities
          : identities // ignore: cast_nullable_to_non_nullable
              as List<Identity>,
      selectedIdentity: freezed == selectedIdentity
          ? _self.selectedIdentity
          : selectedIdentity // ignore: cast_nullable_to_non_nullable
              as Identity?,
    ));
  }

  /// Create a copy of PublishOfferScreenState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $PublishOfferFormDataCopyWith<$Res> get formData {
    return $PublishOfferFormDataCopyWith<$Res>(_self.formData, (value) {
      return _then(_self.copyWith(formData: value));
    });
  }

  /// Create a copy of PublishOfferScreenState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $IdentityCopyWith<$Res>? get selectedIdentity {
    if (_self.selectedIdentity == null) {
      return null;
    }

    return $IdentityCopyWith<$Res>(_self.selectedIdentity!, (value) {
      return _then(_self.copyWith(selectedIdentity: value));
    });
  }
}

/// Adds pattern-matching-related methods to [PublishOfferScreenState].
extension PublishOfferScreenStatePatterns on PublishOfferScreenState {
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
    TResult Function(_PublishOfferScreenState value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _PublishOfferScreenState() when $default != null:
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
    TResult Function(_PublishOfferScreenState value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _PublishOfferScreenState():
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
    TResult? Function(_PublishOfferScreenState value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _PublishOfferScreenState() when $default != null:
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
            PublishOfferFormData formData,
            Map<String, String> availableMediators,
            List<Identity> identities,
            Identity? selectedIdentity)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _PublishOfferScreenState() when $default != null:
        return $default(_that.formData, _that.availableMediators,
            _that.identities, _that.selectedIdentity);
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
            PublishOfferFormData formData,
            Map<String, String> availableMediators,
            List<Identity> identities,
            Identity? selectedIdentity)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _PublishOfferScreenState():
        return $default(_that.formData, _that.availableMediators,
            _that.identities, _that.selectedIdentity);
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
            PublishOfferFormData formData,
            Map<String, String> availableMediators,
            List<Identity> identities,
            Identity? selectedIdentity)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _PublishOfferScreenState() when $default != null:
        return $default(_that.formData, _that.availableMediators,
            _that.identities, _that.selectedIdentity);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _PublishOfferScreenState extends PublishOfferScreenState {
  const _PublishOfferScreenState(
      {required this.formData,
      final Map<String, String> availableMediators = const {},
      final List<Identity> identities = const [],
      this.selectedIdentity})
      : _availableMediators = availableMediators,
        _identities = identities,
        super._();

  @override
  final PublishOfferFormData formData;
  final Map<String, String> _availableMediators;
  @override
  @JsonKey()
  Map<String, String> get availableMediators {
    if (_availableMediators is EqualUnmodifiableMapView)
      return _availableMediators;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_availableMediators);
  }

  final List<Identity> _identities;
  @override
  @JsonKey()
  List<Identity> get identities {
    if (_identities is EqualUnmodifiableListView) return _identities;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_identities);
  }

  @override
  final Identity? selectedIdentity;

  /// Create a copy of PublishOfferScreenState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$PublishOfferScreenStateCopyWith<_PublishOfferScreenState> get copyWith =>
      __$PublishOfferScreenStateCopyWithImpl<_PublishOfferScreenState>(
          this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _PublishOfferScreenState &&
            (identical(other.formData, formData) ||
                other.formData == formData) &&
            const DeepCollectionEquality()
                .equals(other._availableMediators, _availableMediators) &&
            const DeepCollectionEquality()
                .equals(other._identities, _identities) &&
            (identical(other.selectedIdentity, selectedIdentity) ||
                other.selectedIdentity == selectedIdentity));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      formData,
      const DeepCollectionEquality().hash(_availableMediators),
      const DeepCollectionEquality().hash(_identities),
      selectedIdentity);

  @override
  String toString() {
    return 'PublishOfferScreenState(formData: $formData, availableMediators: $availableMediators, identities: $identities, selectedIdentity: $selectedIdentity)';
  }
}

/// @nodoc
abstract mixin class _$PublishOfferScreenStateCopyWith<$Res>
    implements $PublishOfferScreenStateCopyWith<$Res> {
  factory _$PublishOfferScreenStateCopyWith(_PublishOfferScreenState value,
          $Res Function(_PublishOfferScreenState) _then) =
      __$PublishOfferScreenStateCopyWithImpl;
  @override
  @useResult
  $Res call(
      {PublishOfferFormData formData,
      Map<String, String> availableMediators,
      List<Identity> identities,
      Identity? selectedIdentity});

  @override
  $PublishOfferFormDataCopyWith<$Res> get formData;
  @override
  $IdentityCopyWith<$Res>? get selectedIdentity;
}

/// @nodoc
class __$PublishOfferScreenStateCopyWithImpl<$Res>
    implements _$PublishOfferScreenStateCopyWith<$Res> {
  __$PublishOfferScreenStateCopyWithImpl(this._self, this._then);

  final _PublishOfferScreenState _self;
  final $Res Function(_PublishOfferScreenState) _then;

  /// Create a copy of PublishOfferScreenState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? formData = null,
    Object? availableMediators = null,
    Object? identities = null,
    Object? selectedIdentity = freezed,
  }) {
    return _then(_PublishOfferScreenState(
      formData: null == formData
          ? _self.formData
          : formData // ignore: cast_nullable_to_non_nullable
              as PublishOfferFormData,
      availableMediators: null == availableMediators
          ? _self._availableMediators
          : availableMediators // ignore: cast_nullable_to_non_nullable
              as Map<String, String>,
      identities: null == identities
          ? _self._identities
          : identities // ignore: cast_nullable_to_non_nullable
              as List<Identity>,
      selectedIdentity: freezed == selectedIdentity
          ? _self.selectedIdentity
          : selectedIdentity // ignore: cast_nullable_to_non_nullable
              as Identity?,
    ));
  }

  /// Create a copy of PublishOfferScreenState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $PublishOfferFormDataCopyWith<$Res> get formData {
    return $PublishOfferFormDataCopyWith<$Res>(_self.formData, (value) {
      return _then(_self.copyWith(formData: value));
    });
  }

  /// Create a copy of PublishOfferScreenState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $IdentityCopyWith<$Res>? get selectedIdentity {
    if (_self.selectedIdentity == null) {
      return null;
    }

    return $IdentityCopyWith<$Res>(_self.selectedIdentity!, (value) {
      return _then(_self.copyWith(selectedIdentity: value));
    });
  }
}

// dart format on
