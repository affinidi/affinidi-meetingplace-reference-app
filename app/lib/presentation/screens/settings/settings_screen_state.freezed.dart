// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'settings_screen_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SettingsScreenState {
  AppInfo? get appInfo;
  int get numberOfTapsToUnlockDebug;
  List<Mediator> get mediators;
  String get selectedMediatorDid;
  bool get isDebugMode;
  bool get shouldShowMeetingPlaceQR;

  /// Create a copy of SettingsScreenState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $SettingsScreenStateCopyWith<SettingsScreenState> get copyWith =>
      _$SettingsScreenStateCopyWithImpl<SettingsScreenState>(
          this as SettingsScreenState, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is SettingsScreenState &&
            (identical(other.appInfo, appInfo) || other.appInfo == appInfo) &&
            (identical(other.numberOfTapsToUnlockDebug,
                    numberOfTapsToUnlockDebug) ||
                other.numberOfTapsToUnlockDebug == numberOfTapsToUnlockDebug) &&
            const DeepCollectionEquality().equals(other.mediators, mediators) &&
            (identical(other.selectedMediatorDid, selectedMediatorDid) ||
                other.selectedMediatorDid == selectedMediatorDid) &&
            (identical(other.isDebugMode, isDebugMode) ||
                other.isDebugMode == isDebugMode) &&
            (identical(
                    other.shouldShowMeetingPlaceQR, shouldShowMeetingPlaceQR) ||
                other.shouldShowMeetingPlaceQR == shouldShowMeetingPlaceQR));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      appInfo,
      numberOfTapsToUnlockDebug,
      const DeepCollectionEquality().hash(mediators),
      selectedMediatorDid,
      isDebugMode,
      shouldShowMeetingPlaceQR);

  @override
  String toString() {
    return 'SettingsScreenState(appInfo: $appInfo, numberOfTapsToUnlockDebug: $numberOfTapsToUnlockDebug, mediators: $mediators, selectedMediatorDid: $selectedMediatorDid, isDebugMode: $isDebugMode, shouldShowMeetingPlaceQR: $shouldShowMeetingPlaceQR)';
  }
}

/// @nodoc
abstract mixin class $SettingsScreenStateCopyWith<$Res> {
  factory $SettingsScreenStateCopyWith(
          SettingsScreenState value, $Res Function(SettingsScreenState) _then) =
      _$SettingsScreenStateCopyWithImpl;
  @useResult
  $Res call(
      {AppInfo? appInfo,
      int numberOfTapsToUnlockDebug,
      List<Mediator> mediators,
      String selectedMediatorDid,
      bool isDebugMode,
      bool shouldShowMeetingPlaceQR});
}

/// @nodoc
class _$SettingsScreenStateCopyWithImpl<$Res>
    implements $SettingsScreenStateCopyWith<$Res> {
  _$SettingsScreenStateCopyWithImpl(this._self, this._then);

  final SettingsScreenState _self;
  final $Res Function(SettingsScreenState) _then;

  /// Create a copy of SettingsScreenState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? appInfo = freezed,
    Object? numberOfTapsToUnlockDebug = null,
    Object? mediators = null,
    Object? selectedMediatorDid = null,
    Object? isDebugMode = null,
    Object? shouldShowMeetingPlaceQR = null,
  }) {
    return _then(_self.copyWith(
      appInfo: freezed == appInfo
          ? _self.appInfo
          : appInfo // ignore: cast_nullable_to_non_nullable
              as AppInfo?,
      numberOfTapsToUnlockDebug: null == numberOfTapsToUnlockDebug
          ? _self.numberOfTapsToUnlockDebug
          : numberOfTapsToUnlockDebug // ignore: cast_nullable_to_non_nullable
              as int,
      mediators: null == mediators
          ? _self.mediators
          : mediators // ignore: cast_nullable_to_non_nullable
              as List<Mediator>,
      selectedMediatorDid: null == selectedMediatorDid
          ? _self.selectedMediatorDid
          : selectedMediatorDid // ignore: cast_nullable_to_non_nullable
              as String,
      isDebugMode: null == isDebugMode
          ? _self.isDebugMode
          : isDebugMode // ignore: cast_nullable_to_non_nullable
              as bool,
      shouldShowMeetingPlaceQR: null == shouldShowMeetingPlaceQR
          ? _self.shouldShowMeetingPlaceQR
          : shouldShowMeetingPlaceQR // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// Adds pattern-matching-related methods to [SettingsScreenState].
extension SettingsScreenStatePatterns on SettingsScreenState {
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
    TResult Function(_SettingsScreenState value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _SettingsScreenState() when $default != null:
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
    TResult Function(_SettingsScreenState value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _SettingsScreenState():
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
    TResult? Function(_SettingsScreenState value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _SettingsScreenState() when $default != null:
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
            AppInfo? appInfo,
            int numberOfTapsToUnlockDebug,
            List<Mediator> mediators,
            String selectedMediatorDid,
            bool isDebugMode,
            bool shouldShowMeetingPlaceQR)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _SettingsScreenState() when $default != null:
        return $default(
            _that.appInfo,
            _that.numberOfTapsToUnlockDebug,
            _that.mediators,
            _that.selectedMediatorDid,
            _that.isDebugMode,
            _that.shouldShowMeetingPlaceQR);
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
            AppInfo? appInfo,
            int numberOfTapsToUnlockDebug,
            List<Mediator> mediators,
            String selectedMediatorDid,
            bool isDebugMode,
            bool shouldShowMeetingPlaceQR)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _SettingsScreenState():
        return $default(
            _that.appInfo,
            _that.numberOfTapsToUnlockDebug,
            _that.mediators,
            _that.selectedMediatorDid,
            _that.isDebugMode,
            _that.shouldShowMeetingPlaceQR);
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
            AppInfo? appInfo,
            int numberOfTapsToUnlockDebug,
            List<Mediator> mediators,
            String selectedMediatorDid,
            bool isDebugMode,
            bool shouldShowMeetingPlaceQR)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _SettingsScreenState() when $default != null:
        return $default(
            _that.appInfo,
            _that.numberOfTapsToUnlockDebug,
            _that.mediators,
            _that.selectedMediatorDid,
            _that.isDebugMode,
            _that.shouldShowMeetingPlaceQR);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _SettingsScreenState implements SettingsScreenState {
  _SettingsScreenState(
      {this.appInfo,
      required this.numberOfTapsToUnlockDebug,
      final List<Mediator> mediators = const [],
      this.selectedMediatorDid = '',
      this.isDebugMode = false,
      this.shouldShowMeetingPlaceQR = false})
      : _mediators = mediators;

  @override
  final AppInfo? appInfo;
  @override
  final int numberOfTapsToUnlockDebug;
  final List<Mediator> _mediators;
  @override
  @JsonKey()
  List<Mediator> get mediators {
    if (_mediators is EqualUnmodifiableListView) return _mediators;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_mediators);
  }

  @override
  @JsonKey()
  final String selectedMediatorDid;
  @override
  @JsonKey()
  final bool isDebugMode;
  @override
  @JsonKey()
  final bool shouldShowMeetingPlaceQR;

  /// Create a copy of SettingsScreenState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$SettingsScreenStateCopyWith<_SettingsScreenState> get copyWith =>
      __$SettingsScreenStateCopyWithImpl<_SettingsScreenState>(
          this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _SettingsScreenState &&
            (identical(other.appInfo, appInfo) || other.appInfo == appInfo) &&
            (identical(other.numberOfTapsToUnlockDebug,
                    numberOfTapsToUnlockDebug) ||
                other.numberOfTapsToUnlockDebug == numberOfTapsToUnlockDebug) &&
            const DeepCollectionEquality()
                .equals(other._mediators, _mediators) &&
            (identical(other.selectedMediatorDid, selectedMediatorDid) ||
                other.selectedMediatorDid == selectedMediatorDid) &&
            (identical(other.isDebugMode, isDebugMode) ||
                other.isDebugMode == isDebugMode) &&
            (identical(
                    other.shouldShowMeetingPlaceQR, shouldShowMeetingPlaceQR) ||
                other.shouldShowMeetingPlaceQR == shouldShowMeetingPlaceQR));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      appInfo,
      numberOfTapsToUnlockDebug,
      const DeepCollectionEquality().hash(_mediators),
      selectedMediatorDid,
      isDebugMode,
      shouldShowMeetingPlaceQR);

  @override
  String toString() {
    return 'SettingsScreenState(appInfo: $appInfo, numberOfTapsToUnlockDebug: $numberOfTapsToUnlockDebug, mediators: $mediators, selectedMediatorDid: $selectedMediatorDid, isDebugMode: $isDebugMode, shouldShowMeetingPlaceQR: $shouldShowMeetingPlaceQR)';
  }
}

/// @nodoc
abstract mixin class _$SettingsScreenStateCopyWith<$Res>
    implements $SettingsScreenStateCopyWith<$Res> {
  factory _$SettingsScreenStateCopyWith(_SettingsScreenState value,
          $Res Function(_SettingsScreenState) _then) =
      __$SettingsScreenStateCopyWithImpl;
  @override
  @useResult
  $Res call(
      {AppInfo? appInfo,
      int numberOfTapsToUnlockDebug,
      List<Mediator> mediators,
      String selectedMediatorDid,
      bool isDebugMode,
      bool shouldShowMeetingPlaceQR});
}

/// @nodoc
class __$SettingsScreenStateCopyWithImpl<$Res>
    implements _$SettingsScreenStateCopyWith<$Res> {
  __$SettingsScreenStateCopyWithImpl(this._self, this._then);

  final _SettingsScreenState _self;
  final $Res Function(_SettingsScreenState) _then;

  /// Create a copy of SettingsScreenState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? appInfo = freezed,
    Object? numberOfTapsToUnlockDebug = null,
    Object? mediators = null,
    Object? selectedMediatorDid = null,
    Object? isDebugMode = null,
    Object? shouldShowMeetingPlaceQR = null,
  }) {
    return _then(_SettingsScreenState(
      appInfo: freezed == appInfo
          ? _self.appInfo
          : appInfo // ignore: cast_nullable_to_non_nullable
              as AppInfo?,
      numberOfTapsToUnlockDebug: null == numberOfTapsToUnlockDebug
          ? _self.numberOfTapsToUnlockDebug
          : numberOfTapsToUnlockDebug // ignore: cast_nullable_to_non_nullable
              as int,
      mediators: null == mediators
          ? _self._mediators
          : mediators // ignore: cast_nullable_to_non_nullable
              as List<Mediator>,
      selectedMediatorDid: null == selectedMediatorDid
          ? _self.selectedMediatorDid
          : selectedMediatorDid // ignore: cast_nullable_to_non_nullable
              as String,
      isDebugMode: null == isDebugMode
          ? _self.isDebugMode
          : isDebugMode // ignore: cast_nullable_to_non_nullable
              as bool,
      shouldShowMeetingPlaceQR: null == shouldShowMeetingPlaceQR
          ? _self.shouldShowMeetingPlaceQR
          : shouldShowMeetingPlaceQR // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

// dart format on
