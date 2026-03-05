import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../infrastructure/extensions/identities_extensions.dart';
import '../../../../infrastructure/extensions/build_context_extensions.dart';
import '../../../../infrastructure/extensions/contact_card_extensions.dart';
import '../../../../infrastructure/providers/cache_manager_provider.dart';
import '../../../config/persona_field_config.dart';
import '../../../widgets/form_rows/form_card.dart';
import '../../../widgets/form_rows/form_row_text_field.dart';
import '../../../widgets/profile_picture.dart';
import '../../media/media_screen/media_screen.dart';
import 'identity_form_screen_controller.dart';

class IdentityFormFields extends ConsumerWidget {
  IdentityFormFields(
    this.identityId, {
    required this.formKey,
    required this.title,
  });

  final String? identityId;
  final GlobalKey<FormState> formKey;
  final String title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = identityFormScreenControllerProvider(identityId);
    final controller = ref.read(provider.notifier);
    final identity = ref.watch(provider.select((state) => state.identity));
    final cacheManager = ref.read(cacheManagerProvider);
    final personaFields = PersonaField.values;

    String? validateField(PersonaField field, String? value) {
      if (field.shouldValidateOnBlur &&
          !controller.shouldShowValidation(field)) {
        return null;
      }

      return field.validator(context).call(value);
    }

    Widget buildPersonaField(PersonaField field, double traversalOrder) {
      return FormRowTextField(
        icon: field.icon,
        label: field.label(context.l10n),
        color: field.iconColor(
          context.customColors,
          context.colorScheme,
        ),
        controller: controller.controllerFor(field),
        placeholder: field.placeholder(context.l10n),
        textCapitalization: field.textCapitalization,
        autocorrect: field.autocorrect,
        singleLine: true,
        focusNode: controller.focusNodeFor(field),
        keyboardType: field.keyboardType,
        onChanged: (value) => controller.updateField(field, value, formKey),
        onFieldSubmitted: field.shouldValidateOnBlur
            ? (_) => controller.updateErrorVisibilityOnBlur(field, formKey)
            : null,
        validator: (value) => validateField(field, value),
        textInputAction: field.textInputAction,
        traversalOrder: traversalOrder,
        autofocus: field.autofocus,
      );
    }

    return Form(
      key: formKey,
      child: FormCard(
        title: title,
        child: Column(
          children: [
            GestureDetector(
              onTap: () async {
                final result = await Navigator.of(
                  context,
                  rootNavigator: true,
                ).push<MediaReviewResult>(
                  MaterialPageRoute(
                    builder: (context) => const MediaScreen(
                      cameraLensDirection: CameraLensDirection.front,
                      useCamera: true,
                      messageText: '',
                    ),
                  ),
                );

                if (result != null && result.succeeded) {
                  await controller
                      .updateProfilePic(result.compressedImage.base64);
                }
              },
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 16.0,
                      bottom: 16.0,
                      left: 20.0,
                      right: 0.0,
                    ),
                    child: ProfilePicture(
                      image: identity.profileImage(cacheManager: cacheManager),
                      size: 90,
                      displayMode: false,
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            identity.card.fullName,
                            style: context.textTheme.titleMedium,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            softWrap: true,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            context.l10n.profilePictureChangePrompt,
                            style: context.textTheme.labelSmall,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            for (var index = 0; index < personaFields.length; index++) ...[
              const Divider(),
              buildPersonaField(
                personaFields[index],
                (index + 1).toDouble(),
              ),
<<<<<<< HEAD
            ],
=======
              controller: controller.displayNameController,
              placeholder: context.l10n.enterFirstName,
              textCapitalization: TextCapitalization.sentences,
              autocorrect: true,
              singleLine: true,
              onChanged: (value) {
                controller.updateFirstName(value, formKey);
                controller.validateForm(formKey);
              },
              validator: InputValidators.getValidator(
                context,
                PersonaField.firstName.inputType,
              ).call,
              textInputAction: TextInputAction.next,
              traversalOrder: 1.0,
              autofocus: true,
            ),
            const Divider(),
            FormRowTextField(
              icon: PersonaField.lastName.icon,
              label: PersonaField.lastName.label(context.l10n),
              color: PersonaField.lastName.iconColor(
                context.customColors,
                context.colorScheme,
              ),
              controller: controller.lastNameController,
              placeholder: context.l10n.enterLastName,
              textCapitalization: TextCapitalization.sentences,
              autocorrect: true,
              singleLine: true,
              onChanged: (value) {
                controller.updateLastName(value, formKey);
                controller.validateForm(formKey);
              },
              validator: InputValidators.getValidator(
                context,
                PersonaField.lastName.inputType,
              ).call,
              textInputAction: TextInputAction.next,
              traversalOrder: 2.0,
            ),
            const Divider(),
            FormRowTextField(
              icon: PersonaField.email.icon,
              label: PersonaField.email.label(context.l10n),
              color: PersonaField.email.iconColor(
                context.customColors,
                context.colorScheme,
              ),
              controller: controller.emailController,
              placeholder: context.l10n.enterEmail,
              focusNode: controller.emailFocusNode,
              singleLine: true,
              keyboardType: PersonaField.email.keyboardType,
              onChanged: (value) {
                controller.updateEmail(value, formKey);
                controller.handleFieldChange(PersonaField.email, formKey);
              },
              onFieldSubmitted: (_) {
                controller.updateErrorVisibilityOnBlur(
                  PersonaField.email,
                  formKey,
                );
              },
              validator: (value) {
                if (!controller.shouldShowValidation(PersonaField.email)) {
                  return null;
                }
                return InputValidators.getValidator(
                  context,
                  PersonaField.email.inputType,
                ).call(value);
              },
              textInputAction: TextInputAction.next,
              traversalOrder: 3.0,
            ),
            const Divider(),
            FormRowTextField(
              icon: PersonaField.mobile.icon,
              label: PersonaField.mobile.label(context.l10n),
              color: PersonaField.mobile.iconColor(
                context.customColors,
                context.colorScheme,
              ),
              controller: controller.mobileController,
              placeholder: context.l10n.enterMobile,
              singleLine: true,
              keyboardType: PersonaField.mobile.keyboardType,
            ),
>>>>>>> 6b5eec89 (refactor: centralize keyboard type configuration for contact and identity forms)
          ],
        ),
      ),
    );
  }
}
