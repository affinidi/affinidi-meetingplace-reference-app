import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:mpx_app_core/mpx_app_core.dart';

/// Chat action that picks a document file and sends a
/// `cierge/sign-document-request` message with the file content.
final class SignDocumentPlugin implements AttachmentPicker {
  SignDocumentPlugin({required this.filePickerPlatform});

  final FilePickerPlatform filePickerPlatform;

  static const _allowedExtensions = ['pdf', 'doc', 'docx', 'txt'];

  @override
  AttachmentPluginIcon get icon => const MaterialIcon(Icons.draw_outlined);

  @override
  String localizedName(BuildContext context) => 'Sign Document';

  @override
  bool get isPlatformSupported => true;

  @override
  bool get includeInMediaOptions => true;

  @override
  bool get dismissSheetBeforePicking => true;

  @override
  Future<AttachmentPluginPickResult?> pickAttachments(
    AttachmentPickRequest request,
  ) async {
    final result = await filePickerPlatform.pickFiles(
      type: FileType.custom,
      allowedExtensions: _allowedExtensions,
    );

    if (result == null || result.files.isEmpty) return null;

    final file = result.files.first;
    final filePath = file.path;
    if (filePath == null) return null;

    final bytes = await File(filePath).readAsBytes();
    final content = base64Encode(bytes);

    final payload = jsonEncode({
      'type': CiergeSignDocumentRequest.messageType,
      'document': {
        'title': file.name,
        'content': content,
        'mediaType': _mimeType(file.extension),
      },
    });

    return AttachmentPluginPickResult(text: payload, attachments: []);
  }

  String _mimeType(String? ext) => switch (ext?.toLowerCase()) {
    'pdf' => 'application/pdf',
    'doc' => 'application/msword',
    'docx' =>
      'application/vnd.openxmlformats-officedocument'
          '.wordprocessingml.document',
    'txt' => 'text/plain',
    _ => 'application/octet-stream',
  };
}
