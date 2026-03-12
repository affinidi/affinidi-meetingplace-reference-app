import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../domain/models/contact_card/identity_field.dart';
import '../../../../infrastructure/extensions/build_context_extensions.dart';
import '../../../../infrastructure/extensions/contact_card_extensions.dart';
import '../../../../infrastructure/extensions/did_extensions.dart';
import '../../../../infrastructure/providers/cache_manager_provider.dart';
import '../../../config/persona_field_config.dart';
import '../../../dialogs/offer/delete_connection_dialog.dart';
import '../../../widgets/async_loaders/modal_async_loading_status.dart';
import '../../../widgets/buttons/elevated_loading_button.dart';
import '../../../widgets/contact_card_view.dart';
import '../../../widgets/form_rows/form_card.dart';
import '../../../widgets/form_rows/form_row_icon_text.dart';
import '../../../widgets/form_rows/form_row_icon_title.dart';
import '../../../widgets/mnemonic_pill.dart';
import '../../../widgets/offer_banner.dart';
import '../../../widgets/profile_picture.dart';
import '../../../widgets/qr/qr_code_view.dart';
import 'offer_details_screen_controller.dart';

part 'offer_details_action_bar.dart';
part 'offer_details_alias_profile_panel.dart';
part 'offer_details_did_info_panel.dart';
part 'offer_details_header.dart';
part 'offer_details_info_panel.dart';
part 'offer_details_name.dart';
part 'offer_details_description.dart';
part 'offer_details_personal_info_panel.dart';
part 'offer_details_phrase.dart';
part 'offer_details_validity_visibility_panel.dart';
part 'offer_qr_code_view.dart';

class OfferDetailsScreen extends HookConsumerWidget {
  const OfferDetailsScreen({super.key, required this.offerLink});

  final String offerLink;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = offerDetailsScreenControllerProvider(offerLink);
    final controller = ref.read(provider.notifier);

    useEffect(() {
      if (!context.mounted) return;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller.initialize();
      });

      return null;
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.connectionOfferDetails),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _OfferDetailsHeader(offerLink),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: Column(
                        spacing: 10,
                        children: [
                          _OfferDetailsName(offerLink),
                          _OfferDetailsDescription(offerLink),
                          _OfferDetailsPhrase(offerLink),
                          _OfferDetailsValidityVisibilityPanel(offerLink),
                          _OfferDetailsPersonalInfoPanel(offerLink),
                          _OfferDetailsAliasProfilePanel(offerLink),
                          _OfferDetailsDidInfoPanel(offerLink),
                          _OfferDetailsInfoPanel(offerLink),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            _OfferDetailsActionBar(offerLink),
          ],
        ),
      ),
    );
  }
}
