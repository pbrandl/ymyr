import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:text_scroll/text_scroll.dart';
import 'package:ymyr/app_state.dart';
import 'package:ymyr/cateogry_menu.dart';
import 'package:ymyr/map.dart';
import 'package:ymyr/filter_menu.dart';
import 'package:ymyr/sidebar.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  @override
  void initState() {
    super.initState();
  }

  late LocationNotifier locationNotifier;
  late DataNotifier dataNotifier;
  late AudioNotifier audioNotifier;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    locationNotifier = AppState.of(context)!.locationNotifier;
    dataNotifier = AppState.of(context)!.dataNotifier;
    audioNotifier = AppState.of(context)!.audioNotifier;

    // Add listeners
    locationNotifier.addListener(_updateState);
    dataNotifier.addListener(_updateState);
    audioNotifier.addListener(_updateState);
  }

  void _updateState() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    locationNotifier.removeListener(_updateState);
    dataNotifier.removeListener(_updateState);
    audioNotifier.removeListener(_updateState);
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
              const Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ControlButtons(),
                ],
              ),
              Expanded(
                child: TextScroll(
                  audioNotifier.radioLocation == ''
                      ? audioNotifier.radioName
                      : '${audioNotifier.radioName} live from ${audioNotifier.radioLocation}',
                  velocity: const Velocity(
                    pixelsPerSecond: Offset(40, 0),
                  ),
                  intervalSpaces: 50,
                ),
              )
            ],
          )),
      appBar: AppBar(
        /* leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back)),*/
        title: const Center(
          child: Text(
            "YMYR",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
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

/// Displays the play/pause button and volume/speed sliders.
class ControlButtons extends StatefulWidget {
  const ControlButtons({super.key});

  @override
  State<ControlButtons> createState() => _ControlButtonsState();
}

class _ControlButtonsState extends State<ControlButtons> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    AppState.of(context)!.audioNotifier.addListener(_updateState);
  }

  void _updateState() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    AppState.of(context)!.audioNotifier.removeListener(_updateState);
    super.dispose();
  }

  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      // Release the player's resources when not in use. We use "stop" so that
      // if the app resumes later, it will still remember what position to
      // resume from.
      AppState.of(context)!.audioNotifier.player.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(width: 4),
        StreamBuilder<PlayerState>(
          stream: AppState.of(context)!.audioNotifier.player.playerStateStream,
          builder: (context, snapshot) {
            final playerState = snapshot.data;
            final playing = playerState?.playing;

            if (playing != true) {
              return SizedBox(
                width: 42,
                height: 42,
                child: IconButton(
                  icon: const Icon(Icons.play_arrow),
                  iconSize: 28.0,
                  onPressed: AppState.of(context)!.audioNotifier.player.play,
                ),
              );
            } else {
              return SizedBox(
                width: 42,
                height: 42,
                child: IconButton(
                  icon: const Icon(Icons.pause),
                  iconSize: 28.0,
                  onPressed: AppState.of(context)!.audioNotifier.player.pause,
                ),
              );
            }
          },
        ),
        SizedBox(
          width: 42,
          height: 42,
          child: IconButton(
            icon: const Icon(Icons.skip_next),
            iconSize: 28.0,
            onPressed: () {
              AppState.of(context)!.audioNotifier.player.pause;
              var radios = AppState.of(context)!.dataNotifier.radios;
              final random = Random();
              int randomIndex = random.nextInt(radios.length);
              var radio = radios[randomIndex];
              AppState.of(context)!.audioNotifier.setRadio(
                    radio['RadioName'],
                    radio['Stream'],
                    radio['Location'],
                  );
              AppState.of(context)!.audioNotifier.player.play;
            },
          ),
        ),
        const SizedBox(width: 8)
      ],
    );
  }
}
