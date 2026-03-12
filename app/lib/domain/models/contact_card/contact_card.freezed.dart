// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'contact_card.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ContactCard {

 String get id; String get did; String get type; String get displayName; Map<String, String> get personaFields; String? get profilePic; String? get cardColor;
/// Create a copy of ContactCard
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ContactCardCopyWith<ContactCard> get copyWith => _$ContactCardCopyWithImpl<ContactCard>(this as ContactCard, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ContactCard&&(identical(other.id, id) || other.id == id)&&(identical(other.did, did) || other.did == did)&&(identical(other.type, type) || other.type == type)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&const DeepCollectionEquality().equals(other.personaFields, personaFields)&&(identical(other.profilePic, profilePic) || other.profilePic == profilePic)&&(identical(other.cardColor, cardColor) || other.cardColor == cardColor));
}


@override
int get hashCode => Object.hash(runtimeType,id,did,type,displayName,const DeepCollectionEquality().hash(personaFields),profilePic,cardColor);

@override
String toString() {
  return 'ContactCard(id: $id, did: $did, type: $type, displayName: $displayName, personaFields: $personaFields, profilePic: $profilePic, cardColor: $cardColor)';
}


}

/// @nodoc
abstract mixin class $ContactCardCopyWith<$Res>  {
  factory $ContactCardCopyWith(ContactCard value, $Res Function(ContactCard) _then) = _$ContactCardCopyWithImpl;
@useResult
$Res call({
 String id, String did, String type, String displayName, Map<String, String> personaFields, String? profilePic, String? cardColor
});




}
/// @nodoc
class _$ContactCardCopyWithImpl<$Res>
    implements $ContactCardCopyWith<$Res> {
  _$ContactCardCopyWithImpl(this._self, this._then);

  final ContactCard _self;
  final $Res Function(ContactCard) _then;

/// Create a copy of ContactCard
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? did = null,Object? type = null,Object? displayName = null,Object? personaFields = null,Object? profilePic = freezed,Object? cardColor = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,did: null == did ? _self.did : did // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,personaFields: null == personaFields ? _self.personaFields : personaFields // ignore: cast_nullable_to_non_nullable
as Map<String, String>,profilePic: freezed == profilePic ? _self.profilePic : profilePic // ignore: cast_nullable_to_non_nullable
as String?,cardColor: freezed == cardColor ? _self.cardColor : cardColor // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ContactCard].
extension ContactCardPatterns on ContactCard {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ContactCard value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ContactCard() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ContactCard value)  $default,){
final _that = this;
switch (_that) {
case _ContactCard():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ContactCard value)?  $default,){
final _that = this;
switch (_that) {
case _ContactCard() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String did,  String type,  String displayName,  Map<String, String> personaFields,  String? profilePic,  String? cardColor)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ContactCard() when $default != null:
return $default(_that.id,_that.did,_that.type,_that.displayName,_that.personaFields,_that.profilePic,_that.cardColor);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String did,  String type,  String displayName,  Map<String, String> personaFields,  String? profilePic,  String? cardColor)  $default,) {final _that = this;
switch (_that) {
case _ContactCard():
return $default(_that.id,_that.did,_that.type,_that.displayName,_that.personaFields,_that.profilePic,_that.cardColor);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String did,  String type,  String displayName,  Map<String, String> personaFields,  String? profilePic,  String? cardColor)?  $default,) {final _that = this;
switch (_that) {
case _ContactCard() when $default != null:
return $default(_that.id,_that.did,_that.type,_that.displayName,_that.personaFields,_that.profilePic,_that.cardColor);case _:
  return null;

}
}

}

/// @nodoc


class _ContactCard implements ContactCard {
  const _ContactCard({required this.id, required this.did, required this.type, required this.displayName, final  Map<String, String> personaFields = const <String, String>{}, this.profilePic, this.cardColor}): _personaFields = personaFields;
  

@override final  String id;
@override final  String did;
@override final  String type;
@override final  String displayName;
 final  Map<String, String> _personaFields;
@override@JsonKey() Map<String, String> get personaFields {
  if (_personaFields is EqualUnmodifiableMapView) return _personaFields;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_personaFields);
}

@override final  String? profilePic;
@override final  String? cardColor;

/// Create a copy of ContactCard
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ContactCardCopyWith<_ContactCard> get copyWith => __$ContactCardCopyWithImpl<_ContactCard>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ContactCard&&(identical(other.id, id) || other.id == id)&&(identical(other.did, did) || other.did == did)&&(identical(other.type, type) || other.type == type)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&const DeepCollectionEquality().equals(other._personaFields, _personaFields)&&(identical(other.profilePic, profilePic) || other.profilePic == profilePic)&&(identical(other.cardColor, cardColor) || other.cardColor == cardColor));
}


@override
int get hashCode => Object.hash(runtimeType,id,did,type,displayName,const DeepCollectionEquality().hash(_personaFields),profilePic,cardColor);

@override
String toString() {
  return 'ContactCard(id: $id, did: $did, type: $type, displayName: $displayName, personaFields: $personaFields, profilePic: $profilePic, cardColor: $cardColor)';
}


}

/// @nodoc
abstract mixin class _$ContactCardCopyWith<$Res> implements $ContactCardCopyWith<$Res> {
  factory _$ContactCardCopyWith(_ContactCard value, $Res Function(_ContactCard) _then) = __$ContactCardCopyWithImpl;
@override @useResult
$Res call({
 String id, String did, String type, String displayName, Map<String, String> personaFields, String? profilePic, String? cardColor
});




}
/// @nodoc
class __$ContactCardCopyWithImpl<$Res>
    implements _$ContactCardCopyWith<$Res> {
  __$ContactCardCopyWithImpl(this._self, this._then);

  final _ContactCard _self;
  final $Res Function(_ContactCard) _then;

/// Create a copy of ContactCard
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? did = null,Object? type = null,Object? displayName = null,Object? personaFields = null,Object? profilePic = freezed,Object? cardColor = freezed,}) {
  return _then(_ContactCard(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,did: null == did ? _self.did : did // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,personaFields: null == personaFields ? _self._personaFields : personaFields // ignore: cast_nullable_to_non_nullable
as Map<String, String>,profilePic: freezed == profilePic ? _self.profilePic : profilePic // ignore: cast_nullable_to_non_nullable
as String?,cardColor: freezed == cardColor ? _self.cardColor : cardColor // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
