import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';

import '../../../../../infrastructure/extensions/identities_extensions.dart';
import '../../../../domain/models/contact_card/contact_card_field_definition.dart';
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

class IdentityFormFields extends ConsumerStatefulWidget {
  IdentityFormFields(
    this.identityId, {
    required this.formKey,
    required this.title,
  });

  final String? identityId;
  final GlobalKey<FormState> formKey;
  final String title;

  @override
  ConsumerState<IdentityFormFields> createState() => _IdentityFormFieldsState();
}

class _IdentityFormFieldsState extends ConsumerState<IdentityFormFields> {
  final _phoneInputKey = GlobalKey();
  FocusNode? _emailFocusNodeRef;
  VoidCallback? _emailFocusListener;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _setupEmailFocusListener(),
    );
  }

  void _setupEmailFocusListener() {
    final provider = identityFormScreenControllerProvider(widget.identityId);
    final controller = ref.read(provider.notifier);
    final emailField = ContactCardFieldDefinitions.byKey(
      ContactCardFieldKey.email,
    );
    final emailFocusNode = controller.focusNodeFor(emailField);
    if (emailFocusNode == null) return;

    _emailFocusListener = () {
      if (!emailFocusNode.hasFocus) _maybeOpenPhoneSelector(controller);
    };
    emailFocusNode.addListener(_emailFocusListener!);
    _emailFocusNodeRef = emailFocusNode;
  }

  void _maybeOpenPhoneSelector(IdentityFormScreenController controller) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final mobileField = ContactCardFieldDefinitions.byKey(
        ContactCardFieldKey.mobile,
      );
      if (controller.focusNodeFor(mobileField)?.hasFocus != true) return;
      _triggerPhoneSelector();
    });
  }

  void _triggerPhoneSelector() {
    final ctx = _phoneInputKey.currentContext;
    if (ctx == null) return;
    void findAndTap(Element el) {
      if (el.widget is MaterialButton &&
          el.widget.key == const Key('intl_dropdown_key')) {
        (el.widget as MaterialButton).onPressed?.call();
        return;
      }
      el.visitChildElements(findAndTap);
    }

    (ctx as Element).visitChildElements(findAndTap);
  }

  @override
  void dispose() {
    if (_emailFocusNodeRef != null && _emailFocusListener != null) {
      _emailFocusNodeRef!.removeListener(_emailFocusListener!);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = identityFormScreenControllerProvider(widget.identityId);
    final controller = ref.read(provider.notifier);
    final identity = ref.watch(provider.select((state) => state.identity));
    final cacheManager = ref.read(cacheManagerProvider);
    final personaFields = ContactCardFieldDefinitions.values
        .where((f) => f.key != ContactCardFieldKey.mobile)
        .toList();
    final mobileField = ContactCardFieldDefinitions.byKey(
      ContactCardFieldKey.mobile,
    );
    final initialMobilePhoneNumber = controller.initialMobilePhoneNumber;

    return Form(
      key: widget.formKey,
      child: FormCard(
        title: widget.title,
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
            for (var index = 0; index < personaFields.length; index++) ...[
              const Divider(),
              _PersonaField(
                identityId: widget.identityId,
                field: personaFields[index],
                formKey: widget.formKey,
                traversalOrder: (index + 1).toDouble(),
              ),
            ],
            const Divider(),
            FocusTraversalOrder(
              order: NumericFocusOrder((personaFields.length + 1).toDouble()),
              child: ListTile(
                leading: LabelIcon(
                  icon: Icons.phone,
                  iconColor: context.colorScheme.primary,
                  label: mobileField.label(context.l10n),
                ),
                title: Row(
                  children: [
                    Text(
                      mobileField.label(context.l10n),
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: context.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Theme(
                        data: Theme.of(context).copyWith(
                          dialogTheme: Theme.of(context).dialogTheme.copyWith(
                            constraints: BoxConstraints(
                              maxHeight:
                                  MediaQuery.sizeOf(context).height * 0.5,
                            ),
                          ),
                        ),
                        child: InternationalPhoneNumberInput(
                          key: _phoneInputKey,
                          initialValue: initialMobilePhoneNumber,
                          textFieldController: controller.controllerFor(
                            mobileField,
                          ),
                          focusNode: controller.focusNodeFor(mobileField)!,
                          keyboardAction: TextInputAction.next,
                          selectorConfig: const SelectorConfig(
                            selectorType: PhoneInputSelectorType.DIALOG,
                            setSelectorButtonAsPrefixIcon: true,
                            trailingSpace: false,
                            leadingPadding: 0,
                          ),
                          locale: Localizations.localeOf(context).languageCode,
                          searchBoxDecoration: InputDecoration(
                            hintText: context.l10n.filter,
                            prefixIcon: const Icon(Icons.search),
                          ),
                          inputDecoration: InputDecoration(
                            hintText: context.l10n.enterMobile,
                          ),
                          textStyle: context.textTheme.bodyMedium?.copyWith(
                            color: context.colorScheme.onSurfaceVariant,
                          ),
                          selectorTextStyle: context.textTheme.bodyMedium
                              ?.copyWith(
                                color: context.colorScheme.onSurfaceVariant,
                              ),
                          onInputChanged: controller.updateMobile,
                          onInputValidated: (isValid) {
                            controller.updateMobileValidation(
                              isValid,
                              widget.formKey,
                            );
                          },
                          onFieldSubmitted: (_) {
                            controller.updateErrorVisibilityOnBlur(
                              mobileField,
                              widget.formKey,
                            );
                          },
                          validator: (value) {
                            if (!controller.shouldShowValidation(mobileField)) {
                              return null;
                            }
                            return InputValidators.getValidator(
                              context,
                              InputType.phone,
                              isPhoneValid: controller.isMobileValid,
                              hasTouchedPhone: controller.hasTouchedMobile,
                            ).call(value);
                          },
                        ),
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

class _PersonaField extends ConsumerWidget {
  const _PersonaField({
    required this.identityId,
    required this.field,
    required this.formKey,
    required this.traversalOrder,
  });

  final String? identityId;
  final ContactCardFieldDefinition field;
  final GlobalKey<FormState> formKey;
  final double traversalOrder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = identityFormScreenControllerProvider(identityId);
    final controller = ref.read(provider.notifier);

    String? validateField(BuildContext context, String? value) {
      if (field.shouldValidateOnBlur &&
          !controller.shouldShowValidation(field)) {
        return null;
      }

      return field.validator(context).call(value);
    }

    return FormRowTextField(
      icon: field.icon,
      label: field.label(context.l10n),
      color: field.iconColor(context.customColors, context.colorScheme),
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
      validator: (value) => validateField(context, value),
      textInputAction: field.textInputAction,
      traversalOrder: traversalOrder,
      autofocus: field.autofocus,
    );
  }
}
