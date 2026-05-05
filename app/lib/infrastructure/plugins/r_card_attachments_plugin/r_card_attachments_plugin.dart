import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meeting_place_relationship/meeting_place_relationship.dart';
import 'package:mpx_app_core/mpx_app_core.dart';

import '../../../application/services/identities_service/identities_service.dart';
import '../../../domain/models/identity/identity.dart';
import '../../../infrastructure/extensions/build_context_extensions.dart';
import '../../../infrastructure/providers/cache_manager_provider.dart';
import '../../../infrastructure/providers/meeting_place_sdk_provider.dart';
import '../../../navigation/routes/dashboard_routes.dart';
import '../../../presentation/painting/cached_base64_image.dart';
import '../../../presentation/screens/chat/widgets/r_card_chat_tile.dart';
import '../../../presentation/widgets/buttons/elevated_loading_button.dart';
import '../../../presentation/widgets/identity_picker/identity_picker.dart';
import 'r_card_attachment.dart';

part 'r_card_message_attachment.dart';
part 'r_card_attachment_widget.dart';
part 'select_r_card_persona_screen.dart';

class RCardAttachmentsPlugin implements AttachmentPlugin {
  RCardAttachmentsPlugin({
    required BaseCacheManager cacheManager,
    required Ref ref,
  }) : _cacheManager = cacheManager,
       _ref = ref;

  final BaseCacheManager _cacheManager;
  final Ref _ref;

  @override
  String get icon => '💳';

  @override
  bool get isPlatformSupported => true;

  @override
  String localizedName(BuildContext context) => context.l10n.genRCard;

  @override
  Future<AttachmentPluginPickResult?> pickAttachments(
    BuildContext context,
  ) async {
    if (!context.mounted) return null;

    // Dismiss the bottom sheet immediately so it doesn't flash on back/cancel
    final navigator = Navigator.of(context, rootNavigator: true);
    navigator.pop();

    final identity = await navigator.push<Identity>(
      MaterialPageRoute(builder: (_) => const _SelectRCardPersonaScreen()),
    );

    if (identity == null) return null;

    try {
      final sdk = await _ref.read(meetingPlaceSdkProvider.future);
      final didManager = await sdk.getDidManager(identity.did);

      final attachments = await RCardAttachmentBuilder.buildForPersona(
        persona: PersonaDid(did: identity.did, name: identity.card.displayName),
        card: RCardSubject(
          firstName: identity.card.firstName,
          lastName: identity.card.lastName,
          email: identity.card.email,
          phone: identity.card.mobile,
        ),
        issuerDidManager: didManager,
      );

      return AttachmentPluginPickResult(
        text: '',
        attachments: attachments
            .map((a) => _RCardMessageAttachment(attachment: a))
            .toList(),
      );
    } catch (_) {
      return null;
    }
  }

  @override
  bool supportsFormat(Attachment attachment) =>
      attachment.format == RCardAttachment.pluginFormat;

  @override
  Widget renderAttachment({
    required Attachment attachment,
    required bool isFromMe,
    required Color chatItemColor,
  }) => _RCardAttachmentWidget(
    attachment: attachment,
    cacheManager: _cacheManager,
    chatItemColor: chatItemColor,
    isFromMe: isFromMe,
  );

  @override
  Widget renderAttachments({
    required List<Attachment> attachments,
    required bool isFromMe,
    required Color chatItemColor,
  }) => attachments.isEmpty
      ? const SizedBox.shrink()
      : _RCardAttachmentWidget(
          attachment: attachments.first,
          cacheManager: _cacheManager,
          chatItemColor: chatItemColor,
          isFromMe: isFromMe,
        );
}


