import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../../../infrastructure/extensions/build_context_extensions.dart';

/// Shows [json] in a sheet under [title], with [icon] and an optional
/// [subtitle] such as the document's Trust Task type: indented, coloured by
/// kind, selectable, and copied whole from the header. Plain text only: it
/// is a document someone else may have written.
Future<void> showVtcJoinJson(
  BuildContext context, {
  required String title,
  required Map<String, dynamic> json,
  IconData icon = Icons.data_object,
  String? subtitle,
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
    required this.textKey,
  });

  final String title;
  final Map<String, dynamic> json;
  final IconData icon;
  final String? subtitle;
  final Key textKey;

  static const _radius = Radius.circular(24);
  static const _copiedFor = Duration(seconds: 2);

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colorScheme;
    final textTheme = context.textTheme;
    final copied = useState(false);
    final text = useMemoized(
      () => const JsonEncoder.withIndent('  ').convert(json),
      [json],
    );
    final spans = useMemoized(
      () => (_JsonSpans(_JsonColors.of(colors))..value(json, 0)).spans,
      [json, colors],
    );

    Future<void> copy() async {
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
          color: colors.surfaceContainerHigh,
          borderRadius: const BorderRadius.vertical(top: _radius),
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
                  color: colors.onSurfaceVariant.withAlpha(100),
                  borderRadius: BorderRadius.circular(2),
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
                    backgroundColor: colors.primaryContainer,
                    child: Icon(icon, color: colors.onPrimaryContainer),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 2,
                      children: [
                        Text(
                          title,
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (subtitle case final subtitle?)
                          Text(
                            subtitle,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: textTheme.bodySmall?.copyWith(
                              color: colors.onSurfaceVariant,
                              fontFamily: 'monospace',
                            ),
                          ),
                      ],
                    ),
                  ),
                  IconButton(
                    key: const Key('vtc_join_json_copy'),
                    icon: Icon(copied.value ? Icons.check : Icons.copy),
                    tooltip: copied.value
                        ? l10n.copiedToClipboard
                        : l10n.vtcJoinJsonCopy,
                    onPressed: copy,
                  ),
                  IconButton(
                    key: const Key('vtc_join_json_close'),
                    icon: const Icon(Icons.close),
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
                  color: colors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: colors.outlineVariant),
                ),
                clipBehavior: Clip.antiAlias,
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  child: SelectableText.rich(
                    TextSpan(children: spans),
                    key: textKey,
                    style: textTheme.bodySmall?.copyWith(
                      color: colors.onSurface,
                      fontFamily: 'monospace',
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

/// The colours of each kind of JSON token, from the theme.
class _JsonColors {
  const _JsonColors({
    required this.key,
    required this.string,
    required this.literal,
    required this.punctuation,
  });

  factory _JsonColors.of(ColorScheme colors) => _JsonColors(
    key: colors.primary,
    string: colors.tertiary,
    literal: colors.secondary,
    punctuation: colors.onSurfaceVariant,
  );

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
