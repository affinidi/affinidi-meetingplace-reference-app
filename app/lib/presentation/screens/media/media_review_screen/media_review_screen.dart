import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../infrastructure/configuration/environment.dart';
import '../../../../infrastructure/extensions/build_context_extensions.dart';
import '../../../../navigation/navigator.dart';
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

    if (context.mounted) navigator.pop(reviewResult);

    setState(() => _isSending = false);
  }

  @override
  Widget build(BuildContext context) {
    final customColors = context.customColors;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(child: ImagePreview(imageBytes: widget.imageBytes)),
          const Positioned.fill(child: _PreviewScrim()),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _ReviewActionButton(
                      icon: Icons.close,
                      backgroundColor: customColors.mediaSurfaceOverlay,
                      onPressed: _isSending
                          ? null
                          : () => _submitResult(success: false),
                    ),
                    if (_isSending)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 9,
                            ),
                            decoration: BoxDecoration(
                              color: customColors.mediaSurfaceOverlay,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: customColors.mediaSurfaceBorder,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const SizedBox.square(
                                  dimension: 14,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  context.l10n.sending,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(28),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                    child: Container(
                      decoration: BoxDecoration(
                        color: customColors.mediaSurfaceOverlay,
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(
                          color: customColors.mediaSurfaceBorder,
                        ),
                      ),
                      padding: const EdgeInsets.all(10),
                      child: Row(
                        mainAxisSize: widget.useChatSemantics
                            ? MainAxisSize.max
                            : MainAxisSize.min,
                        children: [
                          if (widget.useChatSemantics)
                            Expanded(
                              child: _MessageInput(
                                controller: _messageController,
                                isSending: _isSending,
                                onSend: () => _submitResult(success: true),
                              ),
                            ),
                          if (widget.useChatSemantics)
                            const SizedBox(width: 10),
                          if (_imageBytes != null)
                            _ReviewActionButton(
                              key: const Key('media_review_submit_button'),
                              icon: widget.useChatSemantics
                                  ? Icons.send_rounded
                                  : Icons.check_rounded,
                              backgroundColor: Theme.of(
                                context,
                              ).colorScheme.primary,
                              foregroundColor: Colors.white,
                              onPressed: _isSending
                                  ? null
                                  : () => _submitResult(success: true),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PreviewScrim extends StatelessWidget {
  const _PreviewScrim();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withValues(alpha: 0.58),
              Colors.transparent,
              Colors.black.withValues(alpha: 0.72),
            ],
            stops: const [0, 0.38, 1],
          ),
        ),
      ),
    );
  }
}

class _ReviewActionButton extends StatelessWidget {
  const _ReviewActionButton({
    super.key,
    required this.icon,
    required this.backgroundColor,
    required this.onPressed,
    this.foregroundColor = Colors.white,
  });

  final IconData icon;
  final Color backgroundColor;
  final Color foregroundColor;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: 52,
      child: Material(
        color: onPressed == null
            ? backgroundColor.withValues(alpha: 0.45)
            : backgroundColor,
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed,
          child: Icon(icon, color: foregroundColor, size: 28),
        ),
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
    final customColors = context.customColors;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: customColors.mediaSurfaceBorder),
      ),
      child: TextField(
        key: const Key('media_review_text_input'),
        controller: controller,
        maxLines: 3,
        minLines: 1,
        enabled: !isSending,
        style: const TextStyle(color: Colors.white),
        textInputAction: TextInputAction.send,
        onSubmitted: isSending ? null : (_) => onSend(),
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 11,
          ),
          hintMaxLines: 1,
          hintText: context.l10n.chatAddMessageToMediaPrompt,
          hintStyle: const TextStyle(fontSize: 14, color: Colors.white60),
          border: InputBorder.none,
        ),
      ),
    );
  }
}
