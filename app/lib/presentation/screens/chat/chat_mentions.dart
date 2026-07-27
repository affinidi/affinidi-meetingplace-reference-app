part of 'chat_screen.dart';

class _ChatMentionSuggestions extends StatelessWidget {
  const _ChatMentionSuggestions({
    required this.suggestions,
    required this.onSelected,
  });

  final List<ChatMentionCandidate> suggestions;
  final ValueChanged<ChatMentionCandidate> onSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('chat_mention_suggestions'),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: context.colorScheme.outline.withValues(alpha: 0.20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var index = 0; index < suggestions.length; index++) ...[
                if (index > 0)
                  Divider(
                    height: 1,
                    color: context.colorScheme.outline.withValues(alpha: 0.12),
                  ),
                _ChatMentionSuggestionTile(
                  candidate: suggestions[index],
                  onSelected: onSelected,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ChatMentionSuggestionTile extends StatelessWidget {
  const _ChatMentionSuggestionTile({
    required this.candidate,
    required this.onSelected,
  });

  final ChatMentionCandidate candidate;
  final ValueChanged<ChatMentionCandidate> onSelected;

  @override
  Widget build(BuildContext context) {
    final displayLabel = candidate.label.startsWith('@')
        ? candidate.label.substring(1)
        : candidate.label;

    return Material(
      color: Colors.transparent,
      child: ListTile(
        key: Key('chat_mention_suggestion_${candidate.target}'),
        dense: true,
        leading: ProfileCircleAvatar(radius: 18, image: candidate.avatarImage),
        title: Text(displayLabel),
        subtitle: candidate.subtitle == null ? null : Text(candidate.subtitle!),
        onTap: () => onSelected(candidate),
      ),
    );
  }
}

class _ChatMentionDraftController extends ChangeNotifier {
  _ChatMentionDraftController({
    required TextEditingController textController,
    List<chat.ChatMention> initialMentions = const [],
  }) : _textController = textController,
       _tokens = _tokensFromMentions(textController.text, initialMentions),
       _lastValue = textController.value {
    _textController.addListener(_handleTextChanged);
    _refreshSuggestions();
  }

  final TextEditingController _textController;
  final Debouncer _debouncer = Debouncer();
  TextEditingValue _lastValue;
  List<_ChatMentionToken> _tokens;
  List<ChatMentionCandidate> _allCandidates = const [];
  List<ChatMentionCandidate> _suggestions = const [];
  _ChatActiveMentionQuery? _activeQuery;
  bool _enabled = false;

  List<ChatMentionCandidate> get suggestions => _suggestions;

  bool get shouldShowSuggestions => _enabled && _suggestions.isNotEmpty;

  List<chat.ChatMention> get mentions => mentionsForText(_textController.text);

  void setEnabled(bool enabled) {
    if (_enabled == enabled) return;
    _enabled = enabled;
    _refreshSuggestions(notify: true);
  }

  void setCandidates(List<ChatMentionCandidate> candidates) {
    _allCandidates = List<ChatMentionCandidate>.unmodifiable(candidates);
    _refreshSuggestions(notify: true);
  }

  List<chat.ChatMention> mentionsForText(String text) {
    final mentions = <chat.ChatMention>[];
    for (final token in _tokens) {
      final start = token.start;
      final end = token.end;
      if (start < 0 || end > text.length || start >= end) continue;
      if (text.substring(start, end) != token.label) continue;
      mentions.add(
        chat.ChatMention(
          target: token.target,
          start: start,
          length: token.length,
          display: token.label,
        ),
      );
    }
    return mentions..sort((a, b) => a.start.compareTo(b.start));
  }

  void selectCandidate(ChatMentionCandidate candidate) {
    final query = _activeQuery;
    if (!_enabled || query == null) return;

    final text = _textController.text;
    final replacementToken = _matchingTokenForQuery(text, query);
    final replacementEnd = replacementToken?.end ?? query.end;
    final insertedText = replacementEnd == text.length
        ? '${candidate.label} '
        : candidate.label;
    final newText = text.replaceRange(
      query.start,
      replacementEnd,
      insertedText,
    );
    final updatedTokens = _reconcileTokens(text, newText, _tokens)
      ..add(
        _ChatMentionToken(
          target: candidate.target,
          label: candidate.label,
          start: query.start,
        ),
      );
    updatedTokens.sort((a, b) => a.start.compareTo(b.start));

    final newValue = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(
        offset: query.start + insertedText.length,
      ),
    );

    _tokens = updatedTokens;
    _lastValue = newValue;
    _textController.value = newValue;
    _refreshSuggestions(notify: true);
  }

  _ChatMentionToken? _matchingTokenForQuery(
    String text,
    _ChatActiveMentionQuery query,
  ) {
    for (final token in _tokens) {
      if (token.start != query.start || token.end < query.end) continue;
      if (token.end > text.length) continue;
      if (text.substring(token.start, token.end) != token.label) continue;
      return token;
    }
    return null;
  }

  _ChatMentionToken? _matchingTokenAtCursor(String text, int cursor) {
    for (final token in _tokens) {
      if (cursor <= token.start || cursor > token.end) continue;
      if (token.end > text.length) continue;
      if (text.substring(token.start, token.end) != token.label) continue;
      return token;
    }
    return null;
  }

  void _handleTextChanged() {
    final value = _textController.value;
    final textChanged = value.text != _lastValue.text;
    final selectionChanged = value.selection != _lastValue.selection;

    if (!textChanged && !selectionChanged) return;

    if (textChanged) {
      final expandedDeletion = _expandSingleCharacterDeletionOverMention(
        _lastValue,
        value,
      );
      if (expandedDeletion != null) {
        _tokens = _reconcileTokens(
          _lastValue.text,
          expandedDeletion.text,
          _tokens,
        );
        _lastValue = expandedDeletion;
        _textController.value = expandedDeletion;
        _refreshSuggestions(notify: true);
        return;
      }

      _tokens = _reconcileTokens(_lastValue.text, value.text, _tokens);
      final wasMentionQueryActive = _findActiveMentionQuery(_lastValue) != null;
      final isMentionQueryActive = _findActiveMentionQuery(value) != null;
      if (wasMentionQueryActive || isMentionQueryActive) {
        _debouncer.cancel();
        _refreshSuggestions(notify: true);
      } else {
        _debouncer.run(() => _refreshSuggestions(notify: true));
      }
    } else {
      _refreshSuggestions(notify: true);
    }

    _lastValue = value;
  }

  TextEditingValue? _expandSingleCharacterDeletionOverMention(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (oldValue.text.length != newValue.text.length + 1) return null;

    final oldText = oldValue.text;
    final newText = newValue.text;
    var prefix = 0;
    final sharedPrefixLimit = math.min(oldText.length, newText.length);
    while (prefix < sharedPrefixLimit && oldText[prefix] == newText[prefix]) {
      prefix += 1;
    }

    var suffix = 0;
    while (suffix < oldText.length - prefix &&
        suffix < newText.length - prefix &&
        oldText[oldText.length - 1 - suffix] ==
            newText[newText.length - 1 - suffix]) {
      suffix += 1;
    }

    final deletedStart = prefix;
    final deletedEnd = oldText.length - suffix;
    if (deletedEnd - deletedStart != 1) return null;

    final token = _matchingTokenOverlappingRange(
      oldText,
      deletedStart,
      deletedEnd,
    );
    if (token == null) return null;

    var removalEnd = token.end;
    if (removalEnd < oldText.length && _isWhitespace(oldText[removalEnd])) {
      removalEnd += 1;
    }

    return TextEditingValue(
      text: oldText.replaceRange(token.start, removalEnd, ''),
      selection: TextSelection.collapsed(offset: token.start),
    );
  }

  _ChatMentionToken? _matchingTokenOverlappingRange(
    String text,
    int start,
    int end,
  ) {
    for (final token in _tokens) {
      if (token.end <= start || token.start >= end) continue;
      if (token.end > text.length) continue;
      if (text.substring(token.start, token.end) != token.label) continue;
      return token;
    }
    return null;
  }

  void _refreshSuggestions({bool notify = false}) {
    final value = _textController.value;
    final cursor = value.selection.extentOffset;
    final nextQuery =
        !_enabled ||
            !value.selection.isCollapsed ||
            _matchingTokenAtCursor(value.text, cursor) != null
        ? null
        : _findActiveMentionQuery(value);
    final nextSuggestions = nextQuery == null
        ? const <ChatMentionCandidate>[]
        : _filterCandidates(nextQuery.query);
    final didChange =
        nextQuery != _activeQuery ||
        !_listShallowEquals(nextSuggestions, _suggestions);

    _activeQuery = nextQuery;
    _suggestions = nextSuggestions;

    if (notify && didChange) {
      notifyListeners();
    }
  }

  List<ChatMentionCandidate> _filterCandidates(String query) {
    final normalizedQuery = query.toLowerCase();
    final prefixMatches = <ChatMentionCandidate>[];
    final otherMatches = <ChatMentionCandidate>[];

    for (final candidate in _allCandidates) {
      if (normalizedQuery.isNotEmpty &&
          !candidate.searchText.contains(normalizedQuery)) {
        continue;
      }

      final target =
          normalizedQuery.isEmpty ||
              candidate.normalizedLabel.startsWith(normalizedQuery)
          ? prefixMatches
          : otherMatches;
      _insertSortedCandidate(target, candidate);
    }

    if (prefixMatches.length == _maxMentionSuggestions) {
      return List<ChatMentionCandidate>.unmodifiable(prefixMatches);
    }

    if (otherMatches.isEmpty) {
      return List<ChatMentionCandidate>.unmodifiable(prefixMatches);
    }

    return List<ChatMentionCandidate>.unmodifiable([
      ...prefixMatches,
      ...otherMatches.take(_maxMentionSuggestions - prefixMatches.length),
    ]);
  }

  @override
  void dispose() {
    _debouncer.cancel();
    _textController.removeListener(_handleTextChanged);
    super.dispose();
  }

  static List<_ChatMentionToken> _tokensFromMentions(
    String text,
    List<chat.ChatMention> mentions,
  ) {
    final tokens = <_ChatMentionToken>[];
    for (final mention in mentions) {
      final start = mention.start;
      final end = start + mention.length;
      if (start < 0 || end > text.length || start >= end) continue;
      tokens.add(
        _ChatMentionToken(
          target: mention.target,
          label: text.substring(start, end),
          start: start,
        ),
      );
    }
    tokens.sort((a, b) => a.start.compareTo(b.start));
    return tokens;
  }
}

const _maxMentionSuggestions = 5;

void _insertSortedCandidate(
  List<ChatMentionCandidate> candidates,
  ChatMentionCandidate candidate,
) {
  var insertAt = candidates.length;
  for (var index = 0; index < candidates.length; index++) {
    if (candidate.label.compareTo(candidates[index].label) < 0) {
      insertAt = index;
      break;
    }
  }

  if (insertAt == candidates.length &&
      candidates.length >= _maxMentionSuggestions) {
    return;
  }

  candidates.insert(insertAt, candidate);
  if (candidates.length > _maxMentionSuggestions) {
    candidates.removeLast();
  }
}

class _ChatMentionToken {
  const _ChatMentionToken({
    required this.target,
    required this.label,
    required this.start,
  });

  final String target;
  final String label;
  final int start;

  int get length => label.length;
  int get end => start + length;

  _ChatMentionToken shift(int delta) =>
      _ChatMentionToken(target: target, label: label, start: start + delta);
}

class _ChatActiveMentionQuery {
  const _ChatActiveMentionQuery({
    required this.start,
    required this.end,
    required this.query,
  });

  final int start;
  final int end;
  final String query;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _ChatActiveMentionQuery &&
          runtimeType == other.runtimeType &&
          start == other.start &&
          end == other.end &&
          query == other.query;

  @override
  int get hashCode => Object.hash(start, end, query);
}

_ChatActiveMentionQuery? _findActiveMentionQuery(TextEditingValue value) {
  final selection = value.selection;
  if (!selection.isCollapsed) return null;

  final cursor = selection.extentOffset;
  if (cursor <= 0 || cursor > value.text.length) return null;

  final text = value.text;
  var start = cursor - 1;
  while (start >= 0) {
    final char = text[start];
    if (_isWhitespace(char)) {
      start += 1;
      break;
    }
    if (char == '@') break;
    start -= 1;
  }

  if (start < 0 || start >= text.length || text[start] != '@') return null;
  if (start > 0 && !_isWhitespace(text[start - 1])) return null;

  final token = text.substring(start + 1, cursor);
  if (token.contains(RegExp(r'[@\s]'))) return null;

  return _ChatActiveMentionQuery(start: start, end: cursor, query: token);
}

bool _isWhitespace(String char) => RegExp(r'\s').hasMatch(char);

List<_ChatMentionToken> _reconcileTokens(
  String oldText,
  String newText,
  List<_ChatMentionToken> current,
) {
  if (oldText == newText) return List<_ChatMentionToken>.from(current);

  var prefix = 0;
  final sharedPrefixLimit = math.min(oldText.length, newText.length);
  while (prefix < sharedPrefixLimit && oldText[prefix] == newText[prefix]) {
    prefix += 1;
  }

  var suffix = 0;
  while (suffix < oldText.length - prefix &&
      suffix < newText.length - prefix &&
      oldText[oldText.length - 1 - suffix] ==
          newText[newText.length - 1 - suffix]) {
    suffix += 1;
  }

  final oldChangedEnd = oldText.length - suffix;
  final delta = newText.length - oldText.length;

  return current
      .map((token) {
        if (token.end <= prefix) return token;
        if (token.start >= oldChangedEnd) return token.shift(delta);
        return null;
      })
      .whereType<_ChatMentionToken>()
      .where((token) {
        final start = token.start;
        final end = token.end;
        if (start < 0 || end > newText.length || start >= end) return false;
        return newText.substring(start, end) == token.label;
      })
      .toList(growable: true);
}

bool _listShallowEquals<T>(List<T> left, List<T> right) {
  if (identical(left, right)) return true;
  if (left.length != right.length) return false;
  for (var index = 0; index < left.length; index++) {
    if (left[index] != right[index]) return false;
  }
  return true;
}
