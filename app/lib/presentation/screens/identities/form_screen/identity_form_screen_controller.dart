import 'package:flutter/material.dart';
import 'package:meeting_place_core/meeting_place_core.dart'
    show ContactCard, Identity;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

import '../../../../application/services/identities_service/identities_service.dart';
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

  @override
  IdentityFormScreenState build(String? identityId) {
    ref.onDispose(() {
      scrollController.dispose();
      displayNameController.dispose();
      lastNameController.dispose();
      emailController.dispose();
      mobileController.dispose();
      aliasController.dispose();
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
      firstName: '',
      displayName: '',
    );

    return Identity(
      id: uuid.v4(),
      did: '',
      card: newCard,
    );
  }

  Identity _loadIdentity(String? identityId) {
    if (identityId == null) {
      return _makeNewIdentity();
    }

    final identity = ref
        .read(identitiesServiceProvider)
        .identities
        .where((i) => i.id == identityId)
        .firstOrNull;

    if (identity == null) {
      throw AppException('missing identity',
          code: AppExceptionType.missingIdentity.name);
    }

    displayNameController.text = identity.card.firstName;
    lastNameController.text = identity.card.lastName ?? '';
    emailController.text = identity.card.email ?? '';
    mobileController.text = identity.card.mobile ?? '';
    aliasController.text = identity.card.displayName;

    return identity;
  }

  void _updateHasEnteredAnyInfo() {
    final hasInfo = (displayNameController.text.trim().isNotEmpty ||
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
    final isValid = formKey.currentState?.validate() ?? false;
    state = state.copyWith(canSave: isValid);
  }

  void updateFirstName(String firstName, GlobalKey<FormState> formKey) {
    final error = InputValidators.getValidator(
            formKey.currentContext!, InputType.firstName)
        .call(firstName);
    if (error != null) return;

    final identity = state.identity;

    if (state.isAliasMirroringFirstName) {
      aliasController.text = firstName;

      _updateIdentityCard(identity.card.copyWith(
        firstName: firstName,
        displayName: firstName,
      ));
    } else {
      _updateIdentityCard(identity.card.copyWith(firstName: firstName));
    }

    _updateHasEnteredAnyInfo();
  }

  Future<void> updateProfilePic(String? imageString) async {
    final identity = state.identity;

    _updateIdentityCard(
      identity.card.copyWith(
          profilePic: imageString?.isEmpty ?? true ? null : imageString),
    );
  }

  void updateLastName(String lastName, GlobalKey<FormState> formKey) {
    final error = InputValidators.getValidator(
            formKey.currentContext!, InputType.lastName)
        .call(lastName);
    if (error != null) return;

    final identity = state.identity;

    _updateIdentityCard(
        identity.card.copyWith(lastName: lastName.isEmpty ? null : lastName));
    _updateHasEnteredAnyInfo();
  }

  void updateEmail(String email, GlobalKey<FormState> formKey) {
    final error =
        InputValidators.getValidator(formKey.currentContext!, InputType.email)
            .call(email);
    if (error != null) return;

    final identity = state.identity;

    _updateIdentityCard(
        identity.card.copyWith(email: email.isEmpty ? null : email));
    _updateHasEnteredAnyInfo();
  }

  void updateMobile(String mobile, GlobalKey<FormState> formKey) {
    final error =
        InputValidators.getValidator(formKey.currentContext!, InputType.phone)
            .call(mobile);
    if (error != null) return;

    final identity = state.identity;

    _updateIdentityCard(
        identity.card.copyWith(mobile: mobile.isEmpty ? null : mobile));
    _updateHasEnteredAnyInfo();
  }

  void updateCardColor(Color color) {
    final identity = state.identity;

    _updateIdentityCard(
        identity.card.copyWith(cardColor: color.toARGB32().toString()));
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

    final firstName = displayNameController.text.trim().isEmpty
        ? anonymousLabel
        : displayNameController.text.trim();
    final lastName = lastNameController.text.trim();
    final email = emailController.text.trim();
    final mobile = mobileController.text.trim();
    final displayName = aliasController.text.trim().isEmpty
        ? anonymousLabel
        : aliasController.text.trim();
    final cardColor = state.identity.card.cardColor;
    final profilePic = state.identity.card.profilePic;

    final existingIdentity = state.identity;
    final updatedIdenity = state.identity.copyWith(
        card: existingIdentity.card.copyWith(
      firstName: firstName,
      lastName: lastName.isEmpty ? null : lastName,
      email: email.isEmpty ? null : email,
      mobile: mobile.isEmpty ? null : mobile,
      displayName: displayName,
      cardColor: cardColor,
      profilePic: profilePic,
    ));

    try {
      if (mode == IdentityFormMode.add) {
        await identitiesService.addIdentity(updatedIdenity);
      } else {
        await identitiesService.updateIdentity(updatedIdenity);
      }
      state = state.copyWith(identity: updatedIdenity, hasSaved: true);
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
