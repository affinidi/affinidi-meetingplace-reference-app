import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../infrastructure/extensions/build_context_extensions.dart';

class ConciergeMessage extends StatelessWidget {
  const ConciergeMessage({
    super.key,
    required DateTime dateCreated,
    required String message,
    Color? backgroundColor,
    bool fullWidth = false,
  }) : _dateCreated = dateCreated,
       _message = message,
       _backgroundColor = backgroundColor,
       _fullWidth = fullWidth;

  final DateTime _dateCreated;
  final String _message;
  final Color? _backgroundColor;
  final bool _fullWidth;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final localDate = _dateCreated.toLocal();
    final colorScheme = Theme.of(context).colorScheme;
    final textStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(
      color: colorScheme.onSurface,
    );

    final content = Padding(
      padding: EdgeInsets.symmetric(
        horizontal: _fullWidth ? 0 : 20,
        vertical: 12,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.groupMessageInfo(
              l10n.concierge,
              DateFormat.MMMd().format(localDate),
              DateFormat.jm().format(localDate),
            ),
            style: textStyle?.copyWith(fontSize: 12),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            _message,
            textAlign: TextAlign.center,
            style: textStyle,
          ),
        ],
      ),
    );

    if (_backgroundColor != null) {
      return Container(
        color: _backgroundColor,
        child: content,
      );
    }

    return content;
  }
}
