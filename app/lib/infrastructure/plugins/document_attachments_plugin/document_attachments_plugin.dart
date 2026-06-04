import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:mpx_app_core/mpx_app_core.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../infrastructure/configuration/environment.dart';
import '../../../infrastructure/extensions/build_context_extensions.dart';
import '../../../infrastructure/loggers/app_logger/app_logger.dart';
import '../attachment_plugin_cache.dart';
import 'document_attachment.dart';

/// A plugin for handling document file attachments.
final class DocumentAttachmentsPlugin implements AttachmentPlugin {
  DocumentAttachmentsPlugin({required this._cacheManager});

  static const pluginName = 'mpx_document_attachment_plugin';

  final BaseCacheManager _cacheManager;

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

    final filePath = file.path;
    if (filePath == null) return null;
    final bytes = await File(filePath).readAsBytes();

    final base64Data = base64.encode(bytes);
    final mimeType =
        _mimeTypeFromExtension(file.extension) ?? 'application/octet-stream';

    return AttachmentPluginPickResult(
      text: '',
      attachments: [
        DocumentAttachment(
          base64: base64Data,
          pluginName: pluginName,
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
    Future<Uint8List> Function(ChatAttachment)? download,
  }) => _DocumentAttachmentWidget(
    attachment: attachment,
    cacheManager: _cacheManager,
    download: download,
  );

  @override
  Widget renderAttachments({
    required List<ChatAttachment> attachments,
    required bool isFromMe,
    required Color chatItemColor,
    Future<Uint8List> Function(ChatAttachment)? download,
  }) => _ListDocumentAttachmentsWidget(
    attachments: attachments,
    cacheManager: _cacheManager,
    download: download,
  );

  @override
  bool supportsFormat(ChatAttachment attachment) =>
      attachment.format == pluginName;

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

class _ListDocumentAttachmentsWidget extends StatelessWidget {
  const _ListDocumentAttachmentsWidget({
    required this._attachments,
    required this._cacheManager,
    this._download,
  });

  final List<ChatAttachment> _attachments;
  final BaseCacheManager _cacheManager;
  final Future<Uint8List> Function(ChatAttachment)? _download;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: _attachments.length,
      itemBuilder: (context, index) => _DocumentAttachmentWidget(
        attachment: _attachments[index],
        cacheManager: _cacheManager,
        download: _download,
      ),
    );
  }
}

class _DocumentAttachmentWidget extends StatefulWidget {
  const _DocumentAttachmentWidget({
    required this.attachment,
    required this.cacheManager,
    this.download,
  });

  final ChatAttachment attachment;
  final BaseCacheManager cacheManager;
  final Future<Uint8List> Function(ChatAttachment)? download;

  @override
  State<_DocumentAttachmentWidget> createState() =>
      _DocumentAttachmentWidgetState();
}

class _DocumentAttachmentWidgetState extends State<_DocumentAttachmentWidget> {
  Uint8List? _bytes;
  bool _isDownloading = false;
  bool _hasFailed = false;

  @override
  void initState() {
    super.initState();
    final base64Data = widget.attachment.data?.base64;
    if (base64Data != null) {
      try {
        _bytes = base64.decode(base64Data);
      } catch (_) {}
      return;
    }
    unawaited(_loadFromDiskCache());
  }

  Future<void> _loadFromDiskCache() async {
    final cachedBytes = await readCachedAttachmentBytes(
      widget.cacheManager,
      widget.attachment,
    );
    if (cachedBytes == null || !mounted) return;
    setState(() => _bytes = cachedBytes);
  }

  Future<void> _download() async {
    if (_isDownloading || _bytes != null) return;

    final downloadFn = widget.download;
    if (downloadFn == null) return;

    setState(() {
      _isDownloading = true;
      _hasFailed = false;
    });

    try {
      final bytes = await downloadAndCacheAttachmentBytes(
        cacheManager: widget.cacheManager,
        attachment: widget.attachment,
        download: downloadFn,
      );
      if (!mounted) return;
      if (bytes.isEmpty) {
        setState(() {
          _isDownloading = false;
          _hasFailed = true;
        });
        return;
      }
      setState(() {
        _bytes = bytes;
        _isDownloading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isDownloading = false;
        _hasFailed = true;
      });
    }
  }

  Future<void> _openDocument() async {
    final bytes = _bytes;
    if (bytes == null) return;

    try {
      final tempDir = await getTemporaryDirectory();
      final safeName = path.basename(widget.attachment.filename ?? 'document');
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
        name: 'DocumentAttachmentsPlugin',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final filename = widget.attachment.filename ?? 'Document';
    final size = widget.attachment.byteCount;
    final sizeLabel = size != null ? _formatBytes(size) : '';
    final isLoaded = _bytes != null;

    return SizedBox(
      width: 220,
      child: GestureDetector(
        onTap: isLoaded
            ? _openDocument
            : (_hasFailed ? _download : (_isDownloading ? null : _download)),
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
                Icon(
                  _iconForMimeType(widget.attachment.mediaType),
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
                      if (!isLoaded && !_hasFailed)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            _isDownloading
                                ? context.l10n.loading
                                : context.l10n.documentTapToDownload,
                            style: const TextStyle(
                              color: Colors.white38,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      if (_hasFailed)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            context.l10n.mediaDownloadFailedTapToRetry,
                            style: const TextStyle(
                              color: Colors.redAccent,
                              fontSize: 10,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                if (!isLoaded && !_hasFailed)
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: _isDownloading
                        ? const CircularProgressIndicator(strokeWidth: 2)
                        : const Icon(
                            Icons.download,
                            color: Colors.white54,
                            size: 16,
                          ),
                  ),
                if (_hasFailed)
                  const Icon(
                    Icons.error_outline,
                    color: Colors.redAccent,
                    size: 16,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _iconForMimeType(String? mimeType) {
    if (mimeType == null) return Icons.insert_drive_file;
    if (mimeType.contains('pdf')) return Icons.picture_as_pdf;
    if (mimeType.contains('word') || mimeType.contains('doc')) {
      return Icons.description;
    }
    if (mimeType.contains('sheet') ||
        mimeType.contains('excel') ||
        mimeType.contains('csv')) {
      return Icons.table_chart;
    }
    if (mimeType.contains('presentation') || mimeType.contains('powerpoint')) {
      return Icons.slideshow;
    }
    if (mimeType.contains('zip') ||
        mimeType.contains('tar') ||
        mimeType.contains('gz')) {
      return Icons.folder_zip;
    }
    if (mimeType.contains('text/')) return Icons.article;
    return Icons.insert_drive_file;
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
