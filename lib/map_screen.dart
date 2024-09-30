import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:text_scroll/text_scroll.dart';
import 'package:ymyr/app_state.dart';
import 'package:ymyr/cateogry_menu.dart';
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
                  : AppState.of(context)!.dataNotifier.category ==
                          Category.artist
                      ? "ARTISTS IN"
                      : "STATIONS IN",
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
      body: const Stack(clipBehavior: Clip.none, children: [
        OSMFlutterMap(),
        Positioned(
          top: 20,
          right: 50,
          left: 50,
          child: CateogryMenu(),
        ),
        NavMenu(
          appview: AppView.map,
        ),
        SideBarNotch(),
      ]),
    );
  }
}
