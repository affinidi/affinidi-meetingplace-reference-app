import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../infrastructure/extensions/build_context_extensions.dart';
import '../../../themes/tokens/mc_radius.dart';

class ConciergeMessage extends StatelessWidget {
  const ConciergeMessage({
    super.key,
    required this._dateCreated,
    required this._message,
    this._backgroundColor,
    this._fullWidth = false,
    this._actions,
  });

  final DateTime _dateCreated;
  final String _message;
  final Color? _backgroundColor;
  final bool _fullWidth;
  final List<Widget>? _actions;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final localDate = _dateCreated.toLocal();
    final colorScheme = Theme.of(context).colorScheme;

    final hasActions = _actions != null && _actions.isNotEmpty;

    final textStyle = context.textTheme.bodyMedium?.copyWith(
      color: context.mcColors.textPrimary,
    );

    final headerStyle = hasActions
        ? textStyle?.copyWith(fontWeight: FontWeight.w400)
        : textStyle;

    final messageContent = Column(
      crossAxisAlignment: _fullWidth
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.stretch,
      mainAxisAlignment: _fullWidth
          ? MainAxisAlignment.center
          : MainAxisAlignment.start,
      children: [
        Text(
          hasActions
              ? l10n.genWordConciergeMessage
              : l10n.groupMessageInfo(
                  l10n.concierge,
                  DateFormat.MMMd().format(localDate),
                  DateFormat.jm().format(localDate),
                ),
          style: headerStyle,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Text(_message, textAlign: TextAlign.center, style: textStyle),
        if (hasActions) ...[
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: _actions,
            ),
          ),
        ],
      ],
    );

    Widget content = Padding(
      padding: EdgeInsets.symmetric(
        horizontal: _fullWidth ? 24 : 31,
        vertical: 16,
      ),
      child: messageContent,
    );

    if (hasActions) {
      content = Container(
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHigh,
          borderRadius: const BorderRadius.all(Radius.circular(McRadius.md)),
          border: Border.all(color: context.mcColors.hairline),
        ),
        child: content,
      );
    } else if (_backgroundColor != null) {
      content = Container(color: _backgroundColor, child: content);
    }

    return content;
  }
}
