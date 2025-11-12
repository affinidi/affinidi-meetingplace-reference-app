// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'contacts_service_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ContactsServiceState {
  List<Contact> get contacts;
  String? get errorMessage;

  /// Create a copy of ContactsServiceState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ContactsServiceStateCopyWith<ContactsServiceState> get copyWith =>
      _$ContactsServiceStateCopyWithImpl<ContactsServiceState>(
          this as ContactsServiceState, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is ContactsServiceState &&
            const DeepCollectionEquality().equals(other.contacts, contacts) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, const DeepCollectionEquality().hash(contacts), errorMessage);

  @override
  String toString() {
    return 'ContactsServiceState(contacts: $contacts, errorMessage: $errorMessage)';
  }
}

/// @nodoc
abstract mixin class $ContactsServiceStateCopyWith<$Res> {
  factory $ContactsServiceStateCopyWith(ContactsServiceState value,
          $Res Function(ContactsServiceState) _then) =
      _$ContactsServiceStateCopyWithImpl;
  @useResult
  $Res call({List<Contact> contacts, String? errorMessage});
}

/// @nodoc
class _$ContactsServiceStateCopyWithImpl<$Res>
    implements $ContactsServiceStateCopyWith<$Res> {
  _$ContactsServiceStateCopyWithImpl(this._self, this._then);

  final ContactsServiceState _self;
  final $Res Function(ContactsServiceState) _then;

  /// Create a copy of ContactsServiceState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? contacts = null,
    Object? errorMessage = freezed,
  }) {
    return _then(_self.copyWith(
      contacts: null == contacts
          ? _self.contacts
          : contacts // ignore: cast_nullable_to_non_nullable
              as List<Contact>,
      errorMessage: freezed == errorMessage
          ? _self.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// Adds pattern-matching-related methods to [ContactsServiceState].
extension ContactsServiceStatePatterns on ContactsServiceState {
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
    TResult Function(_ContactsServiceState value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _ContactsServiceState() when $default != null:
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
    TResult Function(_ContactsServiceState value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ContactsServiceState():
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
    TResult? Function(_ContactsServiceState value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ContactsServiceState() when $default != null:
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
    TResult Function(List<Contact> contacts, String? errorMessage)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _ContactsServiceState() when $default != null:
        return $default(_that.contacts, _that.errorMessage);
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
    TResult Function(List<Contact> contacts, String? errorMessage) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ContactsServiceState():
        return $default(_that.contacts, _that.errorMessage);
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
    TResult? Function(List<Contact> contacts, String? errorMessage)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ContactsServiceState() when $default != null:
        return $default(_that.contacts, _that.errorMessage);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _ContactsServiceState extends ContactsServiceState {
  _ContactsServiceState(
      {final List<Contact> contacts = const [], this.errorMessage})
      : _contacts = contacts,
        super._();

  final List<Contact> _contacts;
  @override
  @JsonKey()
  List<Contact> get contacts {
    if (_contacts is EqualUnmodifiableListView) return _contacts;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_contacts);
  }

  @override
  final String? errorMessage;

  /// Create a copy of ContactsServiceState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$ContactsServiceStateCopyWith<_ContactsServiceState> get copyWith =>
      __$ContactsServiceStateCopyWithImpl<_ContactsServiceState>(
          this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _ContactsServiceState &&
            const DeepCollectionEquality().equals(other._contacts, _contacts) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage));
  }

  @override
  int get hashCode => Object.hash(runtimeType,
      const DeepCollectionEquality().hash(_contacts), errorMessage);

  @override
  String toString() {
    return 'ContactsServiceState(contacts: $contacts, errorMessage: $errorMessage)';
  }
}

/// @nodoc
abstract mixin class _$ContactsServiceStateCopyWith<$Res>
    implements $ContactsServiceStateCopyWith<$Res> {
  factory _$ContactsServiceStateCopyWith(_ContactsServiceState value,
          $Res Function(_ContactsServiceState) _then) =
      __$ContactsServiceStateCopyWithImpl;
  @override
  @useResult
  $Res call({List<Contact> contacts, String? errorMessage});
}

/// @nodoc
class __$ContactsServiceStateCopyWithImpl<$Res>
    implements _$ContactsServiceStateCopyWith<$Res> {
  __$ContactsServiceStateCopyWithImpl(this._self, this._then);

  final _ContactsServiceState _self;
  final $Res Function(_ContactsServiceState) _then;

  /// Create a copy of ContactsServiceState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? contacts = null,
    Object? errorMessage = freezed,
  }) {
    return _then(_ContactsServiceState(
      contacts: null == contacts
          ? _self._contacts
          : contacts // ignore: cast_nullable_to_non_nullable
              as List<Contact>,
      errorMessage: freezed == errorMessage
          ? _self.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

// dart format on
