import 'package:clock/clock.dart';
import 'package:meeting_place_core/meeting_place_core.dart';
import 'package:uuid/uuid.dart';

import '../../presentation/screens/media/media_screen/media_screen.dart';

/// Extension methods on [MediaReviewResult] for converting
///  results to attachments.
extension MediaReviewResultAttachment on MediaReviewResult {
  /// Returns an [Attachment] created from the [MediaReviewResult] image data.
  Attachment toImageAttachment() {
    return Attachment(
      id: const Uuid().v4(),
      mediaType: AttachmentMediaType.imageJpeg.value,
      format: AttachmentMediaType.imageJpeg.value,
      lastModifiedTime: clock.now(),
      data: AttachmentData(
        base64: compressedImage.base64,
      ),
    );
  }
}
