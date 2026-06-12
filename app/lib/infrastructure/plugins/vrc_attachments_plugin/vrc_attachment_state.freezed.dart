// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'vrc_attachment_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$VrcAttachmentState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VrcAttachmentState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'VrcAttachmentState()';
}


}

/// @nodoc
class $VrcAttachmentStateCopyWith<$Res>  {
$VrcAttachmentStateCopyWith(VrcAttachmentState _, $Res Function(VrcAttachmentState) __);
}


/// Adds pattern-matching-related methods to [VrcAttachmentState].
extension VrcAttachmentStatePatterns on VrcAttachmentState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _VrcAttachmentStateInitial value)?  initial,TResult Function( _VrcAttachmentStateLoading value)?  loading,TResult Function( _VrcAttachmentStateSuccess value)?  success,TResult Function( _VrcAttachmentStateNotFound value)?  notFound,TResult Function( _VrcAttachmentStateError value)?  error,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VrcAttachmentStateInitial() when initial != null:
return initial(_that);case _VrcAttachmentStateLoading() when loading != null:
return loading(_that);case _VrcAttachmentStateSuccess() when success != null:
return success(_that);case _VrcAttachmentStateNotFound() when notFound != null:
return notFound(_that);case _VrcAttachmentStateError() when error != null:
return error(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _VrcAttachmentStateInitial value)  initial,required TResult Function( _VrcAttachmentStateLoading value)  loading,required TResult Function( _VrcAttachmentStateSuccess value)  success,required TResult Function( _VrcAttachmentStateNotFound value)  notFound,required TResult Function( _VrcAttachmentStateError value)  error,}){
final _that = this;
switch (_that) {
case _VrcAttachmentStateInitial():
return initial(_that);case _VrcAttachmentStateLoading():
return loading(_that);case _VrcAttachmentStateSuccess():
return success(_that);case _VrcAttachmentStateNotFound():
return notFound(_that);case _VrcAttachmentStateError():
return error(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _VrcAttachmentStateInitial value)?  initial,TResult? Function( _VrcAttachmentStateLoading value)?  loading,TResult? Function( _VrcAttachmentStateSuccess value)?  success,TResult? Function( _VrcAttachmentStateNotFound value)?  notFound,TResult? Function( _VrcAttachmentStateError value)?  error,}){
final _that = this;
switch (_that) {
case _VrcAttachmentStateInitial() when initial != null:
return initial(_that);case _VrcAttachmentStateLoading() when loading != null:
return loading(_that);case _VrcAttachmentStateSuccess() when success != null:
return success(_that);case _VrcAttachmentStateNotFound() when notFound != null:
return notFound(_that);case _VrcAttachmentStateError() when error != null:
return error(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  initial,TResult Function()?  loading,TResult Function( VrcCredential credential)?  success,TResult Function()?  notFound,TResult Function( String message)?  error,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VrcAttachmentStateInitial() when initial != null:
return initial();case _VrcAttachmentStateLoading() when loading != null:
return loading();case _VrcAttachmentStateSuccess() when success != null:
return success(_that.credential);case _VrcAttachmentStateNotFound() when notFound != null:
return notFound();case _VrcAttachmentStateError() when error != null:
return error(_that.message);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  initial,required TResult Function()  loading,required TResult Function( VrcCredential credential)  success,required TResult Function()  notFound,required TResult Function( String message)  error,}) {final _that = this;
switch (_that) {
case _VrcAttachmentStateInitial():
return initial();case _VrcAttachmentStateLoading():
return loading();case _VrcAttachmentStateSuccess():
return success(_that.credential);case _VrcAttachmentStateNotFound():
return notFound();case _VrcAttachmentStateError():
return error(_that.message);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  initial,TResult? Function()?  loading,TResult? Function( VrcCredential credential)?  success,TResult? Function()?  notFound,TResult? Function( String message)?  error,}) {final _that = this;
switch (_that) {
case _VrcAttachmentStateInitial() when initial != null:
return initial();case _VrcAttachmentStateLoading() when loading != null:
return loading();case _VrcAttachmentStateSuccess() when success != null:
return success(_that.credential);case _VrcAttachmentStateNotFound() when notFound != null:
return notFound();case _VrcAttachmentStateError() when error != null:
return error(_that.message);case _:
  return null;

}
}

}

/// @nodoc


class _VrcAttachmentStateInitial implements VrcAttachmentState {
  const _VrcAttachmentStateInitial();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _VrcAttachmentStateInitial);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'VrcAttachmentState.initial()';
}


}




/// @nodoc


class _VrcAttachmentStateLoading implements VrcAttachmentState {
  const _VrcAttachmentStateLoading();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _VrcAttachmentStateLoading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'VrcAttachmentState.loading()';
}


}




/// @nodoc


class _VrcAttachmentStateSuccess implements VrcAttachmentState {
  const _VrcAttachmentStateSuccess(this.credential);
  

 final  VrcCredential credential;

/// Create a copy of VrcAttachmentState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VrcAttachmentStateSuccessCopyWith<_VrcAttachmentStateSuccess> get copyWith => __$VrcAttachmentStateSuccessCopyWithImpl<_VrcAttachmentStateSuccess>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _VrcAttachmentStateSuccess&&(identical(other.credential, credential) || other.credential == credential));
}


@override
int get hashCode => Object.hash(runtimeType,credential);

@override
String toString() {
  return 'VrcAttachmentState.success(credential: $credential)';
}


}

/// @nodoc
abstract mixin class _$VrcAttachmentStateSuccessCopyWith<$Res> implements $VrcAttachmentStateCopyWith<$Res> {
  factory _$VrcAttachmentStateSuccessCopyWith(_VrcAttachmentStateSuccess value, $Res Function(_VrcAttachmentStateSuccess) _then) = __$VrcAttachmentStateSuccessCopyWithImpl;
@useResult
$Res call({
 VrcCredential credential
});


$VrcCredentialCopyWith<$Res> get credential;

}
/// @nodoc
class __$VrcAttachmentStateSuccessCopyWithImpl<$Res>
    implements _$VrcAttachmentStateSuccessCopyWith<$Res> {
  __$VrcAttachmentStateSuccessCopyWithImpl(this._self, this._then);

  final _VrcAttachmentStateSuccess _self;
  final $Res Function(_VrcAttachmentStateSuccess) _then;

/// Create a copy of VrcAttachmentState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? credential = null,}) {
  return _then(_VrcAttachmentStateSuccess(
null == credential ? _self.credential : credential // ignore: cast_nullable_to_non_nullable
as VrcCredential,
  ));
}

/// Create a copy of VrcAttachmentState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$VrcCredentialCopyWith<$Res> get credential {
  
  return $VrcCredentialCopyWith<$Res>(_self.credential, (value) {
    return _then(_self.copyWith(credential: value));
  });
}
}

/// @nodoc


class _VrcAttachmentStateNotFound implements VrcAttachmentState {
  const _VrcAttachmentStateNotFound();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _VrcAttachmentStateNotFound);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'VrcAttachmentState.notFound()';
}


}




/// @nodoc


class _VrcAttachmentStateError implements VrcAttachmentState {
  const _VrcAttachmentStateError(this.message);
  

 final  String message;

/// Create a copy of VrcAttachmentState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VrcAttachmentStateErrorCopyWith<_VrcAttachmentStateError> get copyWith => __$VrcAttachmentStateErrorCopyWithImpl<_VrcAttachmentStateError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _VrcAttachmentStateError&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'VrcAttachmentState.error(message: $message)';
}


}

/// @nodoc
abstract mixin class _$VrcAttachmentStateErrorCopyWith<$Res> implements $VrcAttachmentStateCopyWith<$Res> {
  factory _$VrcAttachmentStateErrorCopyWith(_VrcAttachmentStateError value, $Res Function(_VrcAttachmentStateError) _then) = __$VrcAttachmentStateErrorCopyWithImpl;
@useResult
$Res call({
 String message
});




}
/// @nodoc
class __$VrcAttachmentStateErrorCopyWithImpl<$Res>
    implements _$VrcAttachmentStateErrorCopyWith<$Res> {
  __$VrcAttachmentStateErrorCopyWithImpl(this._self, this._then);

  final _VrcAttachmentStateError _self;
  final $Res Function(_VrcAttachmentStateError) _then;

/// Create a copy of VrcAttachmentState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(_VrcAttachmentStateError(
null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
