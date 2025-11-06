part of '../chat_screen.dart';

class UnknownChatItem extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Text(context.l10n.unknownType);
  }
}
