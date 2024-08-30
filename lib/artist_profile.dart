import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

class ArtistProfile extends StatelessWidget {
  final ParseObject artist;

  const ArtistProfile({
    super.key,
    required this.artist,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.zero,
      child: SizedBox(
        width: 400,
        child: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    artist['Image'] == null
                        ? Container(
                            height: 250,
                            width: double.infinity,
                            color: Colors.grey[200],
                            child: Icon(
                              Icons.image,
                              size: 50,
                              color: Colors.grey[400],
                            ),
                          )
                        : SizedBox(
                            height: 250,
                            width: double.infinity,
                            child: Image.network(
                              artist['Image']!.url,
                              fit: BoxFit.cover,
                            ),
                          ),
                    Positioned(
                      left: 10,
                      bottom: 10,
                      child: Stack(
                        children: [
                          Text(
                            artist['Name'],
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              foreground: Paint()
                                ..style = PaintingStyle.stroke
                                ..strokeWidth = 1
                                ..color = Colors.black,
                            ),
                          ),
                          Text(
                            artist['Name'],
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      CupertinoChip(label: artist['Genre']),
                      const SizedBox(width: 16),
                      CupertinoChip(label: artist['Type']),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
            Positioned(
              right: 10,
              top: 10,
              child: IconButton(
                icon: const Icon(
                  Icons.close,
                  color: Colors.white,
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CupertinoChip extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;

  const CupertinoChip({
    super.key,
    required this.label,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: CupertinoColors.inactiveGray,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: CupertinoColors.black,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
