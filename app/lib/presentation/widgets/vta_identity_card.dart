import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../domain/models/contact_card/contact_card.dart';
import '../../infrastructure/extensions/build_context_extensions.dart';
import '../../infrastructure/extensions/contact_card_extensions.dart';
import '../../infrastructure/providers/cache_manager_provider.dart';
import 'onboarding_style/onboarding_style.dart';

/// A VTA identity as a card in the shape of an MPX identity card, frosted
/// for the gradient: a header with its name and host, its picture, the
/// details its profile holds, and its DID. A null [did] is the new identity
/// the VTA would create.
class VtaIdentityCard extends ConsumerWidget {
  const VtaIdentityCard({super.key, required this.did, this.card});

  final String? did;

  /// The identity's profile, as this phone keeps it in step with the VTA;
  /// null for an identity this phone does not hold.
  final ContactCard? card;

  static const _radius = Radius.circular(25);

  /// Lines the DID may take, fewer when the profile's details share the
  /// card with it.
  static const _didMaxLines = 4;
  static const _didMaxLinesWithDetails = 2;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final textTheme = context.textTheme;
    final did = this.did;
    final card = this.card;
    final displayName = card?.displayName.trim() ?? '';
    final details = <(IconData, String)>[
      if (card != null) ...[
        if (card.fullName.isNotEmpty) (Icons.badge_outlined, card.fullName),
        if (card.emailAddress.trim().isNotEmpty)
          (Icons.email_outlined, card.emailAddress),
        if (card.mobilePhone.trim().isNotEmpty)
          (Icons.phone_outlined, card.mobilePhone),
      ],
    ];

    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Color.alphaBlend(
          Colors.white.withAlpha(30),
          context.colorScheme.primary,
        ),
        borderRadius: const BorderRadius.all(_radius),
        border: Border.all(color: Colors.white.withAlpha(90)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(40),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      // Sized to its content, or filling a slot such as a card in a deck.
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(40),
              borderRadius: const BorderRadius.only(
                topLeft: _radius,
                topRight: _radius,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
              child: Row(
                spacing: 12,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 4,
                      children: [
                        Text(
                          did == null
                              ? l10n.vtcJoinNewIdentity
                              : displayName.isNotEmpty
                              ? displayName
                              : l10n.vtcJoinExistingIdentity,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          did == null
                              ? l10n.vtcJoinNewIdentityHost
                              : _host(did),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.labelMedium?.copyWith(
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: Colors.white.withAlpha(50),
                    backgroundImage: card != null && card.hasProfilePic
                        ? card.image(
                            cacheManager: ref.read(cacheManagerProvider),
                          )
                        : null,
                    child: card != null && card.hasProfilePic
                        ? null
                        : Icon(
                            did == null ? Icons.person_add : Icons.fingerprint,
                            color: Colors.white,
                          ),
                  ),
                ],
              ),
            ),
          ),
          Flexible(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: did == null
                  ? Text(
                      l10n.vtcJoinNewIdentityNote,
                      style: onboardingNote(context),
                    )
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 6,
                      children: [
                        for (final (icon, value) in details)
                          _Detail(icon: icon, value: value),
                        Flexible(
                          child: Text(
                            did,
                            maxLines: details.isEmpty
                                ? _didMaxLines
                                : _didMaxLinesWithDetails,
                            overflow: TextOverflow.ellipsis,
                            style: textTheme.bodySmall?.copyWith(
                              color: Colors.white,
                              fontFamily: 'monospace',
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  /// Where a `did:webvh` is published, e.g. `vta.example`; else the method.
  static String _host(String did) {
    final parts = did.split(':');
    if (parts.length > 3 && parts[1] == 'webvh') {
      return Uri.decodeComponent(parts.sublist(3).join('/'));
    }
    return parts.length > 1 ? 'did:${parts[1]}' : did;
  }
}

/// One detail of the identity's profile, by its icon.
class _Detail extends StatelessWidget {
  const _Detail({required this.icon, required this.value});

  final IconData icon;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 8,
      children: [
        Icon(icon, size: 16, color: Colors.white70),
        Expanded(
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.textTheme.bodyMedium?.copyWith(color: Colors.white),
          ),
        ),
      ],
    );
  }
}
