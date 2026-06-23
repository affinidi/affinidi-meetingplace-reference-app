// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'push_notifications_handler.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// A Riverpod provider class that handles push notifications lifecycle,
/// device token updates, and notification streams.

@ProviderFor(PushNotificationsHandler)
const pushNotificationsHandlerProvider = PushNotificationsHandlerProvider._();

/// A Riverpod provider class that handles push notifications lifecycle,
/// device token updates, and notification streams.
final class PushNotificationsHandlerProvider
    extends $AsyncNotifierProvider<PushNotificationsHandler, void> {
  /// A Riverpod provider class that handles push notifications lifecycle,
  /// device token updates, and notification streams.
  const PushNotificationsHandlerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pushNotificationsHandlerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pushNotificationsHandlerHash();

  @$internal
  @override
  PushNotificationsHandler create() => PushNotificationsHandler();
}

String _$pushNotificationsHandlerHash() =>
    r'ad2b8e95d8e3087d696a7c831c85f93b5429e918';

/// A Riverpod provider class that handles push notifications lifecycle,
/// device token updates, and notification streams.

abstract class _$PushNotificationsHandler extends $AsyncNotifier<void> {
  FutureOr<void> build();
  @$mustCallSuper
  @override
  void runBuild() {
    build();
    final ref = this.ref as $Ref<AsyncValue<void>, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<void>, void>,
              AsyncValue<void>,
              Object?,
              Object?
            >;
    element.handleValue(ref, null);
  }
}
