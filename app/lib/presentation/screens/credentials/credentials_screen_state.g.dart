// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'credentials_screen_state.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$CredentialsScreenStateCWProxy {
  CredentialsScreenState hasCredentials(bool hasCredentials);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CredentialsScreenState(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CredentialsScreenState(...).copyWith(id: 12, name: "My name")
  /// ````
  CredentialsScreenState call({bool hasCredentials});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfCredentialsScreenState.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfCredentialsScreenState.copyWith.fieldName(...)`
class _$CredentialsScreenStateCWProxyImpl
    implements _$CredentialsScreenStateCWProxy {
  const _$CredentialsScreenStateCWProxyImpl(this._value);

  final CredentialsScreenState _value;

  @override
  CredentialsScreenState hasCredentials(bool hasCredentials) =>
      this(hasCredentials: hasCredentials);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CredentialsScreenState(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CredentialsScreenState(...).copyWith(id: 12, name: "My name")
  /// ````
  CredentialsScreenState call({
    Object? hasCredentials = const $CopyWithPlaceholder(),
  }) {
    return CredentialsScreenState(
      hasCredentials: hasCredentials == const $CopyWithPlaceholder()
          ? _value.hasCredentials
          // ignore: cast_nullable_to_non_nullable
          : hasCredentials as bool,
    );
  }
}

extension $CredentialsScreenStateCopyWith on CredentialsScreenState {
  /// Returns a callable class that can be used as follows: `instanceOfCredentialsScreenState.copyWith(...)` or like so:`instanceOfCredentialsScreenState.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$CredentialsScreenStateCWProxy get copyWith =>
      _$CredentialsScreenStateCWProxyImpl(this);
}
