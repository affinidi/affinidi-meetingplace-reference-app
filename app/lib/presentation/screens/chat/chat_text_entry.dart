part of 'chat_screen.dart';

class _ChatTextEntry extends HookConsumerWidget {
  _ChatTextEntry({required String contactId}) : _contactId = contactId;

  final String _contactId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = chatScreenControllerProvider(_contactId);
    final controller = ref.read(provider.notifier);
    final otherPartyName = ref.watch(provider.otherPartyName);
    final isGroupChat = ref.watch(provider.isGroupChat);
    final shouldDisable = ref.watch(provider.shouldDisable);
    final inputDecoration = context.chatInputDecoration;
    final borderRadius = inputDecoration.border is OutlineInputBorder
        ? (inputDecoration.border as OutlineInputBorder).borderRadius
        : BorderRadius.circular(8.0);

    void sendChatActivity() {
      if (!context.mounted) return;
      controller.sendChatActivity();
    }

    void sendMessage() {
      if (!context.mounted) return;
      controller.sendMessage();
    }

    void handleMediaSelection() =>
        _ChatMediaOptions.show(context: context, contactId: _contactId);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Row(
          spacing: 10,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: shouldDisable
                    ? context.theme.disabledColor
                    : context.colorScheme.primary,
                shape: BoxShape.circle,
              ),
              child: InkWell(
                key: const Key('chat_add_media_button'),
                radius: 60,
                child: const Icon(
                  Icons.add,
                  size: 25,
                  color: Colors.white,
                ),
                onTap: shouldDisable ? null : handleMediaSelection,
              ),
            ),
            Expanded(
              child: ClipRRect(
                borderRadius: borderRadius,
                child: TextFormField(
                  key: const Key('chat_message_input'),
                  enabled: !shouldDisable,
                  onChanged:
                      shouldDisable ? null : (text) => sendChatActivity(),
                  textInputAction: TextInputAction.send,
                  onFieldSubmitted:
                      shouldDisable ? null : (value) => sendMessage(),
                  onEditingComplete: () {}, // prevent closing keyboard
                  keyboardType: TextInputType.text,
                  textCapitalization: TextCapitalization.sentences,
                  cursorHeight: 16,
                  style: const TextStyle(
                    overflow: TextOverflow.ellipsis,
                    fontSize: 14,
                    color: Colors.white,
                  ),
                  controller: controller.messageTextController,
                  maxLines: 3,
                  minLines: 1,
                  decoration: context.chatInputDecoration.copyWith(
                    hintText: isGroupChat
                        ? context.l10n.chatTypeMessagePromptGroup
                        : context.l10n
                            .chatTypeMessagePrompt(otherPartyName ?? ''),
                  ),
                  validator: MultiValidator([
                    ZalgoTextValidator(
                      errorText: context.l10n.zalgoTextDetectedError,
                    ),
                    MaxLengthValidator(
                      MaxLengthValidatorType.extraLong.value,
                      errorText: context.l10n.chatTooLong,
                    ),
                  ]).call,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: shouldDisable
                    ? context.theme.disabledColor
                    : context.colorScheme.primary,
                shape: BoxShape.circle,
              ),
              child: InkWell(
                key: const Key('chat_send_button'),
                radius: 60,
                onTap: shouldDisable ? null : sendMessage,
                child: const Icon(
                  Icons.send,
                  size: 25,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
