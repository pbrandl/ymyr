import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'package:ymyr/artist_profile.dart';
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
  void dispose() {
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
          child: AudioPlayerWidget(
            player: _audioPlayer,
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
            const Text(
              "ARTISTS IN",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
              child: QuadMenu(),
            ),
          ),
        ),
        const SideBarNotch(),
      ]),
    );
  }
}

class QuadMenu extends StatefulWidget {
  const QuadMenu({
    super.key,
  });

  @override
  State<QuadMenu> createState() => _QuadMenuState();
}

class _QuadMenuState extends State<QuadMenu> {
  late List<ParseObject> data = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final state = AppState.of(context)!;
    state.dataNotifier.addListener(update);
    state.menuNotifier.addListener(update);
  }

  @override
  void dispose() {
    final state = AppState.of(context);
    if (state != null) {
      state.dataNotifier.removeListener(update);
      state.menuNotifier.removeListener(update);
    }
    super.dispose();
  }

  void update() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final state = AppState.of(context)!;
    final DataNotifier dataNotifier = state.dataNotifier;
    final MenuNotifier menuState = state.menuNotifier;
    final view = state.menuNotifier.view;

    return SizedBox(
        width: 200,
        child: Row(children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                if (state.dataNotifier.category == Category.event) {
                  state.dataNotifier.category = Category.artist;
                } else {
                  state.dataNotifier.category = Category.event;
                }
              },
              child: Container(
                height: 30,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(15.0),
                    bottomLeft: Radius.circular(15.0),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      dataNotifier.category == Category.event
                          ? Icons.supervisor_account
                          : Icons.calendar_month,
                      size: 16,
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    Text(
                      dataNotifier.category != Category.event
                          ? "Events"
                          : "Artists",
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                menuState.toggleView();
                if (view == AppView.map) {
                  showBottomSheet(
                    context: context,
                    builder: (BuildContext context) {
                      return FractionallySizedBox(
                        heightFactor: 0.97,
                        child: SizedBox(
                          width: 400,
                          child: AnimatedBuilder(
                            animation: dataNotifier,
                            builder: (context, child) {
                              final data = state.current;
                              return ArtistListView(data: data);
                            },
                          ),
                        ),
                      );
                    },
                  ).closed.then((value) => menuState.toggleView());
                } else {
                  Navigator.pop(context);
                  menuState.toggleView();
                }
              },
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    top: BorderSide(color: Colors.black),
                    bottom: BorderSide(color: Colors.black),
                    right: BorderSide(color: Colors.black),
                  ),
                  borderRadius: BorderRadius.only(
                    bottomRight: Radius.circular(15.0),
                    topRight: Radius.circular(15.0),
                  ),
                ),
                height: 30,
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      view != AppView.list ? Icons.list : Icons.map,
                      size: 16,
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    Text(view != AppView.list ? "List" : "Map")
                  ],
                ),
              ),
            ),
          ),
        ]));
  }
}

class ArtistListView extends StatelessWidget {
  final List<ParseObject> data;

  const ArtistListView({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: data.length,
      itemBuilder: (context, index) {
        final item = data[index];
        return ArtistProfile(artist: item);
      },
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
        height: 38,
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
            style: TextStyle(fontSize: 16, color: Colors.black),
          ),
        ),
      ),
    );
  }
}
