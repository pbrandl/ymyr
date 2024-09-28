import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'package:ymyr/app_state.dart';
import 'package:ymyr/artist_profile.dart';
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
                      : "STATIONS IN",
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
            ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 400.0,
              ),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 48.0),
                child: ListView.builder(
                  itemCount: widget.data.length,
                  itemBuilder: (context, index) {
                    final item = widget.data[index];
                    return Padding(
                      padding: const EdgeInsets.all(16.0),
                      child:
                          ArtistProfile(artist: item, showCloseButton: false),
                    );
                  },
                ),
              ),
            ),
            const Positioned(
              top: 20,
              right: 50,
              left: 50,
              child: CateogryActionChips(),
            ),
            const Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: Center(
                child: NavMenu(
                  appview: AppView.list,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
