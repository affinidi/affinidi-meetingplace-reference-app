import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:meeting_place_core/meeting_place_core.dart';
import 'package:mpx_flutter_reference_app/infrastructure/plugins/audio_attachments_plugin/downloadable_audio_attachment_card.dart';
import 'package:mpx_flutter_reference_app/l10n/app_localizations.dart';
import 'package:path/path.dart' as p;

import 'utils/app.dart';

class _AttachmentCardHarness extends StatefulWidget {
  const _AttachmentCardHarness({
    super.key,
    required this.initialAttachment,
    required this.onDownloadAttachment,
    required this.fakePlayer,
    required this.materializeAudioAttachmentFile,
  });

  final Attachment initialAttachment;
  final Future<void> Function(Attachment attachment) onDownloadAttachment;
  final _FakeAudioAttachmentPlayer fakePlayer;
  final MaterializeAudioAttachmentFile materializeAudioAttachmentFile;

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
            child: DownloadableAudioAttachmentCard(
              attachment: _attachment,
              onDownloadAttachment: widget.onDownloadAttachment,
              createPlayer: () => widget.fakePlayer,
              materializeAudioAttachmentFile:
                  widget.materializeAudioAttachmentFile,
            ),
          ),
        ),
      ),
    );
  }
}

class _FakeAudioAttachmentPlayer extends AudioAttachmentPlayer {
  bool _isReady = false;
  bool _isPlaying = false;
  Duration _currentPosition = Duration.zero;
  final Duration _totalDuration = const Duration(seconds: 8);
  int playCalls = 0;
  int prepareCalls = 0;

  @override
  bool get isPlaying => _isPlaying;

  @override
  bool get isReady => _isReady;

  @override
  Duration get currentPosition => _currentPosition;

  @override
  Duration get totalDuration => _totalDuration;

  @override
  Widget buildWaveform({required BuildContext context, required Size size}) {
    return SizedBox(
      key: const Key('chat_audio_waveform'),
      height: size.height,
      width: size.width,
    );
  }

  @override
  Future<void> pause() async {
    _isPlaying = false;
    notifyListeners();
  }

  @override
  Future<void> play() async {
    if (!_isReady) return;
    playCalls += 1;
    _isPlaying = true;
    _currentPosition = const Duration(seconds: 1);
    notifyListeners();
  }

  @override
  Future<void> prepare(String path) async {
    prepareCalls += 1;
    _isReady = true;
    _isPlaying = false;
    _currentPosition = Duration.zero;
    notifyListeners();
  }

  @override
  Future<void> stop() async {
    _isPlaying = false;
    _currentPosition = Duration.zero;
    notifyListeners();
  }

  void completePlayback() {
    _isPlaying = false;
    _currentPosition = Duration.zero;
    notifyListeners();
  }
}

Attachment _linkAttachment() {
  return Attachment(
    id: 'attachment-audio-1',
    format: 'mpx_audio_attachment_plugin',
    mediaType: 'audio/mp4',
    data: AttachmentData(
      links: [Uri.parse('https://example.com/attachment.m4a')],
    ),
  );
}

Attachment _base64Attachment() {
  return Attachment(
    id: 'attachment-audio-1',
    format: 'mpx_audio_attachment_plugin',
    mediaType: 'audio/mp4',
    data: AttachmentData(
      base64: base64Encode(const [1, 2, 3, 4, 5]),
      links: [Uri.parse('https://example.com/attachment.m4a')],
    ),
  );
}

Future<File> _fakeMaterializeAudioAttachmentFile(Attachment attachment) async {
  final tempDirectory = Directory.systemTemp.createTempSync(
    'downloadable_audio_attachment_card_test_',
  );
  final file = File(p.join(tempDirectory.path, 'audio.m4a'));
  file.writeAsBytesSync(const [1, 2, 3, 4, 5], flush: true);
  return file;
}

void main() {
  group('DownloadableAudioAttachmentCard', () {
    testWidgets('renders playable UI when base64 exists', (tester) async {
      final fakePlayer = _FakeAudioAttachmentPlayer();

      await tester.pumpWidget(
        _AttachmentCardHarness(
          initialAttachment: _base64Attachment(),
          onDownloadAttachment: (_) async {},
          fakePlayer: fakePlayer,
          materializeAudioAttachmentFile: _fakeMaterializeAudioAttachmentFile,
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.byKey(const Key('chat_audio_waveform')), findsOneWidget);
      expect(find.byKey(const Key('chat_audio_play_button')), findsOneWidget);
      expect(find.text('00:08'), findsOneWidget);
      expect(find.text('00:00 / 00:08'), findsNothing);
      expect(fakePlayer.prepareCalls, 1);

      await tester.tap(find.byKey(const Key('chat_audio_play_button')));
      await tester.pump();

      expect(fakePlayer.playCalls, 1);
      expect(find.text('00:01 / 00:08'), findsOneWidget);
      expect(find.byIcon(Icons.pause), findsOneWidget);

      fakePlayer.completePlayback();
      await tester.pump();

      expect(find.byIcon(Icons.play_arrow), findsOneWidget);
      expect(find.text('00:08'), findsOneWidget);

      await tester.tap(find.byKey(const Key('chat_audio_play_button')));
      await tester.pump();

      expect(fakePlayer.playCalls, 2);
      expect(find.text('00:01 / 00:08'), findsOneWidget);
    });

    testWidgets('shows download, error, retry, and then playback', (
      tester,
    ) async {
      final l10n = await getL10n();
      final harnessKey = GlobalKey<_AttachmentCardHarnessState>();
      final fakePlayer = _FakeAudioAttachmentPlayer();
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
          fakePlayer: fakePlayer,
          materializeAudioAttachmentFile: _fakeMaterializeAudioAttachmentFile,
        ),
      );
      await tester.pump();

      expect(
        find.byKey(const Key('chat_audio_download_button')),
        findsOneWidget,
      );
      expect(find.byKey(const Key('chat_audio_waveform')), findsNothing);

      await tester.tap(find.byKey(const Key('chat_audio_download_button')));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text(l10n.unableToDownload), findsNothing);

      firstAttemptCompleter!.completeError(Exception('download failed'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.text(l10n.unableToDownload), findsOneWidget);
      expect(find.text(l10n.generalRetry), findsOneWidget);
      final errorText = tester.widget<Text>(find.text(l10n.unableToDownload));
      final errorTextContext = tester.element(find.text(l10n.unableToDownload));
      expect(
        errorText.style?.color,
        Theme.of(errorTextContext).colorScheme.error,
      );

      await tester.tap(find.text(l10n.generalRetry));
      await tester.pump();

      expect(find.text(l10n.unableToDownload), findsNothing);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      harnessKey.currentState!.updateAttachment(_base64Attachment());
      secondAttemptCompleter!.complete();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.byKey(const Key('chat_audio_waveform')), findsOneWidget);
      expect(find.byKey(const Key('chat_audio_play_button')), findsOneWidget);
      expect(find.text('00:08'), findsOneWidget);
      expect(fakePlayer.prepareCalls, 1);

      await tester.tap(find.byKey(const Key('chat_audio_play_button')));
      await tester.pump();

      expect(fakePlayer.playCalls, 1);
      expect(find.text('00:01 / 00:08'), findsOneWidget);
      expect(find.text(l10n.unableToDownload), findsNothing);
    });
  });
}
