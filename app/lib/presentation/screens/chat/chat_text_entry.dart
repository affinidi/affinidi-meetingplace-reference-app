part of 'chat_screen.dart';

class _ChatTextEntry extends HookConsumerWidget {
  _ChatTextEntry({required this._contactId});

  final String _contactId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = chatScreenControllerProvider(_contactId);
    final controller = ref.read(provider.notifier);
    final routingState = ref.watch(contextRoutingServiceProvider);
    final contactsState = ref.watch(contactsServiceProvider);
    final contact = ref.watch(
      contactsServiceProvider.select(
        (state) => state.getContactById(_contactId),
      ),
    );

    AgentContext inferredDefaultContext() {
      final mapped = routingState.contactContexts[_contactId];
      if (mapped != null) return mapped;

      if (contact == null) return AgentContext.personal;
      final isAiContact =
          contact.category == ContactCategory.robot ||
          contact.card.type.trim().toLowerCase() == 'ai-agent';
      if (!isAiContact) return AgentContext.personal;

      final label = [
        contact.displayName ?? '',
        contact.card.displayName,
        contact.card.firstName,
      ].join(' ').toLowerCase();
      if (label.contains('work')) return AgentContext.work;
      if (label.contains('personal')) return AgentContext.personal;

      final aiContacts =
          contactsState.contacts
              .where(
                (c) =>
                    c.category == ContactCategory.robot ||
                    c.card.type.trim().toLowerCase() == 'ai-agent',
              )
              .toList()
            ..sort((a, b) => a.id.compareTo(b.id));
      if (aiContacts.length >= 2) {
        final idx = aiContacts.indexWhere((c) => c.id == contact.id);
        if (idx == 0) return AgentContext.work;
        if (idx == 1) return AgentContext.personal;
      }

      return AgentContext.personal;
    }

    final activeContext = inferredDefaultContext();

    useEffect(
      () {
        final mapped = routingState.contactContexts[_contactId];
        if (mapped != null || contact == null) {
          return null;
        }

        final isAiContact =
            contact.category == ContactCategory.robot ||
            contact.card.type.trim().toLowerCase() == 'ai-agent';
        if (!isAiContact) {
          return null;
        }

        Future.microtask(() {
          ref
              .read<ContextRoutingService>(
                contextRoutingServiceProvider.notifier,
              )
              .assignContactContext(_contactId, activeContext);
        });
        return null;
      },
      [
        _contactId,
        contact?.id,
        contact?.displayName,
        contact?.card.displayName,
        contact?.card.type,
        routingState.contactContexts[_contactId],
      ],
    );
    final otherPartyName = ref.watch(provider.otherPartyName);
    final isGroupChat = ref.watch(provider.isGroupChat);
    final shouldDisable = ref.watch(provider.shouldDisable);
    final supportsMedia = ref.watch(provider.supportsMedia);
    final supportsVoiceMessages = ref.watch(provider.supportsVoiceMessages);
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

    void handleEffectSelection() =>
        _ChatEffectOptions.show(context: context, contactId: _contactId);

    final inputBorder = OutlineInputBorder(
      borderSide: BorderSide(color: context.colorScheme.primary, width: 1),
      borderRadius: BorderRadius.circular(32.0),
    );
    final inputTextStyle = context.textTheme.bodyLarge?.copyWith(
      overflow: TextOverflow.ellipsis,
      color: context.colorScheme.onSurface,
    );

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _VoiceRecorder(
              controller: controller,
              shouldDisable: shouldDisable,
              hasMessageText: hasMessageText,
              onRequestKeyboard: showKeyboard,
              builder: (context, voice) => Row(
                spacing: 10,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  if (!voice.isVoiceMode && supportsMedia)
                    Material(
                      color: shouldDisable
                          ? context.theme.disabledColor
                          : context.colorScheme.primary,
                      shape: const CircleBorder(),
                      child: InkWell(
                        key: const Key('chat_add_media_button'),
                        onTap: shouldDisable ? null : handleMediaSelection,
                        customBorder: const CircleBorder(),
                        child: SizedBox.square(
                          dimension: 50,
                          child: Icon(
                            Icons.add,
                            size: 30,
                            color: context.colorScheme.onPrimary,
                          ),
                        ),
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
                        onTap: shouldDisable || voice.isBusy
                            ? null
                            : voice.discard,
                        child: Icon(
                          Icons.delete,
                          size: 25,
                          color: context.colorScheme.onPrimary,
                        ),
                      ),
                    ),
                    Expanded(
                      child: _VoiceInputPreview(
                        contactId: _contactId,
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
                          cursorHeight: 22,
                          style: inputTextStyle,
                          controller: controller.messageTextController,
                          maxLines: 3,
                          minLines: 1,
                          decoration: context.chatInputDecoration.copyWith(
                            isDense: true,
                            enabledBorder: inputBorder,
                            focusedBorder: inputBorder,
                            border: inputBorder,
                            contentPadding: const EdgeInsets.only(
                              left: 16,
                              top: 10,
                              bottom: 10,
                            ),
                            hintStyle: inputTextStyle?.copyWith(
                              color: context.colorScheme.onSurface.withValues(
                                alpha: 0.70,
                              ),
                            ),
                            hintText: isGroupChat
                                ? context.l10n.chatTypeMessagePromptGroup
                                : context.l10n.chatTypeMessagePrompt(
                                    otherPartyName ?? '',
                                  ),
                            suffixIcon: SizedBox(
                              width: 36,
                              child: Padding(
                                padding: const EdgeInsets.only(right: 6),
                                child: Center(
                                  child: Material(
                                    color: shouldDisable
                                        ? context.theme.disabledColor
                                        : context.colorScheme.primary,
                                    borderRadius: BorderRadius.circular(4),
                                    child: InkWell(
                                      key: const Key('chat_gif_button'),
                                      onTap: shouldDisable
                                          ? null
                                          : handleEffectSelection,
                                      borderRadius: BorderRadius.circular(4),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 4,
                                        ),
                                        child: Text(
                                          'GIF',
                                          style: TextStyle(
                                            color: context.colorScheme.surface,
                                            fontSize: 8,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
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
                  InkWell(
                    key: const Key('chat_send_button'),
                    radius: 30,
                    onTap: shouldDisable || voice.isBusy
                        ? null
                        : voice.isVoiceMode
                        ? voice.send
                        : hasMessageText
                        ? sendMessage
                        : supportsVoiceMessages
                        ? voice.startRecording
                        : null,
                    child: Padding(
                      padding: const EdgeInsets.all(6.0),
                      child: Icon(
                        key: Key(
                          hasMessageText || voice.hasDraftOrRecording
                              ? 'chat_send_icon'
                              : supportsVoiceMessages
                              ? 'chat_voice_record_icon'
                              : 'chat_send_icon',
                        ),
                        hasMessageText || voice.hasDraftOrRecording
                            ? Icons.send
                            : supportsVoiceMessages
                            ? Icons.mic
                            : Icons.send,
                        size: 40,
                        color: shouldDisable || voice.isBusy
                            ? context.theme.disabledColor
                            : context.colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
