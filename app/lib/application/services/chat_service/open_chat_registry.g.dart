// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'open_chat_registry.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Tracks which contact chats are currently open on screen.
///
/// The presentation layer owns navigation state, so the chat screen publishes
/// its open/closed lifecycle here (see `ChatScreenController`). Application
/// services can then check whether a chat is being viewed without reaching into
/// navigation internals such as the router.

@ProviderFor(OpenChatRegistry)
const openChatRegistryProvider = OpenChatRegistryProvider._();

/// Tracks which contact chats are currently open on screen.
///
/// The presentation layer owns navigation state, so the chat screen publishes
/// its open/closed lifecycle here (see `ChatScreenController`). Application
/// services can then check whether a chat is being viewed without reaching into
/// navigation internals such as the router.
final class OpenChatRegistryProvider
    extends $NotifierProvider<OpenChatRegistry, Set<String>> {
  /// Tracks which contact chats are currently open on screen.
  ///
  /// The presentation layer owns navigation state, so the chat screen publishes
  /// its open/closed lifecycle here (see `ChatScreenController`). Application
  /// services can then check whether a chat is being viewed without reaching into
  /// navigation internals such as the router.
  const OpenChatRegistryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'openChatRegistryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$openChatRegistryHash();

  @$internal
  @override
  OpenChatRegistry create() => OpenChatRegistry();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Set<String> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Set<String>>(value),
    );
  }
}

String _$openChatRegistryHash() => r'2bb57989d7d3ce6e86bf53b342111ddd2f250b04';

/// Tracks which contact chats are currently open on screen.
///
/// The presentation layer owns navigation state, so the chat screen publishes
/// its open/closed lifecycle here (see `ChatScreenController`). Application
/// services can then check whether a chat is being viewed without reaching into
/// navigation internals such as the router.

abstract class _$OpenChatRegistry extends $Notifier<Set<String>> {
  Set<String> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<Set<String>, Set<String>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Set<String>, Set<String>>,
              Set<String>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
