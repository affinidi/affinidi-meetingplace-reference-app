import 'package:meeting_place_relationship/meeting_place_relationship.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../application/services/r_cards_service/r_cards_service.dart';
import 'r_cards_screen_filter.dart';
import 'r_cards_screen_state.dart';

part 'r_cards_screen_controller.g.dart';

@Riverpod(keepAlive: true)
class RCardsScreenController extends _$RCardsScreenController {
  RCardsScreenFilter _currentFilter = RCardsScreenFilter.all;
  String _lastSearchQuery = '';
  String _anonymousLabel = '';

  @override
  RCardsScreenState build() {
    ref.listen(
      rCardsServiceProvider,
      (prev, next) {
        Future.microtask(() {
          state = state.copyWith(cards: _applyFilters(next));
        });
      },
      fireImmediately: true,
    );

    final initialCards = ref.read(rCardsServiceProvider);

    return RCardsScreenState(
      filter: _currentFilter,
      cards: _applyFilters(initialCards),
      isSearchActive: false,
    );
  }

  void setAnonymousLabel(String label) {
    _anonymousLabel = label;
    state =
        state.copyWith(cards: _applyFilters(ref.read(rCardsServiceProvider)));
  }

  void toggleSearch() {
    final next = !state.isSearchActive;
    if (!next) {
      _lastSearchQuery = '';
    }
    state = state.copyWith(
      isSearchActive: next,
      cards: _applyFilters(ref.read(rCardsServiceProvider)),
    );
  }

  void search(String query) {
    _lastSearchQuery = query.trim();
    final allCards = ref.read(rCardsServiceProvider);
    final filteredResults = _applyFilters(allCards);
    state = state.copyWith(
      cards: filteredResults,
      hasFilterApplied: allCards.length != filteredResults.length,
    );
  }

  void applyFilter(RCardsScreenFilter filter) {
    _currentFilter = filter;
    _lastSearchQuery = '';
    final allCards = ref.read(rCardsServiceProvider);
    final filteredResults = _applyFilters(allCards);
    state = state.copyWith(
      filter: filter,
      cards: filteredResults,
    );
  }

  List<ReceivedRCard> _applyFilters(List<ReceivedRCard> all) {
    var cards = all;

    if (_lastSearchQuery.isNotEmpty) {
      final q = _lastSearchQuery.toLowerCase();
      cards = cards.where((c) {
        final s = RCardSubject.fromVcBlob(c.vcBlob);
        final searchable = [
          s?.firstName,
          s?.lastName,
          s?.email,
          s?.phone,
          s?.company,
          s?.position,
          s?.website,
          s?.social,
        ].whereType<String>().join(' ').toLowerCase();
        return searchable.contains(q);
      }).toList();
    }

    switch (_currentFilter) {
      case RCardsScreenFilter.all:
        return cards;
      case RCardsScreenFilter.nonAnonymous:
        return cards.where((c) => !_isAnonymous(c)).toList();
    }
  }

  bool _isAnonymous(ReceivedRCard card) {
    final s = RCardSubject.fromVcBlob(card.vcBlob);
    final firstName = s?.firstName?.trim() ?? '';
    final lastName = s?.lastName?.trim() ?? '';
    return firstName == _anonymousLabel && lastName.isEmpty;
  }
}
