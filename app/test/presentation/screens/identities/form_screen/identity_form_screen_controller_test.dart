import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:mpx_flutter_reference_app/application/services/identities_service/identities_service.dart';
import 'package:mpx_flutter_reference_app/application/services/identities_service/identities_service_state.dart';
import 'package:mpx_flutter_reference_app/domain/models/contact_card/contact_card_field_definition.dart';
import 'package:mpx_flutter_reference_app/domain/models/identity/identity.dart';
import 'package:mpx_flutter_reference_app/l10n/app_localizations.dart';
import 'package:mpx_flutter_reference_app/presentation/screens/identities/form_screen/identity_form_mode.dart';
import 'package:mpx_flutter_reference_app/presentation/screens/identities/form_screen/identity_form_screen_controller.dart';

import '../../../../fakes/fake_identities.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('IdentityFormScreenController', () {
    final mobileField = ContactCardFieldDefinitions.byKey(
      ContactCardFieldKey.mobile,
    );
    final firstNameField = ContactCardFieldDefinitions.byKey(
      ContactCardFieldKey.firstName,
    );

    ProviderContainer makeContainer(_FakeIdentitiesService service) {
      final container = ProviderContainer(
        overrides: [identitiesServiceProvider.overrideWith(() => service)],
      );
      addTearDown(container.dispose);
      return container;
    }

    test('does not mark the stored mobile as touched on init callback', () {
      final identity = FakeIdentities.primaryIdentity;
      final service = _FakeIdentitiesService([identity]);
      final container = makeContainer(service);
      final provider = identityFormScreenControllerProvider(identity.id);
      final controller = container.read(provider.notifier);

      container.read(provider);
      controller.updateMobile(
        PhoneNumber(phoneNumber: identity.card.mobile, isoCode: 'US'),
      );

      expect(controller.hasTouchedMobile, isFalse);
    });

    test('marks mobile as touched when the callback value changes', () {
      final identity = FakeIdentities.primaryIdentity;
      final service = _FakeIdentitiesService([identity]);
      final container = makeContainer(service);
      final provider = identityFormScreenControllerProvider(identity.id);
      final controller = container.read(provider.notifier);

      container.read(provider);
      controller.controllerFor(mobileField).text = '+10987654321';
      controller.updateMobile(
        PhoneNumber(phoneNumber: '+10987654321', isoCode: 'US'),
      );

      expect(controller.hasTouchedMobile, isTrue);
    });

    test(
      'preserves untouched stored mobile when saving unrelated edits',
      () async {
        final identity = FakeIdentities.primaryIdentity.copyWith(
          card: FakeIdentities.primaryIdentity.card.copyWith(mobile: 'legacy'),
        );
        final service = _FakeIdentitiesService([identity]);
        final container = makeContainer(service);
        final provider = identityFormScreenControllerProvider(identity.id);
        final controller = container.read(provider.notifier);

        container.read(provider);
        controller.controllerFor(firstNameField).text = 'Updated';

        final saved = await controller.saveIdentity(
          anonymousLabel: 'Anonymous',
          mode: IdentityFormMode.edit,
        );

        expect(saved, isTrue);
        expect(service.updatedIdentity?.card.firstName, 'Updated');
        expect(service.updatedIdentity?.card.mobile, 'legacy');
      },
    );

    test(
      'preserves the last stored mobile when a touched value is invalid',
      () async {
        final identity = FakeIdentities.primaryIdentity;
        final service = _FakeIdentitiesService([identity]);
        final container = makeContainer(service);
        final provider = identityFormScreenControllerProvider(identity.id);
        final controller = container.read(provider.notifier);

        container.read(provider);
        controller.controllerFor(mobileField).text = '+1';
        controller.updateMobile(PhoneNumber(phoneNumber: '+1', isoCode: 'US'));

        final saved = await controller.saveIdentity(
          anonymousLabel: 'Anonymous',
          mode: IdentityFormMode.edit,
        );

        expect(saved, isTrue);
        expect(service.updatedIdentity?.card.mobile, identity.card.mobile);
      },
    );

    testWidgets(
      'untouched legacy mobile does not block validation or show errors',
      (tester) async {
        final identity = FakeIdentities.primaryIdentity.copyWith(
          card: FakeIdentities.primaryIdentity.card.copyWith(mobile: 'legacy'),
        );
        final service = _FakeIdentitiesService([identity]);
        final container = makeContainer(service);
        final provider = identityFormScreenControllerProvider(identity.id);
        final subscription = container.listen(provider, (_, _) {});
        final controller = container.read(provider.notifier);
        final formKey = GlobalKey<FormState>();

        addTearDown(subscription.close);

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: Scaffold(
                body: Form(key: formKey, child: const SizedBox.shrink()),
              ),
            ),
          ),
        );

        controller.validateForm(formKey);
        controller.updateErrorVisibilityOnBlur(mobileField, formKey);

        expect(container.read(provider).canSave, isTrue);
        expect(controller.shouldShowValidation(mobileField), isFalse);
      },
    );
  });
}

class _FakeIdentitiesService extends IdentitiesService {
  _FakeIdentitiesService(List<Identity> identities)
    : _initialState = IdentitiesServiceState(identities: identities);

  final IdentitiesServiceState _initialState;
  Identity? updatedIdentity;

  @override
  IdentitiesServiceState build() {
    return _initialState;
  }

  @override
  Future<void> updateIdentity(Identity identity) async {
    updatedIdentity = identity;
    state = state.copyWith(
      identities: [
        for (final currentIdentity in state.identities)
          currentIdentity.id == identity.id ? identity : currentIdentity,
      ],
      currentIdentity: state.currentIdentity?.id == identity.id
          ? identity
          : state.currentIdentity,
    );
  }
}
