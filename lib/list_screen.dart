import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'package:ymyr/app_state.dart';
import 'package:ymyr/artist_profile.dart';

class ListScreen extends StatelessWidget {
  final List<ParseObject> data;

  const ListScreen({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    City city = AppState.of(context)!.city;

    return Scaffold(
      appBar: AppBar(
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
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 450.0,
          ),
          child: ListView.builder(
            itemCount: data.length,
            itemBuilder: (context, index) {
              final item = data[index];
              return ArtistProfile(artist: item);
            },
          ),
        ),
      ),
    );
  }
}
