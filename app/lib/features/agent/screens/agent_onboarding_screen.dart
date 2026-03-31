import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../models/onboarding_question.dart';
import '../providers/agent_providers.dart';

/// Full-screen wizard that gathers the user's communication style via 8
/// targeted questions, then calls POST /onboard to synthesise a persona and
/// set readinessScore = 82 in one shot — no organic message accumulation needed.
class AgentOnboardingScreen extends ConsumerStatefulWidget {
  const AgentOnboardingScreen({required this.ownerDid, super.key});

  final String ownerDid;

  @override
  ConsumerState<AgentOnboardingScreen> createState() =>
      _AgentOnboardingScreenState();
}

class _AgentOnboardingScreenState extends ConsumerState<AgentOnboardingScreen> {
  final _questions = OnboardingQuestion.all;
  final _answers = <String, dynamic>{};
  final _pageController = PageController();
  int _currentPage = 0;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // ── Validation ─────────────────────────────────────────────────────────────

  bool _isAnswered(OnboardingQuestion q) {
    final answer = _answers[q.id];
    if (answer == null) return false;
    if (answer is List) return answer.isNotEmpty;
    if (answer is String) return answer.trim().isNotEmpty;
    return false;
  }

  // ── Navigation ─────────────────────────────────────────────────────────────

  void _next() {
    if (_currentPage < _questions.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _submit();
    }
  }

  void _back() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.of(context).pop(false);
    }
  }

  Future<void> _submit() async {
    setState(() => _isSubmitting = true);
    final success = await ref
        .read(agentRepositoryProvider)
        .submitOnboarding(ownerDid: widget.ownerDid, answers: _answers);
    if (!mounted) return;
    setState(() => _isSubmitting = false);
    if (success) {
      Navigator.of(context).pop(true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Something went wrong. Please try again.'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final total = _questions.length;
    final progress = (_currentPage + 1) / total;
    final isLast = _currentPage == total - 1;
    final canProceed = _isAnswered(_questions[_currentPage]);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(false),
        ),
        title: const Text('Quick Setup'),
        centerTitle: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                '${_currentPage + 1} of $total',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Progress bar
          LinearProgressIndicator(
            value: progress,
            minHeight: 3,
            backgroundColor: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.1),
            valueColor: const AlwaysStoppedAnimation(Colors.deepPurpleAccent),
          ),

          // Question pages
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (i) => setState(() => _currentPage = i),
              itemCount: total,
              itemBuilder: (_, i) => _QuestionPage(
                question: _questions[i],
                answer: _answers[_questions[i].id],
                onChanged: (value) =>
                    setState(() => _answers[_questions[i].id] = value),
              ),
            ),
          ),

          // Bottom navigation
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Row(
                children: [
                  // Back
                  TextButton.icon(
                    onPressed: _isSubmitting ? null : _back,
                    icon: const Icon(Icons.arrow_back, size: 16),
                    label: Text(_currentPage == 0 ? 'Cancel' : 'Back'),
                  ),
                  const Spacer(),
                  // Next / Finish
                  _isSubmitting
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : FilledButton.icon(
                          onPressed: canProceed ? _next : null,
                          icon: Icon(
                            isLast ? Icons.check_rounded : Icons.arrow_forward,
                            size: 16,
                          ),
                          label: Text(isLast ? 'Finish' : 'Next'),
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.deepPurpleAccent,
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
}

// ── Individual question page ────────────────────────────────────────────────

class _QuestionPage extends StatelessWidget {
  const _QuestionPage({
    required this.question,
    required this.answer,
    required this.onChanged,
  });

  final OnboardingQuestion question;
  final dynamic answer;
  final ValueChanged<dynamic> onChanged;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question.title,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            question.subtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.65),
            ),
          ),
          const SizedBox(height: 32),
          _buildInput(context),
        ],
      ),
    );
  }

  Widget _buildInput(BuildContext context) {
    switch (question.inputType) {
      case QuestionInputType.singleChips:
        return _ChipGroup(
          options: question.options,
          selected: answer is String ? {answer as String} : {},
          multiSelect: false,
          onChanged: onChanged,
        );
      case QuestionInputType.multiChips:
        return _ChipGroup(
          options: question.options,
          selected: answer is List ? Set<String>.from(answer as List) : {},
          multiSelect: true,
          onChanged: onChanged,
        );
      case QuestionInputType.text:
        return _TextInput(
          initialValue: answer is String ? answer as String : '',
          placeholder: question.placeholder,
          multiline: false,
          onChanged: onChanged,
        );
      case QuestionInputType.textMultiline:
        return _TextInput(
          initialValue: answer is String ? answer as String : '',
          placeholder: question.placeholder,
          multiline: true,
          onChanged: onChanged,
        );
    }
  }
}

// ── Chip group ──────────────────────────────────────────────────────────────

class _ChipGroup extends StatelessWidget {
  const _ChipGroup({
    required this.options,
    required this.selected,
    required this.multiSelect,
    required this.onChanged,
  });

  final List<String> options;
  final Set<String> selected;
  final bool multiSelect;
  final ValueChanged<dynamic> onChanged;

  void _toggle(String option) {
    if (multiSelect) {
      final next = {...selected};
      if (next.contains(option)) {
        next.remove(option);
      } else {
        next.add(option);
      }
      onChanged(next.toList());
    } else {
      onChanged(option);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 10,
      children: options.map((option) {
        final isSelected = selected.contains(option);
        return GestureDetector(
          onTap: () => _toggle(option),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected
                  ? Colors.deepPurpleAccent
                  : Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isSelected
                    ? Colors.deepPurpleAccent
                    : Theme.of(
                        context,
                      ).colorScheme.outline.withValues(alpha: 0.3),
              ),
            ),
            child: Text(
              option,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: isSelected
                    ? Colors.white
                    : Theme.of(context).colorScheme.onSurface,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ── Text input ───────────────────────────────────────────────────────────────

class _TextInput extends StatefulWidget {
  const _TextInput({
    required this.initialValue,
    required this.placeholder,
    required this.multiline,
    required this.onChanged,
  });

  final String initialValue;
  final String placeholder;
  final bool multiline;
  final ValueChanged<String> onChanged;

  @override
  State<_TextInput> createState() => _TextInputState();
}

class _TextInputState extends State<_TextInput> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      onChanged: widget.onChanged,
      maxLines: widget.multiline ? 5 : 1,
      minLines: widget.multiline ? 3 : 1,
      textCapitalization: TextCapitalization.sentences,
      decoration: InputDecoration(
        hintText: widget.placeholder,
        hintStyle: TextStyle(
          color: Theme.of(
            context,
          ).colorScheme.onSurface.withValues(alpha: 0.35),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.deepPurpleAccent),
        ),
        contentPadding: const EdgeInsets.all(14),
      ),
    );
  }
}
