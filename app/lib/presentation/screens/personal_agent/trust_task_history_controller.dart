import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../../application/services/signing_service/signing_service.dart';
import '../../../domain/models/trust_task/trust_task_record.dart';

enum TrustTaskHistoryStatus { idle, loading, loadingMore, ready, error }

class TrustTaskHistoryState {
  const TrustTaskHistoryState({
    this.status = TrustTaskHistoryStatus.idle,
    this.records = const [],
    this.hasMore = false,
    this.page = 0,
    this.errorMessage,
  });

  final TrustTaskHistoryStatus status;
  final List<TrustTaskRecord> records;
  final bool hasMore;
  final int page;
  final String? errorMessage;

  bool get isLoading => status == TrustTaskHistoryStatus.loading;
  bool get isLoadingMore => status == TrustTaskHistoryStatus.loadingMore;
  bool get isEmpty => status == TrustTaskHistoryStatus.ready && records.isEmpty;

  TrustTaskHistoryState copyWith({
    TrustTaskHistoryStatus? status,
    List<TrustTaskRecord>? records,
    bool? hasMore,
    int? page,
    String? errorMessage,
    bool clearError = false,
  }) {
    return TrustTaskHistoryState(
      status: status ?? this.status,
      records: records ?? this.records,
      hasMore: hasMore ?? this.hasMore,
      page: page ?? this.page,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

/// Loads trust-task (document signing) history from the VTA audit log via the
/// [SigningService]. Auto-loads once the signing service reports connected, and
/// supports manual refresh and pagination.
class TrustTaskHistoryController extends StateNotifier<TrustTaskHistoryState> {
  TrustTaskHistoryController(this._ref) : super(const TrustTaskHistoryState()) {
    _init();
  }

  final Ref _ref;
  static const int _pageSize = 20;
  bool _loadedOnce = false;

  void _init() {
    final current = _ref.read(signingServiceProvider);
    if (current.status == SigningServiceStatus.connected) {
      load();
    }
    _ref.listen<SigningServiceState>(signingServiceProvider, (prev, next) {
      if (next.status == SigningServiceStatus.connected && !_loadedOnce) {
        load();
      }
    });
  }

  SigningService get _signingService =>
      _ref.read(signingServiceProvider.notifier);

  /// Loads the first page, replacing any existing records.
  Future<void> load() async {
    if (state.isLoading) return;
    state = state.copyWith(
      status: TrustTaskHistoryStatus.loading,
      clearError: true,
    );
    try {
      final result = await _signingService.fetchTrustTaskHistory(
        page: 1,
        pageSize: _pageSize,
      );
      _loadedOnce = true;
      state = TrustTaskHistoryState(
        status: TrustTaskHistoryStatus.ready,
        records: result.records,
        hasMore: result.hasMore,
        page: result.page,
      );
    } catch (e) {
      state = state.copyWith(
        status: TrustTaskHistoryStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  /// Reloads from the first page (pull-to-refresh / refresh button).
  Future<void> refresh() => load();

  /// Appends the next page, if any.
  Future<void> loadMore() async {
    if (!state.hasMore ||
        state.status == TrustTaskHistoryStatus.loading ||
        state.status == TrustTaskHistoryStatus.loadingMore) {
      return;
    }
    final nextPage = state.page + 1;
    state = state.copyWith(
      status: TrustTaskHistoryStatus.loadingMore,
      clearError: true,
    );
    try {
      final result = await _signingService.fetchTrustTaskHistory(
        page: nextPage,
        pageSize: _pageSize,
      );
      state = state.copyWith(
        status: TrustTaskHistoryStatus.ready,
        records: [...state.records, ...result.records],
        hasMore: result.hasMore,
        page: result.page,
      );
    } catch (e) {
      state = state.copyWith(
        status: TrustTaskHistoryStatus.error,
        errorMessage: e.toString(),
      );
    }
  }
}

final trustTaskHistoryControllerProvider =
    StateNotifierProvider<TrustTaskHistoryController, TrustTaskHistoryState>(
      TrustTaskHistoryController.new,
    );
