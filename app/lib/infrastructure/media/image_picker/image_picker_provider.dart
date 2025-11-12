import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'image_picker_provider.g.dart';

@riverpod
ImagePicker imagePicker(Ref ref) {
  return ImagePicker();
}
