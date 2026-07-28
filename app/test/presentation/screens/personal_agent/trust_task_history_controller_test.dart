import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mpx_flutter_reference_app/application/services/signing_service/signing_service.dart';
import 'package:mpx_flutter_reference_app/domain/models/trust_task/trust_task_record.dart';
import 'package:mpx_flutter_reference_app/presentation/screens/personal_agent/trust_task_history_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  TrustTaskHistoryPage pageOf(
    List<String> ids, {
    required int page,
    required int totalPages,
  }) {
    return TrustTaskHistoryPage(
      records: [
        for (final id in ids)
          TrustTaskRecord(
            id: id,
            timestamp: DateTime(2024),
            status: TrustTaskStatus.signed,
            rawOutcome: 'success',
          ),
      ],
      page: page,
      pageSize: ids.length,
      total: 99,
      totalPages: totalPages,
    );
  }

  ProviderContainer makeContainer(_FakeSigning fake) {
    final container = ProviderContainer(
      overrides: [signingServiceProvider.overrideWith((ref) => fake)],
    );
    addTearDown(container.dispose);
    return container;
  }

  test('load() populates records and hasMore from pagination', () async {
    final fake = _FakeSigning(
      status: SigningServiceStatus.disconnected,
      pages: {1: pageOf(['a', 'b'], page: 1, totalPages: 2)},
    );
    final container = makeContainer(fake);
    final controller = container.read(
      trustTaskHistoryControllerProvider.notifier,
    );

    await controller.load();

    final state = container.read(trustTaskHistoryControllerProvider);
    expect(state.status, TrustTaskHistoryStatus.ready);
    expect(state.records.map((r) => r.id), ['a', 'b']);
    expect(state.hasMore, isTrue);
    expect(state.page, 1);
  });

  test('loadMore() appends the next page', () async {
    final fake = _FakeSigning(
      status: SigningServiceStatus.disconnected,
      pages: {
        1: pageOf(['a'], page: 1, totalPages: 2),
        2: pageOf(['b'], page: 2, totalPages: 2),
      },
    );
    final container = makeContainer(fake);
    final controller = container.read(
      trustTaskHistoryControllerProvider.notifier,
    );

    await controller.load();
    await controller.loadMore();

    final state = container.read(trustTaskHistoryControllerProvider);
    expect(state.records.map((r) => r.id), ['a', 'b']);
    expect(state.hasMore, isFalse);
    expect(fake.requestedPages, [1, 2]);
  });

  test('error surfaces as error status', () async {
    final fake = _FakeSigning(
      status: SigningServiceStatus.disconnected,
      error: StateError('boom'),
    );
    final container = makeContainer(fake);
    final controller = container.read(
      trustTaskHistoryControllerProvider.notifier,
    );

    await controller.load();

    final state = container.read(trustTaskHistoryControllerProvider);
    expect(state.status, TrustTaskHistoryStatus.error);
    expect(state.errorMessage, contains('boom'));
  });

  test('auto-loads once the signing service reports connected', () async {
    final fake = _FakeSigning(
      status: SigningServiceStatus.disconnected,
      pages: {1: pageOf(['a'], page: 1, totalPages: 1)},
    );
    final container = makeContainer(fake);
    // Instantiate the controller (subscribes to signing status).
    container.read(trustTaskHistoryControllerProvider.notifier);

    fake.markConnected();
    await Future<void>.delayed(Duration.zero);
    await Future<void>.delayed(Duration.zero);

    final state = container.read(trustTaskHistoryControllerProvider);
    expect(state.records.map((r) => r.id), ['a']);
    expect(fake.requestedPages, contains(1));
  });
}

class _FakeSigning extends StateNotifier<SigningServiceState>
    implements SigningService {
  _FakeSigning({
    required SigningServiceStatus status,
    this.pages = const {},
    this.error,
  }) : super(SigningServiceState(status: status));

  final Map<int, TrustTaskHistoryPage> pages;
  final Object? error;
  final List<int> requestedPages = [];

  void markConnected() {
    state = const SigningServiceState(
      status: SigningServiceStatus.connected,
    );
  }

  @override
  Future<TrustTaskHistoryPage> fetchTrustTaskHistory({
    int page = 1,
    int pageSize = 20,
  }) async {
    requestedPages.add(page);
    if (error != null) throw error!; // ignore: only_throw_errors
    return pages[page] ?? const TrustTaskHistoryPage.empty();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}
