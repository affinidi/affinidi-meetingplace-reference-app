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
    final focusNode = useFocusNode();
    final inputDecoration = context.chatInputDecoration;
    final messageTextValue = useValueListenable(
      controller.messageTextController,
    );
    final hasMessageText = messageTextValue.text.isNotEmpty;
    final borderRadius = inputDecoration.border is OutlineInputBorder
        ? (inputDecoration.border as OutlineInputBorder).borderRadius
        : BorderRadius.circular(8.0);

    void showKeyboard() {
      if (!context.mounted) return;
      FocusScope.of(context).requestFocus(focusNode);
    }

    void sendChatActivity() {
      if (!context.mounted) return;
      controller.sendChatActivity();
    }

    void sendMessage() {
      if (!context.mounted) return;
      controller.sendMessage();
      showKeyboard();
    }

    void handleMediaSelection() =>
        _ChatMediaOptions.show(context: context, contactId: _contactId);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: _VoiceRecorder(
          controller: controller,
          shouldDisable: shouldDisable,
          hasMessageText: hasMessageText,
          onRequestKeyboard: showKeyboard,
          builder: (context, voice) => Row(
            spacing: 10,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              if (!voice.isVoiceMode)
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
                    child: const Icon(Icons.add, size: 25, color: Colors.white),
                    onTap: shouldDisable ? null : handleMediaSelection,
                  ),
                ),
              if (voice.isVoiceMode) ...[
                Container(
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: shouldDisable || voice.isBusy
                        ? context.theme.disabledColor
                        : context.colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                  child: InkWell(
                    key: const Key('chat_voice_delete_button'),
                    radius: 60,
                    onTap: shouldDisable || voice.isBusy ? null : voice.discard,
                    child: const Icon(
                      Icons.delete,
                      size: 25,
                      color: Colors.white,
                    ),
                  ),
                ),
                Expanded(
                  child: _VoiceInputPreview(
                    draft: voice.draft,
                    isRecording: voice.isRecording,
                    duration: voice.duration,
                    levels: voice.levels,
                    onStopRecording: voice.stopRecording,
                  ),
                ),
              ] else
                Expanded(
                  child: ClipRRect(
                    borderRadius: borderRadius,
                    child: TextFormField(
                      key: const Key('chat_message_input'),
                      enabled: !shouldDisable,
                      onChanged: shouldDisable
                          ? null
                          : (text) => sendChatActivity(),
                      textInputAction: TextInputAction.send,
                      focusNode: focusNode,
                      onEditingComplete:
                          (!kIsWeb &&
                              defaultTargetPlatform == TargetPlatform.iOS)
                          ? (shouldDisable ? null : sendMessage)
                          : null,
                      onFieldSubmitted:
                          (!kIsWeb &&
                              defaultTargetPlatform != TargetPlatform.iOS)
                          ? (shouldDisable ? null : (_) => sendMessage())
                          : null,
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
                            : context.l10n.chatTypeMessagePrompt(
                                otherPartyName ?? '',
                              ),
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
                  color: shouldDisable || voice.isBusy
                      ? context.theme.disabledColor
                      : context.colorScheme.primary,
                  shape: BoxShape.circle,
                ),
                child: InkWell(
                  key: const Key('chat_send_button'),
                  radius: 60,
                  onTap: shouldDisable || voice.isBusy
                      ? null
                      : voice.isVoiceMode
                      ? voice.send
                      : hasMessageText
                      ? sendMessage
                      : voice.startRecording,
                  child: Icon(
                    key: Key(
                      hasMessageText || voice.hasDraftOrRecording
                          ? 'chat_send_icon'
                          : 'chat_voice_record_icon',
                    ),
                    hasMessageText || voice.hasDraftOrRecording
                        ? Icons.send
                        : Icons.mic,
                    size: 25,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
