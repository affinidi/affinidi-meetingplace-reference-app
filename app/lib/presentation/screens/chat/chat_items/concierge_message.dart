import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../infrastructure/extensions/build_context_extensions.dart';

class ConciergeMessage extends StatelessWidget {
  const ConciergeMessage({
    super.key,
    required DateTime dateCreated,
    required String message,
  })  : _dateCreated = dateCreated,
        _message = message;

  final DateTime _dateCreated;
  final String _message;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final localDate = _dateCreated.toLocal();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.groupMessageInfo(
            l10n.concierge,
            DateFormat.MMMd().format(localDate),
            DateFormat.jm().format(localDate),
          ),
          style: const TextStyle(color: Colors.grey, fontSize: 12),
          textAlign: TextAlign.center,
        ),
        Text(
          _message,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
