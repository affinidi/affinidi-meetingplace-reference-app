import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../infrastructure/extensions/build_context_extensions.dart';

class MnemonicPill extends StatelessWidget {
  const MnemonicPill({
    super.key,
    required this.mnemonic,
    this.isCopiable = false,
    this.suffix,
  });

  final String mnemonic;
  final bool isCopiable;
  final Widget? suffix;

  Future<void> _copyToClipboard(BuildContext context, String text) async {
    if (!context.mounted || text.isEmpty) return;
    await Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(context.l10n.copiedToClipboard),
        duration: const Duration(seconds: 2),
        backgroundColor: context.customColors.success,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (mnemonic.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: isCopiable
              ? () async => await _copyToClipboard(context, mnemonic)
              : null,
          child: Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              ...mnemonic.split(' ').map(
                    (word) => Chip(
                      label: Text(
                        word,
                        style: context.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      backgroundColor: context.colorScheme.secondary,
                    ),
                  ),
              if (suffix != null) suffix!,
            ],
          ),
        ),
      ),
    );
  }
}
