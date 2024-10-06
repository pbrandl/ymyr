import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'package:ymyr/app_state.dart';
import 'package:ymyr/artist_profile.dart';
import 'package:ymyr/cateogry_menu.dart';
import 'package:ymyr/event_profile.dart';
import 'package:ymyr/main.dart';
import 'package:ymyr/map_screen.dart';
import 'package:ymyr/nav_menu.dart';
import 'package:ymyr/picker.dart';

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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = AppState.of(context)!;
    City city = state.city;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text(
              AppState.of(context)!.dataNotifier.category == Category.event
                  ? "EVENTS IN"
                  : AppState.of(context)!.dataNotifier.category ==
                          Category.artist
                      ? "ARTISTS IN"
                      : "RADIOS IN",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(
              width: 8,
            ),
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () async {
                Navigator.pop(context);
              },
              child: Text(
                cityStringMap[city]!.toUpperCase(),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
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
                              Category.artist
                          ? ArtistProfile(artist: item, showCloseButton: false)
                          : EventProfile(event: item, showCloseButton: false));
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
