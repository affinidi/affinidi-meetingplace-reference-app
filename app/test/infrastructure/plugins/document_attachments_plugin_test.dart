import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meeting_place_chat/meeting_place_chat.dart';
import 'package:meeting_place_core/meeting_place_core.dart'
    show AttachmentFormat;
import 'package:mpx_flutter_reference_app/infrastructure/plugins/document_attachments_plugin/document_attachment.dart';
import 'package:mpx_flutter_reference_app/infrastructure/plugins/document_attachments_plugin/document_attachments_plugin.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('DocumentAttachment', () {
    test('toAttachment builds ChatAttachment with correct fields', () {
      const mimeType = 'application/pdf';
      const filename = 'report.pdf';
      const byteCount = 1024;

      final attachment = DocumentAttachment(
        base64: 'AAAA',
        pluginName: 'mpx_document_attachment_plugin',
        mimeType: mimeType,
        filename: filename,
        byteCount: byteCount,
      ).toAttachment();

      expect(attachment.mediaType, mimeType);
      expect(attachment.filename, filename);
      expect(attachment.byteCount, byteCount);
      expect(attachment.format, 'mpx_document_attachment_plugin');
      expect(attachment.data?.base64, 'AAAA');
      expect(attachment.id, isNotNull);
    });
  });

  group('DocumentAttachmentsPlugin', () {
    late DocumentAttachmentsPlugin plugin;

    setUp(() {
      plugin = DocumentAttachmentsPlugin();
    });

    group('supportsFormat', () {
      test('returns true for plugin format', () {
        final attachment = ChatAttachment(
          format: 'mpx_document_attachment_plugin',
        );
        expect(plugin.supportsFormat(attachment), isTrue);
      });

      test('returns false for hosted media format', () {
        final attachment = ChatAttachment(
          format: AttachmentFormat.hostedMedia.value,
        );
        expect(plugin.supportsFormat(attachment), isFalse);
      });

      test('returns false for unrelated format', () {
        final attachment = ChatAttachment(format: 'other_plugin');
        expect(plugin.supportsFormat(attachment), isFalse);
      });
    });

    group('pickAttachments', () {
      test('returns null when user cancels', () async {
        FilePickerPlatform.instance = _FakeFilePickerPlatform(result: null);

        final result = await plugin.pickAttachments(_FakeBuildContext());
        expect(result, isNull);
      });

      test('returns null when picked file exceeds max size', () async {
        const maxBytes = 25 * 1024 * 1024;
        FilePickerPlatform.instance = _FakeFilePickerPlatform(
          result: FilePickerResult([
            PlatformFile(name: 'big.pdf', size: maxBytes + 1),
          ]),
        );

        final result = await plugin.pickAttachments(
          _FakeBuildContext(mounted: false),
        );
        expect(result, isNull);
      });

      test('returns null when file path is null', () async {
        FilePickerPlatform.instance = _FakeFilePickerPlatform(
          result: FilePickerResult([
            PlatformFile(name: 'nodisk.pdf', size: 100),
          ]),
        );

        final result = await plugin.pickAttachments(_FakeBuildContext());
        expect(result, isNull);
      });

      test('returns attachment with correct MIME type for pdf', () async {
        final tempFile = await _writeTempFile('doc.pdf', Uint8List(10));

        FilePickerPlatform.instance = _FakeFilePickerPlatform(
          result: FilePickerResult([
            PlatformFile(name: 'doc.pdf', size: 10, path: tempFile.path),
          ]),
        );

        final result = await plugin.pickAttachments(_FakeBuildContext());
        expect(result, isNotNull);
        expect(result!.attachments.length, 1);
        final a = result.attachments.first.toAttachment();
        expect(a.mediaType, 'application/pdf');
        expect(a.filename, 'doc.pdf');
      });

      test('returns attachment with correct MIME type for docx', () async {
        final tempFile = await _writeTempFile('doc.docx', Uint8List(10));

        FilePickerPlatform.instance = _FakeFilePickerPlatform(
          result: FilePickerResult([
            PlatformFile(name: 'doc.docx', size: 10, path: tempFile.path),
          ]),
        );

        final result = await plugin.pickAttachments(_FakeBuildContext());
        expect(result, isNotNull);
        final a = result!.attachments.first.toAttachment();
        expect(a.mediaType, contains('wordprocessingml'));
      });

      test('returns octet-stream for unknown extension', () async {
        final tempFile = await _writeTempFile('data.xyz', Uint8List(10));

        FilePickerPlatform.instance = _FakeFilePickerPlatform(
          result: FilePickerResult([
            PlatformFile(name: 'data.xyz', size: 10, path: tempFile.path),
          ]),
        );

        final result = await plugin.pickAttachments(_FakeBuildContext());
        expect(result, isNotNull);
        final a = result!.attachments.first.toAttachment();
        expect(a.mediaType, 'application/octet-stream');
      });
    });
  });
}

Future<File> _writeTempFile(String name, Uint8List bytes) async {
  final dir = Directory.systemTemp.createTempSync('doc_plugin_test_');
  final file = File('${dir.path}/$name');
  await file.writeAsBytes(bytes);
  addTearDown(() => dir.delete(recursive: true));
  return file;
}

class _FakeFilePickerPlatform extends FilePickerPlatform {
  _FakeFilePickerPlatform({required this.result});

  final FilePickerResult? result;

  @override
  Future<FilePickerResult?> pickFiles({
    String? dialogTitle,
    String? initialDirectory,
    FileType type = FileType.any,
    List<String>? allowedExtensions,
    dynamic Function(FilePickerStatus)? onFileLoading,
    AndroidSAFOptions? androidSafOptions,
    int compressionQuality = 0,
    bool allowMultiple = false,
    bool withData = false,
    bool withReadStream = false,
    bool lockParentWindow = false,
    bool readSequential = false,
    bool cancelUploadOnWindowBlur = true,
  }) async => result;
}

class _FakeBuildContext extends Fake implements BuildContext {
  _FakeBuildContext({this.mounted = true});

  @override
  final bool mounted;
}
