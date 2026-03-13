// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'chat_service_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ChatServiceState {

 Contact? get contact; Group? get group; ContactCard? get otherPartyCard; List<chat.ChatItem> get messages; List<String> get membersTyping; bool get isActive; bool get isInitialized; ContactPresenceStatus get contactPresenceStatus; chat.Effect? get effect;
/// Create a copy of ChatServiceState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChatServiceStateCopyWith<ChatServiceState> get copyWith => _$ChatServiceStateCopyWithImpl<ChatServiceState>(this as ChatServiceState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChatServiceState&&(identical(other.contact, contact) || other.contact == contact)&&(identical(other.group, group) || other.group == group)&&(identical(other.otherPartyCard, otherPartyCard) || other.otherPartyCard == otherPartyCard)&&const DeepCollectionEquality().equals(other.messages, messages)&&const DeepCollectionEquality().equals(other.membersTyping, membersTyping)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.isInitialized, isInitialized) || other.isInitialized == isInitialized)&&(identical(other.contactPresenceStatus, contactPresenceStatus) || other.contactPresenceStatus == contactPresenceStatus)&&(identical(other.effect, effect) || other.effect == effect));
}


@override
int get hashCode => Object.hash(runtimeType,contact,group,otherPartyCard,const DeepCollectionEquality().hash(messages),const DeepCollectionEquality().hash(membersTyping),isActive,isInitialized,contactPresenceStatus,effect);

@override
String toString() {
  return 'ChatServiceState(contact: $contact, group: $group, otherPartyCard: $otherPartyCard, messages: $messages, membersTyping: $membersTyping, isActive: $isActive, isInitialized: $isInitialized, contactPresenceStatus: $contactPresenceStatus, effect: $effect)';
}


}

/// @nodoc
abstract mixin class $ChatServiceStateCopyWith<$Res>  {
  factory $ChatServiceStateCopyWith(ChatServiceState value, $Res Function(ChatServiceState) _then) = _$ChatServiceStateCopyWithImpl;
@useResult
$Res call({
 Contact? contact, Group? group, ContactCard? otherPartyCard, List<chat.ChatItem> messages, List<String> membersTyping, bool isActive, bool isInitialized, ContactPresenceStatus contactPresenceStatus, chat.Effect? effect
});


$ContactCardCopyWith<$Res>? get otherPartyCard;

}
/// @nodoc
class _$ChatServiceStateCopyWithImpl<$Res>
    implements $ChatServiceStateCopyWith<$Res> {
  _$ChatServiceStateCopyWithImpl(this._self, this._then);

  final ChatServiceState _self;
  final $Res Function(ChatServiceState) _then;

/// Create a copy of ChatServiceState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? contact = freezed,Object? group = freezed,Object? otherPartyCard = freezed,Object? messages = null,Object? membersTyping = null,Object? isActive = null,Object? isInitialized = null,Object? contactPresenceStatus = null,Object? effect = freezed,}) {
  return _then(_self.copyWith(
contact: freezed == contact ? _self.contact : contact // ignore: cast_nullable_to_non_nullable
as Contact?,group: freezed == group ? _self.group : group // ignore: cast_nullable_to_non_nullable
as Group?,otherPartyCard: freezed == otherPartyCard ? _self.otherPartyCard : otherPartyCard // ignore: cast_nullable_to_non_nullable
as ContactCard?,messages: null == messages ? _self.messages : messages // ignore: cast_nullable_to_non_nullable
as List<chat.ChatItem>,membersTyping: null == membersTyping ? _self.membersTyping : membersTyping // ignore: cast_nullable_to_non_nullable
as List<String>,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,isInitialized: null == isInitialized ? _self.isInitialized : isInitialized // ignore: cast_nullable_to_non_nullable
as bool,contactPresenceStatus: null == contactPresenceStatus ? _self.contactPresenceStatus : contactPresenceStatus // ignore: cast_nullable_to_non_nullable
as ContactPresenceStatus,effect: freezed == effect ? _self.effect : effect // ignore: cast_nullable_to_non_nullable
as chat.Effect?,
  ));
}
/// Create a copy of ChatServiceState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ContactCardCopyWith<$Res>? get otherPartyCard {
    if (_self.otherPartyCard == null) {
    return null;
  }

  return $ContactCardCopyWith<$Res>(_self.otherPartyCard!, (value) {
    return _then(_self.copyWith(otherPartyCard: value));
  });
}
}


/// Adds pattern-matching-related methods to [ChatServiceState].
extension ChatServiceStatePatterns on ChatServiceState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ChatServiceState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ChatServiceState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ChatServiceState value)  $default,){
final _that = this;
switch (_that) {
case _ChatServiceState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ChatServiceState value)?  $default,){
final _that = this;
switch (_that) {
case _ChatServiceState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Contact? contact,  Group? group,  ContactCard? otherPartyCard,  List<chat.ChatItem> messages,  List<String> membersTyping,  bool isActive,  bool isInitialized,  ContactPresenceStatus contactPresenceStatus,  chat.Effect? effect)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ChatServiceState() when $default != null:
return $default(_that.contact,_that.group,_that.otherPartyCard,_that.messages,_that.membersTyping,_that.isActive,_that.isInitialized,_that.contactPresenceStatus,_that.effect);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Contact? contact,  Group? group,  ContactCard? otherPartyCard,  List<chat.ChatItem> messages,  List<String> membersTyping,  bool isActive,  bool isInitialized,  ContactPresenceStatus contactPresenceStatus,  chat.Effect? effect)  $default,) {final _that = this;
switch (_that) {
case _ChatServiceState():
return $default(_that.contact,_that.group,_that.otherPartyCard,_that.messages,_that.membersTyping,_that.isActive,_that.isInitialized,_that.contactPresenceStatus,_that.effect);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Contact? contact,  Group? group,  ContactCard? otherPartyCard,  List<chat.ChatItem> messages,  List<String> membersTyping,  bool isActive,  bool isInitialized,  ContactPresenceStatus contactPresenceStatus,  chat.Effect? effect)?  $default,) {final _that = this;
switch (_that) {
case _ChatServiceState() when $default != null:
return $default(_that.contact,_that.group,_that.otherPartyCard,_that.messages,_that.membersTyping,_that.isActive,_that.isInitialized,_that.contactPresenceStatus,_that.effect);case _:
  return null;

}
}

}

/// @nodoc


class _ChatServiceState extends ChatServiceState {
   _ChatServiceState({this.contact, this.group, this.otherPartyCard, final  List<chat.ChatItem> messages = const [], final  List<String> membersTyping = const [], this.isActive = false, this.isInitialized = false, this.contactPresenceStatus = ContactPresenceStatus.unknown, this.effect}): _messages = messages,_membersTyping = membersTyping,super._();
  

@override final  Contact? contact;
@override final  Group? group;
@override final  ContactCard? otherPartyCard;
 final  List<chat.ChatItem> _messages;
@override@JsonKey() List<chat.ChatItem> get messages {
  if (_messages is EqualUnmodifiableListView) return _messages;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_messages);
}

 final  List<String> _membersTyping;
@override@JsonKey() List<String> get membersTyping {
  if (_membersTyping is EqualUnmodifiableListView) return _membersTyping;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_membersTyping);
}

@override@JsonKey() final  bool isActive;
@override@JsonKey() final  bool isInitialized;
@override@JsonKey() final  ContactPresenceStatus contactPresenceStatus;
@override final  chat.Effect? effect;

/// Create a copy of ChatServiceState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChatServiceStateCopyWith<_ChatServiceState> get copyWith => __$ChatServiceStateCopyWithImpl<_ChatServiceState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChatServiceState&&(identical(other.contact, contact) || other.contact == contact)&&(identical(other.group, group) || other.group == group)&&(identical(other.otherPartyCard, otherPartyCard) || other.otherPartyCard == otherPartyCard)&&const DeepCollectionEquality().equals(other._messages, _messages)&&const DeepCollectionEquality().equals(other._membersTyping, _membersTyping)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.isInitialized, isInitialized) || other.isInitialized == isInitialized)&&(identical(other.contactPresenceStatus, contactPresenceStatus) || other.contactPresenceStatus == contactPresenceStatus)&&(identical(other.effect, effect) || other.effect == effect));
}


@override
int get hashCode => Object.hash(runtimeType,contact,group,otherPartyCard,const DeepCollectionEquality().hash(_messages),const DeepCollectionEquality().hash(_membersTyping),isActive,isInitialized,contactPresenceStatus,effect);

@override
String toString() {
  return 'ChatServiceState(contact: $contact, group: $group, otherPartyCard: $otherPartyCard, messages: $messages, membersTyping: $membersTyping, isActive: $isActive, isInitialized: $isInitialized, contactPresenceStatus: $contactPresenceStatus, effect: $effect)';
}


}

/// @nodoc
abstract mixin class _$ChatServiceStateCopyWith<$Res> implements $ChatServiceStateCopyWith<$Res> {
  factory _$ChatServiceStateCopyWith(_ChatServiceState value, $Res Function(_ChatServiceState) _then) = __$ChatServiceStateCopyWithImpl;
@override @useResult
$Res call({
 Contact? contact, Group? group, ContactCard? otherPartyCard, List<chat.ChatItem> messages, List<String> membersTyping, bool isActive, bool isInitialized, ContactPresenceStatus contactPresenceStatus, chat.Effect? effect
});


@override $ContactCardCopyWith<$Res>? get otherPartyCard;

}
/// @nodoc
class __$ChatServiceStateCopyWithImpl<$Res>
    implements _$ChatServiceStateCopyWith<$Res> {
  __$ChatServiceStateCopyWithImpl(this._self, this._then);

  final _ChatServiceState _self;
  final $Res Function(_ChatServiceState) _then;

/// Create a copy of ChatServiceState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? contact = freezed,Object? group = freezed,Object? otherPartyCard = freezed,Object? messages = null,Object? membersTyping = null,Object? isActive = null,Object? isInitialized = null,Object? contactPresenceStatus = null,Object? effect = freezed,}) {
  return _then(_ChatServiceState(
contact: freezed == contact ? _self.contact : contact // ignore: cast_nullable_to_non_nullable
as Contact?,group: freezed == group ? _self.group : group // ignore: cast_nullable_to_non_nullable
as Group?,otherPartyCard: freezed == otherPartyCard ? _self.otherPartyCard : otherPartyCard // ignore: cast_nullable_to_non_nullable
as ContactCard?,messages: null == messages ? _self._messages : messages // ignore: cast_nullable_to_non_nullable
as List<chat.ChatItem>,membersTyping: null == membersTyping ? _self._membersTyping : membersTyping // ignore: cast_nullable_to_non_nullable
as List<String>,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,isInitialized: null == isInitialized ? _self.isInitialized : isInitialized // ignore: cast_nullable_to_non_nullable
as bool,contactPresenceStatus: null == contactPresenceStatus ? _self.contactPresenceStatus : contactPresenceStatus // ignore: cast_nullable_to_non_nullable
as ContactPresenceStatus,effect: freezed == effect ? _self.effect : effect // ignore: cast_nullable_to_non_nullable
as chat.Effect?,
  ));
}

/// Create a copy of ChatServiceState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ContactCardCopyWith<$Res>? get otherPartyCard {
    if (_self.otherPartyCard == null) {
    return null;
  }

  return $ContactCardCopyWith<$Res>(_self.otherPartyCard!, (value) {
    return _then(_self.copyWith(otherPartyCard: value));
  });
}
}

// dart format on
