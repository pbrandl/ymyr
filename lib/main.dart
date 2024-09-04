import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'package:text_scroll/text_scroll.dart';
import 'package:ymyr/nav_menu.dart';
import 'package:ymyr/picker.dart';
import 'package:ymyr/app_state.dart';
import 'package:ymyr/location_selection.dart';
import 'package:ymyr/map.dart';
import 'package:ymyr/player.dart';
import 'package:ymyr/sidebar.dart';
import 'package:ymyr/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Parse SDK
  const keyApplicationId = 'yUVvb4hLLk2P2RlCdblresCpTPgV69ZxCtMcXb1u';
  const keyClientKey = 'lpblFYsSydJ0qYIRC2fqI7vdoplKmHU79mrsw7so';
  const keyParseServerUrl = 'https://parseapi.back4app.com/';

  await Parse().initialize(
    keyApplicationId,
    keyParseServerUrl,
    clientKey: keyClientKey,
    autoSendSessionId: true,
  );

  runApp(const Home());
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late LocationNotifier _locationNotifier;
  late DataNotifier _dataNotifier;
  late MenuNotifier _menuNotifier;

  @override
  void initState() {
    super.initState();
    _locationNotifier = LocationNotifier();
    _locationNotifier.addListener(_update);
    _dataNotifier = DataNotifier();
    _dataNotifier.addListener(_update);
    _menuNotifier = MenuNotifier();
    _menuNotifier.addListener(_update);
  }

  @override
  void dispose() {
    _locationNotifier.removeListener(_update);
    _locationNotifier.dispose();
    _dataNotifier.removeListener(_update);
    _dataNotifier.dispose();
    _menuNotifier.removeListener(_update);
    _menuNotifier.dispose();
    super.dispose();
  }

  void _update() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return AppState(
      locationNotifier: _locationNotifier,
      dataNotifier: _dataNotifier,
      menuNotifier: _menuNotifier,
      child: MaterialApp(
        theme: CustomTheme.generateTheme(Color.fromARGB(255, 119, 106, 194)),
        title: 'YMYR',
        home: Scaffold(
          body: _dataNotifier.artists.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "YMYR",
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 16),
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text(
                        "Version 0.1",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                )
              : const LocationSelection(),
        ),
      ),
    );
  }
}

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
    final state = AppState.of(context)!;
    final DataNotifier dataNotifier = state.dataNotifier;

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
                cityStringMap[state.city]!.toUpperCase(),
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
                defaultText: 'Genre',
                items: ['All'] + genreStringMap.values.toList(),
                onChanged: (genre) => dataNotifier.genre = genre,
              ),
              const SizedBox(width: 24),
              Picker(
                defaultText: 'Type',
                items: ['All'] + typeStringMap.values.toList(),
                onChanged: (type) => dataNotifier.type = type,
              ),
              const SizedBox(width: 24),
              const FintaActionChip(),
            ],
          ),
        ),
        const Positioned(
          bottom: 20,
          left: 0,
          right: 0,
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

class FintaActionChip extends StatefulWidget {
  const FintaActionChip({super.key});

  @override
  State<FintaActionChip> createState() => _FintaActionChipState();
}

class _FintaActionChipState extends State<FintaActionChip> {
  bool toggle = false;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      clipBehavior: Clip.antiAlias,
      labelPadding: EdgeInsets.zero,
      padding: EdgeInsets.zero,
      onPressed: () {
        setState(() {
          toggle = !toggle;
        });
        AppState.of(context)!.dataNotifier.finta = toggle;
      },
      label: Container(
        width: 76,
        height: 36,
        decoration: BoxDecoration(
          gradient: !toggle
              ? null
              : const LinearGradient(
                  colors: [
                    Colors.red,
                    Colors.orange,
                    Colors.yellow,
                    Colors.green,
                    Colors.blue,
                    Colors.purple,
                  ],
                  stops: [
                    0.16, // End of the first color and start of the second
                    0.33, // End of the second color and start of the third
                    0.5, // End of the third color and start of the fourth
                    0.66, // End of the fourth color and start of the fifth
                    0.83, // End of the fifth color and start of the sixth
                    1.0, // End of the sixth color
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
        ),
        child: const Center(
          child: Text(
            'Finta',
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 14, color: Colors.black),
          ),
        ),
      ),
    );
  }
}

class MarqueeWidget extends StatefulWidget {
  final Widget child;
  final Axis direction;
  final Duration animationDuration, backDuration, pauseDuration;

  const MarqueeWidget({
    super.key,
    required this.child,
    this.direction = Axis.horizontal,
    this.animationDuration = const Duration(milliseconds: 6000),
    this.backDuration = const Duration(milliseconds: 800),
    this.pauseDuration = const Duration(milliseconds: 800),
  });

  @override
  MarqueeWidgetState createState() => MarqueeWidgetState();
}

class MarqueeWidgetState extends State<MarqueeWidget> {
  late ScrollController scrollController;

  @override
  void initState() {
    scrollController = ScrollController(initialScrollOffset: 50.0);
    WidgetsBinding.instance.addPostFrameCallback(scroll);
    super.initState();
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      scrollDirection: widget.direction,
      controller: scrollController,
      child: widget.child,
    );
  }

  void scroll(_) async {
    while (scrollController.hasClients) {
      await Future.delayed(widget.pauseDuration);
      if (scrollController.hasClients) {
        await scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: widget.animationDuration,
          curve: Curves.ease,
        );
      }
      await Future.delayed(widget.pauseDuration);
      if (scrollController.hasClients) {
        await scrollController.animateTo(
          0.0,
          duration: widget.backDuration,
          curve: Curves.easeOut,
        );
      }
    }
  }
}
