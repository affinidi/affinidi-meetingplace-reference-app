import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../application/services/identities_service/identities_service.dart';
import '../../../domain/models/contact_card/contact_card.dart';
import '../../../domain/models/contact_card/contact_card_field_definition.dart';
import '../../../domain/models/identity/identity.dart';
import '../../../infrastructure/extensions/identities_screen_filter_extensions.dart';
import '../../../infrastructure/extensions/string_list_extensions.dart';
import 'identities_screen_filter.dart';
import 'identities_screen_state.dart';

part 'identities_screen_controller.g.dart';

@Riverpod(keepAlive: true)
class IdentitiesScreenController extends _$IdentitiesScreenController {
  String _lastSearchQuery = '';
  IdentitiesScreenFilter _currentFilter = IdentitiesScreenFilter.all;
  late final createNewIdentityPlaceholder = Identity(
    id: placeholderIdentityId,
    did: '',
    card: ContactCard.empty(),
  );

  @override
  IdentitiesScreenState build() {
    ref.listen(
      identitiesServiceProvider.select((state) => state.currentIdentity),
      (prev, next) {
        if (prev == next) return;

        Future.microtask(() {
          state = state.copyWith(currentIdentity: next);
        });
      },
      fireImmediately: true,
    );

    ref.listen(
      identitiesServiceProvider.select((state) => state.identities),
      (prev, next) {
        if (prev == next) return;

        Future.microtask(() {
          state = state.copyWith(
            identities: [..._filteredIdentities, createNewIdentityPlaceholder],
            shouldSetupPrimaryIdentity: next.isEmpty,
          );
        });
      },
      fireImmediately: true,
    );

    final currentIdentity = ref.read(
      identitiesServiceProvider.currentIdentityOrPrimary,
    );

    return IdentitiesScreenState(
      currentIdentity: currentIdentity,
      filter: _currentFilter,
      identities: [createNewIdentityPlaceholder],
    );
  }

  List<Identity> get _filteredIdentities {
    final allIdentities = ref.read(identitiesServiceProvider).identities;

    var searchFiltered = allIdentities;
    if (_lastSearchQuery.isNotEmpty) {
      final lowerQuery = _lastSearchQuery.toLowerCase();
      searchFiltered = allIdentities.where((identity) {
        final card = identity.card;
        final searchableText = ContactCardFieldDefinitions.values
            .where((f) => f.hasTag(ContactCardFieldTags.searchable))
            .map((f) => f.valueFrom(card))
            .nonEmpty
            .join(' ')
            .toLowerCase();
        return searchableText.contains(lowerQuery);
      }).toList();
    }

    return searchFiltered.where((identity) {
      return _currentFilter.matches(identity);
    }).toList();
  }

  void setCurrentIdentity(Identity identity) {
    ref
        .read(identitiesServiceProvider.notifier)
        .setCurrentIdentityById(identity.id);
  }

  Future<void> deleteIdentity(String identityId) async {
    await ref
        .read(identitiesServiceProvider.notifier)
        .deleteIdentity(identityId);
  }

  void toggleFilterVisibility() {
    if (state.shouldShowFilter) {
      clearSearch();
    }
    state = state.copyWith(shouldShowFilter: !state.shouldShowFilter);
  }

  void search(String query) {
    final trimmedQuery = query.trim();
    final hadText = _lastSearchQuery.isNotEmpty;
    final isEmpty = trimmedQuery.isEmpty;

    if (hadText && isEmpty) {
      clearSearch();
      return;
    }

    _lastSearchQuery = query;

    if (isEmpty) return;

    _lastSearchQuery = trimmedQuery;

    final filtered = _filteredIdentities;
    state = state.copyWith(
      identities: [...filtered, createNewIdentityPlaceholder],
    );
  }

  void clearSearch() {
    _lastSearchQuery = '';

    final filtered = _filteredIdentities;
    final defaultIdentity = filtered.firstWhereOrNull((i) => i.isPrimary);
    state = state.copyWith(
      currentIdentity: defaultIdentity,
      identities: [...filtered, createNewIdentityPlaceholder],
    );
  }

  Future<void> applyFilter(IdentitiesScreenFilter filter) async {
    _currentFilter = filter;
    _lastSearchQuery = '';

    state = state.copyWith(filter: filter);

    final filtered = _filteredIdentities;
    final defaultIdentity = filtered.firstWhereOrNull((i) => i.isPrimary);

    state = state.copyWith(
      currentIdentity: defaultIdentity,
      identities: [...filtered, createNewIdentityPlaceholder],
    );
  }
}
