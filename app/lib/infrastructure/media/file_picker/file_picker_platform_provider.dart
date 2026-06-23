import 'package:file_picker/file_picker.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'file_picker_platform_provider.g.dart';

@riverpod
FilePickerPlatform filePickerPlatform(Ref ref) {
  return FilePickerPlatform.instance;
}
