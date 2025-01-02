import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'package:text_scroll/text_scroll.dart';
import 'package:ymyr/app_state.dart';
import 'package:ymyr/profile_artist.dart';
import 'package:ymyr/cateogry_menu.dart';
import 'package:ymyr/profile_event.dart';
import 'package:ymyr/main.dart';
import 'package:ymyr/map_screen.dart';
import 'package:ymyr/filter_menu.dart';
import 'package:ymyr/picker.dart';
import 'package:ymyr/profile_radio.dart';

class ListScreen extends StatefulWidget {
  final List<ParseObject> data;

  const ListScreen({
    super.key,
    required this.data,
  });

  @override
  State<ListScreen> createState() => _ListScreenState();
}

class _ListScreenState extends State<ListScreen> {
  late AudioNotifier audioNotifier;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    AppState.of(context)!.dataNotifier.addListener(_updateState);
    audioNotifier = AppState.of(context)!.audioNotifier;
    audioNotifier.addListener(_updateState);
  }

  void _updateState() {
    setState(() {});
  }

  @override
  void dispose() {
    AppState.of(context)!.dataNotifier.removeListener(_updateState);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = AppState.of(context)!;
    City city = state.city;

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
      backgroundColor: Colors.white,
      body: Center(
        child: Stack(
          children: [
            SizedBox(
              width: 400,
              child: ListView.builder(
                itemCount: widget.data.length,
                itemBuilder: (context, index) {
                  final item = widget.data[index];
                  return Padding(
                    padding: EdgeInsets.only(
                      top: index == 0 ? 64.0 : 16.0,
                      bottom: index == widget.data.length - 1 ? 72.0 : 16.0,
                      left: 16.0,
                      right: 16.0,
                    ),
                    child: AppState.of(context)!.dataNotifier.category ==
                            Category.station
                        ? RadioProfile(
                            radio: item,
                            showCloseButton: false,
                          )
                        : ArtistProfile(
                            artist: item,
                            showCloseButton: false,
                          ),
                  );
                },
              ),
            ),
            const Positioned(
              top: 20,
              right: 50,
              left: 50,
              child: CateogryMenu(),
            ),
            const NavMenu(appview: AppView.list),
          ],
        ),
      ),
    );
  }
}
