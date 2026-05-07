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
    List<Widget>? actions,
  }) : _dateCreated = dateCreated,
       _message = message,
       _backgroundColor = backgroundColor,
       _fullWidth = fullWidth,
       _actions = actions;

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

    final textStyle = hasActions
        ? const TextStyle(color: Colors.white, fontSize: 14)
        : Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface);

    final headerStyle = hasActions
        ? const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w400,
          )
        : textStyle?.copyWith(fontSize: 14);

    final messageContent = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
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
        Text(_message, textAlign: TextAlign.left, style: textStyle),
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
        horizontal: _fullWidth ? 0 : 31,
        vertical: 16,
      ),
      child: messageContent,
    );

    if (hasActions) {
      content = Container(
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          gradient: RadialGradient(
            center: Alignment.bottomCenter,
            radius: 2,
            colors: [
              Color.fromARGB(255, 76, 76, 76),
              Color.fromARGB(255, 31, 31, 31),
            ],
          ),
        ),
        child: content,
      );
    } else if (_backgroundColor != null) {
      content = Container(color: _backgroundColor, child: content);
    }

    return content;
  }
}
