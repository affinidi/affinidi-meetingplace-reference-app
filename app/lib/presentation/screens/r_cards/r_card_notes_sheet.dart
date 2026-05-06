import 'package:flutter/material.dart';

import '../../../infrastructure/extensions/build_context_extensions.dart';

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
      backgroundColor: Colors.black,
      clipBehavior: Clip.antiAlias,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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
    _controller.addListener(() {
      setState(() {});
    });
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

    const titleColor = Colors.white;
    final dividerColor = context.colorScheme.primary;
    final fieldBorderColor = context.colorScheme.primary;
    const hintColor = Color(0xFF9CA3AF);
    final saveButtonColor = context.colorScheme.primary;

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
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: titleColor,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close, color: titleColor),
              ),
            ],
          ),
        ),
        Divider(height: 1, thickness: 1, color: dividerColor),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.rCardAddNotes,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: titleColor,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _controller,
                minLines: 7,
                maxLines: 7,
                style: const TextStyle(color: titleColor),
                decoration: InputDecoration(
                  hintText: l10n.rCardNotesPlaceholder,
                  hintStyle: const TextStyle(color: hintColor),
                  contentPadding: const EdgeInsets.all(16),
                  filled: true,
                  fillColor: const Color(0xFF1F1F1F),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4),
                    borderSide: BorderSide(color: fieldBorderColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4),
                    borderSide: BorderSide(color: fieldBorderColor, width: 2),
                  ),
                ),
              ),
            ],
          ),
        ),
        Divider(height: 1, thickness: 1, color: dividerColor),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                style: TextButton.styleFrom(
                  foregroundColor: titleColor,
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                child: Text(l10n.generalCancel),
              ),
              SizedBox(
                height: 44,
                child: ElevatedButton(
                  onPressed: _canSave ? save : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: saveButtonColor,
                    disabledBackgroundColor: saveButtonColor.withValues(
                      alpha: 0.4,
                    ),
                    foregroundColor: Colors.black,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    shape: const StadiumBorder(),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  child: Text(l10n.generalSave),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
