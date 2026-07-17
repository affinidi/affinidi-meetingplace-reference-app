// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_screen_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Controller class for managing the state and logic of the chat screen.
///
/// Extends [_$ChatScreenController] to provide reactive state management
/// and business logic for chat-related features, such as handling messages,
/// user interactions, and UI updates within the chat screen.

@ProviderFor(ChatScreenController)
const chatScreenControllerProvider = ChatScreenControllerFamily._();

/// Controller class for managing the state and logic of the chat screen.
///
/// Extends [_$ChatScreenController] to provide reactive state management
/// and business logic for chat-related features, such as handling messages,
/// user interactions, and UI updates within the chat screen.
final class ChatScreenControllerProvider
    extends $NotifierProvider<ChatScreenController, ChatScreenState> {
  /// Controller class for managing the state and logic of the chat screen.
  ///
  /// Extends [_$ChatScreenController] to provide reactive state management
  /// and business logic for chat-related features, such as handling messages,
  /// user interactions, and UI updates within the chat screen.
  const ChatScreenControllerProvider._({
    required ChatScreenControllerFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'chatScreenControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$chatScreenControllerHash();

  @override
  String toString() {
    return r'chatScreenControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  ChatScreenController create() => ChatScreenController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ChatScreenState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ChatScreenState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ChatScreenControllerProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$chatScreenControllerHash() =>
    r'0c09d4cf7d367b123bd8e3386a98e5159ca20393';

/// Controller class for managing the state and logic of the chat screen.
///
/// Extends [_$ChatScreenController] to provide reactive state management
/// and business logic for chat-related features, such as handling messages,
/// user interactions, and UI updates within the chat screen.

final class ChatScreenControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          ChatScreenController,
          ChatScreenState,
          ChatScreenState,
          ChatScreenState,
          String
        > {
  const ChatScreenControllerFamily._()
    : super(
        retry: null,
        name: r'chatScreenControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Controller class for managing the state and logic of the chat screen.
  ///
  /// Extends [_$ChatScreenController] to provide reactive state management
  /// and business logic for chat-related features, such as handling messages,
  /// user interactions, and UI updates within the chat screen.

  ChatScreenControllerProvider call(String contactId) =>
      ChatScreenControllerProvider._(argument: contactId, from: this);

  @override
  String toString() => r'chatScreenControllerProvider';
}

/// Controller class for managing the state and logic of the chat screen.
///
/// Extends [_$ChatScreenController] to provide reactive state management
/// and business logic for chat-related features, such as handling messages,
/// user interactions, and UI updates within the chat screen.

abstract class _$ChatScreenController extends $Notifier<ChatScreenState> {
  late final _$args = ref.$arg as String;
  String get contactId => _$args;

  ChatScreenState build(String contactId);
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(_$args);
    final ref = this.ref as $Ref<ChatScreenState, ChatScreenState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ChatScreenState, ChatScreenState>,
              ChatScreenState,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
