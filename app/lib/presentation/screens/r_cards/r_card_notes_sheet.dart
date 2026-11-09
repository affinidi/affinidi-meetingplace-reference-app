import 'package:flutter/material.dart';

import '../../../infrastructure/extensions/build_context_extensions.dart';
import '../../themes/tokens/mc_radius.dart';

class RCardNotesSheet extends StatefulWidget {
  const RCardNotesSheet({
    super.key,
    required this.initialNotes,
    required this.onSave,
  });

  final String? initialNotes;
  final Future<void> Function(String notes) onSave;

  static Future<void> show({
    required BuildContext context,
    required String? initialNotes,
    required Future<void> Function(String notes) onSave,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      clipBehavior: Clip.antiAlias,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(McRadius.xl)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: RCardNotesSheet(initialNotes: initialNotes, onSave: onSave),
      ),
    );
  }

  @override
  State<RCardNotesSheet> createState() => _RCardNotesSheetState();
}

class _RCardNotesSheetState extends State<RCardNotesSheet> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialNotes ?? '');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _hasChanges {
    final current = _controller.text;
    return current.trim() != (widget.initialNotes ?? '').trim();
  }

  bool get _canSave {
    final current = _controller.text.trim();
    return current.isNotEmpty && _hasChanges;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    final mc = context.mcColors;
    final textTheme = context.textTheme;
    final titleColor = mc.textPrimary;

    Future<void> save() async {
      if (!_canSave) return;
      await widget.onSave(_controller.text.trim());
      if (!context.mounted) return;
      Navigator.of(context).pop();
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 18, 8, 8),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  l10n.rCardNotesTitle,
                  style: textTheme.titleLarge?.copyWith(color: titleColor),
                ),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: Icon(Icons.close, color: titleColor),
              ),
            ],
          ),
        ),
        Divider(height: 1, thickness: 1, color: mc.hairline),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.rCardAddNotes,
                style: textTheme.labelLarge?.copyWith(color: titleColor),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _controller,
                minLines: 7,
                maxLines: 7,
                style: TextStyle(color: titleColor),
                decoration: InputDecoration(
                  hintText: l10n.rCardNotesPlaceholder,
                  hintStyle: TextStyle(color: mc.textTertiary),
                  contentPadding: const EdgeInsets.all(16),
                  filled: true,
                  fillColor: context.colorScheme.surfaceContainerLow,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(McRadius.xs),
                    borderSide: BorderSide(color: mc.hairlineStrong),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(McRadius.xs),
                    borderSide: BorderSide(color: mc.control, width: 2),
                  ),
                ),
              ),
            ],
          ),
        ),
        Divider(height: 1, thickness: 1, color: mc.hairline),
        SafeArea(
          top: false,
          left: false,
          right: false,
          minimum: const EdgeInsets.fromLTRB(24, 12, 24, 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                style: TextButton.styleFrom(
                  foregroundColor: titleColor,
                  textStyle: textTheme.titleSmall,
                ),
                child: Text(l10n.generalCancel),
              ),
              ValueListenableBuilder<TextEditingValue>(
                valueListenable: _controller,
                builder: (context, _, _) => SizedBox(
                  height: 44,
                  child: ElevatedButton(
                    onPressed: _canSave ? save : null,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 28),
                      textStyle: textTheme.titleSmall,
                    ),
                    child: Text(l10n.generalSave),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
