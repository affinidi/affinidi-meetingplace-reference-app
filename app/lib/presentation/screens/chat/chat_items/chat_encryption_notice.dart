import 'package:flutter/material.dart';
import '../../../../infrastructure/extensions/build_context_extensions.dart';

class ChatEncryptionNotice extends StatelessWidget {
  const ChatEncryptionNotice({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: _ChatEncryptionNoticeContent(),
    );
  }
}

class _ChatEncryptionNoticeContent extends StatelessWidget {
  const _ChatEncryptionNoticeContent();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textStyle = Theme.of(
      context,
    ).textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.lock, size: 16, color: colorScheme.onSurface),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            context.l10n.chatEncryptionNotice,
            textAlign: TextAlign.center,
            style: textStyle,
          ),
        ),
      ],
    );
  }
}
