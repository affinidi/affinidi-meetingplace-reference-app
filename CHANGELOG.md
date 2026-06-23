# Change Log

## 2026-06-23

## Highlights

This update adds major Matrix chat capabilities, introduces document sharing, and expands what users can do in chats and groups. It also includes a round of usability fixes across messages, profiles, voice notes, and verification flows.

## What You Will Notice

### New chat capabilities

- You can now delete messages in Matrix chats.
- Matrix chats support edited message labels, so it is easier to tell when something changed.
- Very long messages are handled more safely.
- Unread counts behave more predictably when you open a group chat.
- If a group has been deleted, the app now prevents you from continuing to type into that conversation.

### New group controls and group chat refinements

- Group typing indicators are more accurate when several people are active at once.
- Group owners can now remove members.
- Removing members is clearer and less awkward in the UI.
- Group member updates, including profile pictures and membership changes, appear more reliably.

### New attachments and media support

- Document attachments are now supported in Matrix chats.
- More file types are now supported when sharing attachments.
- Chat media actions and icons are more consistent.

### New reactions support and voice message fixes

- Chats now show your own reaction counts.
- Voice messages show sender profile avatar.

### Profile and card updates

- R-Card entries now include profile pictures.
- R-Card notes now respect safe areas on screen layouts that need them.
- Some connection and offer flows are more reliable and easier to complete.

### Verification flow updates

- ZKP messages are easier to understand.
- Requesters now see a dedicated message when a ZKP flow starts.
- Unsupported actions are hidden or limited more cleanly in chats where they do not apply.

## Behind The Scenes

- Matrix chat support was expanded and tightened across message actions and transport-specific behavior.
- Platform compatibility and dependency updates were made to support these changes more reliably.
- Additional automated test coverage was added around chat, attachments, profiles, and connection flows.


