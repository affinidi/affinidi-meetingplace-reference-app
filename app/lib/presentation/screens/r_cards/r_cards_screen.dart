import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:meeting_place_relationship/meeting_place_relationship.dart';

import '../../../application/services/r_cards_service/r_cards_service.dart';
import '../../../infrastructure/extensions/build_context_extensions.dart';
import '../../../navigation/routes/dashboard_routes.dart';
import '../../../navigation/tabs/tabs.dart';
import '../../widgets/section_banner.dart';

/// Displays all received R-Cards as a scrollable list.
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

    return SafeArea(
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
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: cards.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final card = cards[index];
                      return _RCardListTile(card: card);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _RCardListTile extends StatelessWidget {
  const _RCardListTile({required this.card});

  final ReceivedRCard card;

  @override
  Widget build(BuildContext context) {
    final subject = RCardSubject.fromVcBlob(card.vcBlob);
    final displayName = subject?.name.trim().isNotEmpty == true
        ? subject!.name
        : null;
    final subtitle = displayName ?? _truncateDid(card.subjectDid);
    final receivedText = DateFormat(
      'MMM d, y',
    ).format(card.receivedAt.toLocal());

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        child: Text(
          displayName?.characters.first.toUpperCase() ??
              card.subjectDid.characters.elementAt(8).toUpperCase(),
          style: TextStyle(
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
        ),
      ),
      title: Text(subtitle),
      subtitle: Text(receivedText),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => RCardDetailsRoute(subjectDid: card.subjectDid).go(context),
    );
  }

  String _truncateDid(String did) {
    if (did.length <= 24) return did;
    return '${did.substring(0, 12)}…${did.substring(did.length - 8)}';
  }
}
