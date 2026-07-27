import 'package:flutter/widgets.dart';
import 'package:meeting_place_chat/meeting_place_chat.dart' as chat;

class ChatMentionHighlightingTextController extends TextEditingController {
  ChatMentionHighlightingTextController({
    super.text,
    List<chat.ChatMention> Function(String text)? mentionsForText,
  }) : _mentionsForText = mentionsForText ?? _emptyMentions;

  static List<chat.ChatMention> _emptyMentions(String text) => const [];

  List<chat.ChatMention> Function(String text) _mentionsForText;
  TextStyle? _mentionStyle;

  void setMentionStyle(TextStyle? mentionStyle) {
    _mentionStyle = mentionStyle;
  }

  void setMentionsResolver(
    List<chat.ChatMention> Function(String text) resolver,
  ) {
    _mentionsForText = resolver;
  }

  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    return buildMentionTextSpan(
      text: text,
      mentions: _mentionsForText(text),
      style: style,
      mentionStyle: _mentionStyle,
      withComposing: withComposing,
      composing: value.composing,
    );
  }
}

TextSpan buildMentionTextSpan({
  required String text,
  required List<chat.ChatMention> mentions,
  required TextStyle? style,
  required TextStyle? mentionStyle,
  required bool withComposing,
  required TextRange composing,
  String Function(chat.ChatMention mention, String rawText)? mentionTextBuilder,
}) {
  if (text.isEmpty) {
    return TextSpan(style: style, text: text);
  }

  final validMentions = mentions.where((mention) {
    final start = mention.start;
    final end = mention.start + mention.length;
    return start >= 0 && start < end && end <= text.length;
  }).toList()..sort((a, b) => a.start.compareTo(b.start));

  final hasComposingRange =
      withComposing &&
      composing.isValid &&
      !composing.isCollapsed &&
      composing.start >= 0 &&
      composing.end <= text.length;

  final boundaries = <int>{0, text.length};
  for (final mention in validMentions) {
    boundaries
      ..add(mention.start)
      ..add(mention.start + mention.length);
  }
  if (hasComposingRange) {
    boundaries
      ..add(composing.start)
      ..add(composing.end);
  }

  final sortedBoundaries = boundaries.toList()..sort();
  final children = <InlineSpan>[];

  for (var index = 0; index < sortedBoundaries.length - 1; index++) {
    final start = sortedBoundaries[index];
    final end = sortedBoundaries[index + 1];
    if (start >= end) continue;

    chat.ChatMention? mention;
    for (final candidate in validMentions) {
      if (candidate.start <= start &&
          start < candidate.start + candidate.length) {
        mention = candidate;
        break;
      }
    }
    final isMention = mention != null;
    final isComposing =
        hasComposingRange && composing.start <= start && end <= composing.end;
    final rawSegmentText = text.substring(start, end);

    TextStyle? segmentStyle;
    if (isMention) {
      segmentStyle = mentionStyle;
    }
    if (isComposing) {
      segmentStyle = (segmentStyle ?? const TextStyle()).merge(
        const TextStyle(decoration: TextDecoration.underline),
      );
    }

    children.add(
      TextSpan(
        text:
            mention != null &&
                mentionTextBuilder != null &&
                start == mention.start &&
                end == mention.start + mention.length
            ? mentionTextBuilder(mention, rawSegmentText)
            : rawSegmentText,
        style: segmentStyle,
      ),
    );
  }

  return TextSpan(style: style, children: children);
}
