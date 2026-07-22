// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_session_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ChatSessionService)
const chatSessionServiceProvider = ChatSessionServiceFamily._();

final class ChatSessionServiceProvider
    extends $NotifierProvider<ChatSessionService, ChatServiceState> {
  const ChatSessionServiceProvider._({
    required ChatSessionServiceFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'chatSessionServiceProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$chatSessionServiceHash();

  @override
  String toString() {
    return r'chatSessionServiceProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  ChatSessionService create() => ChatSessionService();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ChatServiceState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ChatServiceState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ChatSessionServiceProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$chatSessionServiceHash() =>
    r'00ed6acbd2837ec957ea181b6bf5f57683315b30';

final class ChatSessionServiceFamily extends $Family
    with
        $ClassFamilyOverride<
          ChatSessionService,
          ChatServiceState,
          ChatServiceState,
          ChatServiceState,
          String
        > {
  const ChatSessionServiceFamily._()
    : super(
        retry: null,
        name: r'chatSessionServiceProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ChatSessionServiceProvider call(String channelDid) =>
      ChatSessionServiceProvider._(argument: channelDid, from: this);

  @override
  String toString() => r'chatSessionServiceProvider';
}

abstract class _$ChatSessionService extends $Notifier<ChatServiceState> {
  late final _$args = ref.$arg as String;
  String get channelDid => _$args;

  ChatServiceState build(String channelDid);
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(_$args);
    final ref = this.ref as $Ref<ChatServiceState, ChatServiceState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ChatServiceState, ChatServiceState>,
              ChatServiceState,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
