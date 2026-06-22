import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:mpx_app_core/mpx_app_core.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../infrastructure/configuration/environment.dart';
import '../../../infrastructure/extensions/build_context_extensions.dart';
import '../../loggers/app_logger/app_logger.dart';
import 'document_attachment.dart';

/// A plugin for handling document file attachments.
final class DocumentAttachmentsPlugin implements AttachmentPlugin {
  DocumentAttachmentsPlugin();

  static const _pluginName = 'mpx_document_attachment_plugin';

  /// Hard upper bound on raw document bytes accepted from the picker.
  /// Above this the file is rejected before being base64-encoded, which would
  /// otherwise inflate the in-memory footprint by roughly 33 percent.
  int get _maxBytes => Environment.instance.chatAttachmentMaxBytes;

  static const _allowedExtensions = [
    'pdf',
    'doc',
    'docx',
    'xls',
    'xlsx',
    'ppt',
    'pptx',
    'txt',
    'csv',
    'rtf',
    'zip',
    'gz',
    'tar',
  ];

  @override
  Future<AttachmentPluginPickResult?> pickAttachments(
    BuildContext context,
  ) async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: _allowedExtensions,
    );

    if (result == null || result.files.isEmpty) return null;

    final file = result.files.first;
    if (file.size > _maxBytes) {
      if (context.mounted) {
        _showTooLargeSnackBar(context);
      }
      return null;
    }

    final path = file.path;
    if (path == null) return null;
    final bytes = await File(path).readAsBytes();

    final base64Data = base64.encode(bytes);
    final mimeType =
        _mimeTypeFromExtension(file.extension) ?? 'application/octet-stream';

    return AttachmentPluginPickResult(
      text: '',
      attachments: [
        DocumentAttachment(
          base64: base64Data,
          pluginName: _pluginName,
          mimeType: mimeType,
          filename: file.name,
          byteCount: bytes.length,
        ),
      ],
    );
  }

  void _showTooLargeSnackBar(BuildContext context) {
    final maxMb = _maxBytes ~/ (1024 * 1024);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.l10n.attachmentTooLarge(maxMb))),
    );
  }

  @override
  Widget renderAttachment({
    required ChatAttachment attachment,
    required bool isFromMe,
    required Color chatItemColor,
  }) => _DocumentAttachmentWidget(attachment: attachment);

  @override
  Widget renderAttachments({
    required List<ChatAttachment> attachments,
    required bool isFromMe,
    required Color chatItemColor,
  }) => ListView.builder(
    physics: const NeverScrollableScrollPhysics(),
    shrinkWrap: true,
    itemCount: attachments.length,
    itemBuilder: (context, index) =>
        _DocumentAttachmentWidget(attachment: attachments[index]),
  );

  @override
  bool supportsFormat(ChatAttachment attachment) =>
      attachment.format == _pluginName;

  @override
  AttachmentPluginIcon get icon => const EmojiIcon('📄');

  @override
  String localizedName(BuildContext context) => context.l10n.generalDocument;

  @override
  bool get isPlatformSupported => true;

  String? _mimeTypeFromExtension(String? ext) {
    if (ext == null) return null;
    return switch (ext.toLowerCase()) {
      'pdf' => 'application/pdf',
      'doc' => 'application/msword',
      'docx' =>
        'application/vnd.openxmlformats-officedocument'
            '.wordprocessingml.document',
      'xls' => 'application/vnd.ms-excel',
      'xlsx' =>
        'application/vnd.openxmlformats-officedocument'
            '.spreadsheetml.sheet',
      'ppt' => 'application/vnd.ms-powerpoint',
      'pptx' =>
        'application/vnd.openxmlformats-officedocument'
            '.presentationml.presentation',
      'txt' => 'text/plain',
      'csv' => 'text/csv',
      'rtf' => 'application/rtf',
      'zip' => 'application/zip',
      'gz' => 'application/gzip',
      'tar' => 'application/x-tar',
      _ => null,
    };
  }

  @override
  bool get dismissSheetBeforePicking => false;
}

class _DocumentAttachmentWidget extends StatelessWidget {
  const _DocumentAttachmentWidget({required this._attachment});

  final ChatAttachment _attachment;

  @override
  Widget build(BuildContext context) {
    final filename = _attachment.filename ?? 'Document';
    final size = _attachment.byteCount;
    final sizeLabel = size != null ? _formatBytes(size) : '';
    final hasData = _attachment.data?.base64?.isNotEmpty ?? false;

    return SizedBox(
      width: 220,
      child: GestureDetector(
        onTap: hasData ? () => _openDocument(context) : null,
        child: Card(
          color: Colors.grey.shade900,
          clipBehavior: Clip.hardEdge,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          elevation: 3,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                const Icon(
                  Icons.insert_drive_file,
                  color: Colors.white70,
                  size: 32,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        filename,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (sizeLabel.isNotEmpty)
                        Text(
                          sizeLabel,
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 11,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _openDocument(BuildContext context) async {
    final base64Data = _attachment.data?.base64;
    if (base64Data == null || base64Data.isEmpty) return;

    try {
      final bytes = base64.decode(base64Data);
      final tempDir = await getTemporaryDirectory();
      final safeName = path.basename(_attachment.filename ?? 'document');
      // Use a uniquely-named file so concurrent opens don't collide and so the
      // OS can clean it up on its own. The file must not be deleted immediately
      // after share() returns because on Android the receiving app reads
      // through the FileProvider URI after the intent is dispatched.
      final uniqueName =
          '${path.basenameWithoutExtension(safeName)}_'
          '${DateTime.now().millisecondsSinceEpoch}'
          '${path.extension(safeName)}';
      final tempFile = File('${tempDir.path}/$uniqueName');
      await tempFile.writeAsBytes(bytes);
      await SharePlus.instance.share(
        ShareParams(files: [XFile(tempFile.path)]),
      );
    } catch (e, stackTrace) {
      AppLogger.instance.error(
        'Failed to open document',
        error: e,
        stackTrace: stackTrace,
        name: '_DocumentAttachmentWidget',
      );
    }
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
