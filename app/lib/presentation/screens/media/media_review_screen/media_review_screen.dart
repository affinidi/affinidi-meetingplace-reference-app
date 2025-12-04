// ignore_for_file: avoid_print

import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../infrastructure/configuration/environment.dart';
import '../../../../infrastructure/extensions/build_context_extensions.dart';
import '../../../../navigation/navigator.dart';
import '../bottom_media_bar.dart';
import '../image_preview.dart';
import '../media_screen/media_screen.dart';
import 'media_review_controller.dart';

class MediaReviewScreen extends ConsumerStatefulWidget {
  const MediaReviewScreen({
    super.key,
    this.useChatSemantics = false,
    required this.imageBytes,
    this.messageText,
  });

  final bool useChatSemantics;
  final Uint8List? imageBytes;
  final String? messageText;

  @override
  ConsumerState<MediaReviewScreen> createState() => _MediaReviewScreenState();
}

class _MediaReviewScreenState extends ConsumerState<MediaReviewScreen> {
  late final Uint8List? _imageBytes;
  late final TextEditingController _messageController;
  bool _isSending = false;
  late final controller = ref.read(mediaReviewControllerProvider.notifier);

  @override
  void initState() {
    super.initState();
    _imageBytes = widget.imageBytes;
    _messageController = TextEditingController(text: widget.messageText);
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _submitResult({required bool success}) async {
    final navigator = ref.read(navigatorProvider);
    if (_imageBytes == null) {
      navigator.pop(MediaReviewResult.empty());
      return;
    }

    setState(() => _isSending = true);

    final environment = ref.read(environmentProvider);
    final reviewResult = await controller.submitResult(
      bytes: _imageBytes,
      success: success,
      message: _messageController.text,
      imageConfig: widget.useChatSemantics
          ? environment.chatImageConfig
          : environment.profileImageConfig,
    );

    print('XXX: MediaReviewScreen submitResult completed');
    if (context.mounted) navigator.pop(reviewResult);

    setState(() => _isSending = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: ImagePreview(imageBytes: widget.imageBytes),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: BottomMediaBar(
              children: [
                if (widget.useChatSemantics)
                  Expanded(
                    child: _MessageInput(
                      controller: _messageController,
                      isSending: _isSending,
                      onSend: () => _submitResult(success: true),
                    ),
                  )
                else
                  const Spacer(),
                if (widget.useChatSemantics) const SizedBox(width: 10),
                FloatingActionButton(
                  heroTag: 2,
                  backgroundColor: Colors.red,
                  onPressed: () => _submitResult(success: false),
                  child: const Icon(Icons.cancel_sharp,
                      size: 35, color: Colors.white),
                ),
                const SizedBox(width: 10),
                if (_imageBytes != null)
                  FloatingActionButton(
                    key: const Key('media_review_submit_button'),
                    heroTag: 1,
                    backgroundColor: Colors.green,
                    onPressed:
                        _isSending ? null : () => _submitResult(success: true),
                    child: Icon(
                      widget.useChatSemantics ? Icons.send : Icons.done,
                      size: 35,
                      color: Colors.white,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageInput extends StatelessWidget {
  const _MessageInput({
    required this.controller,
    required this.isSending,
    required this.onSend,
  });

  final TextEditingController controller;
  final bool isSending;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 49, 49, 51),
        borderRadius: BorderRadius.circular(20),
      ),
      child: TextField(
        key: const Key('media_review_text_input'),
        controller: controller,
        maxLines: 3,
        minLines: 1,
        style: const TextStyle(color: Colors.white),
        textInputAction: TextInputAction.send,
        onSubmitted: isSending ? null : (_) => onSend(),
        decoration: InputDecoration(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          hintMaxLines: 1,
          hintText: context.l10n.chatAddMessageToMediaPrompt,
          hintStyle: const TextStyle(fontSize: 14, color: Colors.grey),
          border: InputBorder.none,
        ),
      ),
    );
  }
}
