part of 'r_card_attachments_plugin.dart';

class _RCardAttachmentWidget extends StatelessWidget {
  const _RCardAttachmentWidget({
    required Attachment attachment,
    required BaseCacheManager cacheManager,
    required Color chatItemColor,
    required bool isFromMe,
  }) : _attachment = attachment,
       _cacheManager = cacheManager,
       _chatItemColor = chatItemColor,
       _isFromMe = isFromMe;

  final Attachment _attachment;
  final BaseCacheManager _cacheManager;
  final Color _chatItemColor;
  final bool _isFromMe;

  @override
  Widget build(BuildContext context) {
    final subjectDid = _attachment.rCardSubjectDid;
    final vcBlob = _attachment.rCardVcBlob;
    final subject = (vcBlob != null && vcBlob.isNotEmpty)
        ? RCardSubject.fromVcBlob(vcBlob)
        : null;
    final name = subject?.name.trim() ?? '';
    final displayName = name.isNotEmpty ? name : (subjectDid ?? '—');
    final profilePic = subject?.profilePic?.trim();
    final avatarImage = (profilePic != null && profilePic.isNotEmpty)
        ? CachedBase64Image(profilePic, cacheManager: _cacheManager)
              as ImageProvider
        : null;
    final canOpenDetails = subjectDid != null && subjectDid.isNotEmpty;

    return RCardChatTile(
      name: displayName,
      avatarImage: avatarImage,
      chatItemColor: _chatItemColor,
      onTap: canOpenDetails ? () => _openRCardDetails(context) : null,
    );
  }

  Future<void> _openRCardDetails(BuildContext context) async {
    final subjectDid = _attachment.rCardSubjectDid;
    if (subjectDid == null || subjectDid.isEmpty) return;
    final vcBlob = _attachment.rCardVcBlob;
    final route = RCardDetailsRoute(subjectDid: subjectDid);
    if (_isFromMe && vcBlob != null && vcBlob.isNotEmpty) {
      await context.push<void>(
        route.location,
        extra: {'vcBlob': vcBlob, 'isFromMe': true},
      );
    } else {
      await route.push<void>(context);
    }
  }
}
