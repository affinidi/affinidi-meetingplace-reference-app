part of 'contacts_screen.dart';

class _ContactsSearchField extends HookConsumerWidget {
  const _ContactsSearchField();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(contactsScreenControllerProvider.notifier);
    final searchTextController = useTextEditingController();
    final text = useListenable(searchTextController).text;
    final colorScheme = context.colorScheme;
    final shouldShowFilter = ref.watch(
      contactsScreenControllerProvider
          .select((state) => state.shouldShowFilter),
    );

    useEffect(() {
      if (!shouldShowFilter) {
        searchTextController.clear();
      }
      return null;
    }, [shouldShowFilter]);

    if (!shouldShowFilter) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Container(
        height: 35,
        decoration: BoxDecoration(
          border: Border.all(
            color: colorScheme.outline,
            width: 0.8,
          ),
          borderRadius: BorderRadius.circular(20.0),
          color: colorScheme.surface,
        ),
        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: TextField(
                  controller: searchTextController,
                  keyboardType: TextInputType.text,
                  autocorrect: false,
                  textCapitalization: TextCapitalization.none,
                  style: context.textTheme.bodyMedium,
                  decoration: InputDecoration(
                    hintText: context.l10n.filter,
                    hintStyle: TextStyle(color: colorScheme.outline),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  onChanged: controller.search,
                ),
              ),
            ),
            if (text.isNotEmpty)
              IconButton(
                icon: Icon(
                  Icons.clear,
                  color: colorScheme.onSurface,
                  size: 20,
                ),
                onPressed: () {
                  searchTextController.clear();
                  controller.clearSearch();
                },
              ),
          ],
        ),
      ),
    );
  }
}
