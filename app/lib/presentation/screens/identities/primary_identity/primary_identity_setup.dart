part of '../identities_screen.dart';

class _PrimaryIdentitySetup extends ConsumerWidget {
  const _PrimaryIdentitySetup({
    required this.formKey,
    required this.identityId,
  });

  final String? identityId;
  final GlobalKey<FormState> formKey;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final colorScheme = context.colorScheme;
    final provider = identityFormScreenControllerProvider(identityId);
    final controller = ref.read(provider.notifier);

    controller.initializeFocusListeners(formKey);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SectionBanner(
                      title: l10n.tabsTitle(Tabs.identities.name),
                      subtitle: context.l10n.identitiesPanelSubtitle,
                      icon: Icon(
                        Icons.fingerprint,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        children: [
                          const SizedBox(height: 32),
                          Text(
                            l10n.setupPrimaryIdentityTitle,
                            style: context.textTheme.titleLarge,
                          ),
                          const SizedBox(height: 20),
                          Container(
                            width: ScreensizeHelper.getConstrainedWidth(
                              context,
                            ),
                            decoration: BoxDecoration(
                              color: context.colorScheme.surfaceContainerHighest
                                  .withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: IdentityFormFields(
                              identityId,
                              controller: controller,
                              formKey: formKey,
                              title: l10n.primaryIdentityInformation,
                            ),
                          ),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            _PrimaryIdentityBottomContainer(
              identityId: identityId,
              formKey: formKey,
            ),
          ],
        ),
      ),
    );
  }
}
