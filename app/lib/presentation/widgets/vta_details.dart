import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../application/services/vtc_service/vtc_service.dart';
import '../../infrastructure/extensions/build_context_extensions.dart';
import '../../l10n/app_localizations.dart';
import '../themes/tokens/mc_icons.dart';
import '../themes/tokens/mc_radius.dart';
import '../themes/tokens/mc_spacing.dart';

/// The VTA's shield, as in the trail diagrams, beside an identity's name:
/// opens [showVtaDetails] for where the identity lives on the VTA.
class VtaDetailsButton extends StatelessWidget {
  const VtaDetailsButton({
    super.key,
    required this.contextId,
    required this.profileId,
    this.color,
  });

  final String contextId;
  final String profileId;

  /// The icon's colour, for a dark card; else the theme's.
  final Color? color;

  static const _iconSize = 20.0;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      key: const Key('vta_details_toggle'),
      tooltip: context.l10n.vtaDetailsTitle,
      visualDensity: VisualDensity.compact,
      icon: Icon(McIcons.shield, size: _iconSize, color: color),
      onPressed: () =>
          showVtaDetails(context, contextId: contextId, profileId: profileId),
    );
  }
}

/// Shows where an identity lives on the member's VTA in a sheet: its
/// context, its profile, and the profile as the VTA keeps it, read from the
/// VTA as the sheet opens.
Future<void> showVtaDetails(
  BuildContext context, {
  required String contextId,
  required String profileId,
}) => showModalBottomSheet<void>(
  context: context,
  useRootNavigator: true,
  isScrollControlled: true,
  useSafeArea: true,
  backgroundColor: Colors.transparent,
  builder: (_) => _VtaDetailsSheet(contextId: contextId, profileId: profileId),
);

class _VtaDetailsSheet extends HookConsumerWidget {
  const _VtaDetailsSheet({required this.contextId, required this.profileId});

  final String contextId;
  final String profileId;

  static const _radius = Radius.circular(McRadius.xl);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final mc = context.mcColors;
    final colors = context.colorScheme;
    Future<Map<String, dynamic>> read() => ref
        .read(vtcServiceProvider)
        .identityProfileDocument(contextId: contextId, profileId: profileId);
    final document = useState(useMemoized(read));

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      builder: (context, scrollController) => DecoratedBox(
        decoration: BoxDecoration(
          color: mc.raised,
          borderRadius: const BorderRadius.vertical(top: _radius),
          border: Border(top: BorderSide(color: mc.hairline)),
        ),
        child: ListView(
          key: const Key('vta_details_sheet'),
          controller: scrollController,
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          children: [
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 10, bottom: 6),
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: mc.hairlineStrong,
                  borderRadius: BorderRadius.circular(McRadius.xs),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 16),
              child: Row(
                spacing: 12,
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: colors.secondary,
                    child: Icon(McIcons.shield, color: colors.onSecondary),
                  ),
                  Expanded(
                    child: Text(
                      l10n.vtaDetailsTitle,
                      style: context.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  IconButton(
                    key: const Key('vta_details_close'),
                    icon: const Icon(McIcons.close),
                    tooltip: l10n.generalClose,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 12,
              children: [
                _Field(
                  label: l10n.vtaDetailsContextId,
                  value: contextId,
                  color: mc.textPrimary,
                ),
                _Field(
                  label: l10n.vtaDetailsProfileId,
                  value: profileId,
                  color: mc.textPrimary,
                ),
                FutureBuilder(
                  future: document.value,
                  builder: (context, snapshot) => _Profile(
                    snapshot: snapshot,
                    onRetry: () => document.value = read(),
                    color: mc.textPrimary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({required this.label, required this.value, required this.color});

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 2,
      children: [
        Text(
          label,
          style: textTheme.labelSmall?.copyWith(color: color.withAlpha(180)),
        ),
        SelectableText(
          value,
          style: textTheme.bodySmall?.copyWith(
            color: color,
            fontFamily: 'monospace',
          ),
        ),
      ],
    );
  }
}

/// The profile as the VTA keeps it, as indented JSON; or how reading it
/// stands.
class _Profile extends StatelessWidget {
  const _Profile({
    required this.snapshot,
    required this.onRetry,
    required this.color,
  });

  final AsyncSnapshot<Map<String, dynamic>> snapshot;
  final VoidCallback onRetry;
  final Color color;

  /// Longest value shown whole; a thumbnail runs to tens of thousands of
  /// characters.
  static const _maxShownValueLength = 120;
  static const _shortenedValueStart = 40;
  static const _json = JsonEncoder.withIndent('  ');

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = context.textTheme;
    final document = snapshot.data;

    final Widget body;
    // Checked first: a retry keeps the last error until it is answered.
    if (snapshot.connectionState != ConnectionState.done) {
      body = Padding(
        padding: const EdgeInsets.all(8),
        child: Center(
          child: SizedBox.square(
            dimension: 20,
            child: CircularProgressIndicator(strokeWidth: 2, color: color),
          ),
        ),
      );
    } else if (snapshot.hasError || document == null) {
      body = Row(
        children: [
          Expanded(
            child: Text(
              l10n.vtaDetailsProfileFailed,
              style: textTheme.bodySmall?.copyWith(color: color),
            ),
          ),
          TextButton(
            onPressed: onRetry,
            style: TextButton.styleFrom(foregroundColor: color),
            child: Text(l10n.generalRetry),
          ),
        ],
      );
    } else {
      final mc = context.mcColors;
      // A sunken panel of its own, as the JSON sheet shows a document.
      body = DecoratedBox(
        key: const Key('vta_details_profile_panel'),
        decoration: BoxDecoration(
          color: context.colorScheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(McRadius.lg),
          border: Border.all(color: mc.hairline),
        ),
        child: Padding(
          padding: const EdgeInsets.all(McSpacing.s4),
          child: SelectableText(
            _json.convert(_shortened(document, l10n)),
            key: const Key('vta_details_profile'),
            style: textTheme.labelSmall?.copyWith(
              color: color,
              fontFamily: 'monospace',
              height: 1.4,
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 2,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                l10n.vtaDetailsProfile,
                style: textTheme.labelSmall?.copyWith(
                  color: color.withAlpha(180),
                ),
              ),
            ),
            if (snapshot.connectionState == ConnectionState.done &&
                document != null)
              IconButton(
                key: const Key('vta_details_copy_profile'),
                tooltip: l10n.vtaDetailsCopyProfile,
                visualDensity: VisualDensity.compact,
                iconSize: 16,
                color: color,
                icon: const Icon(McIcons.copy),
                onPressed: () => _copy(context, document),
              ),
          ],
        ),
        body,
      ],
    );
  }

  /// Copies the whole profile, long values included.
  Future<void> _copy(
    BuildContext context,
    Map<String, dynamic> document,
  ) async {
    final messenger = ScaffoldMessenger.maybeOf(context);
    final copied = context.l10n.copiedToClipboard;
    await Clipboard.setData(ClipboardData(text: _json.convert(document)));
    messenger?.showSnackBar(SnackBar(content: Text(copied)));
  }

  static Object? _shortened(Object? value, AppLocalizations l10n) =>
      switch (value) {
        final String text when text.length > _maxShownValueLength =>
          l10n.vtaDetailsValueShortened(
            text.substring(0, _shortenedValueStart),
            text.length,
          ),
        final Map<String, dynamic> map => {
          for (final MapEntry(:key, :value) in map.entries)
            key: _shortened(value, l10n),
        },
        final List<dynamic> list => [
          for (final item in list) _shortened(item, l10n),
        ],
        _ => value,
      };
}
