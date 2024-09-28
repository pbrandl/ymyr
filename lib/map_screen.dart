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
          child: CateogryActionChips(),
        ),
        Positioned(
          bottom: 20,
          right: 0,
          left: 0,
          child: Center(
            child: NavMenu(
              appview: AppView.map,
            ),
          ),
        ),
        SideBarNotch(),
      ]),
    );
  }
}

class CateogryActionChips extends StatefulWidget {
  const CateogryActionChips({super.key});

  @override
  State<CateogryActionChips> createState() => _CateogryActionChipsState();
}

class _CateogryActionChipsState extends State<CateogryActionChips> {
  bool toggle = false;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ActionChip(
          clipBehavior: Clip.antiAlias,
          labelPadding: EdgeInsets.zero,
          padding: EdgeInsets.zero,
          onPressed: () {
            AppState.of(context)!.dataNotifier.category = Category.artist;
          },
          label: Container(
            width: 76,
            height: 36,
            decoration: BoxDecoration(
              color:
                  AppState.of(context)!.dataNotifier.category != Category.artist
                      ? Colors.transparent
                      : Theme.of(context).primaryColor,
            ),
            child: Center(
              child: Text(
                'Artist',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14,
                  color: !toggle ? Colors.black : Colors.white,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        ActionChip(
          clipBehavior: Clip.antiAlias,
          labelPadding: EdgeInsets.zero,
          padding: EdgeInsets.zero,
          onPressed: () {
            AppState.of(context)!.dataNotifier.category = Category.event;
          },
          label: Container(
            width: 76,
            height: 36,
            decoration: BoxDecoration(
              color:
                  AppState.of(context)!.dataNotifier.category != Category.event
                      ? Colors.transparent
                      : Theme.of(context).primaryColor,
            ),
            child: Center(
              child: Text(
                'Events',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14,
                  color: !toggle ? Colors.black : Colors.white,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        ActionChip(
          clipBehavior: Clip.antiAlias,
          labelPadding: EdgeInsets.zero,
          padding: EdgeInsets.zero,
          onPressed: () {
            AppState.of(context)!.dataNotifier.category = Category.station;
          },
          label: Container(
            width: 76,
            height: 36,
            decoration: BoxDecoration(
              color: AppState.of(context)!.dataNotifier.category !=
                      Category.station
                  ? Colors.transparent
                  : Theme.of(context).primaryColor,
            ),
            child: Center(
              child: Text(
                'Stations',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14,
                  color: !toggle ? Colors.black : Colors.white,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
