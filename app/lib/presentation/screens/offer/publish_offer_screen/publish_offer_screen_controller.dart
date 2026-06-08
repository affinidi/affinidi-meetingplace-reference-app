import 'dart:async';

import 'package:clock/clock.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../application/services/connections_service/connections_service.dart';
import '../../../../application/services/connections_service/publish_offer_request.dart';
import '../../../../application/services/identities_service/identities_service.dart';
import '../../../../application/services/mediator_service/mediator_service.dart';
import '../../../../application/services/settings_service/settings_service.dart';
import '../../../../application/services/vrc_service/vrc_service.dart';
import '../../../../domain/models/identity/identity.dart';
import '../../../../domain/models/mediator/mediator_status.dart';
import '../../../../infrastructure/exceptions/app_exception.dart';
import '../../../../infrastructure/exceptions/app_exception_type.dart';
import '../../../../infrastructure/helpers/debouncer.dart';
import '../../../../infrastructure/providers/app_logger_provider.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../navigation/navigator.dart';
import '../../../../navigation/routes/dashboard_routes.dart';
import '../../../widgets/async_loaders/async_loading_controller.dart';
import 'publish_offer_form_data.dart';
import 'publish_offer_screen_state.dart';

part 'publish_offer_screen_controller.g.dart';

@riverpod
class PublishOfferScreenController extends _$PublishOfferScreenController {
  static const _logKey = 'UXPUB';
  late final _logger = ref.read(appLoggerProvider);
  late final headlineController = TextEditingController();
  late final descriptionController = TextEditingController();
  late final customPhraseController = TextEditingController();
  late final publishOfferLoadingController = AsyncLoadingController.provider(
    'publishOfferLoadingController',
  );

  late final _debouncer = Debouncer();
  late final scrollController = ScrollController();

  @override
  PublishOfferScreenState build(String identityId, AppLocalizations l10n) {
    ref.listen(
      connectionsServiceProvider.select((state) => state.publishedOffer),
      (previous, next) {
        if (next != null && next != previous) {
          Future.microtask(() {
            ref
                .read(navigatorProvider)
                .go(OfferDetailsRoute(next.offerLink).location);
            ref.read(connectionsServiceProvider.notifier).clearPublishedOffer();
          });
        }
      },
      fireImmediately: true,
    );

    ref.listen(
      identitiesServiceProvider.select((state) => state.identities),
      (previous, next) {
        Future.microtask(() {
          state = state.copyWith(identities: next);
        });
      },
      fireImmediately: true,
    );

    final selectedMediatorDid = ref
        .read(settingsServiceProvider)
        .selectedMediatorDid;

    ref.listen(
      mediatorServiceProvider.select((state) => state.mediators),
      (previous, next) {
        if (next != previous) {
          Future.microtask(() {
            final activeMediators = ref.read(
              mediatorServiceProvider.filteredMediators,
            );
            final selectedMediatorName = activeMediators
                .firstWhereOrNull(
                  (mediator) => mediator.mediatorDid == selectedMediatorDid,
                )
                ?.mediatorName;
            state = state.copyWith(
              formData: state.formData.copyWith(
                selectedMediatorName: selectedMediatorName,
              ),
              availableMediators: {
                for (var mediator in activeMediators)
                  mediator.mediatorName: mediator.mediatorDid,
              },
            );
          });
        }
      },
      fireImmediately: true,
    );

    final initialFormData = PublishOfferFormData(
      headline: '',
      description: '',
      isGroupOffer: false,
      hasExpiry: false,
      expiryDate: clock.now().add(const Duration(days: 3)),
      hasMaxUsages: false,
      randomPhraseEnabled: true,
      customPhrase: null,
      isSearchable: false,
      selectedMediatorDid: selectedMediatorDid,
    );

    headlineController.addListener(_updateFormData);
    descriptionController.addListener(_updateFormData);
    customPhraseController.addListener(_updateFormData);

    ref.onDispose(() {
      headlineController.removeListener(_updateFormData);
      descriptionController.removeListener(_updateFormData);
      customPhraseController.removeListener(_updateFormData);
      headlineController.dispose();
      descriptionController.dispose();
      customPhraseController.dispose();
      scrollController.dispose();
      _debouncer.cancel();
    });

    final selectedIdentity = ref.read(
      identitiesServiceProvider.currentIdentityOrPrimary,
    );

    return PublishOfferScreenState(
      formData: initialFormData,
      selectedIdentity: selectedIdentity,
    );
  }

  void initialize() {
    loadIdentity(identityId);
  }

  Future<void> updateMediatorConfig(String mediatorDid) async {
    final mediatorServiceState = ref.read(mediatorServiceProvider);
    final mediators = mediatorServiceState.mediators;

    final mediatorName = mediators
        .firstWhereOrNull(
          (mediator) =>
              mediator.mediatorDid == mediatorDid &&
              mediator.status == MediatorStatus.active,
        )
        ?.mediatorName;

    final updatedFormData = state.formData.copyWith(
      selectedMediatorDid: mediatorDid,
      selectedMediatorName: mediatorName,
    );
    updateFormData(updatedFormData);
  }

  void loadIdentity(String identityId) {
    final identity =
        ref
            .read(identitiesServiceProvider)
            .identities
            .where((i) => i.id == identityId)
            .firstOrNull ??
        state.selectedIdentity;

    if (identity != null) {
      state = state.copyWith(selectedIdentity: identity);

      _prefill(
        connectMessage: l10n.connectWithFirstName(
          state.selectedIdentity!.card.firstName,
        ),
        chatGroupName: l10n.firstNameChatGroup(
          state.selectedIdentity!.card.firstName,
        ),
        defaultDescription: l10n.passphraseDescription,
      );
    }
  }

  void _prefill({
    required String connectMessage,
    required String chatGroupName,
    required String defaultDescription,
  }) {
    final updatedFormData = state.formData.copyWith(
      headline: state.formData.isGroupOffer ? chatGroupName : connectMessage,
      description: defaultDescription,
    );

    headlineController.text = updatedFormData.headline;
    descriptionController.text = updatedFormData.description;

    state = state.copyWith(formData: updatedFormData);
  }

  void _updateHeadline({
    required String connectMessage,
    required String chatGroupName,
    required PublishOfferFormData formData,
  }) {
    if (state.selectedIdentity != null &&
        state.selectedIdentity!.card.firstName.isNotEmpty) {
      final headline = formData.isGroupOffer ? chatGroupName : connectMessage;

      headlineController.text = headline;

      final updatedFormData = formData.copyWith(headline: headline);

      state = state.copyWith(formData: updatedFormData);
    } else {
      state = state.copyWith(formData: formData);
    }
  }

  void toggleGroupOffer(
    bool value, {
    required String connectMessage,
    required String chatGroupName,
  }) {
    final updatedFormData = state.formData.copyWith(isGroupOffer: value);

    _updateHeadline(
      connectMessage: connectMessage,
      chatGroupName: chatGroupName,
      formData: updatedFormData,
    );
  }

  void toggleRandomPhrase(bool value) {
    final updatedFormData = state.formData.copyWith(randomPhraseEnabled: value);
    updateFormData(updatedFormData);

    if (value) {
      final clearedFormData = updatedFormData.copyWith(
        customPhrase: null,
        isPhraseAvailable: null,
        isPhraseValidating: false,
      );
      customPhraseController.clear();
      updateFormData(clearedFormData);
    }
  }

  void updateFormData(PublishOfferFormData formData) {
    state = state.copyWith(formData: formData);
  }

  Future<bool> validateOfferPhrase(String phrase) async {
    final trimmed = phrase.trim();
    final formData = state.formData;

    if (formData.randomPhraseEnabled || trimmed.isEmpty) {
      final updatedFormData = formData.copyWith(
        customPhrase: trimmed.isEmpty ? null : formData.customPhrase,
        isPhraseAvailable: null,
        isPhraseValidating: false,
      );
      state = state.copyWith(formData: updatedFormData);
      return false;
    }

    state = state.copyWith(
      formData: formData.copyWith(
        customPhrase: trimmed,
        isPhraseValidating: true,
      ),
    );

    try {
      await ref
          .read(connectionsServiceProvider.notifier)
          .validateOfferPhrase(trimmed);
      final isPhraseAvailable = ref.read(
        connectionsServiceProvider.select((s) => s.isCustomPhraseAvailable),
      );
      final finalFormData = state.formData.copyWith(
        isPhraseAvailable: isPhraseAvailable,
        isPhraseValidating: false,
      );
      state = state.copyWith(formData: finalFormData);
      return isPhraseAvailable == true;
    } catch (error, stackTrace) {
      _logger.error(
        'Error validating phrase',
        error: error,
        stackTrace: stackTrace,
        name: _logKey,
      );
      state = state.copyWith(
        formData: state.formData.copyWith(
          isPhraseAvailable: false,
          isPhraseValidating: false,
        ),
      );
      return false;
    }
  }

  Future<void> publishOffer({required PublishOfferFormData formData}) async {
    await ref.read(publishOfferLoadingController.notifier).start(() async {
      final selectedIdentity = state.selectedIdentity;
      if (selectedIdentity == null) {
        throw AppException(
          'You must select an identity',
          code: AppExceptionType.missingIdentity.name,
        );
      }

      var latestFormData = state.formData;

      if (!latestFormData.randomPhraseEnabled) {
        final latestCustomPhrase = customPhraseController.text.trim();
        latestFormData = latestFormData.copyWith(
          customPhrase: latestCustomPhrase,
          isPhraseValidating: true,
        );
        updateFormData(latestFormData);

        _debouncer.cancel();

        final isAvailable = await validateOfferPhrase(latestCustomPhrase);
        latestFormData = state.formData;
        if (!isAvailable) {
          return;
        }
      }

      // Reset expiryDate to null if not set and refresh offer score.
      final vrcCount = await ref
          .read(vrcServiceProvider.notifier)
          .countVrcsByDid(selectedIdentity.did);

      final normalizedFormData = formData.hasExpiry
          ? formData
          : formData.copyWith(expiryDate: null);
      final updatedFormData = normalizedFormData.copyWith(score: vrcCount);

      final request = PublishOfferRequest(
        headline: updatedFormData.headline,
        description: updatedFormData.description,
        isGroupOffer: updatedFormData.isGroupOffer,
        selectedMediatorDid: updatedFormData.selectedMediatorDid,
        expiryDate: updatedFormData.expiryDate,
        maxUsages: updatedFormData.maxUsages,
        customPhrase: updatedFormData.customPhrase,
        score: updatedFormData.score,
      );

      await ref
          .read(connectionsServiceProvider.notifier)
          .publishOffer(request, identity: selectedIdentity);
    });
  }

  void _updateFormData() {
    final currentFormData = state.formData;

    final updatedFormData = currentFormData.copyWith(
      headline: headlineController.text,
      description: descriptionController.text,
      customPhrase: currentFormData.randomPhraseEnabled
          ? null
          : customPhraseController.text,
    );

    updateFormData(updatedFormData);

    final customPhrase = updatedFormData.customPhrase?.trim() ?? '';
    if (!updatedFormData.randomPhraseEnabled) {
      // If custom phrase is empty, reset validation state immediately
      if (customPhrase.isEmpty) {
        updateFormData(
          updatedFormData.copyWith(
            isPhraseAvailable: null,
            isPhraseValidating: false,
          ),
        );
        return;
      }

      // Only validate if the custom phrase has changed
      final previousCustomPhrase = currentFormData.customPhrase?.trim() ?? '';
      if (customPhrase != previousCustomPhrase) {
        updateFormData(updatedFormData.copyWith(isPhraseValidating: true));
        _validateCustomPhraseWithDebounce();
      }
    }
  }

  void _validateCustomPhraseWithDebounce() {
    final phrase = state.formData.customPhrase?.trim() ?? '';
    _debouncer.run(() async {
      if (phrase.isNotEmpty) {
        await validateOfferPhrase(phrase);
      } else {
        state = state.copyWith(
          formData: state.formData.copyWith(
            isPhraseAvailable: null,
            isPhraseValidating: false,
          ),
        );
      }
    });
  }

  void selectIdentity(Identity identity) {
    state = state.copyWith(selectedIdentity: identity);

    _updateHeadline(
      connectMessage: l10n.connectWithFirstName(identity.card.firstName),
      chatGroupName: l10n.firstNameChatGroup(identity.card.firstName),
      formData: state.formData,
    );
  }
}

extension PublishOfferScreenControllerProviderSelector
    on PublishOfferScreenControllerProvider {
  ProviderListenable<bool> get canPublish {
    return select((state) {
      if (state.formData.headline.trim().isEmpty ||
          state.formData.description.trim().isEmpty) {
        return false;
      }

      if (state.formData.randomPhraseEnabled) {
        return true;
      }

      if (state.formData.isPhraseValidating == true) {
        return false;
      }

      if (state.formData.isPhraseAvailable != true) {
        return false;
      }

      final customPhrase = state.formData.customPhrase;
      return customPhrase != null && customPhrase.trim().isNotEmpty;
    });
  }
}
