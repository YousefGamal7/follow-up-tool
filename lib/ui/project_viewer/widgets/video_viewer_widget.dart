import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoViewerWidget extends StatefulWidget {
  final File videoFile;

  const VideoViewerWidget({super.key, required this.videoFile});

  @override
  State<VideoViewerWidget> createState() => _VideoViewerWidgetState();
}

class _VideoViewerWidgetState extends State<VideoViewerWidget> {
  late VideoPlayerController _controller;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _initVideo();
  }

  Future<void> _initVideo() async {
    _controller = VideoPlayerController.file(widget.videoFile);
    try {
      await _controller.initialize();
      setState(() {});
      _controller.play();
    } catch (e) {
      setState(() {
        _hasError = true;
      });
    }
  }

  @override
  void didUpdateWidget(covariant VideoViewerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.videoFile.path != widget.videoFile.path) {
      _controller.dispose();
      _hasError = false;
      _initVideo();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Colors.red, size: 64),
            SizedBox(height: 16),
            Text('Failed to load or play video.'),
          ],
        ),
      );
    }

    if (!_controller.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        Expanded(
          child: Center(
            child: AspectRatio(
              aspectRatio: _controller.value.aspectRatio,
              child: VideoPlayer(_controller),
            ),
          ),
        ),
        VideoProgressIndicator(
          _controller,
          allowScrubbing: true,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: Icon(_controller.value.isPlaying ? Icons.pause : Icons.play_arrow),
              onPressed: () {
                setState(() {
                  _controller.value.isPlaying ? _controller.pause() : _controller.play();
                });
              },
            ),
          ],
        ),
      ],
    );
  }
}
