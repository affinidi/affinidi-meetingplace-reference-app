import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

import '../../../../application/services/identities_service/identities_service.dart';
import '../../../../domain/models/contact_card/contact_card.dart';
import '../../../../domain/models/identity/identity.dart';
import '../../../../infrastructure/exceptions/app_exception.dart';
import '../../../../infrastructure/exceptions/app_exception_type.dart';
import '../../../validators/input_validators.dart';
import 'identity_form_mode.dart';
import 'identity_form_screen_state.dart';

part 'identity_form_screen_controller.g.dart';

@riverpod
class IdentityFormScreenController extends _$IdentityFormScreenController {
  late final scrollController = ScrollController();

  late final displayNameController = TextEditingController();
  late final lastNameController = TextEditingController();
  late final emailController = TextEditingController();
  late final mobileController = TextEditingController();
  late final aliasController = TextEditingController();

  late final emailFocusNode = FocusNode();
  late final mobileFocusNode = FocusNode();

  PhoneNumber? _initialMobilePhoneNumber;
  String? _latestNormalizedMobile;
  String? _selectedPhoneIsoCode;
  bool _isPhoneNumberValid = true;
  bool _isPhoneNumberValidationPending = false;
  bool _isDisposed = false;
  int _phoneValidationRevision = 0;
  String? _scheduledLoadedMobileValidation;

  GlobalKey<FormState>? _formKey;

  void initializeFocusListeners(GlobalKey<FormState> formKey) {
    _formKey = formKey;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_isDisposed || _formKey != formKey) return;

      validateForm(formKey);
      _scheduleLoadedMobileValidation();
    });
  }

  PhoneNumber initialMobilePhoneNumber(String isoCode) {
    _selectedPhoneIsoCode ??= isoCode;

    return _initialMobilePhoneNumber ??= PhoneNumber(
      phoneNumber: mobileController.text.trim().isEmpty
          ? null
          : mobileController.text.trim(),
      isoCode: _selectedPhoneIsoCode,
    );
  }

  void _scheduleLoadedMobileValidation() {
    final formKey = _formKey;
    final currentContext = formKey?.currentContext;
    final mobile = mobileController.text.trim();

    if (formKey == null ||
        currentContext == null ||
        mobile.isEmpty ||
        !_isPhoneNumberValidationPending ||
        _scheduledLoadedMobileValidation == mobile) {
      return;
    }

    _scheduledLoadedMobileValidation = mobile;

    final validationRevision = ++_phoneValidationRevision;
    final isoCode =
        _selectedPhoneIsoCode ??
        InputValidators.defaultPhoneIsoCode(currentContext);

    unawaited(
      _validateLoadedMobile(
        mobile: mobile,
        isoCode: isoCode,
        validationRevision: validationRevision,
        formKey: formKey,
      ),
    );
  }

  Future<void> _validateLoadedMobile({
    required String mobile,
    required String isoCode,
    required int validationRevision,
    required GlobalKey<FormState> formKey,
  }) async {
    final normalizedPhoneNumber = await InputValidators.normalizePhoneNumber(
      mobile,
      isoCode: isoCode,
    );

    if (_isDisposed ||
        validationRevision != _phoneValidationRevision ||
        mobileController.text.trim() != mobile) {
      return;
    }

    _latestNormalizedMobile = normalizedPhoneNumber;
    updatePhoneValidation(normalizedPhoneNumber != null, formKey);
  }

  @override
  IdentityFormScreenState build(String? identityId) {
    emailFocusNode.addListener(() {
      if (!emailFocusNode.hasFocus && _formKey != null) {
        updateErrorVisibilityOnBlur('email', _formKey!);
      }
    });
    mobileFocusNode.addListener(() {
      if (!mobileFocusNode.hasFocus && _formKey != null) {
        updateErrorVisibilityOnBlur('mobile', _formKey!);
      }
    });

    ref.onDispose(() {
      _isDisposed = true;
      scrollController.dispose();
      displayNameController.dispose();
      lastNameController.dispose();
      emailController.dispose();
      mobileController.dispose();
      aliasController.dispose();
      emailFocusNode.dispose();
      mobileFocusNode.dispose();
    });

    final identity = _loadIdentity(identityId);
    final canDelete = !identity.isPrimary;

    return IdentityFormScreenState(
      identity: identity,
      isAliasMirroringFirstName: identity.card.displayName.isEmpty,
      canDelete: canDelete,
    );
  }

  Identity _makeNewIdentity() {
    final uuid = const Uuid();
    final newCard = ContactCard(
      id: uuid.v4(),
      did: '',
      type: '',
      firstName: '',
      displayName: '',
    );

    return Identity(id: uuid.v4(), did: '', card: newCard);
  }

  Identity _loadIdentity(String? identityId) {
    final identity = switch (identityId) {
      null => _makeNewIdentity(),
      _ =>
        ref
                .read(identitiesServiceProvider)
                .identities
                .where((i) => i.id == identityId)
                .firstOrNull ??
            (throw AppException(
              'missing identity',
              code: AppExceptionType.missingIdentity.name,
            )),
    };

    displayNameController.text = identity.card.firstName;
    lastNameController.text = identity.card.lastName ?? '';
    emailController.text = identity.card.email ?? '';
    mobileController.text = identity.card.mobile ?? '';
    aliasController.text = identity.card.displayName;
    _initialMobilePhoneNumber = null;
    _scheduledLoadedMobileValidation = null;
    _selectedPhoneIsoCode = null;
    _phoneValidationRevision++;

    final mobile = identity.card.mobile?.trim();
    if (mobile == null || mobile.isEmpty) {
      _latestNormalizedMobile = null;
      _isPhoneNumberValid = true;
      _isPhoneNumberValidationPending = false;
    } else {
      _latestNormalizedMobile = null;
      _isPhoneNumberValid = false;
      _isPhoneNumberValidationPending = true;
    }

    return identity;
  }

  void _updateHasEnteredAnyInfo() {
    final hasInfo =
        (displayNameController.text.trim().isNotEmpty ||
            lastNameController.text.trim().isNotEmpty ||
            emailController.text.trim().isNotEmpty ||
            mobileController.text.trim().isNotEmpty) &&
        state.canSave;

    state = state.copyWith(hasEnteredAnyInfo: hasInfo);
  }

  void _updateIdentityCard(ContactCard updatedCard) {
    final updatedIdentity = state.identity.copyWith(card: updatedCard);
    state = state.copyWith(identity: updatedIdentity);
  }

  void validateForm(GlobalKey<FormState> formKey) {
    final ctx = formKey.currentContext!;
    final emailError = InputValidators.getValidator(
      ctx,
      InputType.email,
    ).call(emailController.text);
    final mobileError = phoneValidationError(ctx);

    final isValidForSave = emailError == null && mobileError == null;

    state = state.copyWith(canSave: isValidForSave);
    _updateHasEnteredAnyInfo();
  }

  String? phoneValidationError(BuildContext context) {
    return InputValidators.phoneValidationError(
      context,
      value: mobileController.text,
      isPhoneNumberValid: _isPhoneNumberValid,
      isValidationPending: _isPhoneNumberValidationPending,
    );
  }

  bool shouldShowValidation(String fieldName) {
    return state.showingErrorFields.contains(fieldName);
  }

  void _setErrorVisibility(String fieldName, bool visible) {
    final current = {...state.showingErrorFields};
    if (visible) {
      current.add(fieldName);
    } else {
      current.remove(fieldName);
    }
    state = state.copyWith(showingErrorFields: current);
  }

  InputType _typeFor(String fieldName) {
    switch (fieldName) {
      case 'email':
        return InputType.email;
      case 'mobile':
        return InputType.phone;
      default:
        return InputType.alias;
    }
  }

  String _textFor(String fieldName) {
    switch (fieldName) {
      case 'email':
        return emailController.text;
      case 'mobile':
        return mobileController.text;
      default:
        return '';
    }
  }

  void updateErrorVisibilityOnBlur(
    String fieldName,
    GlobalKey<FormState> formKey,
  ) {
    final ctx = formKey.currentContext!;
    final error = switch (fieldName) {
      'mobile' => phoneValidationError(ctx),
      _ => InputValidators.getValidator(
        ctx,
        _typeFor(fieldName),
      ).call(_textFor(fieldName)),
    };
    _setErrorVisibility(fieldName, error != null);
    formKey.currentState?.validate();
    validateForm(formKey);
  }

  void handleFieldChange(String fieldName, GlobalKey<FormState> formKey) {
    if (state.showingErrorFields.contains(fieldName)) {
      final ctx = formKey.currentContext!;
      final error = switch (fieldName) {
        'mobile' => phoneValidationError(ctx),
        _ => InputValidators.getValidator(
          ctx,
          _typeFor(fieldName),
        ).call(_textFor(fieldName)),
      };
      if (error == null) {
        _setErrorVisibility(fieldName, false);
        formKey.currentState?.validate();
      }
    }
    validateForm(formKey);
  }

  void updateFirstName(String firstName, GlobalKey<FormState> formKey) {
    final error = InputValidators.getValidator(
      formKey.currentContext!,
      InputType.firstName,
    ).call(firstName);
    if (error != null) return;

    final identity = state.identity;

    if (state.isAliasMirroringFirstName) {
      aliasController.text = firstName;

      _updateIdentityCard(
        identity.card.copyWith(firstName: firstName, displayName: firstName),
      );
    } else {
      _updateIdentityCard(identity.card.copyWith(firstName: firstName));
    }

    _updateHasEnteredAnyInfo();
  }

  Future<void> updateProfilePic(String? imageString) async {
    final identity = state.identity;

    _updateIdentityCard(
      identity.card.copyWith(
        profilePic: imageString?.isEmpty ?? true ? null : imageString,
      ),
    );
  }

  void updateLastName(String lastName, GlobalKey<FormState> formKey) {
    final error = InputValidators.getValidator(
      formKey.currentContext!,
      InputType.lastName,
    ).call(lastName);
    if (error != null) return;

    final identity = state.identity;

    _updateIdentityCard(
      identity.card.copyWith(lastName: lastName.isEmpty ? null : lastName),
    );
    _updateHasEnteredAnyInfo();
  }

  void updateEmail(String email, GlobalKey<FormState> formKey) {
    final error = InputValidators.getValidator(
      formKey.currentContext!,
      InputType.email,
    ).call(email);
    if (error != null) return;

    final identity = state.identity;

    _updateIdentityCard(
      identity.card.copyWith(email: email.isEmpty ? null : email),
    );
    _updateHasEnteredAnyInfo();
  }

  bool updateMobile(String mobile, GlobalKey<FormState> formKey) {
    final error = InputValidators.getValidator(
      formKey.currentContext!,
      InputType.phone,
    ).call(mobile);
    if (error != null) return false;

    final identity = state.identity;

    _updateIdentityCard(
      identity.card.copyWith(mobile: mobile.isEmpty ? null : mobile),
    );
    _updateHasEnteredAnyInfo();
    return true;
  }

  void handlePhoneInputChanged(
    PhoneNumber phoneNumber,
    GlobalKey<FormState> formKey,
  ) {
    _phoneValidationRevision++;
    _scheduledLoadedMobileValidation = null;
    _selectedPhoneIsoCode = phoneNumber.isoCode ?? _selectedPhoneIsoCode;

    final hasValue = mobileController.text.trim().isNotEmpty;
    _latestNormalizedMobile = hasValue ? phoneNumber.phoneNumber : null;

    if (!hasValue) {
      _isPhoneNumberValidationPending = false;
      _isPhoneNumberValid = true;
      updateMobile('', formKey);
    } else {
      _isPhoneNumberValidationPending = true;
    }

    if (state.showingErrorFields.contains('mobile')) {
      formKey.currentState?.validate();
    }

    validateForm(formKey);
  }

  void updatePhoneValidation(bool isValid, GlobalKey<FormState> formKey) {
    final hasValue = mobileController.text.trim().isNotEmpty;
    _scheduledLoadedMobileValidation = null;
    _isPhoneNumberValidationPending = false;

    if (!hasValue) {
      _isPhoneNumberValid = updateMobile('', formKey);
    } else if (isValid) {
      final normalizedPhoneNumber = _latestNormalizedMobile;
      _isPhoneNumberValid =
          normalizedPhoneNumber != null &&
          normalizedPhoneNumber.isNotEmpty &&
          updateMobile(normalizedPhoneNumber, formKey);
    } else {
      _isPhoneNumberValid = false;
    }

    handleFieldChange('mobile', formKey);
  }

  void updateCardColor(Color color) {
    final identity = state.identity;

    _updateIdentityCard(
      identity.card.copyWith(cardColor: color.toARGB32().toString()),
    );
  }

  void updateAlias(String alias) {
    final identity = state.identity;
    aliasController.text = alias;
    state = state.copyWith(isAliasMirroringFirstName: alias.isEmpty);
    _updateIdentityCard(identity.card.copyWith(displayName: alias));
  }

  Future<bool> saveIdentity({
    required String anonymousLabel,
    required IdentityFormMode mode,
  }) async {
    if ((state.hasDeleted) || (state.hasSaved)) return true;
    if (mobileController.text.trim().isNotEmpty &&
        (_isPhoneNumberValidationPending || !_isPhoneNumberValid)) {
      return false;
    }

    final identitiesService = ref.read(identitiesServiceProvider.notifier);
    final firstName = state.identity.card.firstName.trim().isEmpty
        ? anonymousLabel
        : state.identity.card.firstName.trim();
    final lastName = state.identity.card.lastName?.trim();
    final email = state.identity.card.email?.trim();
    final mobile = state.identity.card.mobile?.trim();
    final displayName = state.identity.card.displayName.trim().isEmpty
        ? anonymousLabel
        : state.identity.card.displayName.trim();

    try {
      final updatedIdentity = state.identity.copyWith(
        card: state.identity.card.copyWith(
          firstName: firstName,
          lastName: lastName?.isEmpty ?? true ? null : lastName,
          email: email?.isEmpty ?? true ? null : email,
          mobile: mobile?.isEmpty ?? true ? null : mobile,
          displayName: displayName,
        ),
      );

      if (mode == IdentityFormMode.add) {
        await identitiesService.addIdentity(updatedIdentity);
      } else {
        await identitiesService.updateIdentity(updatedIdentity);
      }
      state = state.copyWith(identity: updatedIdentity, hasSaved: true);
      return true;
    } catch (error) {
      return false;
    }
  }

  Future<bool> deleteIdentity() async {
    if (state.identity.isPrimary) return false;

    try {
      final id = state.identity.id;
      await ref.read(identitiesServiceProvider.notifier).deleteIdentity(id);
      state = state.copyWith(hasDeleted: true);
      return true;
    } catch (error) {
      return false;
    }
  }

  void markAsCurrentIdentity() {
    ref
        .read(identitiesServiceProvider.notifier)
        .setCurrentIdentityById(state.identity.id);
  }
}
