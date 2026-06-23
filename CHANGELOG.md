# Change Log

## 2026-06-23

## Highlights

This update improves chat reliability, group conversations, attachments, and profile-related experiences, with the biggest gains landing in Matrix-based chats.

## What You Will Notice

### Better chat experience

- You can now delete messages in Matrix chats.
- Edited messages are shown more clearly, so it is easier to tell when something changed.
- Very long messages are handled more safely.
- Unread counts behave more predictably when you open a group chat.
- If a group has been deleted, the app now prevents you from continuing to type into that conversation.

### Smoother group conversations

- Group typing indicators are more accurate when several people are active at once.
- Group owners can now remove members.
- Removing members is clearer and less awkward in the UI.
- Group member updates, including profile pictures and membership changes, appear more reliably.

### Improved attachments and media

- Document attachments are now supported in Matrix chats.
- More file types are recognized correctly when sharing attachments.
- Chat media actions and icons are more consistent.

### Better reactions and voice messages

- Reaction counts are clearer, including your own reactions.
- Voice messages show sender profile avatar.

### Better profile and card details

- R-Card entries now show profile pictures more consistently.
- R-Card notes display better on screen layouts with safe areas.
- Some connection and offer flows are more reliable and easier to complete.

### Clearer verification flow

- ZKP messages are easier to understand.
- Requesters now see a clearer message when a ZKP flow starts.
- Unsupported actions are hidden or limited more cleanly in chats where they do not apply.

## Behind The Scenes

- Matrix chat support was expanded and tightened across message actions and transport-specific behavior.
- Platform compatibility and dependency updates were made to support these changes more reliably.
- Additional automated test coverage was added around chat, attachments, profiles, and connection flows.


