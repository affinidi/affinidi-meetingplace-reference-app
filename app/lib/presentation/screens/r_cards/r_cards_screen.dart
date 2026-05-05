import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:meeting_place_relationship/meeting_place_relationship.dart';

import '../../../application/services/r_cards_service/r_cards_service.dart';
import '../../../infrastructure/extensions/build_context_extensions.dart';
import '../../../navigation/tabs/tabs.dart';
import '../../widgets/section_banner.dart';
import 'r_cards_deck.dart';

/// Displays all received R-Cards as a stacked card deck.
///
/// Tapping a card navigates to `RCardDetailsScreen` for the full credential
/// view.
class RCardsScreen extends ConsumerWidget {
  const RCardsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final colorScheme = context.colorScheme;

    // Ensure the service stays alive while this tab is active.
    ref.watch(rCardsServiceProvider);

    final cards = ref.watch(rCardsServiceProvider.select((state) => state));
    final deckKey = 'r_cards_deck_${cards.length}';

    return ColoredBox(
      color: Colors.black,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SectionBanner(
              title: l10n.tabsTitle(Tabs.rCards.name),
              subtitle: l10n.rCardsPanelSubtitle,
              icon: Icon(
                Icons.badge_outlined,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            Expanded(
              child: cards.isEmpty
                  ? Center(
                      child: Text(
                        l10n.rCardsEmpty,
                        style: context.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    )
                  : ScrollConfiguration(
                      behavior: ScrollConfiguration.of(context).copyWith(
                        overscroll: true,
                        physics: const AlwaysScrollableScrollPhysics(
                          parent: ClampingScrollPhysics(),
                        ),
                        scrollbars: false,
                      ),
                      child: StretchingOverscrollIndicator(
                        axisDirection: AxisDirection.down,
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(
                            parent: ClampingScrollPhysics(),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
                            child: RCardsDeck(
                              deckKey: deckKey,
                              cards: cards,
                              extractSubject: RCardSubject.fromVcBlob,
                            ),
                          ),
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
