import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:meeting_place_vtc/meeting_place_vtc.dart';

import '../../../application/services/vtc_trust_service/vtc_trust_service.dart';
import '../../../infrastructure/extensions/build_context_extensions.dart';
import 'vtc_member_avatar.dart';
import 'vtc_vouch.dart';

/// Finds which member of a community a contact is: searches the community's
/// directory, starting from the contact's name, and returns the entry the
/// member confirms is theirs. Entries that show no identity to vouch for
/// cannot be picked, and say why.
class VtcMemberSearchScreen extends HookConsumerWidget {
  const VtcMemberSearchScreen({
    super.key,
    required this.communityDid,
    required this.communityName,
    required this.contactName,
  });

  final String communityDid;
  final String communityName;

  /// The contact's name, which the search starts from.
  final String contactName;

  /// Shortest search the community answers.
  static const minQueryLength = 3;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final service = ref.read(vtcTrustServiceProvider);
    final field = useTextEditingController(text: contactName);
    final query = useState(contactName.trim());
    final results = useState<List<DirectoryEntry>?>(null);
    final failure = useState<VtcTrustFailure?>(null);

    useEffect(() {
      var current = true;
      final text = query.value;
      results.value = null;
      failure.value = null;
      if (text.length < minQueryLength) {
        failure.value = VtcTrustFailure.searchTooShort;
        return null;
      }
      unawaited(
        service
            .findMembers(communityDid, query: text)
            .then((found) {
              if (current) results.value = found;
            })
            .catchError((Object error) {
              if (current && error is VtcTrustException) {
                failure.value = error.failure;
              }
            }),
      );
      return () => current = false;
    }, [query.value]);

    Future<void> pick(DirectoryEntry entry) async {
      final member =
          entry.displayName ?? entry.nickname ?? l10n.vtcTrustUnnamed;
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          key: const Key('vtc_member_confirm'),
          title: Text(l10n.vtcTrustConfirmMatchTitle(contactName)),
          content: Text(
            l10n.vtcTrustConfirmMatchMessage(
              contactName,
              communityName,
              member,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(l10n.generalCancel),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(l10n.vtcTrustConfirmMatchAction),
            ),
          ],
        ),
      );
      if ((confirmed ?? false) && context.mounted) {
        Navigator.of(context).pop(entry);
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.vtcTrustSearchTitle(contactName, communityName)),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                key: const Key('vtc_member_search_field'),
                controller: field,
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  labelText: l10n.vtcTrustSearchHint,
                  prefixIcon: const Icon(Icons.search),
                ),
                onSubmitted: (text) => query.value = text.trim(),
              ),
            ),
            Expanded(
              child: switch ((results.value, failure.value)) {
                (_, final failure?) => _Message(
                  vtcTrustFailureMessage(
                    l10n,
                    failure,
                    community: communityName,
                    name: contactName,
                  ),
                ),
                (null, _) => const Center(child: CircularProgressIndicator()),
                (final found?, _) when found.isEmpty => _Message(
                  l10n.vtcTrustSearchNone,
                ),
                (final found?, _) => ListView.separated(
                  itemCount: found.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final entry = found[index];
                    final name =
                        entry.displayName ??
                        entry.nickname ??
                        l10n.vtcTrustUnnamed;
                    final isFindable = entry.did != null;
                    return ListTile(
                      key: Key('vtc_member_${entry.entryId}'),
                      enabled: isFindable,
                      leading: VtcMemberAvatar(
                        communityDid: communityDid,
                        entry: entry,
                      ),
                      title: Text(name),
                      subtitle: isFindable
                          ? null
                          : Text(l10n.vtcTrustNotFindable(name, communityName)),
                      onTap: isFindable ? () => pick(entry) : null,
                    );
                  },
                ),
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _Message extends StatelessWidget {
  const _Message(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Text(text, textAlign: TextAlign.center),
    ),
  );
}
