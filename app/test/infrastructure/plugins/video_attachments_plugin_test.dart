import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mpx_flutter_reference_app/infrastructure/plugins/video_attachments_plugin/video_attachment.dart';
import 'package:mpx_flutter_reference_app/infrastructure/plugins/video_attachments_plugin/video_attachments_plugin.dart';

import '../../fakes/fake_cache_manager.dart';
import '../../fakes/fake_image_picker.dart';

void main() {
  group('VideoAttachmentsPlugin', () {
    test('returns null when user cancels', () async {
      final plugin = VideoAttachmentsPlugin(
        cacheManager: FakeCacheManager(),
        imagePicker: FakeImagePicker(shouldReturnNull: true),
      );

      final result = await plugin.pickAttachments(_FakeBuildContext());
      expect(result, isNull);
    });

    test('returns null when picked video exceeds max size', () async {
      const maxBytes = 25 * 1024 * 1024;
      final plugin = VideoAttachmentsPlugin(
        cacheManager: FakeCacheManager(),
        imagePicker: FakeImagePicker(
          xFileToReturn: XFile.fromData(Uint8List(maxBytes + 1)),
        ),
      );

      final result = await plugin.pickAttachments(
        _FakeBuildContext(mounted: false),
      );
      expect(result, isNull);
    });

    test('returns video attachment when picker succeeds', () async {
      final plugin = VideoAttachmentsPlugin(
        cacheManager: FakeCacheManager(),
        imagePicker: FakeImagePicker(
          xFileToReturn: XFile.fromData(
            Uint8List.fromList([1, 2, 3]),
            mimeType: 'video/mp4',
            name: 'clip.mp4',
            path: 'clip.mp4',
          ),
        ),
      );

      final result = await plugin.pickAttachments(_FakeBuildContext());
      expect(result, isNotNull);
      expect(result!.attachments.length, 1);
      expect(result.attachments.first, isA<VideoAttachment>());

      final attachment = result.attachments.first.toAttachment();
      expect(attachment.mediaType, 'video/mp4');
      expect(attachment.filename, 'clip.mp4');
      expect(attachment.byteCount, 3);
      expect(attachment.format, VideoAttachmentsPlugin.pluginName);
    });
  });
}

class _FakeBuildContext extends Fake implements BuildContext {
  _FakeBuildContext({this.mounted = true});

  @override
  final bool mounted;
}
