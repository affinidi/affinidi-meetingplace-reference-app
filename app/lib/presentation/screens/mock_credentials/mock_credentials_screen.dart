import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../domain/models/identity/identity.dart';
import '../../../domain/models/vtc/mock_credential_template.dart';
import '../../../infrastructure/extensions/build_context_extensions.dart';
import '../../../navigation/routes/route_paths.dart';
import '../../themes/tokens/mc_icons.dart';
import '../../themes/tokens/mc_spacing.dart';
import '../../themes/tokens/mc_typography.dart';
import '../../widgets/common/app_card.dart';
import '../../widgets/section_header.dart';
import 'mock_credentials_controller.dart';
import 'mock_credentials_state.dart';

/// The test credentials this phone can issue, each importable into the
/// member's VTA for one of their identities, to join a community whose way
/// in asks for it.
class MockCredentialsScreen extends ConsumerWidget {
  const MockCredentialsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final state = ref.watch(mockCredentialsControllerProvider);
    final controller = ref.read(mockCredentialsControllerProvider.notifier);

    Future<void> importFor(MockCredentialTemplate template) async {
      final identity = await _chooseIdentity(context, state.identities);
      if (identity == null) return;
      final (:outcome, :reason) = await controller.import(
        template.id,
        identity.did,
      );
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            switch (outcome) {
              MockCredentialImport.imported => l10n.mockCredentialsImported(
                _nameOf(context, identity),
              ),
              MockCredentialImport.notKept => l10n.mockCredentialsNotKept,
              MockCredentialImport.failed when reason != null =>
                l10n.mockCredentialsRefused(reason),
              MockCredentialImport.failed => l10n.mockCredentialsImportFailed,
            },
            style: outcome == MockCredentialImport.imported
                ? null
                : TextStyle(color: context.mcColors.dangerText),
          ),
        ),
      );
    }

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SectionHeader(
            icon: McIcons.mockCredentials,
            title: l10n.mockCredentialsTitle,
            subtitle: l10n.mockCredentialsSubtitle,
            onClose: () {
              final router = GoRouter.of(context);
              if (router.canPop()) {
                router.pop();
              } else {
                router.go(RoutePaths.contacts);
              }
            },
          ),
          if (state.isLoading)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator.adaptive()),
            )
          else if (state.failure case final failure?)
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                spacing: 8,
                children: [
                  Text(switch (failure) {
                    MockCredentialsFailure.vtaMissing =>
                      l10n.mockCredentialsVtaMissing,
                    MockCredentialsFailure.unreachable =>
                      l10n.mockCredentialsUnreachable,
                  }, textAlign: TextAlign.center),
                  TextButton(
                    onPressed: controller.refresh,
                    child: Text(l10n.generalRetry),
                  ),
                ],
              ),
            )
          else
            Expanded(
              child: RefreshIndicator(
                onRefresh: controller.refresh,
                child: ListView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: McSpacing.s4,
                    vertical: McSpacing.s3,
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(
                        l10n.mockCredentialsNote,
                        style: context.textTheme.bodySmall,
                      ),
                    ),
                    if (state.identities.isEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Text(
                          l10n.mockCredentialsNoIdentities,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    for (final template in mockCredentialTemplates)
                      _TemplateCard(
                        template: template,
                        holders: [
                          for (final identity in state.identities)
                            if (state.holders[template.id]?.contains(
                                  identity.did,
                                ) ??
                                false)
                              _nameOf(context, identity),
                        ],
                        importing: state.importing == template.id,
                        onImport:
                            state.identities.isEmpty || state.importing != null
                            ? null
                            : () => importFor(template),
                      ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// One test credential: what it is, what it claims, who holds it, and
/// Import.
class _TemplateCard extends StatelessWidget {
  const _TemplateCard({
    required this.template,
    required this.holders,
    required this.importing,
    required this.onImport,
  });

  final MockCredentialTemplate template;
  final List<String> holders;
  final bool importing;
  final VoidCallback? onImport;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colorScheme = context.colorScheme;
    final textTheme = context.textTheme;
    final onCard = colorScheme.onSurface;
    return Padding(
      padding: const EdgeInsets.only(bottom: McSpacing.s3),
      child: AppCard(
        key: Key('mock_credential_${template.id}'),
        padding: const EdgeInsets.all(McSpacing.s4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 6,
          children: [
            Text(
              template.title,
              style: textTheme.titleMedium?.copyWith(color: onCard),
            ),
            Text(
              template.type,
              style: McTypography.code.copyWith(color: onCard),
            ),
            for (final MapEntry(:key, :value) in template.claims.entries)
              Text(
                '$key: $value',
                style: textTheme.bodyMedium?.copyWith(color: onCard),
              ),
            if (holders.isNotEmpty)
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final name in holders)
                    Chip(
                      avatar: const Icon(Icons.verified, size: 16),
                      label: Text(l10n.mockCredentialsHeldBy(name)),
                    ),
                ],
              ),
            Align(
              alignment: Alignment.centerRight,
              child: importing
                  ? const SizedBox.square(
                      dimension: 24,
                      child: CircularProgressIndicator.adaptive(),
                    )
                  : FilledButton.icon(
                      onPressed: onImport,
                      icon: const Icon(Icons.download),
                      label: Text(l10n.mockCredentialsImport),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Asks which of [identities] to import a credential for.
Future<Identity?> _chooseIdentity(
  BuildContext context,
  List<Identity> identities,
) => showModalBottomSheet<Identity>(
  context: context,
  builder: (context) => SafeArea(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          title: Text(
            context.l10n.mockCredentialsChooseIdentity,
            style: context.textTheme.titleMedium,
          ),
        ),
        for (final identity in identities)
          ListTile(
            leading: const Icon(Icons.person),
            title: Text(_nameOf(context, identity)),
            onTap: () => Navigator.of(context).pop(identity),
          ),
      ],
    ),
  ),
);

/// [identity]'s name, or a fallback when its card has none.
String _nameOf(BuildContext context, Identity identity) {
  final name = identity.card.displayName.trim();
  return name.isNotEmpty ? name : context.l10n.vtcJoinExistingIdentity;
}
