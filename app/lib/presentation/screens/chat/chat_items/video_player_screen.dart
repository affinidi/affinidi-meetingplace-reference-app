part of '../chat_screen.dart';

class _VideoPlayerScreen extends StatefulWidget {
  const _VideoPlayerScreen({required this.videoBytes, this.filename});

  final Uint8List videoBytes;
  final String? filename;

  @override
  State<_VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<_VideoPlayerScreen> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    try {
      final tempDir = await getTemporaryDirectory();
      final filename =
          widget.filename ?? 'video_${clock.now().millisecondsSinceEpoch}.mp4';
      final file = File('${tempDir.path}/$filename');
      await file.writeAsBytes(widget.videoBytes);

      final controller = VideoPlayerController.file(file);
      await controller.initialize();

      if (!mounted) {
        await controller.dispose();
        return;
      }

      setState(() {
        _controller = controller;
        _isInitialized = true;
      });
    } catch (e, stackTrace) {
      AppLogger.instance.error(
        'Failed to initialize video player',
        error: e,
        stackTrace: stackTrace,
        name: '_VideoPlayerScreen',
      );
      if (mounted) {
        setState(() => _hasError = true);
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: widget.filename != null
            ? Text(
                widget.filename!,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                overflow: TextOverflow.ellipsis,
              )
            : null,
      ),
      body: Center(child: _buildBody(context)),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_hasError) {
      return Text(
        context.l10n.videoLoadingError,
        style: const TextStyle(color: Colors.white70),
      );
    }

    if (!_isInitialized || _controller == null) {
      return const CircularProgressIndicator();
    }

    return GestureDetector(
      onTap: _togglePlayback,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AspectRatio(
            aspectRatio: _controller!.value.aspectRatio,
            child: VideoPlayer(_controller!),
          ),
          ValueListenableBuilder<VideoPlayerValue>(
            valueListenable: _controller!,
            builder: (context, value, child) {
              if (!value.isPlaying) {
                return const Icon(
                  Icons.play_circle_fill,
                  color: Colors.white70,
                  size: 72,
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }

  void _togglePlayback() {
    final controller = _controller;
    if (controller == null) return;

    setState(() {
      if (controller.value.isPlaying) {
        controller.pause();
      } else {
        if (controller.value.position >= controller.value.duration) {
          controller.seekTo(Duration.zero);
        }
        controller.play();
      }
    });
  }
}
