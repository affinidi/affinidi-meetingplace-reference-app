// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'contacts_screen_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ContactsScreenState {

 bool get isEditMode; bool get shouldShowGrid; bool get shouldShowFilter; List<Contact> get contacts; List<Contact> get selectedContacts; Map<String, Mediator> get contactMediators; ContactsScreenFilter get filter; Identity? get identity;
/// Create a copy of ContactsScreenState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ContactsScreenStateCopyWith<ContactsScreenState> get copyWith => _$ContactsScreenStateCopyWithImpl<ContactsScreenState>(this as ContactsScreenState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ContactsScreenState&&(identical(other.isEditMode, isEditMode) || other.isEditMode == isEditMode)&&(identical(other.shouldShowGrid, shouldShowGrid) || other.shouldShowGrid == shouldShowGrid)&&(identical(other.shouldShowFilter, shouldShowFilter) || other.shouldShowFilter == shouldShowFilter)&&const DeepCollectionEquality().equals(other.contacts, contacts)&&const DeepCollectionEquality().equals(other.selectedContacts, selectedContacts)&&const DeepCollectionEquality().equals(other.contactMediators, contactMediators)&&(identical(other.filter, filter) || other.filter == filter)&&(identical(other.identity, identity) || other.identity == identity));
}


@override
int get hashCode => Object.hash(runtimeType,isEditMode,shouldShowGrid,shouldShowFilter,const DeepCollectionEquality().hash(contacts),const DeepCollectionEquality().hash(selectedContacts),const DeepCollectionEquality().hash(contactMediators),filter,identity);

@override
String toString() {
  return 'ContactsScreenState(isEditMode: $isEditMode, shouldShowGrid: $shouldShowGrid, shouldShowFilter: $shouldShowFilter, contacts: $contacts, selectedContacts: $selectedContacts, contactMediators: $contactMediators, filter: $filter, identity: $identity)';
}


}

/// @nodoc
abstract mixin class $ContactsScreenStateCopyWith<$Res>  {
  factory $ContactsScreenStateCopyWith(ContactsScreenState value, $Res Function(ContactsScreenState) _then) = _$ContactsScreenStateCopyWithImpl;
@useResult
$Res call({
 bool isEditMode, bool shouldShowGrid, bool shouldShowFilter, List<Contact> contacts, List<Contact> selectedContacts, Map<String, Mediator> contactMediators, ContactsScreenFilter filter, Identity? identity
});


$IdentityCopyWith<$Res>? get identity;

}
/// @nodoc
class _$ContactsScreenStateCopyWithImpl<$Res>
    implements $ContactsScreenStateCopyWith<$Res> {
  _$ContactsScreenStateCopyWithImpl(this._self, this._then);

  final ContactsScreenState _self;
  final $Res Function(ContactsScreenState) _then;

/// Create a copy of ContactsScreenState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? isEditMode = null,Object? shouldShowGrid = null,Object? shouldShowFilter = null,Object? contacts = null,Object? selectedContacts = null,Object? contactMediators = null,Object? filter = null,Object? identity = freezed,}) {
  return _then(_self.copyWith(
isEditMode: null == isEditMode ? _self.isEditMode : isEditMode // ignore: cast_nullable_to_non_nullable
as bool,shouldShowGrid: null == shouldShowGrid ? _self.shouldShowGrid : shouldShowGrid // ignore: cast_nullable_to_non_nullable
as bool,shouldShowFilter: null == shouldShowFilter ? _self.shouldShowFilter : shouldShowFilter // ignore: cast_nullable_to_non_nullable
as bool,contacts: null == contacts ? _self.contacts : contacts // ignore: cast_nullable_to_non_nullable
as List<Contact>,selectedContacts: null == selectedContacts ? _self.selectedContacts : selectedContacts // ignore: cast_nullable_to_non_nullable
as List<Contact>,contactMediators: null == contactMediators ? _self.contactMediators : contactMediators // ignore: cast_nullable_to_non_nullable
as Map<String, Mediator>,filter: null == filter ? _self.filter : filter // ignore: cast_nullable_to_non_nullable
as ContactsScreenFilter,identity: freezed == identity ? _self.identity : identity // ignore: cast_nullable_to_non_nullable
as Identity?,
  ));
}
/// Create a copy of ContactsScreenState
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


/// Adds pattern-matching-related methods to [ContactsScreenState].
extension ContactsScreenStatePatterns on ContactsScreenState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ContactsScreenState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ContactsScreenState() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ContactsScreenState value)  $default,){
final _that = this;
switch (_that) {
case _ContactsScreenState():
return $default(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ContactsScreenState value)?  $default,){
final _that = this;
switch (_that) {
case _ContactsScreenState() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool isEditMode,  bool shouldShowGrid,  bool shouldShowFilter,  List<Contact> contacts,  List<Contact> selectedContacts,  Map<String, Mediator> contactMediators,  ContactsScreenFilter filter,  Identity? identity)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ContactsScreenState() when $default != null:
return $default(_that.isEditMode,_that.shouldShowGrid,_that.shouldShowFilter,_that.contacts,_that.selectedContacts,_that.contactMediators,_that.filter,_that.identity);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool isEditMode,  bool shouldShowGrid,  bool shouldShowFilter,  List<Contact> contacts,  List<Contact> selectedContacts,  Map<String, Mediator> contactMediators,  ContactsScreenFilter filter,  Identity? identity)  $default,) {final _that = this;
switch (_that) {
case _ContactsScreenState():
return $default(_that.isEditMode,_that.shouldShowGrid,_that.shouldShowFilter,_that.contacts,_that.selectedContacts,_that.contactMediators,_that.filter,_that.identity);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool isEditMode,  bool shouldShowGrid,  bool shouldShowFilter,  List<Contact> contacts,  List<Contact> selectedContacts,  Map<String, Mediator> contactMediators,  ContactsScreenFilter filter,  Identity? identity)?  $default,) {final _that = this;
switch (_that) {
case _ContactsScreenState() when $default != null:
return $default(_that.isEditMode,_that.shouldShowGrid,_that.shouldShowFilter,_that.contacts,_that.selectedContacts,_that.contactMediators,_that.filter,_that.identity);case _:
  return null;

}
}

}

/// @nodoc


class _ContactsScreenState extends ContactsScreenState {
   _ContactsScreenState({this.isEditMode = false, this.shouldShowGrid = true, this.shouldShowFilter = false, final  List<Contact> contacts = const [], final  List<Contact> selectedContacts = const [], final  Map<String, Mediator> contactMediators = const {}, this.filter = ContactsScreenFilter.any, this.identity}): _contacts = contacts,_selectedContacts = selectedContacts,_contactMediators = contactMediators,super._();
  

@override@JsonKey() final  bool isEditMode;
@override@JsonKey() final  bool shouldShowGrid;
@override@JsonKey() final  bool shouldShowFilter;
 final  List<Contact> _contacts;
@override@JsonKey() List<Contact> get contacts {
  if (_contacts is EqualUnmodifiableListView) return _contacts;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_contacts);
}

 final  List<Contact> _selectedContacts;
@override@JsonKey() List<Contact> get selectedContacts {
  if (_selectedContacts is EqualUnmodifiableListView) return _selectedContacts;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_selectedContacts);
}

 final  Map<String, Mediator> _contactMediators;
@override@JsonKey() Map<String, Mediator> get contactMediators {
  if (_contactMediators is EqualUnmodifiableMapView) return _contactMediators;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_contactMediators);
}

@override@JsonKey() final  ContactsScreenFilter filter;
@override final  Identity? identity;

/// Create a copy of ContactsScreenState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ContactsScreenStateCopyWith<_ContactsScreenState> get copyWith => __$ContactsScreenStateCopyWithImpl<_ContactsScreenState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ContactsScreenState&&(identical(other.isEditMode, isEditMode) || other.isEditMode == isEditMode)&&(identical(other.shouldShowGrid, shouldShowGrid) || other.shouldShowGrid == shouldShowGrid)&&(identical(other.shouldShowFilter, shouldShowFilter) || other.shouldShowFilter == shouldShowFilter)&&const DeepCollectionEquality().equals(other._contacts, _contacts)&&const DeepCollectionEquality().equals(other._selectedContacts, _selectedContacts)&&const DeepCollectionEquality().equals(other._contactMediators, _contactMediators)&&(identical(other.filter, filter) || other.filter == filter)&&(identical(other.identity, identity) || other.identity == identity));
}


@override
int get hashCode => Object.hash(runtimeType,isEditMode,shouldShowGrid,shouldShowFilter,const DeepCollectionEquality().hash(_contacts),const DeepCollectionEquality().hash(_selectedContacts),const DeepCollectionEquality().hash(_contactMediators),filter,identity);

@override
String toString() {
  return 'ContactsScreenState(isEditMode: $isEditMode, shouldShowGrid: $shouldShowGrid, shouldShowFilter: $shouldShowFilter, contacts: $contacts, selectedContacts: $selectedContacts, contactMediators: $contactMediators, filter: $filter, identity: $identity)';
}


}

/// @nodoc
abstract mixin class _$ContactsScreenStateCopyWith<$Res> implements $ContactsScreenStateCopyWith<$Res> {
  factory _$ContactsScreenStateCopyWith(_ContactsScreenState value, $Res Function(_ContactsScreenState) _then) = __$ContactsScreenStateCopyWithImpl;
@override @useResult
$Res call({
 bool isEditMode, bool shouldShowGrid, bool shouldShowFilter, List<Contact> contacts, List<Contact> selectedContacts, Map<String, Mediator> contactMediators, ContactsScreenFilter filter, Identity? identity
});


@override $IdentityCopyWith<$Res>? get identity;

}
/// @nodoc
class __$ContactsScreenStateCopyWithImpl<$Res>
    implements _$ContactsScreenStateCopyWith<$Res> {
  __$ContactsScreenStateCopyWithImpl(this._self, this._then);

  final _ContactsScreenState _self;
  final $Res Function(_ContactsScreenState) _then;

/// Create a copy of ContactsScreenState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? isEditMode = null,Object? shouldShowGrid = null,Object? shouldShowFilter = null,Object? contacts = null,Object? selectedContacts = null,Object? contactMediators = null,Object? filter = null,Object? identity = freezed,}) {
  return _then(_ContactsScreenState(
isEditMode: null == isEditMode ? _self.isEditMode : isEditMode // ignore: cast_nullable_to_non_nullable
as bool,shouldShowGrid: null == shouldShowGrid ? _self.shouldShowGrid : shouldShowGrid // ignore: cast_nullable_to_non_nullable
as bool,shouldShowFilter: null == shouldShowFilter ? _self.shouldShowFilter : shouldShowFilter // ignore: cast_nullable_to_non_nullable
as bool,contacts: null == contacts ? _self._contacts : contacts // ignore: cast_nullable_to_non_nullable
as List<Contact>,selectedContacts: null == selectedContacts ? _self._selectedContacts : selectedContacts // ignore: cast_nullable_to_non_nullable
as List<Contact>,contactMediators: null == contactMediators ? _self._contactMediators : contactMediators // ignore: cast_nullable_to_non_nullable
as Map<String, Mediator>,filter: null == filter ? _self.filter : filter // ignore: cast_nullable_to_non_nullable
as ContactsScreenFilter,identity: freezed == identity ? _self.identity : identity // ignore: cast_nullable_to_non_nullable
as Identity?,
  ));
}

/// Create a copy of ContactsScreenState
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
