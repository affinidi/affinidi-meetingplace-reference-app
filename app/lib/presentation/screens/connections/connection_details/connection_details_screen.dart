import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:meeting_place_core/meeting_place_core.dart';

import '../../../../infrastructure/extensions/build_context_extensions.dart';
import '../../../../infrastructure/extensions/contact_extensions.dart';
import '../../../../infrastructure/extensions/date_time_extensions.dart';
import '../../../../infrastructure/extensions/did_extensions.dart';
import '../../../../infrastructure/extensions/vcard_extensions.dart';
import '../../../../infrastructure/providers/cache_manager_provider.dart';
import '../../../painting/cached_base64_image.dart';
import '../../../widgets/async_loaders/modal_async_loading_status.dart';
import '../../../widgets/buttons/elevated_loading_button.dart';
import '../../../widgets/form_rows/form_card.dart';
import '../../../widgets/form_rows/form_row_icon_title.dart';
import '../../../widgets/form_rows/form_row_text_field.dart';
import '../../../widgets/identity_picker/identity_card.dart';
import '../../../widgets/images/default_profile_image.dart';
import '../../../widgets/mnemonic_pill.dart';
import '../../../widgets/qr/qr_code_view.dart';
import '../../media/image_view_screen/image_view_screen.dart';
import '../../media/media_screen/media_screen.dart';
import 'connection_details_screen_controller.dart';

part 'connection_details_actions_bar.dart';
part 'connection_details_display_name.dart';
part 'connection_details_names.dart';
part 'connection_details_panel.dart';
part 'connection_details_profile_pictures.dart';
part 'connection_details_shared_identity.dart';
part 'connection_details_status.dart';
part 'connection_details_their_details.dart';
part 'connection_details_group_details.dart';
part 'connection_mnemonic.dart';
part 'connection_qr_code_view.dart';
part 'group_members_panel.dart';

class ConnectionDetailsScreen extends HookConsumerWidget {
  const ConnectionDetailsScreen({
    super.key,
    required this.contactId,
  });

  final String contactId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = connectionDetailsScreenControllerProvider(contactId);
    final controller = ref.read(provider.notifier);
    final isGroupChat = ref.watch(provider.isGroupChat);
    final l10n = context.l10n;

    useEffect(() {
      if (!context.mounted) return;

      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await controller.initialize();
      });

      return null;
    }, const []);

    return Scaffold(
      appBar: AppBar(
        title: Text(isGroupChat
            ? context.l10n.groupDetails
            : context.l10n.connectionDetails),
      ),
      body: SafeArea(
        child: Column(
          children: [
            ModalAsyncLoadingStatus(
              controller.approveOfferLoadingController,
              loadingMessage: l10n.approving,
              successMessage: l10n.connectionRequestInProgress,
              successMessageStyle: LoadingMessageStyle.progress,
            ),
            ModalAsyncLoadingStatus(
              controller.rejectOfferLoadingController,
              loadingMessage: l10n.rejecting,
              successMessage: l10n.connectionRequestRejected,
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: 10,
                  children: [
                    _ProfilePictures(contactId),
                    _Names(contactId),
                    _Status(contactId),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: Column(
                        spacing: 20,
                        children: [
                          _DisplayNamePanel(contactId),
                          if (isGroupChat) _GroupMembersPanel(contactId),
                          isGroupChat
                              ? _GroupDetailsPanel(contactId)
                              : _TheirDetailsPanel(contactId),
                          _SharedIdentityPanel(contactId),
                          _ConnectionDetailsPanel(contactId),
                          _ConnectionMnenomicPanel(contactId),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            _ActionBar(contactId),
          ],
        ),
      ),
    );
  }
}
