import 'package:flutter/material.dart';

import '../models/agent_persona.dart';
import '../models/agent_readiness_state.dart';
import '../models/tone_patterns.dart';

/// Displays a structured summary of what the agent has learned about the user.
///
/// Shows a placeholder when [AgentReadinessState.persona] is null.
/// All sub-widgets are private to this file.
class PersonaSummaryCard extends StatelessWidget {
  const PersonaSummaryCard({required this.readiness, super.key});

  final AgentReadinessState readiness;

  @override
  Widget build(BuildContext context) {
    final persona = readiness.persona;
    if (persona == null) {
      return const _PlaceholderCard();
    }
    return _PersonaContent(readiness: readiness, persona: persona);
  }
}

// ---------------------------------------------------------------------------
// Placeholder
// ---------------------------------------------------------------------------

class _PlaceholderCard extends StatelessWidget {
  const _PlaceholderCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade100),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Icon(
            Icons.psychology_outlined,
            size: 48,
            color: Colors.blue.shade300,
          ),
          const SizedBox(height: 8),
          Text(
            'Your agent is still learning',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.blue.shade700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Send more messages to help it understand your style.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: Colors.blue.shade600),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Full persona content
// ---------------------------------------------------------------------------

class _PersonaContent extends StatelessWidget {
  const _PersonaContent({required this.readiness, required this.persona});

  final AgentReadinessState readiness;
  final AgentPersona persona;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Header(messageCount: readiness.messagesObserved),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _TraitRow(
                  icon: Icons.chat_bubble_outline,
                  label: 'Style',
                  value: persona.communicationStyle.isEmpty
                      ? '—'
                      : persona.communicationStyle,
                ),
                const SizedBox(height: 12),
                _MiniChipRow(persona: persona),
                if (persona.commonPhrases.isNotEmpty ||
                    persona.avoidPhrases.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _PhraseSection(
                    used: persona.commonPhrases,
                    avoided: persona.avoidPhrases,
                  ),
                ],
                if (persona.topicsDiscussed.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _TopicsSection(topics: persona.topicsDiscussed),
                ],
                if (persona.tonePatterns != null) ...[
                  const SizedBox(height: 12),
                  _ToneSection(patterns: persona.tonePatterns!),
                ],
                if (persona.hardLimits.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _HardLimitsSection(limits: persona.hardLimits),
                ],
                if (readiness.scorePercent < 100 &&
                    readiness.whatsMissing.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _ImprovementSection(items: readiness.whatsMissing),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Header
// ---------------------------------------------------------------------------

class _Header extends StatelessWidget {
  const _Header({required this.messageCount});

  final int messageCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.blue.shade700,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          const Icon(Icons.smart_toy_outlined, color: Colors.white, size: 20),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'What your agent learned',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$messageCount msgs',
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Trait row
// ---------------------------------------------------------------------------

class _TraitRow extends StatelessWidget {
  const _TraitRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: Colors.blueGrey),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
        ),
        Expanded(child: Text(value, style: textTheme.bodySmall)),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Mini chip row (formality / length / emoji)
// ---------------------------------------------------------------------------

class _MiniChipRow extends StatelessWidget {
  const _MiniChipRow({required this.persona});

  final AgentPersona persona;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      runSpacing: 4,
      children: [
        _MiniChip(label: persona.formality),
        _MiniChip(label: persona.averageMessageLength),
        _MiniChip(label: persona.usesEmoji ? 'uses emoji' : 'no emoji'),
      ],
    );
  }
}

class _MiniChip extends StatelessWidget {
  const _MiniChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.blueGrey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blueGrey.shade200),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 11, color: Colors.blueGrey.shade700),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Phrase section
// ---------------------------------------------------------------------------

class _PhraseSection extends StatelessWidget {
  const _PhraseSection({required this.used, required this.avoided});

  final List<String> used;
  final List<String> avoided;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Phrases',
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 6,
          runSpacing: 4,
          children: [
            for (final p in used) _PhraseChip(phrase: p, isUsed: true),
            for (final p in avoided) _PhraseChip(phrase: p, isUsed: false),
          ],
        ),
      ],
    );
  }
}

class _PhraseChip extends StatelessWidget {
  const _PhraseChip({required this.phrase, required this.isUsed});

  final String phrase;
  final bool isUsed;

  @override
  Widget build(BuildContext context) {
    final bg = isUsed ? Colors.green.shade50 : Colors.grey.shade100;
    final border = isUsed ? Colors.green.shade300 : Colors.grey.shade300;
    final text = isUsed ? Colors.green.shade800 : Colors.grey.shade700;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: border),
      ),
      child: Text(phrase, style: TextStyle(fontSize: 11, color: text)),
    );
  }
}

// ---------------------------------------------------------------------------
// Topics section
// ---------------------------------------------------------------------------

class _TopicsSection extends StatelessWidget {
  const _TopicsSection({required this.topics});

  final List<String> topics;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Topics',
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 6,
          runSpacing: 4,
          children: topics
              .map(
                (t) => Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.indigo.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.indigo.shade200),
                  ),
                  child: Text(
                    t,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.indigo.shade700,
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Tone patterns section
// ---------------------------------------------------------------------------

class _ToneSection extends StatelessWidget {
  const _ToneSection({required this.patterns});

  final TonePatterns patterns;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tone',
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 6),
        if (patterns.whenAgreeing.isNotEmpty)
          _ToneRow(emoji: '✅', label: 'agreeing', value: patterns.whenAgreeing),
        if (patterns.whenDisagreeing.isNotEmpty)
          _ToneRow(
            emoji: '🙅',
            label: 'disagreeing',
            value: patterns.whenDisagreeing,
          ),
        if (patterns.whenAsking.isNotEmpty)
          _ToneRow(emoji: '🙋', label: 'asking', value: patterns.whenAsking),
      ],
    );
  }
}

class _ToneRow extends StatelessWidget {
  const _ToneRow({
    required this.emoji,
    required this.label,
    required this.value,
  });

  final String emoji;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 6),
          Text(
            '$label: ',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500),
          ),
          Expanded(
            child: Text(value, style: Theme.of(context).textTheme.bodySmall),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Hard limits section
// ---------------------------------------------------------------------------

class _HardLimitsSection extends StatelessWidget {
  const _HardLimitsSection({required this.limits});

  final List<String> limits;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hard limits',
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 6,
          runSpacing: 4,
          children: limits
              .map(
                (l) => Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.block, size: 11, color: Colors.red.shade600),
                      const SizedBox(width: 4),
                      Text(
                        l,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.red.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Improvement section (shown when score < 100)
// ---------------------------------------------------------------------------

class _ImprovementSection extends StatelessWidget {
  const _ImprovementSection({required this.items});

  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.tips_and_updates_outlined,
                size: 14,
                color: Colors.orange.shade700,
              ),
              const SizedBox(width: 6),
              Text(
                'To improve accuracy',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.orange.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          for (final item in items)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '• ',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.orange.shade700,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      item,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.orange.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
