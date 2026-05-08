import 'package:flutter/material.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

import '../../../../application/services/identities_service/identities_service.dart';
import '../../../../domain/models/contact_card/contact_card.dart';
import '../../../../domain/models/contact_card/contact_card_field_definition.dart';
import '../../../../domain/models/identity/identity.dart';
import '../../../../infrastructure/exceptions/app_exception.dart';
import '../../../../infrastructure/exceptions/app_exception_type.dart';
import 'identity_form_mode.dart';
import 'identity_form_screen_state.dart';

part 'identity_form_screen_controller.g.dart';

@riverpod
class IdentityFormScreenController extends _$IdentityFormScreenController {
  late final scrollController = ScrollController();

  late final _fieldControllers = {
    for (final field in ContactCardFieldDefinitions.values)
      field: TextEditingController(),
  };
  late final _fieldFocusNodes = {
    for (final field in ContactCardFieldDefinitions.values.where(
      (field) => field.shouldValidateOnBlur,
    ))
      field: FocusNode(),
  };
  late final aliasController = TextEditingController();

  GlobalKey<FormState>? _formKey;
  bool _focusListenersInitialized = false;
  String? _normalizedMobile;
  bool? _isMobileValid;
  bool _hasTouchedMobile = false;

  bool? get isMobileValid => _isMobileValid;
  bool get hasTouchedMobile => _hasTouchedMobile;

  TextEditingController controllerFor(ContactCardFieldDefinition field) {
    return _fieldControllers[field]!;
  }

  FocusNode? focusNodeFor(ContactCardFieldDefinition field) {
    return _fieldFocusNodes[field];
  }

  void initializeFocusListeners(GlobalKey<FormState> formKey) {
    _formKey = formKey;
    if (_focusListenersInitialized) return;
    _focusListenersInitialized = true;
    for (final entry in _fieldFocusNodes.entries) {
      final field = entry.key;
      final focusNode = entry.value;
      focusNode.addListener(() {
        if (!focusNode.hasFocus && _formKey != null) {
          updateErrorVisibilityOnBlur(field, _formKey!);
        }
      });
    }
  }

  @override
  IdentityFormScreenState build(String? identityId) {

    ref.onDispose(() {
      scrollController.dispose();
      for (final controller in _fieldControllers.values) {
        controller.dispose();
      }
      aliasController.dispose();
      for (final focusNode in _fieldFocusNodes.values) {
        focusNode.dispose();
      }
    });

    final identity = _loadIdentity(identityId);
    final canDelete = !identity.isPrimary;

    return IdentityFormScreenState(
      identity: identity,
      isAliasMirroringFirstName:
          identity.card.displayName.isEmpty ||
          identity.card.displayName == identity.card.firstName,
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
    if (identityId == null) {
      _normalizedMobile = null;
      _isMobileValid = null;
      _hasTouchedMobile = false;
      return _makeNewIdentity();
    }

    final identity = ref
        .read(identitiesServiceProvider)
        .identities
        .where((i) => i.id == identityId)
        .firstOrNull;

    if (identity == null) {
      throw AppException(
        'missing identity',
        code: AppExceptionType.missingIdentity.name,
      );
    }

    for (final field in ContactCardFieldDefinitions.values) {
      controllerFor(field).text = field.valueFrom(identity.card);
    }
    aliasController.text = identity.card.displayName;
    _normalizedMobile = identity.card.mobile;
    _isMobileValid = identity.card.mobile?.isNotEmpty == true ? true : null;
    _hasTouchedMobile = false;

    return identity;
  }

  bool _hasEnteredAnyInfo(bool canSave) {
    return ContactCardFieldDefinitions.values.any(
          (field) => controllerFor(field).text.trim().isNotEmpty,
        ) &&
        canSave;
  }

  void _updateIdentityCard(ContactCard updatedCard) {
    final updatedIdentity = state.identity.copyWith(card: updatedCard);
    state = state.copyWith(identity: updatedIdentity);
  }

  void validateForm(GlobalKey<FormState> formKey) {
    final ctx = formKey.currentContext!;
    final isValidForSave = ContactCardFieldDefinitions.values.every((field) {
      if (field.key == ContactCardFieldKey.mobile) {
        final mobile = controllerFor(field).text.trim();
        return mobile.isEmpty || _isMobileValid == true;
      }
      return field.validator(ctx).call(controllerFor(field).text) == null;
    });

    state = state.copyWith(
      canSave: isValidForSave,
      hasEnteredAnyInfo: _hasEnteredAnyInfo(isValidForSave),
    );
  }

  bool shouldShowValidation(ContactCardFieldDefinition field) {
    return state.showingErrorFields.contains(field);
  }

  void _setErrorVisibility(ContactCardFieldDefinition field, bool visible) {
    final current = {...state.showingErrorFields};
    if (visible) {
      current.add(field);
    } else {
      current.remove(field);
    }
    state = state.copyWith(showingErrorFields: current);
  }

  String _textFor(ContactCardFieldDefinition field) {
    return controllerFor(field).text;
  }

  void updateErrorVisibilityOnBlur(
    ContactCardFieldDefinition field,
    GlobalKey<FormState> formKey,
  ) {
    final ctx = formKey.currentContext!;
    final bool hasError;
    if (field.key == ContactCardFieldKey.mobile) {
      final mobile = controllerFor(field).text.trim();
      hasError = mobile.isNotEmpty && _isMobileValid != true;
    } else {
      final error = field.validator(ctx).call(_textFor(field));
      hasError = error != null;
    }
    _setErrorVisibility(field, hasError);
    formKey.currentState?.validate();
    validateForm(formKey);
  }

  void handleFieldChange(
    ContactCardFieldDefinition field,
    GlobalKey<FormState> formKey,
  ) {
    if (state.showingErrorFields.contains(field)) {
      final ctx = formKey.currentContext!;
      final bool hasError;
      if (field.key == ContactCardFieldKey.mobile) {
        final mobile = controllerFor(field).text.trim();
        hasError = mobile.isNotEmpty && _isMobileValid != true;
      } else {
        final error = field.validator(ctx).call(_textFor(field));
        hasError = error != null;
      }
      if (error == null) {
        _setErrorVisibility(field, false);
        formKey.currentState?.validate();
      }
    }
    validateForm(formKey);
  }

  Future<void> updateProfilePic(String? imageString) async {
    final identity = state.identity;

    _updateIdentityCard(
      identity.card.copyWith(
        profilePic: imageString?.isEmpty ?? true ? null : imageString,
      ),
    );
  }

  void updateField(
    ContactCardFieldDefinition field,
    String value,
    GlobalKey<FormState> formKey,
  ) {
    final error = field.validator(formKey.currentContext!).call(value);
    if (error == null) {
      var updatedCard = field.updateContactCard(state.identity.card, value);

      if (field.key == ContactCardFieldKey.firstName &&
          state.isAliasMirroringFirstName) {
        aliasController.text = value;
        updatedCard = updatedCard.copyWith(displayName: value);
      }

      _updateIdentityCard(updatedCard);
    }

    if (field.shouldValidateOnBlur) {
      handleFieldChange(field, formKey);
    } else {
      validateForm(formKey);
    }
  }

  void updateMobile(PhoneNumber phoneNumber) {
    _hasTouchedMobile = true;
    _normalizedMobile = phoneNumber.phoneNumber;
  }

  void updateMobileValidation(bool isValid, GlobalKey<FormState> formKey) {
    final mobileField = ContactCardFieldDefinitions.byKey(
      ContactCardFieldKey.mobile,
    );
    final mobile = controllerFor(mobileField).text.trim();
    _isMobileValid = mobile.isEmpty ? null : isValid;

    if (mobile.isEmpty) {
      _normalizedMobile = null;
      _updateIdentityCard(state.identity.card.copyWith(mobile: null));
    } else if (_isMobileValid == true && _normalizedMobile != null) {
      _updateIdentityCard(
        state.identity.card.copyWith(mobile: _normalizedMobile),
      );
    }

    handleFieldChange(mobileField, formKey);
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

    final identitiesService = ref.read(identitiesServiceProvider.notifier);

    var updatedCard = state.identity.card;

    for (final field in ContactCardFieldDefinitions.values) {
      final String? persistedValue;
      if (field.key == ContactCardFieldKey.mobile) {
        if (!_hasTouchedMobile) {
          persistedValue = updatedCard.mobile;
        } else {
          final mobile = controllerFor(field).text.trim();
          persistedValue = mobile.isEmpty
              ? null
              : _isMobileValid == true && _normalizedMobile != null
              ? _normalizedMobile
              : updatedCard.mobile;
        }
      } else {
        final controllerValue = controllerFor(field).text.trim();
        persistedValue =
            field.key == ContactCardFieldKey.firstName && controllerValue.isEmpty
            ? anonymousLabel
            : controllerValue;
      }
      updatedCard = field.updateContactCard(updatedCard, persistedValue);
    }

    final displayName = aliasController.text.trim().isEmpty
        ? updatedCard.firstName
        : aliasController.text.trim();
    updatedCard = updatedCard.copyWith(displayName: displayName);

    final updatedIdentity = state.identity.copyWith(card: updatedCard);

    try {
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
