import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:meeting_place_relationship/meeting_place_relationship.dart';
import 'package:mpx_app_core/mpx_app_core.dart';

import '../../../application/services/identities_service/identities_service.dart';
import '../../../domain/models/identity/identity.dart';
import '../../../infrastructure/extensions/build_context_extensions.dart';
import '../../../infrastructure/providers/cache_manager_provider.dart';
import '../../../navigation/routes/dashboard_routes.dart';
import '../../../presentation/painting/cached_base64_image.dart';
import '../../../presentation/screens/chat/widgets/r_card_chat_tile.dart';
import '../../../presentation/widgets/buttons/elevated_loading_button.dart';
import '../../../presentation/widgets/identity_picker/identity_picker.dart';
import 'r_card_attachment.dart';

part 'r_card_attachment_widget.dart';
part 'select_r_card_identity_screen.dart';

class RCardAttachmentsPlugin implements AttachmentPlugin {
  RCardAttachmentsPlugin({required BaseCacheManager cacheManager})
    : _cacheManager = cacheManager;

  final _startRCardController = StreamController<Identity>.broadcast();

  Stream<Identity> get onRCardFromAttachment => _startRCardController.stream;

  final BaseCacheManager _cacheManager;

  @override
  @override
  AttachmentPluginIcon get icon => const EmojiIcon('💳');

  @override
  bool get isPlatformSupported => true;

  @override
  bool get dismissSheetBeforePicking => true;

  @override
  String localizedName(BuildContext context) => context.l10n.genRCard;

  @override
  Future<AttachmentPluginPickResult?> pickAttachments(
    BuildContext context,
  ) async {
    if (!context.mounted) return null;

    final identity = await Navigator.of(context, rootNavigator: true)
        .push<Identity>(
          MaterialPageRoute(builder: (_) => const _SelectRCardIdentityScreen()),
        );

    if (identity == null) return null;

    _startRCardController.add(identity);
    return null;
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
  }) {
    if (attachments.isEmpty) return const SizedBox.shrink();
    return Column(
      children: attachments
          .map(
            (attachment) => _RCardAttachmentWidget(
              attachment: attachment,
              cacheManager: _cacheManager,
              chatItemColor: chatItemColor,
              isFromMe: isFromMe,
            ),
          )
          .toList(),
    );
  }
}
