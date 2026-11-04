import 'package:flutter/material.dart';

import '../../infrastructure/extensions/build_context_extensions.dart';
import 'onboarding_style/onboarding_style.dart';

/// A VTA identity as a card in the shape of an MPX identity card, frosted
/// for the gradient: a header with its title and host, its avatar, and its
/// DID. A null [did] is the new identity the VTA would create.
class VtaIdentityCard extends StatelessWidget {
  const VtaIdentityCard({super.key, required this.did, this.name});

  final String? did;

  /// The identity's name, as the member gave it.
  final String? name;

  static const _radius = Radius.circular(25);

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = context.textTheme;
    final did = this.did;

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
                              : name ?? l10n.vtcJoinExistingIdentity,
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
                    child: Icon(
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
                  : Text(
                      did,
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodySmall?.copyWith(
                        color: Colors.white,
                        fontFamily: 'monospace',
                        height: 1.4,
                      ),
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
