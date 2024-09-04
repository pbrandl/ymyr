import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

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
      child: Container(
        width: 300,
        decoration: BoxDecoration(
          border: Border.all(),
          color: Colors.white,
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CupertinoChip(label: artist['City'], color: Colors.yellow),
                  Container(
                    decoration: BoxDecoration(border: Border.all()),
                    child: artist['Image'] == null
                        ? Container(
                            height: 200,
                            width: double.infinity,
                            color: Colors.grey[200],
                            child: Icon(
                              Icons.image,
                              size: 50,
                              color: Colors.grey[400],
                            ),
                          )
                        : SizedBox(
                            height: 200,
                            width: double.infinity,
                            child: Image.network(
                              artist['Image']!.url,
                              fit: BoxFit.cover,
                            ),
                          ),
                  ),
                  Row(
                    children: [
                      CupertinoChip(
                        label: artist['Genre'],
                        color: Colors.lightBlue,
                      ),
                      const SizedBox(width: 16),
                      CupertinoChip(label: artist['Type']),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    artist['Name'],
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    artist['Description'],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.play_arrow_outlined),
                      OpenUrlWidget(
                        label: 'Listen via Stream',
                        url: artist['Link'],
                      )
                    ],
                  ),
                ],
              ),
            ),
            Positioned(
                right: 20,
                top: 65,
                child: Container(
                  height: 30,
                  width: 30,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white,
                      width: 2.0,
                    ),
                  ),
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    iconSize: 20,
                    icon: const Icon(
                      Icons.close,
                      color: Colors.white,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                )),
          ],
        ),
      ),
    );
  }
}

class CupertinoChip extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final Color? color;

  const CupertinoChip({
    super.key,
    required this.label,
    this.onPressed,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(20),
            border: Border.all()),
        child: Text(
          label,
          style: const TextStyle(
            color: CupertinoColors.black,
            fontSize: 12,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.05,
          ),
        ),
      ),
    );
  }
}

class OpenUrlWidget extends StatelessWidget {
  final String url;
  final String label;

  const OpenUrlWidget({
    super.key,
    required this.url,
    required this.label,
  });

  Future<void> _launchUrl() async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _launchUrl,
      child: Text(
        label,
      ),
    );
  }
}
