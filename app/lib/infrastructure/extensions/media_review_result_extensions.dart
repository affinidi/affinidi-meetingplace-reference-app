import 'package:clock/clock.dart';
import 'package:meeting_place_chat/meeting_place_chat.dart';
import 'package:meeting_place_core/meeting_place_core.dart';
import 'package:uuid/uuid.dart';

import '../../presentation/screens/media/media_screen/media_screen.dart';

/// Extension methods on [MediaReviewResult] for converting
///  results to attachments.
extension MediaReviewResultAttachment on MediaReviewResult {
  /// Returns a [ChatAttachment] created from
  /// the [MediaReviewResult] image data.
  ChatAttachment toImageAttachment() {
    return ChatAttachment(
      id: const Uuid().v4(),
      mediaType: AttachmentMediaType.imageJpeg.value,
      format: AttachmentMediaType.imageJpeg.value,
      lastModifiedTime: clock.now(),
      data: ChatAttachmentData(base64: compressedImage.base64),
    );
  }
}
