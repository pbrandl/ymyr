import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

class AudioPlayerWidget extends StatefulWidget {
  final String url = "https://azuracast.gatekeeperradio.com:8000/radio.mp3";

  final AudioPlayer player;

  const AudioPlayerWidget({super.key, required this.player});

  @override
  AudioPlayerWidgetState createState() => AudioPlayerWidgetState();
}

class AudioPlayerWidgetState extends State<AudioPlayerWidget> {
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() async {
    super.dispose();
  }

  void _playPause() async {
    if (_isPlaying) {
      await widget.player.pause();
    } else {
      await widget.player.play(UrlSource(widget.url));
    }
    setState(() {
      _isPlaying = !_isPlaying;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: IconButton(
        icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
        onPressed: mounted ? _playPause : () => {},
        iconSize: 35.0,
      ),
    );
  }
}
