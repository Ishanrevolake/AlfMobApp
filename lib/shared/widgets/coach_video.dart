import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class CoachVideo extends StatefulWidget {
  final String url;
  const CoachVideo({super.key, required this.url});
  @override
  State<CoachVideo> createState() => _CoachVideoState();
}

class _CoachVideoState extends State<CoachVideo> {
  VideoPlayerController? player;
  String? error;
  @override
  void initState() {
    super.initState();
    final uri = Uri.tryParse(widget.url);
    if (uri == null || uri.scheme != 'https') {
      error = 'Video requires a secure HTTPS link.';
      return;
    }
    player = VideoPlayerController.networkUrl(uri);
    player!
        .initialize()
        .then((_) {
          if (mounted) setState(() {});
        })
        .catchError((Object e) {
          if (mounted) setState(() => error = 'Unable to play this video.');
        });
  }

  @override
  void dispose() {
    player?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (error != null) return Text(error!);
    if (player?.value.isInitialized != true) {
      return const Center(child: CircularProgressIndicator());
    }
    return Column(
      children: [
        AspectRatio(
          aspectRatio: player!.value.aspectRatio,
          child: VideoPlayer(player!),
        ),
        VideoProgressIndicator(player!, allowScrubbing: true),
        IconButton(
          tooltip: 'Play or pause video',
          onPressed: () {
            setState(() {
              player!.value.isPlaying ? player!.pause() : player!.play();
            });
          },
          icon: Icon(player!.value.isPlaying ? Icons.pause : Icons.play_arrow),
        ),
      ],
    );
  }
}
