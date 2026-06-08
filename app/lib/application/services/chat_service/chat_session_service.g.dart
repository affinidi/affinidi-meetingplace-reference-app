// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_session_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ChatSessionService)
final chatSessionServiceProvider = ChatSessionServiceFamily._();

final class ChatSessionServiceProvider
    extends $NotifierProvider<ChatSessionService, ChatServiceState> {
  ChatSessionServiceProvider._({
    required ChatSessionServiceFamily super.from,
    required (
      String, {
      void Function(StreamData data, String channelDid)? onZkpAttachment,
    })
    super.argument,
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
        '$argument';
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
    r'cef9cbcdf00139a54b151a7f1641b6cbc0a39b32';

final class ChatSessionServiceFamily extends $Family
    with
        $ClassFamilyOverride<
          ChatSessionService,
          ChatServiceState,
          ChatServiceState,
          ChatServiceState,
          (
            String, {
            void Function(StreamData data, String channelDid)? onZkpAttachment,
          })
        > {
  ChatSessionServiceFamily._()
    : super(
        retry: null,
        name: r'chatSessionServiceProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ChatSessionServiceProvider call(
    String channelDid, {
    void Function(StreamData data, String channelDid)? onZkpAttachment,
  }) => ChatSessionServiceProvider._(
    argument: (channelDid, onZkpAttachment: onZkpAttachment),
    from: this,
  );

  @override
  String toString() => r'chatSessionServiceProvider';
}

abstract class _$ChatSessionService extends $Notifier<ChatServiceState> {
  late final _$args =
      ref.$arg
          as (
            String, {
            void Function(StreamData data, String channelDid)? onZkpAttachment,
          });
  String get channelDid => _$args.$1;
  void Function(StreamData data, String channelDid)? get onZkpAttachment =>
      _$args.onZkpAttachment;

  ChatServiceState build(
    String channelDid, {
    void Function(StreamData data, String channelDid)? onZkpAttachment,
  });
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<ChatServiceState, ChatServiceState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ChatServiceState, ChatServiceState>,
              ChatServiceState,
              Object?,
              Object?
            >;
    element.handleCreate(
      ref,
      () => build(_$args.$1, onZkpAttachment: _$args.onZkpAttachment),
    );
  }
}
