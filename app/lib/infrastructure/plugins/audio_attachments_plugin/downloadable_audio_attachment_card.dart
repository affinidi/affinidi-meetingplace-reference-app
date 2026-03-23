import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mpx_app_core/mpx_app_core.dart';
import 'package:path/path.dart' as p;

import '../../../presentation/widgets/async_loaders/async_loading_controller.dart';
import '../../extensions/build_context_extensions.dart';

typedef CreateAudioAttachmentPlayer = AudioAttachmentPlayer Function();
typedef MaterializeAudioAttachmentFile =
    Future<File> Function(Attachment attachment);

class DownloadableAudioAttachmentCard extends HookConsumerWidget {
  const DownloadableAudioAttachmentCard({
    super.key,
    required Attachment attachment,
    Future<void> Function(Attachment attachment)? onDownloadAttachment,
    CreateAudioAttachmentPlayer createPlayer = createAudioAttachmentPlayer,
    MaterializeAudioAttachmentFile materializeAudioAttachmentFile =
        materializeAudioAttachmentFile,
  }) : _attachment = attachment,
       _onDownloadAttachment = onDownloadAttachment,
       _createPlayer = createPlayer,
       _materializeAudioAttachmentFile = materializeAudioAttachmentFile;

  final Attachment _attachment;
  final Future<void> Function(Attachment attachment)? _onDownloadAttachment;
  final CreateAudioAttachmentPlayer _createPlayer;
  final MaterializeAudioAttachmentFile _materializeAudioAttachmentFile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final downloadControllerProvider = useMemoized(
      () => AsyncLoadingController.provider(
        'download_audio_attachment_${_attachment.id ?? _attachment.hashCode}',
      ),
      [_attachment.id, _attachment.hashCode],
    );
    final player = useMemoized(_createPlayer, const []);
    useListenable(player);

    final audioDataBase64 = _attachment.data?.base64;
    final preparedFile = useState<File?>(null);
    final isPreparingPlayer = useState(false);
    final prepareError = useState<Object?>(null);
    final prepareAttempt = useState(0);

    useEffect(() {
      return () {
        final file = preparedFile.value;
        Future.microtask(() async {
          try {
            await player.stop();
          } catch (_) {
            // ignore
          }
          player.dispose();
          if (file != null) {
            await deletePreparedAudioFile(file);
          }
        });
      };
    }, const []);

    useEffect(
      () {
        final previousFile = preparedFile.value;
        preparedFile.value = null;

        if (audioDataBase64 == null) {
          prepareError.value = null;
          isPreparingPlayer.value = false;
          Future.microtask(() async {
            try {
              await player.stop();
            } catch (_) {
              // ignore
            }
            if (previousFile != null) {
              await deletePreparedAudioFile(previousFile);
            }
          });
          return null;
        }

        var cancelled = false;
        File? nextFile;

        isPreparingPlayer.value = true;
        prepareError.value = null;

        Future<void> prepare() async {
          try {
            try {
              await player.stop();
            } catch (_) {
              // ignore
            }

            if (previousFile != null) {
              await deletePreparedAudioFile(previousFile);
            }

            nextFile = await _materializeAudioAttachmentFile(_attachment);
            if (cancelled || nextFile == null) {
              if (nextFile != null) {
                await deletePreparedAudioFile(nextFile!);
              }
              return;
            }

            await player.prepare(nextFile!.path);
            if (cancelled) {
              await player.stop();
              await deletePreparedAudioFile(nextFile!);
              return;
            }

            preparedFile.value = nextFile;
          } catch (error) {
            if (nextFile != null) {
              await deletePreparedAudioFile(nextFile!);
            }
            if (!cancelled) {
              prepareError.value = error;
            }
          } finally {
            if (!cancelled) {
              isPreparingPlayer.value = false;
            }
          }
        }

        unawaited(prepare());

        return () {
          cancelled = true;
        };
      },
      [
        _attachment.id,
        _attachment.mediaType,
        audioDataBase64,
        prepareAttempt.value,
      ],
    );

    final hasDownloadLink = _attachment.data?.links?.isNotEmpty == true;
    if (audioDataBase64 == null) {
      if (!hasDownloadLink) return const SizedBox.shrink();

      Future<void> onDownloadPressed() async {
        final onDownloadAttachment = _onDownloadAttachment;
        if (onDownloadAttachment == null) {
          return;
        }

        await ref
            .read(downloadControllerProvider.notifier)
            .start(() => onDownloadAttachment(_attachment));
      }

      return _AudioAttachmentShell(
        child: _AudioAttachmentDownloadOverlay(
          errorMessage: context.l10n.unableToDownload,
          loadingControllerProvider: downloadControllerProvider,
          onDownloadPressed: _onDownloadAttachment == null
              ? null
              : onDownloadPressed,
        ),
      );
    }

    if (isPreparingPlayer.value) {
      return const _AudioAttachmentShell(
        child: Center(child: CircularProgressIndicator.adaptive()),
      );
    }

    if (prepareError.value != null) {
      return _AudioAttachmentShell(
        child: Center(
          child: IconButton.filledTonal(
            key: const Key('chat_audio_retry_button'),
            padding: EdgeInsets.zero,
            iconSize: 18,
            constraints: const BoxConstraints.tightFor(width: 28, height: 28),
            visualDensity: VisualDensity.compact,
            onPressed: () {
              prepareAttempt.value += 1;
            },
            icon: const Icon(Icons.refresh_rounded),
          ),
        ),
      );
    }

    final currentDuration = player.currentPosition;
    final totalDuration = player.totalDuration == Duration.zero
        ? currentDuration
        : player.totalDuration;
    final durationLabel = currentDuration == Duration.zero && !player.isPlaying
        ? formatDuration(totalDuration)
        : '${formatDuration(currentDuration)} / ${formatDuration(totalDuration)}';

    return _AudioAttachmentShell(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Stack(
                    children: [
                      Positioned.fill(
                        child: Align(
                          alignment: Alignment.center,
                          child: player.buildWaveform(
                            context: context,
                            size: Size(constraints.maxWidth, 20),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 0,
                        bottom: 0,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: context.colorScheme.surface.withValues(
                              alpha: 0.62,
                            ),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 5,
                              vertical: 1,
                            ),
                            child: Text(
                              durationLabel,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: context.textTheme.labelSmall?.copyWith(
                                fontSize: 9,
                                height: 1,
                                color: context.colorScheme.onSurface.withValues(
                                  alpha: 0.82,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(width: 8),
            _AudioAttachmentTrailingControl(
              child: IconButton.filled(
                key: const Key('chat_audio_play_button'),
                padding: EdgeInsets.zero,
                iconSize: 18,
                visualDensity: VisualDensity.compact,
                style: IconButton.styleFrom(
                  minimumSize: const Size.square(28),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                onPressed: player.isReady
                    ? () async {
                        if (player.isPlaying) {
                          await player.pause();
                          return;
                        }

                        await player.play();
                      }
                    : null,
                icon: Icon(player.isPlaying ? Icons.pause : Icons.play_arrow),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

abstract class AudioAttachmentPlayer extends ChangeNotifier {
  bool get isReady;
  bool get isPlaying;
  Duration get currentPosition;
  Duration get totalDuration;

  Future<void> prepare(String path);
  Future<void> play();
  Future<void> pause();
  Future<void> stop();
  Widget buildWaveform({required BuildContext context, required Size size});
}

AudioAttachmentPlayer createAudioAttachmentPlayer() {
  return _AudioWaveformsAttachmentPlayer();
}

Future<File> materializeAudioAttachmentFile(Attachment attachment) async {
  final base64 = attachment.data?.base64;
  if (base64 == null) {
    throw StateError('Attachment does not contain base64 audio data.');
  }

  final tempDirectory = await Directory.systemTemp.createTemp(
    'mpx_audio_attachment_',
  );
  final file = File(
    p.join(
      tempDirectory.path,
      'audio${attachmentFileExtension(attachment.mediaType ?? '')}',
    ),
  );
  await file.writeAsBytes(base64Decode(base64), flush: true);
  return file;
}

Future<void> deletePreparedAudioFile(File file) async {
  try {
    if (await file.exists()) {
      await file.delete();
    }
  } catch (_) {
    // ignore
  }

  try {
    final parentDirectory = file.parent;
    if (await parentDirectory.exists()) {
      await parentDirectory.delete(recursive: true);
    }
  } catch (_) {
    // ignore
  }
}

String attachmentFileExtension(String mediaType) {
  final normalizedMediaType = mediaType.toLowerCase();
  if (normalizedMediaType.contains('mpeg') ||
      normalizedMediaType.endsWith('/mp3')) {
    return '.mp3';
  }
  if (normalizedMediaType.contains('wav')) {
    return '.wav';
  }
  if (normalizedMediaType.contains('ogg')) {
    return '.ogg';
  }
  if (normalizedMediaType.contains('aac') ||
      normalizedMediaType.contains('mp4')) {
    return '.m4a';
  }
  return '.m4a';
}

String formatDuration(Duration value) {
  final totalSeconds = value.inSeconds;
  final minutes = (totalSeconds ~/ 60).toString().padLeft(2, '0');
  final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
  return '$minutes:$seconds';
}

class _AudioWaveformsAttachmentPlayer extends AudioAttachmentPlayer {
  _AudioWaveformsAttachmentPlayer() {
    _playerController.updateFrequency = UpdateFrequency.high;
    _playerController.overrideAudioSession = true;
    _playerStateSubscription = _playerController.onPlayerStateChanged.listen((
      playerState,
    ) {
      _playerState = playerState;
      notifyListeners();
    });
    _currentDurationSubscription = _playerController.onCurrentDurationChanged
        .listen((durationMs) {
          _currentPosition = Duration(milliseconds: durationMs);
          notifyListeners();
        });
    _completionSubscription = _playerController.onCompletion.listen((_) {
      _hasCompletedPlayback = true;
      _playerState = PlayerState.stopped;
      _currentPosition = Duration.zero;
      notifyListeners();
    });
  }

  final PlayerController _playerController = PlayerController();
  late final StreamSubscription<PlayerState> _playerStateSubscription;
  late final StreamSubscription<int> _currentDurationSubscription;
  late final StreamSubscription<void> _completionSubscription;

  static const _waveformSampleCount = 96;

  PlayerState _playerState = PlayerState.stopped;
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;
  bool _isReady = false;
  bool _hasCompletedPlayback = false;
  int _prepareRequestId = 0;
  List<double> _waveformData = const [];
  String? _preparedPath;

  @override
  bool get isPlaying => _playerState.isPlaying;

  @override
  bool get isReady => _isReady;

  @override
  Duration get currentPosition => _currentPosition;

  @override
  Duration get totalDuration => _totalDuration;

  @override
  Widget buildWaveform({required BuildContext context, required Size size}) {
    if (_waveformData.isEmpty) {
      return _AudioWaveformPlaceholder(size: size);
    }

    return AudioFileWaveforms(
      key: ValueKey('${_playerController.playerKey}_${_waveformData.length}'),
      size: size,
      playerController: _playerController,
      waveformData: _waveformData,
      continuousWaveform: false,
      enableSeekGesture: true,
      waveformType: WaveformType.fitWidth,
      playerWaveStyle: PlayerWaveStyle(
        fixedWaveColor: context.colorScheme.onSurface.withValues(alpha: 0.32),
        liveWaveColor: context.colorScheme.primary,
        seekLineColor: context.colorScheme.primary,
        seekLineThickness: 2,
        backgroundColor: Colors.transparent,
        waveThickness: 2,
        spacing: 4,
        showSeekLine: true,
        showTop: true,
        showBottom: true,
      ),
    );
  }

  @override
  Future<void> pause() async {
    if (!_playerState.isPlaying) return;
    await _playerController.pausePlayer();
  }

  @override
  Future<void> play() async {
    if (!_isReady) return;

    if (_playerState.isStopped) {
      final preparedPath = _preparedPath;
      if (preparedPath == null) return;

      await _repreparePreparedFile(preparedPath);
    } else if (_hasCompletedPlayback) {
      await _playerController.seekTo(0);
      _hasCompletedPlayback = false;
    }

    await _playerController.startPlayer(forceRefresh: true);
  }

  @override
  Future<void> prepare(String path) async {
    final requestId = ++_prepareRequestId;

    if (_isReady) {
      try {
        await _playerController.stopPlayer();
        await _playerController.release();
      } catch (_) {
        // ignore
      }
    }

    _currentPosition = Duration.zero;
    _totalDuration = Duration.zero;
    _playerState = PlayerState.stopped;
    _isReady = false;
    _hasCompletedPlayback = false;
    _waveformData = const [];
    _preparedPath = path;
    notifyListeners();

    await _prepareUnderlyingPlayer(path);

    if (requestId != _prepareRequestId) {
      return;
    }

    _totalDuration = Duration(
      milliseconds: _playerController.maxDuration < 0
          ? 0
          : _playerController.maxDuration,
    );
    _playerState = _playerController.playerState;
    _isReady = true;
    notifyListeners();

    try {
      final waveformData = await _playerController.waveformExtraction
          .extractWaveformData(path: path, noOfSamples: _waveformSampleCount);

      if (requestId != _prepareRequestId) {
        return;
      }

      _waveformData = waveformData;
      notifyListeners();
    } catch (_) {
      if (requestId != _prepareRequestId) {
        return;
      }

      notifyListeners();
    }
  }

  @override
  Future<void> stop() async {
    try {
      await _playerController.stopPlayer();
    } catch (_) {
      // ignore
    }
    _currentPosition = Duration.zero;
    _playerState = PlayerState.stopped;
    _hasCompletedPlayback = false;
    notifyListeners();
  }

  Future<void> _prepareUnderlyingPlayer(String path) async {
    await _playerController.preparePlayer(
      path: path,
      volume: 1.0,
      shouldExtractWaveform: false,
    );
    await _playerController.setFinishMode(finishMode: FinishMode.stop);
    await _playerController.setVolume(1.0);
  }

  Future<void> _repreparePreparedFile(String path) async {
    try {
      await _playerController.release();
    } catch (_) {
      // ignore
    }

    await _prepareUnderlyingPlayer(path);
    _currentPosition = Duration.zero;
    _playerState = _playerController.playerState;
    _hasCompletedPlayback = false;
    notifyListeners();
  }

  @override
  void dispose() {
    unawaited(_playerStateSubscription.cancel());
    unawaited(_currentDurationSubscription.cancel());
    unawaited(_completionSubscription.cancel());
    _playerController.dispose();
    super.dispose();
  }
}

class _AudioWaveformPlaceholder extends StatelessWidget {
  const _AudioWaveformPlaceholder({required this.size});

  final Size size;

  @override
  Widget build(BuildContext context) {
    final placeholderColor = context.colorScheme.onSurface.withValues(
      alpha: 0.18,
    );
    final maxBarHeight = size.height;
    final minBarHeight = maxBarHeight * 0.35;

    return SizedBox(
      key: const Key('chat_audio_waveform'),
      height: size.height,
      width: size.width,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: List.generate(20, (index) {
          final step = (index % 5) / 4;
          final height = minBarHeight + ((maxBarHeight - minBarHeight) * step);
          return Expanded(
            child: Align(
              alignment: Alignment.center,
              child: Container(
                height: height,
                margin: const EdgeInsets.symmetric(horizontal: 1.5),
                decoration: BoxDecoration(
                  color: placeholderColor,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _AudioAttachmentDownloadOverlay extends ConsumerWidget {
  const _AudioAttachmentDownloadOverlay({
    required this.errorMessage,
    required this.loadingControllerProvider,
    required this.onDownloadPressed,
  });

  final String errorMessage;
  final AutoDisposeNotifierProvider<AsyncLoadingController, AsyncValue<void>>
  loadingControllerProvider;
  final Future<void> Function()? onDownloadPressed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(loadingControllerProvider);

    void onRetryPressed() {
      final onDownloadPressed = this.onDownloadPressed;
      if (onDownloadPressed == null) {
        return;
      }

      unawaited(onDownloadPressed());
    }

    if (state.isLoading) {
      return const Center(
        child: SizedBox.square(
          dimension: 16,
          child: CircularProgressIndicator.adaptive(strokeWidth: 2),
        ),
      );
    }

    if (state.hasError) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          children: [
            Expanded(
              child: Text(
                errorMessage,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.textTheme.labelSmall?.copyWith(
                  height: 1,
                  color: context.colorScheme.error,
                ),
              ),
            ),
            const SizedBox(width: 6),
            TextButton(
              onPressed: onDownloadPressed == null ? null : onRetryPressed,
              style: TextButton.styleFrom(
                minimumSize: const Size(0, 24),
                padding: const EdgeInsets.symmetric(horizontal: 6),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
              ),
              child: Text(
                context.l10n.generalRetry,
                style: context.textTheme.labelSmall?.copyWith(height: 1),
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          const Expanded(child: SizedBox()),
          const SizedBox(width: 8),
          _AudioAttachmentTrailingControl(
            child: IconButton.filled(
              key: const Key('chat_audio_download_button'),
              onPressed: onDownloadPressed,
              padding: EdgeInsets.zero,
              iconSize: 18,
              constraints: const BoxConstraints.tightFor(width: 28, height: 28),
              visualDensity: VisualDensity.compact,
              icon: const Icon(Icons.download_rounded),
            ),
          ),
        ],
      ),
    );
  }
}

class _AudioAttachmentTrailingControl extends StatelessWidget {
  const _AudioAttachmentTrailingControl({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(dimension: 28, child: child);
  }
}

class _AudioAttachmentShell extends StatelessWidget {
  const _AudioAttachmentShell({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      width: 260,
      child: Card(
        color: const Color.fromARGB(0, 10, 10, 10),
        clipBehavior: Clip.hardEdge,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        elevation: 5,
        child: Stack(
          fit: StackFit.expand,
          children: [const _AudioAttachmentPlaceholder(), child],
        ),
      ),
    );
  }
}

class _AudioAttachmentPlaceholder extends StatelessWidget {
  const _AudioAttachmentPlaceholder();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xFF2B3547),
      child: ImageFiltered(
        imageFilter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Stack(
          fit: StackFit.expand,
          children: [
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF8395A7), Color(0xFF1D2735)],
                ),
              ),
            ),
            Align(
              alignment: const Alignment(-0.75, -0.75),
              child: Container(
                width: 90,
                height: 90,
                decoration: const BoxDecoration(
                  color: Color(0x35FFFFFF),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Align(
              alignment: const Alignment(0.85, 0.55),
              child: Container(
                width: 72,
                height: 72,
                decoration: const BoxDecoration(
                  color: Color(0x25000000),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            const Center(
              child: Icon(
                Icons.graphic_eq_rounded,
                size: 88,
                color: Color(0x32FFFFFF),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
