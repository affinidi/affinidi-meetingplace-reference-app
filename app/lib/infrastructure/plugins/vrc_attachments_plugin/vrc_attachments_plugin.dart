import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meeting_place_credentials/meeting_place_credentials.dart';
import 'package:mpx_app_core/mpx_app_core.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../application/services/identities_service/identities_service.dart';
import '../../../domain/models/contact_card/contact_card.dart';
import '../../../domain/models/identity/identity.dart';
import '../../../domain/models/vrc/vrc_credential.dart';
import '../../../infrastructure/extensions/build_context_extensions.dart';
import '../../../infrastructure/extensions/contact_card_extensions.dart';
import '../../../infrastructure/extensions/vrc_extensions.dart';
import '../../../infrastructure/providers/cache_manager_provider.dart';
import '../../../presentation/screens/chat/widgets/credential_attachment_widget.dart';
import '../../../presentation/screens/verifiable_credential/verifiable_credential_screen.dart';
import '../../../presentation/widgets/buttons/elevated_loading_button.dart';
import '../../../presentation/widgets/identity_picker/identity_picker.dart';
import '../../../presentation/widgets/profile_picture.dart';
import 'vrc_attachment.dart';
import 'vrc_attachment_controller.dart';
import 'vrc_attachment_state.dart';

part 'select_vrc_identity_screen.dart';

class VrcAttachmentsPlugin implements AttachmentPlugin {
  VrcAttachmentsPlugin();

  final StreamController<void> _onPickController =
      StreamController<void>.broadcast();
  Stream<void> get onPick => _onPickController.stream;

  @override
  AttachmentPluginIcon get icon =>
      const MaterialIcon(Icons.verified_user, color: Colors.white);

  @override
  bool get isPlatformSupported => true;

  @override
  bool get dismissSheetBeforePicking => true;

  @override
  String localizedName(BuildContext context) =>
      context.l10n.verifiableRelationshipCredential;

  @override
  Future<AttachmentPluginPickResult?> pickAttachments(
    BuildContext context,
  ) async {
    _onPickController.add(null);
    return null;
  }

  @override
  bool supportsFormat(Attachment attachment) =>
      attachment.format == VrcAttachment.pluginFormat;

  @override
  Widget renderAttachment({
    required Attachment attachment,
    required bool isFromMe,
    required Color chatItemColor,
  }) => _VrcAttachmentWidget(attachment: attachment, isFromMe: isFromMe);

  @override
  Widget renderAttachments({
    required List<Attachment> attachments,
    required bool isFromMe,
    required Color chatItemColor,
  }) => attachments.isEmpty
      ? const SizedBox.shrink()
      : _VrcAttachmentWidget(attachment: attachments.first, isFromMe: isFromMe);
}

class _VrcAttachmentWidget extends ConsumerWidget {
  const _VrcAttachmentWidget({
    required Attachment attachment,
    required bool isFromMe,
  }) : _attachment = attachment,
       _isFromMe = isFromMe;

  final Attachment _attachment;
  final bool _isFromMe;

  void _openDetails(BuildContext context, VrcCredential credential) {
    Navigator.of(context, rootNavigator: true).push<void>(
      MaterialPageRoute(
        builder: (_) => VrcDetailsScreen(
          credentialId: credential.id,
          credential: credential,
          isFromMe: _isFromMe,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vcBlob = _attachment.vrcVcBlob;

    final verificationState = vcBlob != null
        ? ref.watch(vrcAttachmentControllerProvider(vcBlob))
        : const VrcAttachmentState.notFound();

    return Skeletonizer(
      enabled: verificationState.maybeWhen(
        initial: () => true,
        loading: () => true,
        orElse: () => false,
      ),
      child: CredentialAttachmentWidget(
        onTap: () {
          verificationState.maybeWhen(
            success: (credential) => _openDetails(context, credential),
            orElse: () {},
          );
        },
      ),
    );
  }
}
