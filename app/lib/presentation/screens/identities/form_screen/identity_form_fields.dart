import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';

import '../../../../../infrastructure/extensions/identities_extensions.dart';
import '../../../../infrastructure/extensions/build_context_extensions.dart';
import '../../../../infrastructure/extensions/contact_card_extensions.dart';
import '../../../../infrastructure/providers/cache_manager_provider.dart';
import '../../../validators/input_validators.dart';
import '../../../widgets/form_rows/form_card.dart';
import '../../../widgets/form_rows/form_row_text_field.dart';
import '../../../widgets/form_rows/label_icon.dart';
import '../../../widgets/profile_picture.dart';
import '../../media/media_screen/media_screen.dart';
import 'identity_form_screen_controller.dart';

class IdentityFormFields extends ConsumerWidget {
  IdentityFormFields(
    this.identityId, {
    required this.controller,
    required this.formKey,
    required this.title,
  });

  final String? identityId;
  final IdentityFormScreenController controller;
  final GlobalKey<FormState> formKey;
  final String title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = identityFormScreenControllerProvider(identityId);
    final controller = ref.read(provider.notifier);
    final identity = ref.watch(provider.select((state) => state.identity));
    final cacheManager = ref.read(cacheManagerProvider);

    return Form(
      key: formKey,
      child: FormCard(
        title: title,
        child: Column(
          children: [
            GestureDetector(
              onTap: () async {
                final result = await Navigator.of(context, rootNavigator: true)
                    .push<MediaReviewResult>(
                      MaterialPageRoute(
                        builder: (context) => const MediaScreen(
                          cameraLensDirection: CameraLensDirection.front,
                          useCamera: true,
                          messageText: '',
                        ),
                      ),
                    );

                if (result != null && result.succeeded) {
                  await controller.updateProfilePic(
                    result.compressedImage.base64,
                  );
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
            const Divider(),
            FormRowTextField(
              icon: Icons.person,
              label: context.l10n.firstName,
              color: context.customColors.success,
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
                InputType.firstName,
              ).call,
              textInputAction: TextInputAction.next,
              traversalOrder: 1.0,
              autofocus: true,
            ),
            const Divider(),
            FormRowTextField(
              icon: Icons.badge,
              label: context.l10n.lastName,
              color: context.customColors.purple,
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
                InputType.lastName,
              ).call,
              textInputAction: TextInputAction.next,
              traversalOrder: 2.0,
            ),
            const Divider(),
            FormRowTextField(
              icon: Icons.email,
              label: context.l10n.email,
              color: context.customColors.warning,
              controller: controller.emailController,
              placeholder: context.l10n.enterEmail,
              focusNode: controller.emailFocusNode,
              singleLine: true,
              keyboardType: TextInputType.emailAddress,
              onChanged: (value) {
                controller.updateEmail(value, formKey);
                controller.handleFieldChange('email', formKey);
              },
              onFieldSubmitted: (_) {
                controller.updateErrorVisibilityOnBlur('email', formKey);
              },
              validator: (value) {
                if (!controller.shouldShowValidation('email')) {
                  return null;
                }
                return InputValidators.getValidator(
                  context,
                  InputType.email,
                ).call(value);
              },
              textInputAction: TextInputAction.next,
              traversalOrder: 3.0,
            ),
            const Divider(),
            FocusTraversalOrder(
              order: const NumericFocusOrder(4.0),
              child: ListTile(
                leading: LabelIcon(
                  icon: Icons.phone,
                  iconColor: context.colorScheme.primary,
                  label: context.l10n.mobile,
                ),
                title: Row(
                  children: [
                    Text(
                      context.l10n.mobile,
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: context.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: InternationalPhoneNumberInput(
                        onInputChanged: (phoneNumber) {
                          controller.handlePhoneInputChanged(
                            phoneNumber,
                            formKey,
                          );
                        },
                        onInputValidated: (isValid) {
                          controller.updatePhoneValidation(isValid, formKey);
                        },
                        selectorConfig: const SelectorConfig(
                          selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
                          setSelectorButtonAsPrefixIcon: true,
                          leadingPadding: 8,
                          trailingSpace: false,
                        ),
                        ignoreBlank: true,
                        locale: Localizations.localeOf(context).languageCode,
                        textFieldController: controller.mobileController,
                        focusNode: controller.mobileFocusNode,
                        keyboardAction: TextInputAction.next,
                        initialValue: controller.initialMobilePhoneNumber(
                          InputValidators.defaultPhoneIsoCode(context),
                        ),
                        textStyle: context.textTheme.bodyMedium?.copyWith(
                          color: context.colorScheme.onSurfaceVariant,
                        ),
                        selectorTextStyle: context.textTheme.bodyMedium
                            ?.copyWith(
                              color: context.colorScheme.onSurfaceVariant,
                            ),
                        inputDecoration: InputDecoration(
                          hintText: context.l10n.enterMobile,
                        ),
                        onFieldSubmitted: (_) {
                          controller.updateErrorVisibilityOnBlur(
                            'mobile',
                            formKey,
                          );
                        },
                        validator: (_) {
                          if (!controller.shouldShowValidation('mobile')) {
                            return null;
                          }

                          return controller.phoneValidationError(context);
                        },
                      ),
                    ),
                  ],
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
