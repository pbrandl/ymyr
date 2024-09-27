import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:text_scroll/text_scroll.dart';
import 'package:ymyr/app_state.dart';
import 'package:ymyr/main.dart';
import 'package:ymyr/map.dart';
import 'package:ymyr/nav_menu.dart';
import 'package:ymyr/picker.dart';
import 'package:ymyr/player.dart';
import 'package:ymyr/sidebar.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();

  void stopAudioPlayer() async {
    if (mounted) {
      await _audioPlayer.stop();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    AppState.of(context)!.dataNotifier.addListener(_updateState);
  }

  void _updateState() {
    setState(() {});
  }

  @override
  void dispose() {
    AppState.of(context)!.dataNotifier.removeListener(_updateState);

    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: Container(
          height: 50,
          color: Theme.of(context).canvasColor,
          child: Row(
            children: [
              AudioPlayerWidget(
                player: _audioPlayer,
              ),
              const Expanded(
                child: TextScroll(
                  "RADIO SHOW <NAME> If this text is to long to be shown in just one line, it moves from right to left.",
                  velocity: Velocity(
                    pixelsPerSecond: Offset(40, 0),
                  ),
                  intervalSpaces: 50,
                ),
              )
            ],
          )),
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              stopAudioPlayer();
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back)),
        title: Row(
          children: [
            Text(
              AppState.of(context)!.dataNotifier.category == Category.event
                  ? "EVENTS IN"
                  : "ARTISTS IN",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(
              width: 8,
            ),
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () async {
                await _audioPlayer.dispose();
                Navigator.pop(context);
              },
              child: Text(
                cityStringMap[AppState.of(context)!.city]!.toUpperCase(),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
      body: Stack(clipBehavior: Clip.none, children: [
        const OSMFlutterMap(),
        Positioned(
          top: 20,
          right: 50,
          left: 50,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Picker(
                defaultText: AppState.of(context)!.dataNotifier.genre == 'All'
                    ? 'Genre'
                    : AppState.of(context)!.dataNotifier.genre,
                items: ['All'] + genreStringMap.values.toList(),
                onChanged: (genre) =>
                    AppState.of(context)!.dataNotifier.genre = genre,
              ),
              const SizedBox(width: 24),
              Picker(
                defaultText: AppState.of(context)!.dataNotifier.type == 'All'
                    ? 'Type'
                    : AppState.of(context)!.dataNotifier.type,
                items: ['All'] + typeStringMap.values.toList(),
                onChanged: (type) =>
                    AppState.of(context)!.dataNotifier.type = type,
              ),
              const SizedBox(width: 24),
              const FintaActionChip(),
            ],
          ),
        ),
        const Positioned(
          bottom: 20,
          right: 0,
          left: 0,
          child: Center(
            child: SizedBox(
              width: 200,
              child: NavMenu(
                appview: AppView.map,
              ),
            ),
          ),
        ),
        const SideBarNotch(),
      ]),
    );
  }
}
