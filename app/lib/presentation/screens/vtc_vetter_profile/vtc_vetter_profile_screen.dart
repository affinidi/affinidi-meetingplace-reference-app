import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:meeting_place_vtc/meeting_place_vtc.dart';

import '../../../infrastructure/extensions/build_context_extensions.dart';
import '../../widgets/onboarding_style/onboarding_style.dart';
import 'vtc_vetter_profile_controller.dart';
import 'vtc_vetter_profile_state.dart';

/// The documentation a vetter can say they accept, `none` being prior
/// acquaintance.
const _documentClasses = ['passport', 'nationalId', 'driverLicence', 'none'];

/// The member's vetter profile for a community: what applicants looking for
/// a vetter are told about them, in their own words. Starts unlisted;
/// listing is the member's choice.
class VtcVetterProfileScreen extends HookConsumerWidget {
  const VtcVetterProfileScreen({
    super.key,
    required this.communityDid,
    required this.communityName,
  });

  final String communityDid;
  final String communityName;

  static Future<void> show(
    BuildContext context, {
    required String communityDid,
    required String communityName,
  }) => Navigator.of(context, rootNavigator: true).push<void>(
    MaterialPageRoute<void>(
      builder: (context) => VtcVetterProfileScreen(
        communityDid: communityDid,
        communityName: communityName,
      ),
    ),
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = vtcVetterProfileControllerProvider(communityDid);
    final state = ref.watch(provider);
    final l10n = context.l10n;
    void close() => Navigator.of(context).pop();

    return OnboardingLayout(
      onClose: close,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 12,
        children: [
          OnboardingTitle(l10n.vtcVetterProfileTitle),
          ...switch (state.step) {
            VtcVetterProfileStep.loading => [
              const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ],
            VtcVetterProfileStep.notVetter => [
              OnboardingMessage(
                l10n.vtcVetterNotVetter(communityName),
                key: const Key('vtc_vetter_profile_not_vetter'),
                isError: true,
              ),
            ],
            VtcVetterProfileStep.editing => [
              OnboardingSubtitle(l10n.vtcVetterProfileIntro(communityName)),
              _ProfileForm(
                // Starts again from what the community stored, once read.
                key: ValueKey(state.recorded?.updatedAt),
                state: state,
                onPublish: (profile) async {
                  if (await ref.read(provider.notifier).publish(profile) &&
                      context.mounted) {
                    close();
                  }
                },
              ),
            ],
          },
          OnboardingTextButton(label: l10n.generalDone, onPressed: close),
        ],
      ),
    );
  }
}

/// The profile's fields, starting from the profile last published, else
/// unlisted and in the device's language.
class _ProfileForm extends HookWidget {
  const _ProfileForm({super.key, required this.state, required this.onPublish});

  final VtcVetterProfileState state;
  final ValueChanged<VetterProfile> onPublish;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final recorded = state.recorded?.profile;
    final listed = useState(recorded?.listed ?? false);
    final displayName = useTextEditingController(text: recorded?.displayName);
    final languages = useTextEditingController(
      text: recorded == null
          ? Localizations.localeOf(context).languageCode
          : recorded.languages.join(', '),
    );
    final country = useTextEditingController(text: recorded?.location?.country);
    final city = useTextEditingController(text: recorded?.location?.city);
    final contactHint = useTextEditingController(text: recorded?.contactHint);
    final availability = useTextEditingController(text: recorded?.availability);
    final methods = useState({...?recorded?.methods});
    final documents = useState({...?recorded?.acceptsDocumentation});

    String? text(TextEditingController controller) {
      final value = controller.text.trim();
      return value.isEmpty ? null : value;
    }

    VetterProfile profile() {
      final countryCode = text(country)?.toUpperCase();
      return VetterProfile(
        listed: listed.value,
        displayName: text(displayName),
        languages: [
          for (final language in languages.text.split(','))
            if (language.trim().isNotEmpty) language.trim(),
        ],
        location: countryCode == null
            ? null
            : VetterLocation(country: countryCode, city: text(city)),
        methods: [
          for (final method in VettingMethod.values)
            if (methods.value.contains(method)) method,
        ],
        acceptsDocumentation: [
          for (final document in _documentClasses)
            if (documents.value.contains(document)) document,
        ],
        availability: text(availability),
        contactHint: text(contactHint),
        // Not edited here, and the profile replaces what the community held.
        events: recorded?.events ?? const [],
      );
    }

    Widget field(String key, TextEditingController controller, String label) =>
        OnboardingTextField(
          key: Key('vtc_vetter_profile_$key'),
          controller: controller,
          label: label,
          onSubmitted: (_) {},
        );

    Widget heading(String text) => Text(
      text,
      style: context.textTheme.titleSmall?.copyWith(color: Colors.white),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 12,
      children: [
        if (state.recorded case final recorded?)
          OnboardingMessage(
            recorded.listed
                ? l10n.vtcVetterProfileStoredListed
                : l10n.vtcVetterProfileStoredHidden,
            key: const Key('vtc_vetter_profile_stored'),
            isError: false,
          ),
        // A Row, not a SwitchListTile: the onboarding layout measures
        // intrinsic heights, which a ListTile misreports.
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 2,
                children: [
                  Text(
                    l10n.vtcVetterProfileListed,
                    style: const TextStyle(color: Colors.white),
                  ),
                  Text(
                    l10n.vtcVetterProfileListedNote,
                    style: onboardingNote(context),
                  ),
                ],
              ),
            ),
            Switch.adaptive(
              key: const Key('vtc_vetter_profile_listed'),
              value: listed.value,
              onChanged: (value) => listed.value = value,
              activeTrackColor: Colors.white,
            ),
          ],
        ),
        field('name', displayName, l10n.vtcVetterProfileDisplayName),
        field('languages', languages, l10n.vtcVetterProfileLanguages),
        field('country', country, l10n.vtcVetterProfileCountry),
        field('city', city, l10n.vtcVetterProfileCity),
        field('contact_hint', contactHint, l10n.vtcVetterProfileContactHint),
        field('availability', availability, l10n.vtcVetterProfileAvailability),
        heading(l10n.vtcVetterProfileMethodsHeading),
        // A column, not a wrap: the layout measures its content's height as
        // if a wrap fitted on one line.
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final method in VettingMethod.values)
              FilterChip(
                key: Key('vtc_vetter_profile_method_${method.name}'),
                label: Text(l10n.vtcVetterProfileMethod(method.name)),
                selected: methods.value.contains(method),
                onSelected: (selected) => methods.value = selected
                    ? {...methods.value, method}
                    : ({...methods.value}..remove(method)),
              ),
          ],
        ),
        heading(l10n.vtcVetterProfileDocumentsHeading),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final document in _documentClasses)
              FilterChip(
                key: Key('vtc_vetter_profile_document_$document'),
                label: Text(
                  document == 'none'
                      ? l10n.vtcVetterProfileNoDocument
                      : l10n.vtcVetterDocument(document),
                ),
                selected: documents.value.contains(document),
                onSelected: (selected) => documents.value = selected
                    ? {...documents.value, document}
                    : ({...documents.value}..remove(document)),
              ),
          ],
        ),
        if (state.failure case final failure?)
          OnboardingMessage(
            switch (failure) {
              VtcVetterProfileFailure.invalid => l10n.vtcVetterProfileInvalid(
                state.invalidReason ?? '',
              ),
              VtcVetterProfileFailure.unreachable => l10n.vtcVetterFailure(
                failure.name,
              ),
            },
            key: const Key('vtc_vetter_profile_failure'),
            isError: true,
          ),
        OnboardingButton(
          key: const Key('vtc_vetter_profile_publish'),
          label: l10n.vtcVetterProfilePublish,
          isLoading: state.busy,
          onPressed: methods.value.isEmpty ? null : () => onPublish(profile()),
        ),
      ],
    );
  }
}
