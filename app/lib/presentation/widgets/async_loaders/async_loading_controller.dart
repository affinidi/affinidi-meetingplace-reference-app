import 'package:hooks_riverpod/hooks_riverpod.dart';

/// Use this controller to execute a future and check its statuses like
/// loading, error and completion.
class AsyncLoadingController extends AutoDisposeNotifier<AsyncValue<void>> {
  /// Creates an [AsyncLoadingController].
  AsyncLoadingController() : super();

  static AutoDisposeNotifierProvider<AsyncLoadingController, AsyncValue<void>>
  provider(String name) =>
      NotifierProvider.autoDispose<AsyncLoadingController, AsyncValue<void>>(
        AsyncLoadingController.new,
        name: name,
      );

  @override
  AsyncValue<void> build() {
    return const AsyncValue.data(null);
  }

  Future<void> start(Future<void> Function() load) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => load());
  }
}
