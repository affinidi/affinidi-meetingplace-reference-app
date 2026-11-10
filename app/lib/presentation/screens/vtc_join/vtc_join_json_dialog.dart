import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../../../infrastructure/extensions/build_context_extensions.dart';
import '../../themes/tokens/mc_colors.dart';
import '../../themes/tokens/mc_icons.dart';
import '../../themes/tokens/mc_radius.dart';
import '../../themes/tokens/mc_typography.dart';

/// Shows [json] in a sheet under [title], with [icon] and an optional
/// [subtitle] such as the document's Trust Task type: indented, coloured by
/// kind, selectable, and copied whole from the header. Plain text only: it
/// is a document someone else may have written. A [command], such as the
/// `pnm` command that fetches the same document from the member's VTA, is
/// copied from the header too.
Future<void> showVtcJoinJson(
  BuildContext context, {
  required String title,
  required Map<String, dynamic> json,
  IconData icon = McIcons.code,
  String? subtitle,
  String? command,
  Key textKey = const Key('vtc_join_json'),
}) {
  return showModalBottomSheet<void>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _JsonSheet(
      title: title,
      json: json,
      icon: icon,
      subtitle: subtitle,
      command: command,
      textKey: textKey,
    ),
  );
}

class _JsonSheet extends HookWidget {
  const _JsonSheet({
    required this.title,
    required this.json,
    required this.icon,
    required this.subtitle,
    required this.command,
    required this.textKey,
  });

  final String title;
  final Map<String, dynamic> json;
  final IconData icon;
  final String? subtitle;
  final String? command;
  final Key textKey;

  static const _radius = Radius.circular(McRadius.xl);
  static const _copiedFor = Duration(seconds: 2);

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colorScheme;
    final mc = context.mcColors;
    final textTheme = context.textTheme;
    final copied = useState(false);
    final commandCopied = useState(false);
    final text = useMemoized(
      () => const JsonEncoder.withIndent('  ').convert(json),
      [json],
    );
    final spans = useMemoized(
      () => (_JsonSpans(_JsonColors.of(mc))..value(json, 0)).spans,
      [json, mc],
    );

    Future<void> copy(String text, ValueNotifier<bool> copied) async {
      await Clipboard.setData(ClipboardData(text: text));
      copied.value = true;
      await Future<void>.delayed(_copiedFor);
      if (context.mounted) copied.value = false;
    }

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.75,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      builder: (context, scrollController) => DecoratedBox(
        decoration: BoxDecoration(
          color: mc.raised,
          borderRadius: const BorderRadius.vertical(top: _radius),
          border: Border(top: BorderSide(color: mc.hairline)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
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
              padding: const EdgeInsets.fromLTRB(20, 8, 8, 12),
              child: Row(
                spacing: 12,
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: colors.secondary,
                    child: Icon(icon, color: colors.onSecondary),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 2,
                      children: [
                        Text(
                          title,
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (subtitle case final subtitle?)
                          Text(
                            subtitle,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: McTypography.code.copyWith(
                              color: mc.textSecondary,
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (command case final command?)
                    IconButton(
                      key: const Key('vtc_join_json_copy_command'),
                      icon: Icon(
                        commandCopied.value ? McIcons.check : McIcons.terminal,
                      ),
                      tooltip: commandCopied.value
                          ? l10n.copiedToClipboard
                          : l10n.linkedVtaCopyCommand,
                      onPressed: () => copy(command, commandCopied),
                    ),
                  IconButton(
                    key: const Key('vtc_join_json_copy'),
                    icon: Icon(copied.value ? McIcons.check : McIcons.copy),
                    tooltip: copied.value
                        ? l10n.copiedToClipboard
                        : l10n.vtcJoinJsonCopy,
                    onPressed: () => copy(text, copied),
                  ),
                  IconButton(
                    key: const Key('vtc_join_json_close'),
                    icon: const Icon(McIcons.close),
                    tooltip: l10n.generalClose,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                decoration: BoxDecoration(
                  color: _JsonColors.background(colors),
                  borderRadius: BorderRadius.circular(McRadius.lg),
                  border: Border.all(color: mc.hairline),
                ),
                clipBehavior: Clip.antiAlias,
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  child: SelectableText.rich(
                    TextSpan(children: spans),
                    key: textKey,
                    style: McTypography.code.copyWith(
                      color: mc.textPrimary,
                      height: 1.5,
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

/// The colours of each kind of JSON token, on the sunken panel they are
/// drawn on: Mission Control text tokens, readable in both modes. Strings
/// stay neutral; the status tokens that would tint them are too faint as
/// copy on the light panel.
class _JsonColors {
  const _JsonColors({
    required this.key,
    required this.string,
    required this.literal,
    required this.punctuation,
  });

  factory _JsonColors.of(McColors mc) => _JsonColors(
    key: mc.highlightSecondary,
    string: mc.textPrimary,
    literal: mc.warning,
    // Readable, but steps back from the values.
    punctuation: mc.textSecondary,
  );

  /// The panel the document is drawn on.
  static Color background(ColorScheme colors) => colors.surfaceContainerLowest;

  final Color key;
  final Color string;
  final Color literal;
  final Color punctuation;
}

/// Writes a JSON value as coloured spans, laid out exactly as
/// `JsonEncoder.withIndent('  ')` writes it, so a selection copies as JSON.
class _JsonSpans {
  _JsonSpans(this.colors);

  final _JsonColors colors;
  final spans = <TextSpan>[];

  static const _indent = '  ';

  void value(Object? value, int depth) {
    switch (value) {
      case final Map<dynamic, dynamic> map:
        _members('{', '}', [
          for (final MapEntry(:key, :value) in map.entries)
            () {
              _put(jsonEncode('$key'), colors.key);
              _put(': ', colors.punctuation);
              this.value(value, depth + 1);
            },
        ], depth);
      case final List<dynamic> list:
        _members('[', ']', [
          for (final item in list) () => this.value(item, depth + 1),
        ], depth);
      case final String string:
        _put(jsonEncode(string), colors.string);
      default:
        _put(jsonEncode(value), colors.literal);
    }
  }

  void _members(
    String open,
    String close,
    List<void Function()> members,
    int depth,
  ) {
    if (members.isEmpty) return _put('$open$close', colors.punctuation);
    _put('$open\n', colors.punctuation);
    for (final (index, member) in members.indexed) {
      _put(_indent * (depth + 1), colors.punctuation);
      member();
      _put(index < members.length - 1 ? ',\n' : '\n', colors.punctuation);
    }
    _put('${_indent * depth}$close', colors.punctuation);
  }

  void _put(String text, Color color) => spans.add(
    TextSpan(
      text: text,
      style: TextStyle(color: color),
    ),
  );
}
