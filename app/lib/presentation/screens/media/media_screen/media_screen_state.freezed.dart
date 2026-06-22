// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'media_screen_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$MediaScreenState {

 Uint8List? get pickedImageBytes; bool get isCameraAvailable; CameraController? get cameraController; bool get isFrontCamera; bool get isLoading; bool get permissionGranted; int? get videoTooLargeMaxMb; bool get unsupportedMediaSelected;
/// Create a copy of MediaScreenState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MediaScreenStateCopyWith<MediaScreenState> get copyWith => _$MediaScreenStateCopyWithImpl<MediaScreenState>(this as MediaScreenState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MediaScreenState&&const DeepCollectionEquality().equals(other.pickedImageBytes, pickedImageBytes)&&(identical(other.isCameraAvailable, isCameraAvailable) || other.isCameraAvailable == isCameraAvailable)&&(identical(other.cameraController, cameraController) || other.cameraController == cameraController)&&(identical(other.isFrontCamera, isFrontCamera) || other.isFrontCamera == isFrontCamera)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.permissionGranted, permissionGranted) || other.permissionGranted == permissionGranted)&&(identical(other.videoTooLargeMaxMb, videoTooLargeMaxMb) || other.videoTooLargeMaxMb == videoTooLargeMaxMb)&&(identical(other.unsupportedMediaSelected, unsupportedMediaSelected) || other.unsupportedMediaSelected == unsupportedMediaSelected));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(pickedImageBytes),isCameraAvailable,cameraController,isFrontCamera,isLoading,permissionGranted,videoTooLargeMaxMb,unsupportedMediaSelected);

@override
String toString() {
  return 'MediaScreenState(pickedImageBytes: $pickedImageBytes, isCameraAvailable: $isCameraAvailable, cameraController: $cameraController, isFrontCamera: $isFrontCamera, isLoading: $isLoading, permissionGranted: $permissionGranted, videoTooLargeMaxMb: $videoTooLargeMaxMb, unsupportedMediaSelected: $unsupportedMediaSelected)';
}


}

/// @nodoc
abstract mixin class $MediaScreenStateCopyWith<$Res>  {
  factory $MediaScreenStateCopyWith(MediaScreenState value, $Res Function(MediaScreenState) _then) = _$MediaScreenStateCopyWithImpl;
@useResult
$Res call({
 Uint8List? pickedImageBytes, bool isCameraAvailable, CameraController? cameraController, bool isFrontCamera, bool isLoading, bool permissionGranted, int? videoTooLargeMaxMb, bool unsupportedMediaSelected
});




}
/// @nodoc
class _$MediaScreenStateCopyWithImpl<$Res>
    implements $MediaScreenStateCopyWith<$Res> {
  _$MediaScreenStateCopyWithImpl(this._self, this._then);

  final MediaScreenState _self;
  final $Res Function(MediaScreenState) _then;

/// Create a copy of MediaScreenState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? pickedImageBytes = freezed,Object? isCameraAvailable = null,Object? cameraController = freezed,Object? isFrontCamera = null,Object? isLoading = null,Object? permissionGranted = null,Object? videoTooLargeMaxMb = freezed,Object? unsupportedMediaSelected = null,}) {
  return _then(_self.copyWith(
pickedImageBytes: freezed == pickedImageBytes ? _self.pickedImageBytes : pickedImageBytes // ignore: cast_nullable_to_non_nullable
as Uint8List?,isCameraAvailable: null == isCameraAvailable ? _self.isCameraAvailable : isCameraAvailable // ignore: cast_nullable_to_non_nullable
as bool,cameraController: freezed == cameraController ? _self.cameraController : cameraController // ignore: cast_nullable_to_non_nullable
as CameraController?,isFrontCamera: null == isFrontCamera ? _self.isFrontCamera : isFrontCamera // ignore: cast_nullable_to_non_nullable
as bool,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,permissionGranted: null == permissionGranted ? _self.permissionGranted : permissionGranted // ignore: cast_nullable_to_non_nullable
as bool,videoTooLargeMaxMb: freezed == videoTooLargeMaxMb ? _self.videoTooLargeMaxMb : videoTooLargeMaxMb // ignore: cast_nullable_to_non_nullable
as int?,unsupportedMediaSelected: null == unsupportedMediaSelected ? _self.unsupportedMediaSelected : unsupportedMediaSelected // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [MediaScreenState].
extension MediaScreenStatePatterns on MediaScreenState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MediaScreenState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MediaScreenState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MediaScreenState value)  $default,){
final _that = this;
switch (_that) {
case _MediaScreenState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MediaScreenState value)?  $default,){
final _that = this;
switch (_that) {
case _MediaScreenState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Uint8List? pickedImageBytes,  bool isCameraAvailable,  CameraController? cameraController,  bool isFrontCamera,  bool isLoading,  bool permissionGranted,  int? videoTooLargeMaxMb,  bool unsupportedMediaSelected)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MediaScreenState() when $default != null:
return $default(_that.pickedImageBytes,_that.isCameraAvailable,_that.cameraController,_that.isFrontCamera,_that.isLoading,_that.permissionGranted,_that.videoTooLargeMaxMb,_that.unsupportedMediaSelected);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Uint8List? pickedImageBytes,  bool isCameraAvailable,  CameraController? cameraController,  bool isFrontCamera,  bool isLoading,  bool permissionGranted,  int? videoTooLargeMaxMb,  bool unsupportedMediaSelected)  $default,) {final _that = this;
switch (_that) {
case _MediaScreenState():
return $default(_that.pickedImageBytes,_that.isCameraAvailable,_that.cameraController,_that.isFrontCamera,_that.isLoading,_that.permissionGranted,_that.videoTooLargeMaxMb,_that.unsupportedMediaSelected);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Uint8List? pickedImageBytes,  bool isCameraAvailable,  CameraController? cameraController,  bool isFrontCamera,  bool isLoading,  bool permissionGranted,  int? videoTooLargeMaxMb,  bool unsupportedMediaSelected)?  $default,) {final _that = this;
switch (_that) {
case _MediaScreenState() when $default != null:
return $default(_that.pickedImageBytes,_that.isCameraAvailable,_that.cameraController,_that.isFrontCamera,_that.isLoading,_that.permissionGranted,_that.videoTooLargeMaxMb,_that.unsupportedMediaSelected);case _:
  return null;

}
}

}

/// @nodoc


class _MediaScreenState extends MediaScreenState {
   _MediaScreenState({this.pickedImageBytes, this.isCameraAvailable = false, this.cameraController, this.isFrontCamera = false, this.isLoading = false, this.permissionGranted = true, this.videoTooLargeMaxMb, this.unsupportedMediaSelected = false}): super._();
  

@override final  Uint8List? pickedImageBytes;
@override@JsonKey() final  bool isCameraAvailable;
@override final  CameraController? cameraController;
@override@JsonKey() final  bool isFrontCamera;
@override@JsonKey() final  bool isLoading;
@override@JsonKey() final  bool permissionGranted;
@override final  int? videoTooLargeMaxMb;
@override@JsonKey() final  bool unsupportedMediaSelected;

/// Create a copy of MediaScreenState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MediaScreenStateCopyWith<_MediaScreenState> get copyWith => __$MediaScreenStateCopyWithImpl<_MediaScreenState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MediaScreenState&&const DeepCollectionEquality().equals(other.pickedImageBytes, pickedImageBytes)&&(identical(other.isCameraAvailable, isCameraAvailable) || other.isCameraAvailable == isCameraAvailable)&&(identical(other.cameraController, cameraController) || other.cameraController == cameraController)&&(identical(other.isFrontCamera, isFrontCamera) || other.isFrontCamera == isFrontCamera)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.permissionGranted, permissionGranted) || other.permissionGranted == permissionGranted)&&(identical(other.videoTooLargeMaxMb, videoTooLargeMaxMb) || other.videoTooLargeMaxMb == videoTooLargeMaxMb)&&(identical(other.unsupportedMediaSelected, unsupportedMediaSelected) || other.unsupportedMediaSelected == unsupportedMediaSelected));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(pickedImageBytes),isCameraAvailable,cameraController,isFrontCamera,isLoading,permissionGranted,videoTooLargeMaxMb,unsupportedMediaSelected);

@override
String toString() {
  return 'MediaScreenState(pickedImageBytes: $pickedImageBytes, isCameraAvailable: $isCameraAvailable, cameraController: $cameraController, isFrontCamera: $isFrontCamera, isLoading: $isLoading, permissionGranted: $permissionGranted, videoTooLargeMaxMb: $videoTooLargeMaxMb, unsupportedMediaSelected: $unsupportedMediaSelected)';
}


}

/// @nodoc
abstract mixin class _$MediaScreenStateCopyWith<$Res> implements $MediaScreenStateCopyWith<$Res> {
  factory _$MediaScreenStateCopyWith(_MediaScreenState value, $Res Function(_MediaScreenState) _then) = __$MediaScreenStateCopyWithImpl;
@override @useResult
$Res call({
 Uint8List? pickedImageBytes, bool isCameraAvailable, CameraController? cameraController, bool isFrontCamera, bool isLoading, bool permissionGranted, int? videoTooLargeMaxMb, bool unsupportedMediaSelected
});




}
/// @nodoc
class __$MediaScreenStateCopyWithImpl<$Res>
    implements _$MediaScreenStateCopyWith<$Res> {
  __$MediaScreenStateCopyWithImpl(this._self, this._then);

  final _MediaScreenState _self;
  final $Res Function(_MediaScreenState) _then;

/// Create a copy of MediaScreenState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? pickedImageBytes = freezed,Object? isCameraAvailable = null,Object? cameraController = freezed,Object? isFrontCamera = null,Object? isLoading = null,Object? permissionGranted = null,Object? videoTooLargeMaxMb = freezed,Object? unsupportedMediaSelected = null,}) {
  return _then(_MediaScreenState(
pickedImageBytes: freezed == pickedImageBytes ? _self.pickedImageBytes : pickedImageBytes // ignore: cast_nullable_to_non_nullable
as Uint8List?,isCameraAvailable: null == isCameraAvailable ? _self.isCameraAvailable : isCameraAvailable // ignore: cast_nullable_to_non_nullable
as bool,cameraController: freezed == cameraController ? _self.cameraController : cameraController // ignore: cast_nullable_to_non_nullable
as CameraController?,isFrontCamera: null == isFrontCamera ? _self.isFrontCamera : isFrontCamera // ignore: cast_nullable_to_non_nullable
as bool,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,permissionGranted: null == permissionGranted ? _self.permissionGranted : permissionGranted // ignore: cast_nullable_to_non_nullable
as bool,videoTooLargeMaxMb: freezed == videoTooLargeMaxMb ? _self.videoTooLargeMaxMb : videoTooLargeMaxMb // ignore: cast_nullable_to_non_nullable
as int?,unsupportedMediaSelected: null == unsupportedMediaSelected ? _self.unsupportedMediaSelected : unsupportedMediaSelected // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
