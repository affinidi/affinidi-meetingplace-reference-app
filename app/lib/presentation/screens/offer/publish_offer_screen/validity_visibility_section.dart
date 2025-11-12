part of 'publish_offer_screen.dart';

class _ValidityVisibilitySection extends ConsumerWidget {
  const _ValidityVisibilitySection(String identityId)
      : _identityId = identityId;

  final String _identityId;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider =
        publishOfferScreenControllerProvider(_identityId, context.l10n);
    final controller = ref.read(provider.notifier);
    final environment = ref.read(environmentProvider);

    // final isSearchable = ref.watch(
    //   provider.select((s) => s.formData.isSearchable),
    // );
    final hasExpiry = ref.watch(
      provider.select((s) => s.formData.hasExpiry),
    );
    final expiryDate = ref.watch(
      provider.select((s) => s.formData.expiryDate),
    );
    final hasMaxUsages = ref.watch(
      provider.select((s) => s.formData.hasMaxUsages),
    );
    final maxUsages = ref.watch(
      provider.select((s) => s.formData.maxUsages),
    );

    return FormCard(
      title: context.l10n.validityVisibilitySettings,
      child: Column(
        children: [
          // FormRowToggle(
          //   icon: Icons.public,
          //   iconColor: context.customColors.warning,
          //   label: context.l10n.searchableAtMeetingPlace,
          //   helperText: context.l10n.searchableHelperText,
          //   value: isSearchable,
          //   onChanged: (value) {
          //     controller.updateFormData(
          //       ref.read(provider).formData.copyWith(isSearchable: value),
          //     );
          //   },
          // ),
          // const Divider(),
          FormRowToggle(
            icon: Icons.timer_outlined,
            iconColor: context.colorScheme.error,
            label: context.l10n.setExpiry,
            helperText: hasExpiry && expiryDate != null
                ? context.l10n.setExpiryHelperEnabled
                : context.l10n.setExpiryHelperDisabled,
            value: hasExpiry,
            switchKey: ValueKey('set_expiry_switch_$_identityId'),
            onChanged: (value) {
              controller.updateFormData(
                ref.read(provider).formData.copyWith(hasExpiry: value),
              );
            },
          ),
          const Divider(),
          if (hasExpiry) ...[
            Padding(
              padding: const EdgeInsets.only(left: 35),
              child: FormRowPicker(
                label: expiryDate != null
                    ? context.l10n.expiresAt(
                        DateFormat('MMMM d, y').format(expiryDate),
                        DateFormat('h:mm a').format(expiryDate))
                    : context.l10n.setExpiryDateTime,
                helperText: context.l10n.selectExpiryHelperText,
                buttonText: context.l10n.changeButton,
                onPressed: () async {
                  final selectedDate = await ExpiryDatePickerMenu.show(
                    context: context,
                    ref: ref,
                    initialDate: expiryDate ??
                        clock.now().add(environment.defaultExpiryOffset),
                    minDate: clock.now().add(environment.minimumExpiryOffset),
                    maxDate: clock.now().add(environment.maximumExpiryOffset),
                  );
                  if (selectedDate != null) {
                    controller.updateFormData(
                      ref
                          .read(provider)
                          .formData
                          .copyWith(expiryDate: selectedDate),
                    );
                  }
                },
              ),
            ),
            const Divider(),
          ],
          FormRowToggle(
            icon: Icons.replay_5_sharp,
            iconColor: context.customColors.rose,
            label: context.l10n.limitNumberOfUses,
            helperText: hasMaxUsages
                ? context.l10n.limitUsesHelperEnabled
                : context.l10n.limitUsesHelperDisabled,
            value: hasMaxUsages,
            switchKey: ValueKey('limit_uses_switch_$_identityId'),
            onChanged: (value) {
              controller.updateFormData(
                ref.read(provider).formData.copyWith(
                      hasMaxUsages: value,
                      maxUsages: value ? 3 : null,
                    ),
              );
            },
          ),
          const Divider(),
          if (hasMaxUsages) ...[
            Padding(
              padding: const EdgeInsets.only(left: 35),
              child: FormRowPicker(
                label: context.l10n.canBeUsedTimes(maxUsages!),
                helperText: context.l10n.selectMaxUsagesHelperText,
                buttonText: context.l10n.changeButton,
                onPressed: () async {
                  final selectedUsages = await MaxUsagePickerMenu.show(
                    context: context,
                    currentValue: maxUsages,
                    maxValue: environment.maxOfferUsages,
                  );
                  if (selectedUsages != null) {
                    controller.updateFormData(
                      ref
                          .read(provider)
                          .formData
                          .copyWith(maxUsages: selectedUsages),
                    );
                  }
                },
              ),
            ),
            const Divider(),
          ],
        ],
      ),
    );
  }
}
