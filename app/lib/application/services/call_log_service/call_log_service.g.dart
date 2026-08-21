// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'call_log_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Aggregates past calls across all contacts' chats for the Call log screen.
///
/// For each contact, resolves its chat via `getChannelByOtherPartyPermanentDid`
/// and `Chat.deriveId`, fetches its call-only messages via
/// `chat.ChatRepository.listMessagesByMediaKind`, filters to messages
/// carrying [CallMetadata] (`CallMetadata.isCall`), maps each to a
/// [CallLogEntry], and returns the combined list sorted most-recent-first.
/// Contacts whose channel or chat cannot be resolved are skipped, as are
/// contacts whose message history fails to load (logged, not rethrown), so
/// one bad chat cannot fail the whole Call log.

@ProviderFor(callLogEntries)
const callLogEntriesProvider = CallLogEntriesProvider._();

/// Aggregates past calls across all contacts' chats for the Call log screen.
///
/// For each contact, resolves its chat via `getChannelByOtherPartyPermanentDid`
/// and `Chat.deriveId`, fetches its call-only messages via
/// `chat.ChatRepository.listMessagesByMediaKind`, filters to messages
/// carrying [CallMetadata] (`CallMetadata.isCall`), maps each to a
/// [CallLogEntry], and returns the combined list sorted most-recent-first.
/// Contacts whose channel or chat cannot be resolved are skipped, as are
/// contacts whose message history fails to load (logged, not rethrown), so
/// one bad chat cannot fail the whole Call log.

final class CallLogEntriesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<CallLogEntry>>,
          List<CallLogEntry>,
          FutureOr<List<CallLogEntry>>
        >
    with
        $FutureModifier<List<CallLogEntry>>,
        $FutureProvider<List<CallLogEntry>> {
  /// Aggregates past calls across all contacts' chats for the Call log screen.
  ///
  /// For each contact, resolves its chat via `getChannelByOtherPartyPermanentDid`
  /// and `Chat.deriveId`, fetches its call-only messages via
  /// `chat.ChatRepository.listMessagesByMediaKind`, filters to messages
  /// carrying [CallMetadata] (`CallMetadata.isCall`), maps each to a
  /// [CallLogEntry], and returns the combined list sorted most-recent-first.
  /// Contacts whose channel or chat cannot be resolved are skipped, as are
  /// contacts whose message history fails to load (logged, not rethrown), so
  /// one bad chat cannot fail the whole Call log.
  const CallLogEntriesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'callLogEntriesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$callLogEntriesHash();

  @$internal
  @override
  $FutureProviderElement<List<CallLogEntry>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<CallLogEntry>> create(Ref ref) {
    return callLogEntries(ref);
  }
}

String _$callLogEntriesHash() => r'f333079ccdb64a5d564b86d68bccb5da54ee710f';
