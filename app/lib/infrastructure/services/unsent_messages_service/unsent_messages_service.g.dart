// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'unsent_messages_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Service for managing unsent messages per contact.
///
/// This service persists draft messages to secure storage (encrypted),
/// allowing them to survive app restarts while keeping them secure and
/// separate from the main database.

@ProviderFor(UnsentMessagesService)
const unsentMessagesServiceProvider = UnsentMessagesServiceProvider._();

/// Service for managing unsent messages per contact.
///
/// This service persists draft messages to secure storage (encrypted),
/// allowing them to survive app restarts while keeping them secure and
/// separate from the main database.
final class UnsentMessagesServiceProvider
    extends
        $NotifierProvider<UnsentMessagesService, UnsentMessagesServiceState> {
  /// Service for managing unsent messages per contact.
  ///
  /// This service persists draft messages to secure storage (encrypted),
  /// allowing them to survive app restarts while keeping them secure and
  /// separate from the main database.
  const UnsentMessagesServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'unsentMessagesServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$unsentMessagesServiceHash();

  @$internal
  @override
  UnsentMessagesService create() => UnsentMessagesService();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UnsentMessagesServiceState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UnsentMessagesServiceState>(value),
    );
  }
}

String _$unsentMessagesServiceHash() =>
    r'de387ec0e3196eed7254f20977b9bfe6135e82eb';

/// Service for managing unsent messages per contact.
///
/// This service persists draft messages to secure storage (encrypted),
/// allowing them to survive app restarts while keeping them secure and
/// separate from the main database.

abstract class _$UnsentMessagesService
    extends $Notifier<UnsentMessagesServiceState> {
  UnsentMessagesServiceState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref =
        this.ref
            as $Ref<UnsentMessagesServiceState, UnsentMessagesServiceState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                UnsentMessagesServiceState,
                UnsentMessagesServiceState
              >,
              UnsentMessagesServiceState,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
