import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../application/services/vtc_service/vtc_service.dart';
import '../../infrastructure/extensions/build_context_extensions.dart';
import '../../l10n/app_localizations.dart';
import '../themes/tokens/mc_radius.dart';

/// Where an identity lives on the member's VTA: its context, its profile,
/// and the profile as the VTA keeps it. Collapsed until the member opens it;
/// the profile is read from the VTA the first time it is opened.
class VtaDetails extends HookConsumerWidget {
  const VtaDetails({
    super.key,
    required this.contextId,
    required this.profileId,
    this.color,
  });

  final String contextId;
  final String profileId;

  /// Text and icon colour, for a section on a dark card; else the theme's.
  final Color? color;

  static const _animation = Duration(milliseconds: 200);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final foreground = color ?? context.colorScheme.onSurface;
    final expanded = useState(false);
    final document = useState<Future<Map<String, dynamic>>?>(null);

    void load() => document.value = ref
        .read(vtcServiceProvider)
        .identityProfileDocument(contextId: contextId, profileId: profileId);

    void toggle() {
      expanded.value = !expanded.value;
      if (expanded.value && document.value == null) load();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InkWell(
          key: const Key('vta_details_toggle'),
          onTap: toggle,
          borderRadius: BorderRadius.circular(McRadius.sm),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              spacing: 6,
              children: [
                Icon(Icons.dns_outlined, size: 16, color: foreground),
                Expanded(
                  child: Text(
                    l10n.vtaDetailsTitle,
                    style: context.textTheme.labelLarge?.copyWith(
                      color: foreground,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Icon(
                  expanded.value ? Icons.expand_less : Icons.expand_more,
                  color: foreground,
                ),
              ],
            ),
          ),
        ),
        AnimatedSize(
          duration: _animation,
          alignment: Alignment.topCenter,
          child: expanded.value
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: 8,
                  children: [
                    _Field(
                      label: l10n.vtaDetailsContextId,
                      value: contextId,
                      color: foreground,
                    ),
                    _Field(
                      label: l10n.vtaDetailsProfileId,
                      value: profileId,
                      color: foreground,
                    ),
                    FutureBuilder(
                      future: document.value,
                      builder: (context, snapshot) => _Profile(
                        snapshot: snapshot,
                        onRetry: load,
                        color: foreground,
                      ),
                    ),
                  ],
                )
              : const SizedBox(width: double.infinity),
        ),
      ],
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
      body = SelectableText(
        _json.convert(_shortened(document, l10n)),
        key: const Key('vta_details_profile'),
        style: textTheme.labelSmall?.copyWith(
          color: color,
          fontFamily: 'monospace',
          height: 1.4,
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
                icon: const Icon(Icons.copy),
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
