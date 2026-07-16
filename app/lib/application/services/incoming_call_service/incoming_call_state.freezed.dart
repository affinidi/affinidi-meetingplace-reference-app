// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'incoming_call_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$IncomingCallState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is IncomingCallState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'IncomingCallState()';
}


}

/// @nodoc
class $IncomingCallStateCopyWith<$Res>  {
$IncomingCallStateCopyWith(IncomingCallState _, $Res Function(IncomingCallState) __);
}


/// Adds pattern-matching-related methods to [IncomingCallState].
extension IncomingCallStatePatterns on IncomingCallState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( IncomingCallIdle value)?  idle,TResult Function( IncomingCallRinging value)?  ringing,required TResult orElse(),}){
final _that = this;
switch (_that) {
case IncomingCallIdle() when idle != null:
return idle(_that);case IncomingCallRinging() when ringing != null:
return ringing(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( IncomingCallIdle value)  idle,required TResult Function( IncomingCallRinging value)  ringing,}){
final _that = this;
switch (_that) {
case IncomingCallIdle():
return idle(_that);case IncomingCallRinging():
return ringing(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( IncomingCallIdle value)?  idle,TResult? Function( IncomingCallRinging value)?  ringing,}){
final _that = this;
switch (_that) {
case IncomingCallIdle() when idle != null:
return idle(_that);case IncomingCallRinging() when ringing != null:
return ringing(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  idle,TResult Function( IncomingAudioVideoCallEvent event)?  ringing,required TResult orElse(),}) {final _that = this;
switch (_that) {
case IncomingCallIdle() when idle != null:
return idle();case IncomingCallRinging() when ringing != null:
return ringing(_that.event);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  idle,required TResult Function( IncomingAudioVideoCallEvent event)  ringing,}) {final _that = this;
switch (_that) {
case IncomingCallIdle():
return idle();case IncomingCallRinging():
return ringing(_that.event);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  idle,TResult? Function( IncomingAudioVideoCallEvent event)?  ringing,}) {final _that = this;
switch (_that) {
case IncomingCallIdle() when idle != null:
return idle();case IncomingCallRinging() when ringing != null:
return ringing(_that.event);case _:
  return null;

}
}

}

/// @nodoc


class IncomingCallIdle extends IncomingCallState {
  const IncomingCallIdle(): super._();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is IncomingCallIdle);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'IncomingCallState.idle()';
}


}




/// @nodoc


class IncomingCallRinging extends IncomingCallState {
  const IncomingCallRinging(this.event): super._();
  

 final  IncomingAudioVideoCallEvent event;

/// Create a copy of IncomingCallState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$IncomingCallRingingCopyWith<IncomingCallRinging> get copyWith => _$IncomingCallRingingCopyWithImpl<IncomingCallRinging>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is IncomingCallRinging&&(identical(other.event, event) || other.event == event));
}


@override
int get hashCode => Object.hash(runtimeType,event);

@override
String toString() {
  return 'IncomingCallState.ringing(event: $event)';
}


}

/// @nodoc
abstract mixin class $IncomingCallRingingCopyWith<$Res> implements $IncomingCallStateCopyWith<$Res> {
  factory $IncomingCallRingingCopyWith(IncomingCallRinging value, $Res Function(IncomingCallRinging) _then) = _$IncomingCallRingingCopyWithImpl;
@useResult
$Res call({
 IncomingAudioVideoCallEvent event
});




}
/// @nodoc
class _$IncomingCallRingingCopyWithImpl<$Res>
    implements $IncomingCallRingingCopyWith<$Res> {
  _$IncomingCallRingingCopyWithImpl(this._self, this._then);

  final IncomingCallRinging _self;
  final $Res Function(IncomingCallRinging) _then;

/// Create a copy of IncomingCallState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? event = null,}) {
  return _then(IncomingCallRinging(
null == event ? _self.event : event // ignore: cast_nullable_to_non_nullable
as IncomingAudioVideoCallEvent,
  ));
}


}

// dart format on
