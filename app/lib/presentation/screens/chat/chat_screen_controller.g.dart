// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_screen_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$chatScreenControllerHash() =>
    r'4cb64e7789342173db4a8cc2405b1f5b4b0f4533';

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

abstract class _$ChatScreenController
    extends BuildlessAutoDisposeNotifier<ChatScreenState> {
  late final String contactId;

  ChatScreenState build(String contactId);
}

/// Controller class for managing the state and logic of the chat screen.
///
/// Extends [_$ChatScreenController] to provide reactive state management
/// and business logic for chat-related features, such as handling messages,
/// user interactions, and UI updates within the chat screen.
///
/// Copied from [ChatScreenController].
@ProviderFor(ChatScreenController)
const chatScreenControllerProvider = ChatScreenControllerFamily();

/// Controller class for managing the state and logic of the chat screen.
///
/// Extends [_$ChatScreenController] to provide reactive state management
/// and business logic for chat-related features, such as handling messages,
/// user interactions, and UI updates within the chat screen.
///
/// Copied from [ChatScreenController].
class ChatScreenControllerFamily extends Family<ChatScreenState> {
  /// Controller class for managing the state and logic of the chat screen.
  ///
  /// Extends [_$ChatScreenController] to provide reactive state management
  /// and business logic for chat-related features, such as handling messages,
  /// user interactions, and UI updates within the chat screen.
  ///
  /// Copied from [ChatScreenController].
  const ChatScreenControllerFamily();

  /// Controller class for managing the state and logic of the chat screen.
  ///
  /// Extends [_$ChatScreenController] to provide reactive state management
  /// and business logic for chat-related features, such as handling messages,
  /// user interactions, and UI updates within the chat screen.
  ///
  /// Copied from [ChatScreenController].
  ChatScreenControllerProvider call(String contactId) {
    return ChatScreenControllerProvider(contactId);
  }

  @override
  ChatScreenControllerProvider getProviderOverride(
    covariant ChatScreenControllerProvider provider,
  ) {
    return call(provider.contactId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'chatScreenControllerProvider';
}

/// Controller class for managing the state and logic of the chat screen.
///
/// Extends [_$ChatScreenController] to provide reactive state management
/// and business logic for chat-related features, such as handling messages,
/// user interactions, and UI updates within the chat screen.
///
/// Copied from [ChatScreenController].
class ChatScreenControllerProvider
    extends
        AutoDisposeNotifierProviderImpl<ChatScreenController, ChatScreenState> {
  /// Controller class for managing the state and logic of the chat screen.
  ///
  /// Extends [_$ChatScreenController] to provide reactive state management
  /// and business logic for chat-related features, such as handling messages,
  /// user interactions, and UI updates within the chat screen.
  ///
  /// Copied from [ChatScreenController].
  ChatScreenControllerProvider(String contactId)
    : this._internal(
        () => ChatScreenController()..contactId = contactId,
        from: chatScreenControllerProvider,
        name: r'chatScreenControllerProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$chatScreenControllerHash,
        dependencies: ChatScreenControllerFamily._dependencies,
        allTransitiveDependencies:
            ChatScreenControllerFamily._allTransitiveDependencies,
        contactId: contactId,
      );

  ChatScreenControllerProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.contactId,
  }) : super.internal();

  final String contactId;

  @override
  ChatScreenState runNotifierBuild(covariant ChatScreenController notifier) {
    return notifier.build(contactId);
  }

  @override
  Override overrideWith(ChatScreenController Function() create) {
    return ProviderOverride(
      origin: this,
      override: ChatScreenControllerProvider._internal(
        () => create()..contactId = contactId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        contactId: contactId,
      ),
    );
  }

  @override
  AutoDisposeNotifierProviderElement<ChatScreenController, ChatScreenState>
  createElement() {
    return _ChatScreenControllerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ChatScreenControllerProvider &&
        other.contactId == contactId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, contactId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ChatScreenControllerRef
    on AutoDisposeNotifierProviderRef<ChatScreenState> {
  /// The parameter `contactId` of this provider.
  String get contactId;
}

class _ChatScreenControllerProviderElement
    extends
        AutoDisposeNotifierProviderElement<
          ChatScreenController,
          ChatScreenState
        >
    with ChatScreenControllerRef {
  _ChatScreenControllerProviderElement(super.provider);

  @override
  String get contactId => (origin as ChatScreenControllerProvider).contactId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
