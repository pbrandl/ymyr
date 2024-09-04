import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'package:text_scroll/text_scroll.dart';
import 'package:ymyr/map_screen.dart';
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
