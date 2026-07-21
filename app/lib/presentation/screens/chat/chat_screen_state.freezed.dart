// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'chat_screen_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ChatScreenState {

 Contact? get contact; Group? get group; String? get offerName; ContactCard? get otherPartyCard; ContactCard? get myCard; List<chat.ChatItem> get messages; ChatSuggestion? get latestSuggestion; String? get pendingSuggestionMessageId; List<String> get membersTyping; int get selectedReactionIndex; bool get isActive; bool get isInitialized; ContactPresenceStatus get contactPresenceStatus; ScreenEffect? get effect; Map<String, Uint8List> get attachmentsDataCache; String? get notificationToken; String? get myDid; bool get shouldEnableVrcAttachment; bool get shouldShowVrcBanner; bool get shouldStartVrcExchangeFromAttachment; chat.TransportCapabilities? get capabilities;
/// Create a copy of ChatScreenState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChatScreenStateCopyWith<ChatScreenState> get copyWith => _$ChatScreenStateCopyWithImpl<ChatScreenState>(this as ChatScreenState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChatScreenState&&(identical(other.contact, contact) || other.contact == contact)&&(identical(other.group, group) || other.group == group)&&(identical(other.offerName, offerName) || other.offerName == offerName)&&(identical(other.otherPartyCard, otherPartyCard) || other.otherPartyCard == otherPartyCard)&&(identical(other.myCard, myCard) || other.myCard == myCard)&&const DeepCollectionEquality().equals(other.messages, messages)&&(identical(other.latestSuggestion, latestSuggestion) || other.latestSuggestion == latestSuggestion)&&(identical(other.pendingSuggestionMessageId, pendingSuggestionMessageId) || other.pendingSuggestionMessageId == pendingSuggestionMessageId)&&const DeepCollectionEquality().equals(other.membersTyping, membersTyping)&&(identical(other.selectedReactionIndex, selectedReactionIndex) || other.selectedReactionIndex == selectedReactionIndex)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.isInitialized, isInitialized) || other.isInitialized == isInitialized)&&(identical(other.contactPresenceStatus, contactPresenceStatus) || other.contactPresenceStatus == contactPresenceStatus)&&(identical(other.effect, effect) || other.effect == effect)&&const DeepCollectionEquality().equals(other.attachmentsDataCache, attachmentsDataCache)&&(identical(other.notificationToken, notificationToken) || other.notificationToken == notificationToken)&&(identical(other.myDid, myDid) || other.myDid == myDid)&&(identical(other.shouldEnableVrcAttachment, shouldEnableVrcAttachment) || other.shouldEnableVrcAttachment == shouldEnableVrcAttachment)&&(identical(other.shouldShowVrcBanner, shouldShowVrcBanner) || other.shouldShowVrcBanner == shouldShowVrcBanner)&&(identical(other.shouldStartVrcExchangeFromAttachment, shouldStartVrcExchangeFromAttachment) || other.shouldStartVrcExchangeFromAttachment == shouldStartVrcExchangeFromAttachment)&&(identical(other.capabilities, capabilities) || other.capabilities == capabilities));
}


@override
int get hashCode => Object.hashAll([runtimeType,contact,group,offerName,otherPartyCard,myCard,const DeepCollectionEquality().hash(messages),latestSuggestion,pendingSuggestionMessageId,const DeepCollectionEquality().hash(membersTyping),selectedReactionIndex,isActive,isInitialized,contactPresenceStatus,effect,const DeepCollectionEquality().hash(attachmentsDataCache),notificationToken,myDid,shouldEnableVrcAttachment,shouldShowVrcBanner,shouldStartVrcExchangeFromAttachment,capabilities]);

@override
String toString() {
  return 'ChatScreenState(contact: $contact, group: $group, offerName: $offerName, otherPartyCard: $otherPartyCard, myCard: $myCard, messages: $messages, latestSuggestion: $latestSuggestion, pendingSuggestionMessageId: $pendingSuggestionMessageId, membersTyping: $membersTyping, selectedReactionIndex: $selectedReactionIndex, isActive: $isActive, isInitialized: $isInitialized, contactPresenceStatus: $contactPresenceStatus, effect: $effect, attachmentsDataCache: $attachmentsDataCache, notificationToken: $notificationToken, myDid: $myDid, shouldEnableVrcAttachment: $shouldEnableVrcAttachment, shouldShowVrcBanner: $shouldShowVrcBanner, shouldStartVrcExchangeFromAttachment: $shouldStartVrcExchangeFromAttachment, capabilities: $capabilities)';
}


}

/// @nodoc
abstract mixin class $ChatScreenStateCopyWith<$Res>  {
  factory $ChatScreenStateCopyWith(ChatScreenState value, $Res Function(ChatScreenState) _then) = _$ChatScreenStateCopyWithImpl;
@useResult
$Res call({
 Contact? contact, Group? group, String? offerName, ContactCard? otherPartyCard, ContactCard? myCard, List<chat.ChatItem> messages, ChatSuggestion? latestSuggestion, String? pendingSuggestionMessageId, List<String> membersTyping, int selectedReactionIndex, bool isActive, bool isInitialized, ContactPresenceStatus contactPresenceStatus, ScreenEffect? effect, Map<String, Uint8List> attachmentsDataCache, String? notificationToken, String? myDid, bool shouldEnableVrcAttachment, bool shouldShowVrcBanner, bool shouldStartVrcExchangeFromAttachment, chat.TransportCapabilities? capabilities
});


$ContactCardCopyWith<$Res>? get otherPartyCard;$ContactCardCopyWith<$Res>? get myCard;

}
/// @nodoc
class _$ChatScreenStateCopyWithImpl<$Res>
    implements $ChatScreenStateCopyWith<$Res> {
  _$ChatScreenStateCopyWithImpl(this._self, this._then);

  final ChatScreenState _self;
  final $Res Function(ChatScreenState) _then;

/// Create a copy of ChatScreenState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? contact = freezed,Object? group = freezed,Object? offerName = freezed,Object? otherPartyCard = freezed,Object? myCard = freezed,Object? messages = null,Object? latestSuggestion = freezed,Object? pendingSuggestionMessageId = freezed,Object? membersTyping = null,Object? selectedReactionIndex = null,Object? isActive = null,Object? isInitialized = null,Object? contactPresenceStatus = null,Object? effect = freezed,Object? attachmentsDataCache = null,Object? notificationToken = freezed,Object? myDid = freezed,Object? shouldEnableVrcAttachment = null,Object? shouldShowVrcBanner = null,Object? shouldStartVrcExchangeFromAttachment = null,Object? capabilities = freezed,}) {
  return _then(_self.copyWith(
contact: freezed == contact ? _self.contact : contact // ignore: cast_nullable_to_non_nullable
as Contact?,group: freezed == group ? _self.group : group // ignore: cast_nullable_to_non_nullable
as Group?,offerName: freezed == offerName ? _self.offerName : offerName // ignore: cast_nullable_to_non_nullable
as String?,otherPartyCard: freezed == otherPartyCard ? _self.otherPartyCard : otherPartyCard // ignore: cast_nullable_to_non_nullable
as ContactCard?,myCard: freezed == myCard ? _self.myCard : myCard // ignore: cast_nullable_to_non_nullable
as ContactCard?,messages: null == messages ? _self.messages : messages // ignore: cast_nullable_to_non_nullable
as List<chat.ChatItem>,latestSuggestion: freezed == latestSuggestion ? _self.latestSuggestion : latestSuggestion // ignore: cast_nullable_to_non_nullable
as ChatSuggestion?,pendingSuggestionMessageId: freezed == pendingSuggestionMessageId ? _self.pendingSuggestionMessageId : pendingSuggestionMessageId // ignore: cast_nullable_to_non_nullable
as String?,membersTyping: null == membersTyping ? _self.membersTyping : membersTyping // ignore: cast_nullable_to_non_nullable
as List<String>,selectedReactionIndex: null == selectedReactionIndex ? _self.selectedReactionIndex : selectedReactionIndex // ignore: cast_nullable_to_non_nullable
as int,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,isInitialized: null == isInitialized ? _self.isInitialized : isInitialized // ignore: cast_nullable_to_non_nullable
as bool,contactPresenceStatus: null == contactPresenceStatus ? _self.contactPresenceStatus : contactPresenceStatus // ignore: cast_nullable_to_non_nullable
as ContactPresenceStatus,effect: freezed == effect ? _self.effect : effect // ignore: cast_nullable_to_non_nullable
as ScreenEffect?,attachmentsDataCache: null == attachmentsDataCache ? _self.attachmentsDataCache : attachmentsDataCache // ignore: cast_nullable_to_non_nullable
as Map<String, Uint8List>,notificationToken: freezed == notificationToken ? _self.notificationToken : notificationToken // ignore: cast_nullable_to_non_nullable
as String?,myDid: freezed == myDid ? _self.myDid : myDid // ignore: cast_nullable_to_non_nullable
as String?,shouldEnableVrcAttachment: null == shouldEnableVrcAttachment ? _self.shouldEnableVrcAttachment : shouldEnableVrcAttachment // ignore: cast_nullable_to_non_nullable
as bool,shouldShowVrcBanner: null == shouldShowVrcBanner ? _self.shouldShowVrcBanner : shouldShowVrcBanner // ignore: cast_nullable_to_non_nullable
as bool,shouldStartVrcExchangeFromAttachment: null == shouldStartVrcExchangeFromAttachment ? _self.shouldStartVrcExchangeFromAttachment : shouldStartVrcExchangeFromAttachment // ignore: cast_nullable_to_non_nullable
as bool,capabilities: freezed == capabilities ? _self.capabilities : capabilities // ignore: cast_nullable_to_non_nullable
as chat.TransportCapabilities?,
  ));
}
/// Create a copy of ChatScreenState
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
}/// Create a copy of ChatScreenState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ContactCardCopyWith<$Res>? get myCard {
    if (_self.myCard == null) {
    return null;
  }

  return $ContactCardCopyWith<$Res>(_self.myCard!, (value) {
    return _then(_self.copyWith(myCard: value));
  });
}
}


/// Adds pattern-matching-related methods to [ChatScreenState].
extension ChatScreenStatePatterns on ChatScreenState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ChatScreenState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ChatScreenState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ChatScreenState value)  $default,){
final _that = this;
switch (_that) {
case _ChatScreenState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ChatScreenState value)?  $default,){
final _that = this;
switch (_that) {
case _ChatScreenState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Contact? contact,  Group? group,  String? offerName,  ContactCard? otherPartyCard,  ContactCard? myCard,  List<chat.ChatItem> messages,  ChatSuggestion? latestSuggestion,  String? pendingSuggestionMessageId,  List<String> membersTyping,  int selectedReactionIndex,  bool isActive,  bool isInitialized,  ContactPresenceStatus contactPresenceStatus,  ScreenEffect? effect,  Map<String, Uint8List> attachmentsDataCache,  String? notificationToken,  String? myDid,  bool shouldEnableVrcAttachment,  bool shouldShowVrcBanner,  bool shouldStartVrcExchangeFromAttachment,  chat.TransportCapabilities? capabilities)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ChatScreenState() when $default != null:
return $default(_that.contact,_that.group,_that.offerName,_that.otherPartyCard,_that.myCard,_that.messages,_that.latestSuggestion,_that.pendingSuggestionMessageId,_that.membersTyping,_that.selectedReactionIndex,_that.isActive,_that.isInitialized,_that.contactPresenceStatus,_that.effect,_that.attachmentsDataCache,_that.notificationToken,_that.myDid,_that.shouldEnableVrcAttachment,_that.shouldShowVrcBanner,_that.shouldStartVrcExchangeFromAttachment,_that.capabilities);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Contact? contact,  Group? group,  String? offerName,  ContactCard? otherPartyCard,  ContactCard? myCard,  List<chat.ChatItem> messages,  ChatSuggestion? latestSuggestion,  String? pendingSuggestionMessageId,  List<String> membersTyping,  int selectedReactionIndex,  bool isActive,  bool isInitialized,  ContactPresenceStatus contactPresenceStatus,  ScreenEffect? effect,  Map<String, Uint8List> attachmentsDataCache,  String? notificationToken,  String? myDid,  bool shouldEnableVrcAttachment,  bool shouldShowVrcBanner,  bool shouldStartVrcExchangeFromAttachment,  chat.TransportCapabilities? capabilities)  $default,) {final _that = this;
switch (_that) {
case _ChatScreenState():
return $default(_that.contact,_that.group,_that.offerName,_that.otherPartyCard,_that.myCard,_that.messages,_that.latestSuggestion,_that.pendingSuggestionMessageId,_that.membersTyping,_that.selectedReactionIndex,_that.isActive,_that.isInitialized,_that.contactPresenceStatus,_that.effect,_that.attachmentsDataCache,_that.notificationToken,_that.myDid,_that.shouldEnableVrcAttachment,_that.shouldShowVrcBanner,_that.shouldStartVrcExchangeFromAttachment,_that.capabilities);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Contact? contact,  Group? group,  String? offerName,  ContactCard? otherPartyCard,  ContactCard? myCard,  List<chat.ChatItem> messages,  ChatSuggestion? latestSuggestion,  String? pendingSuggestionMessageId,  List<String> membersTyping,  int selectedReactionIndex,  bool isActive,  bool isInitialized,  ContactPresenceStatus contactPresenceStatus,  ScreenEffect? effect,  Map<String, Uint8List> attachmentsDataCache,  String? notificationToken,  String? myDid,  bool shouldEnableVrcAttachment,  bool shouldShowVrcBanner,  bool shouldStartVrcExchangeFromAttachment,  chat.TransportCapabilities? capabilities)?  $default,) {final _that = this;
switch (_that) {
case _ChatScreenState() when $default != null:
return $default(_that.contact,_that.group,_that.offerName,_that.otherPartyCard,_that.myCard,_that.messages,_that.latestSuggestion,_that.pendingSuggestionMessageId,_that.membersTyping,_that.selectedReactionIndex,_that.isActive,_that.isInitialized,_that.contactPresenceStatus,_that.effect,_that.attachmentsDataCache,_that.notificationToken,_that.myDid,_that.shouldEnableVrcAttachment,_that.shouldShowVrcBanner,_that.shouldStartVrcExchangeFromAttachment,_that.capabilities);case _:
  return null;

}
}

}

/// @nodoc


class _ChatScreenState extends ChatScreenState {
   _ChatScreenState({this.contact, this.group, this.offerName, this.otherPartyCard, this.myCard, final  List<chat.ChatItem> messages = const [], this.latestSuggestion, this.pendingSuggestionMessageId, final  List<String> membersTyping = const [], this.selectedReactionIndex = -1, this.isActive = false, this.isInitialized = false, this.contactPresenceStatus = ContactPresenceStatus.unknown, this.effect, final  Map<String, Uint8List> attachmentsDataCache = const {}, this.notificationToken, this.myDid, this.shouldEnableVrcAttachment = false, this.shouldShowVrcBanner = false, this.shouldStartVrcExchangeFromAttachment = false, this.capabilities}): _messages = messages,_membersTyping = membersTyping,_attachmentsDataCache = attachmentsDataCache,super._();
  

@override final  Contact? contact;
@override final  Group? group;
@override final  String? offerName;
@override final  ContactCard? otherPartyCard;
@override final  ContactCard? myCard;
 final  List<chat.ChatItem> _messages;
@override@JsonKey() List<chat.ChatItem> get messages {
  if (_messages is EqualUnmodifiableListView) return _messages;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_messages);
}

@override final  ChatSuggestion? latestSuggestion;
@override final  String? pendingSuggestionMessageId;
 final  List<String> _membersTyping;
@override@JsonKey() List<String> get membersTyping {
  if (_membersTyping is EqualUnmodifiableListView) return _membersTyping;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_membersTyping);
}

@override@JsonKey() final  int selectedReactionIndex;
@override@JsonKey() final  bool isActive;
@override@JsonKey() final  bool isInitialized;
@override@JsonKey() final  ContactPresenceStatus contactPresenceStatus;
@override final  ScreenEffect? effect;
 final  Map<String, Uint8List> _attachmentsDataCache;
@override@JsonKey() Map<String, Uint8List> get attachmentsDataCache {
  if (_attachmentsDataCache is EqualUnmodifiableMapView) return _attachmentsDataCache;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_attachmentsDataCache);
}

@override final  String? notificationToken;
@override final  String? myDid;
@override@JsonKey() final  bool shouldEnableVrcAttachment;
@override@JsonKey() final  bool shouldShowVrcBanner;
@override@JsonKey() final  bool shouldStartVrcExchangeFromAttachment;
@override final  chat.TransportCapabilities? capabilities;

/// Create a copy of ChatScreenState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChatScreenStateCopyWith<_ChatScreenState> get copyWith => __$ChatScreenStateCopyWithImpl<_ChatScreenState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChatScreenState&&(identical(other.contact, contact) || other.contact == contact)&&(identical(other.group, group) || other.group == group)&&(identical(other.offerName, offerName) || other.offerName == offerName)&&(identical(other.otherPartyCard, otherPartyCard) || other.otherPartyCard == otherPartyCard)&&(identical(other.myCard, myCard) || other.myCard == myCard)&&const DeepCollectionEquality().equals(other._messages, _messages)&&(identical(other.latestSuggestion, latestSuggestion) || other.latestSuggestion == latestSuggestion)&&(identical(other.pendingSuggestionMessageId, pendingSuggestionMessageId) || other.pendingSuggestionMessageId == pendingSuggestionMessageId)&&const DeepCollectionEquality().equals(other._membersTyping, _membersTyping)&&(identical(other.selectedReactionIndex, selectedReactionIndex) || other.selectedReactionIndex == selectedReactionIndex)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.isInitialized, isInitialized) || other.isInitialized == isInitialized)&&(identical(other.contactPresenceStatus, contactPresenceStatus) || other.contactPresenceStatus == contactPresenceStatus)&&(identical(other.effect, effect) || other.effect == effect)&&const DeepCollectionEquality().equals(other._attachmentsDataCache, _attachmentsDataCache)&&(identical(other.notificationToken, notificationToken) || other.notificationToken == notificationToken)&&(identical(other.myDid, myDid) || other.myDid == myDid)&&(identical(other.shouldEnableVrcAttachment, shouldEnableVrcAttachment) || other.shouldEnableVrcAttachment == shouldEnableVrcAttachment)&&(identical(other.shouldShowVrcBanner, shouldShowVrcBanner) || other.shouldShowVrcBanner == shouldShowVrcBanner)&&(identical(other.shouldStartVrcExchangeFromAttachment, shouldStartVrcExchangeFromAttachment) || other.shouldStartVrcExchangeFromAttachment == shouldStartVrcExchangeFromAttachment)&&(identical(other.capabilities, capabilities) || other.capabilities == capabilities));
}


@override
int get hashCode => Object.hashAll([runtimeType,contact,group,offerName,otherPartyCard,myCard,const DeepCollectionEquality().hash(_messages),latestSuggestion,pendingSuggestionMessageId,const DeepCollectionEquality().hash(_membersTyping),selectedReactionIndex,isActive,isInitialized,contactPresenceStatus,effect,const DeepCollectionEquality().hash(_attachmentsDataCache),notificationToken,myDid,shouldEnableVrcAttachment,shouldShowVrcBanner,shouldStartVrcExchangeFromAttachment,capabilities]);

@override
String toString() {
  return 'ChatScreenState(contact: $contact, group: $group, offerName: $offerName, otherPartyCard: $otherPartyCard, myCard: $myCard, messages: $messages, latestSuggestion: $latestSuggestion, pendingSuggestionMessageId: $pendingSuggestionMessageId, membersTyping: $membersTyping, selectedReactionIndex: $selectedReactionIndex, isActive: $isActive, isInitialized: $isInitialized, contactPresenceStatus: $contactPresenceStatus, effect: $effect, attachmentsDataCache: $attachmentsDataCache, notificationToken: $notificationToken, myDid: $myDid, shouldEnableVrcAttachment: $shouldEnableVrcAttachment, shouldShowVrcBanner: $shouldShowVrcBanner, shouldStartVrcExchangeFromAttachment: $shouldStartVrcExchangeFromAttachment, capabilities: $capabilities)';
}


}

/// @nodoc
abstract mixin class _$ChatScreenStateCopyWith<$Res> implements $ChatScreenStateCopyWith<$Res> {
  factory _$ChatScreenStateCopyWith(_ChatScreenState value, $Res Function(_ChatScreenState) _then) = __$ChatScreenStateCopyWithImpl;
@override @useResult
$Res call({
 Contact? contact, Group? group, String? offerName, ContactCard? otherPartyCard, ContactCard? myCard, List<chat.ChatItem> messages, ChatSuggestion? latestSuggestion, String? pendingSuggestionMessageId, List<String> membersTyping, int selectedReactionIndex, bool isActive, bool isInitialized, ContactPresenceStatus contactPresenceStatus, ScreenEffect? effect, Map<String, Uint8List> attachmentsDataCache, String? notificationToken, String? myDid, bool shouldEnableVrcAttachment, bool shouldShowVrcBanner, bool shouldStartVrcExchangeFromAttachment, chat.TransportCapabilities? capabilities
});


@override $ContactCardCopyWith<$Res>? get otherPartyCard;@override $ContactCardCopyWith<$Res>? get myCard;

}
/// @nodoc
class __$ChatScreenStateCopyWithImpl<$Res>
    implements _$ChatScreenStateCopyWith<$Res> {
  __$ChatScreenStateCopyWithImpl(this._self, this._then);

  final _ChatScreenState _self;
  final $Res Function(_ChatScreenState) _then;

/// Create a copy of ChatScreenState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? contact = freezed,Object? group = freezed,Object? offerName = freezed,Object? otherPartyCard = freezed,Object? myCard = freezed,Object? messages = null,Object? latestSuggestion = freezed,Object? pendingSuggestionMessageId = freezed,Object? membersTyping = null,Object? selectedReactionIndex = null,Object? isActive = null,Object? isInitialized = null,Object? contactPresenceStatus = null,Object? effect = freezed,Object? attachmentsDataCache = null,Object? notificationToken = freezed,Object? myDid = freezed,Object? shouldEnableVrcAttachment = null,Object? shouldShowVrcBanner = null,Object? shouldStartVrcExchangeFromAttachment = null,Object? capabilities = freezed,}) {
  return _then(_ChatScreenState(
contact: freezed == contact ? _self.contact : contact // ignore: cast_nullable_to_non_nullable
as Contact?,group: freezed == group ? _self.group : group // ignore: cast_nullable_to_non_nullable
as Group?,offerName: freezed == offerName ? _self.offerName : offerName // ignore: cast_nullable_to_non_nullable
as String?,otherPartyCard: freezed == otherPartyCard ? _self.otherPartyCard : otherPartyCard // ignore: cast_nullable_to_non_nullable
as ContactCard?,myCard: freezed == myCard ? _self.myCard : myCard // ignore: cast_nullable_to_non_nullable
as ContactCard?,messages: null == messages ? _self._messages : messages // ignore: cast_nullable_to_non_nullable
as List<chat.ChatItem>,latestSuggestion: freezed == latestSuggestion ? _self.latestSuggestion : latestSuggestion // ignore: cast_nullable_to_non_nullable
as ChatSuggestion?,pendingSuggestionMessageId: freezed == pendingSuggestionMessageId ? _self.pendingSuggestionMessageId : pendingSuggestionMessageId // ignore: cast_nullable_to_non_nullable
as String?,membersTyping: null == membersTyping ? _self._membersTyping : membersTyping // ignore: cast_nullable_to_non_nullable
as List<String>,selectedReactionIndex: null == selectedReactionIndex ? _self.selectedReactionIndex : selectedReactionIndex // ignore: cast_nullable_to_non_nullable
as int,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,isInitialized: null == isInitialized ? _self.isInitialized : isInitialized // ignore: cast_nullable_to_non_nullable
as bool,contactPresenceStatus: null == contactPresenceStatus ? _self.contactPresenceStatus : contactPresenceStatus // ignore: cast_nullable_to_non_nullable
as ContactPresenceStatus,effect: freezed == effect ? _self.effect : effect // ignore: cast_nullable_to_non_nullable
as ScreenEffect?,attachmentsDataCache: null == attachmentsDataCache ? _self._attachmentsDataCache : attachmentsDataCache // ignore: cast_nullable_to_non_nullable
as Map<String, Uint8List>,notificationToken: freezed == notificationToken ? _self.notificationToken : notificationToken // ignore: cast_nullable_to_non_nullable
as String?,myDid: freezed == myDid ? _self.myDid : myDid // ignore: cast_nullable_to_non_nullable
as String?,shouldEnableVrcAttachment: null == shouldEnableVrcAttachment ? _self.shouldEnableVrcAttachment : shouldEnableVrcAttachment // ignore: cast_nullable_to_non_nullable
as bool,shouldShowVrcBanner: null == shouldShowVrcBanner ? _self.shouldShowVrcBanner : shouldShowVrcBanner // ignore: cast_nullable_to_non_nullable
as bool,shouldStartVrcExchangeFromAttachment: null == shouldStartVrcExchangeFromAttachment ? _self.shouldStartVrcExchangeFromAttachment : shouldStartVrcExchangeFromAttachment // ignore: cast_nullable_to_non_nullable
as bool,capabilities: freezed == capabilities ? _self.capabilities : capabilities // ignore: cast_nullable_to_non_nullable
as chat.TransportCapabilities?,
  ));
}

/// Create a copy of ChatScreenState
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
}/// Create a copy of ChatScreenState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ContactCardCopyWith<$Res>? get myCard {
    if (_self.myCard == null) {
    return null;
  }

  return $ContactCardCopyWith<$Res>(_self.myCard!, (value) {
    return _then(_self.copyWith(myCard: value));
  });
}
}

// dart format on
