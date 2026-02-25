import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../infrastructure/configuration/environment.dart';
import '../../../../infrastructure/extensions/build_context_extensions.dart';
import '../../../../infrastructure/extensions/widget_ref_extensions.dart';
import '../../../../infrastructure/providers/cache_manager_provider.dart';
import '../../../dialogs/offer/expiry_date_picker_menu.dart';
import '../../../dialogs/offer/max_usage_picker_menu.dart';
import '../../../dialogs/offer/mediator_picker_menu.dart';
import '../../../widgets/async_loaders/modal_async_loading_status.dart';
import '../../../widgets/buttons/elevated_loading_button.dart';
import '../../../widgets/form_rows/form_card.dart';
import '../../../widgets/form_rows/form_row_picker.dart';
import '../../../widgets/form_rows/form_row_text_field.dart';
import '../../../widgets/form_rows/form_row_toggle.dart';
import '../../../widgets/identity_picker/identity_picker.dart';
import '../../../widgets/offer_banner.dart';
import 'publish_offer_screen_controller.dart';

part 'mediator_section.dart';
part 'offer_app_bar.dart';
part 'offer_bottom_container.dart';
part 'offer_details_section.dart';
part 'phrase_validation_icon.dart';
part 'validity_visibility_section.dart';

class PublishOfferScreen extends HookConsumerWidget {
  const PublishOfferScreen({
    super.key,
    required String identityId,
  }) : _identityId = identityId;

  final String _identityId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider =
        publishOfferScreenControllerProvider(_identityId, context.l10n);
    final controller = ref.read(provider.notifier);
    ref.keepAround(provider);

    const double maxWidth = 900;
    final width = MediaQuery.sizeOf(context).width;
    final inset = width > maxWidth ? (width - maxWidth) / 2 : 20.0;

    useEffect(
      () {
        if (!context.mounted) return;

        WidgetsBinding.instance.addPostFrameCallback((_) {
          controller.initialize();
        });

        return null;
      },
      [],
    );

    return Scaffold(
      appBar: _OfferAppBar(_identityId),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                controller: controller.scrollController,
                padding: EdgeInsets.fromLTRB(inset, 0, inset, 20),
                child: Column(
                  spacing: 20,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 0, 0, 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 10,
                        children: [
                          const OfferBanner(),
                          Text(
                            context.l10n.meetingPlaceBannerText,
                            style: context.textTheme.bodyMedium,
                          ),
                          _IdentitiesCardDeck(_identityId),
                        ],
                      ),
                    ),
                    _OfferDetailsSection(_identityId),
                    _ValidityVisibilitySection(_identityId),
                    _MediatorSection(_identityId),
                  ],
                ),
              ),
            ),
            _OfferBottomContainer(_identityId),
          ],
        ),
      ),
    );
  }
}

class _IdentitiesCardDeck extends ConsumerWidget {
  _IdentitiesCardDeck(String identityId) : _identityId = identityId;

  final String _identityId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider =
        publishOfferScreenControllerProvider(_identityId, context.l10n);
    final controller = ref.read(provider.notifier);

    final selectedIdentity =
        ref.watch(provider.select((state) => state.selectedIdentity));
    final identities = ref.watch(provider.select((state) => state.identities));
    final identityIndex =
        identities.indexWhere((identity) => identity == selectedIdentity);
    final cacheManager = ref.read(cacheManagerProvider);

    return IdentityPicker(
      key: const ValueKey('publish_offer_identity_picker'),
      identities: identities,
      onSelectedIdentity: controller.selectIdentity,
      displayMode: true,
      initialCardIndex: identityIndex,
      cacheManager: cacheManager,
    );
  }
}
