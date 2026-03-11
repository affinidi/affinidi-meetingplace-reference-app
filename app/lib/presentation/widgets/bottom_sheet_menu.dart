import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../../infrastructure/extensions/build_context_extensions.dart';
import '../../infrastructure/extensions/scroll_controller_extensions.dart';

class BottomSheetMenu extends HookWidget {
  BottomSheetMenu({
    super.key,
    this.header,
    required this.itemCount,
    required this.itemBuilder,
    this.showHandle = false,
  });

  final int itemCount;
  final Widget Function(BuildContext, int) itemBuilder;
  final String? header;
  final bool showHandle;

  @override
  Widget build(BuildContext context) {
    final scrollController = useScrollController();
    final isScrollable = useState(false);
    final scaler = MediaQuery.maybeTextScalerOf(context);
    final colors = context.colorScheme;

    void updateScrollable() {
      isScrollable.value = scrollController.isScrollable;
    }

    useEffect(() {
      if (!context.mounted) return;
      Future.microtask(updateScrollable);

      return null;
    }, [scrollController.isScrollable, scaler]);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (showHandle)
          Center(
            child: Container(
              width: 32,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey[600],
                borderRadius: BorderRadius.circular(2.5),
              ),
            ),
          ),
        if (header != null)
          ColoredBox(
            color: colors.inverseSurface,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Text(header!, textAlign: TextAlign.center),
            ),
          ),
        Flexible(
          child: ListView.builder(
            controller: scrollController,
            shrinkWrap: true,
            physics: isScrollable.value
                ? const AlwaysScrollableScrollPhysics()
                : const NeverScrollableScrollPhysics(),
            itemCount: itemCount,
            itemBuilder: itemBuilder,
          ),
        ),
      ],
    );
  }
}
