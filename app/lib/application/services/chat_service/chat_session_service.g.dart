// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_session_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$chatSessionServiceHash() =>
    r'72c534bfe68edaecd2c941047e25faed49a2adb7';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

abstract class _$ChatSessionService
    extends BuildlessAutoDisposeNotifier<ChatServiceState> {
  late final String channelDid;

  ChatServiceState build(String channelDid);
}

/// See also [ChatSessionService].
@ProviderFor(ChatSessionService)
const chatSessionServiceProvider = ChatSessionServiceFamily();

/// See also [ChatSessionService].
class ChatSessionServiceFamily extends Family<ChatServiceState> {
  /// See also [ChatSessionService].
  const ChatSessionServiceFamily();

  /// See also [ChatSessionService].
  ChatSessionServiceProvider call(String channelDid) {
    return ChatSessionServiceProvider(channelDid);
  }

  @override
  ChatSessionServiceProvider getProviderOverride(
    covariant ChatSessionServiceProvider provider,
  ) {
    return call(provider.channelDid);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'chatSessionServiceProvider';
}

/// See also [ChatSessionService].
class ChatSessionServiceProvider
    extends
        AutoDisposeNotifierProviderImpl<ChatSessionService, ChatServiceState> {
  /// See also [ChatSessionService].
  ChatSessionServiceProvider(String channelDid)
    : this._internal(
        () => ChatSessionService()..channelDid = channelDid,
        from: chatSessionServiceProvider,
        name: r'chatSessionServiceProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$chatSessionServiceHash,
        dependencies: ChatSessionServiceFamily._dependencies,
        allTransitiveDependencies:
            ChatSessionServiceFamily._allTransitiveDependencies,
        channelDid: channelDid,
      );

  ChatSessionServiceProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.channelDid,
  }) : super.internal();

  final String channelDid;

  @override
  ChatServiceState runNotifierBuild(covariant ChatSessionService notifier) {
    return notifier.build(channelDid);
  }

  @override
  Override overrideWith(ChatSessionService Function() create) {
    return ProviderOverride(
      origin: this,
      override: ChatSessionServiceProvider._internal(
        () => create()..channelDid = channelDid,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        channelDid: channelDid,
      ),
    );
  }

  @override
  AutoDisposeNotifierProviderElement<ChatSessionService, ChatServiceState>
  createElement() {
    return _ChatSessionServiceProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ChatSessionServiceProvider &&
        other.channelDid == channelDid;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, channelDid.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ChatSessionServiceRef
    on AutoDisposeNotifierProviderRef<ChatServiceState> {
  /// The parameter `channelDid` of this provider.
  String get channelDid;
}

class _ChatSessionServiceProviderElement
    extends
        AutoDisposeNotifierProviderElement<ChatSessionService, ChatServiceState>
    with ChatSessionServiceRef {
  _ChatSessionServiceProviderElement(super.provider);

  @override
  String get channelDid => (origin as ChatSessionServiceProvider).channelDid;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
