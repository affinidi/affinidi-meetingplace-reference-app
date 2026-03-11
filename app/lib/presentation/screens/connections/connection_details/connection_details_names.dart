part of 'connection_details_screen.dart';

class _Names extends ConsumerWidget {
  const _Names(this.contactId);

  final String contactId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = connectionDetailsScreenControllerProvider(contactId);
    final otherPartyDisplayName = ref.watch(provider.otherPartyDisplayName);
    final myDisplayName = ref.watch(
      provider.select((state) => state.identity?.card.firstName ?? ''),
    );

    if (otherPartyDisplayName.isEmpty && myDisplayName.isEmpty) {
      return const SizedBox.shrink();
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (otherPartyDisplayName.isNotEmpty)
          Flexible(
            child: Text(
              otherPartyDisplayName,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.right,
              style: context.textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        if (otherPartyDisplayName.isNotEmpty && myDisplayName.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Icon(
              Icons.arrow_forward,
              color: context.colorScheme.onSurface,
              size: 24,
            ),
          ),
        if (myDisplayName.isNotEmpty)
          Flexible(
            child: Text(
              myDisplayName,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.left,
              style: context.textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
      ],
    );
  }
}
