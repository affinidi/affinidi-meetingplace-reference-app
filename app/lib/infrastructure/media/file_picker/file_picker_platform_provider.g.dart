// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'file_picker_platform_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(filePickerPlatform)
const filePickerPlatformProvider = FilePickerPlatformProvider._();

final class FilePickerPlatformProvider
    extends
        $FunctionalProvider<
          FilePickerPlatform,
          FilePickerPlatform,
          FilePickerPlatform
        >
    with $Provider<FilePickerPlatform> {
  const FilePickerPlatformProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'filePickerPlatformProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$filePickerPlatformHash();

  @$internal
  @override
  $ProviderElement<FilePickerPlatform> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  FilePickerPlatform create(Ref ref) {
    return filePickerPlatform(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FilePickerPlatform value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FilePickerPlatform>(value),
    );
  }
}

String _$filePickerPlatformHash() =>
    r'bc5c89646dc7f3627ce685a0d0918f7ee2522092';
