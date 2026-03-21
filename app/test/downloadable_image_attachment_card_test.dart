import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:meeting_place_core/meeting_place_core.dart';
import 'package:mpx_flutter_reference_app/infrastructure/exceptions/app_exception.dart';
import 'package:mpx_flutter_reference_app/infrastructure/exceptions/app_exception_type.dart';
import 'package:mpx_flutter_reference_app/infrastructure/plugins/downloadable_image_attachment_card.dart';
import 'package:mpx_flutter_reference_app/l10n/app_localizations.dart';

import 'fakes/fake_cache_manager.dart';
import 'fakes/fake_image_picker.dart';
import 'utils/app.dart';

class _AttachmentCardHarness extends StatefulWidget {
  const _AttachmentCardHarness({
    super.key,
    required this.initialAttachment,
    required this.onDownloadAttachment,
  });

  final Attachment initialAttachment;
  final Future<void> Function(Attachment attachment) onDownloadAttachment;

  @override
  State<_AttachmentCardHarness> createState() => _AttachmentCardHarnessState();
}

class _AttachmentCardHarnessState extends State<_AttachmentCardHarness> {
  late Attachment _attachment = widget.initialAttachment;

  void updateAttachment(Attachment attachment) {
    setState(() {
      _attachment = attachment;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: Center(
            child: DownloadableImageAttachmentCard(
              attachment: _attachment,
              cacheManager: FakeCacheManager(),
              onDownloadAttachment: widget.onDownloadAttachment,
            ),
          ),
        ),
      ),
    );
  }
}

Attachment _linkAttachment() {
  return Attachment(
    id: 'attachment-1',
    format: 'mpx_gallery_attachment_plugin',
    mediaType: AttachmentMediaType.imageJpeg.value,
    data: AttachmentData(
      links: [Uri.parse('https://example.com/attachment.jpg')],
    ),
  );
}

Attachment _base64Attachment() {
  return Attachment(
    id: 'attachment-1',
    format: 'mpx_gallery_attachment_plugin',
    mediaType: AttachmentMediaType.imageJpeg.value,
    data: AttachmentData(
      base64: base64Encode(FakeImagePicker.defaultImageBytes),
      links: [Uri.parse('https://example.com/attachment.jpg')],
    ),
  );
}

void main() {
  group('DownloadableImageAttachmentCard', () {
    testWidgets('renders the standard image card when base64 exists', (
      tester,
    ) async {
      await tester.pumpWidget(
        _AttachmentCardHarness(
          initialAttachment: _base64Attachment(),
          onDownloadAttachment: (_) async {},
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(Image), findsOneWidget);
      expect(find.byIcon(Icons.download_rounded), findsNothing);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('shows icon, loading, error, retry, and rebuilt image', (
      tester,
    ) async {
      final l10n = await getL10n();
      final harnessKey = GlobalKey<_AttachmentCardHarnessState>();
      Completer<void>? firstAttemptCompleter;
      Completer<void>? secondAttemptCompleter;
      var attempt = 0;

      Future<void> onDownloadAttachment(Attachment attachment) async {
        attempt += 1;

        if (attempt == 1) {
          firstAttemptCompleter = Completer<void>();
          return firstAttemptCompleter!.future;
        }

        secondAttemptCompleter = Completer<void>();
        return secondAttemptCompleter!.future;
      }

      await tester.pumpWidget(
        _AttachmentCardHarness(
          key: harnessKey,
          initialAttachment: _linkAttachment(),
          onDownloadAttachment: onDownloadAttachment,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.download_rounded), findsOneWidget);
      expect(find.byType(Image), findsNothing);

      await tester.tap(find.byIcon(Icons.download_rounded));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text(l10n.error(AppExceptionType.other.name)), findsNothing);

      firstAttemptCompleter!.completeError(
        AppException('download failed', code: AppExceptionType.other.name),
      );
      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.download_rounded), findsNothing);
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(
        find.text(l10n.error(AppExceptionType.other.name)),
        findsOneWidget,
      );
      expect(find.text(l10n.generalRetry), findsOneWidget);

      await tester.tap(find.text(l10n.generalRetry));
      await tester.pump();

      expect(find.text(l10n.error(AppExceptionType.other.name)), findsNothing);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      harnessKey.currentState!.updateAttachment(_base64Attachment());
      secondAttemptCompleter!.complete();
      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.byType(Image), findsOneWidget);
      expect(find.byIcon(Icons.download_rounded), findsNothing);
      expect(find.text(l10n.error(AppExceptionType.other.name)), findsNothing);
    });
  });
}
