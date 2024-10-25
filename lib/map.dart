import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:latlong2/latlong.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'package:ymyr/animated_icon.dart';
import 'package:ymyr/app_state.dart';
import 'package:ymyr/profile_artist.dart';
import 'package:geolocator/geolocator.dart';
import 'package:ymyr/profile_event.dart';
import 'package:ymyr/profile_radio.dart';

class OSMFlutterMap extends StatefulWidget {
  const OSMFlutterMap({super.key});

  @override
  State<OSMFlutterMap> createState() => _OSMFlutterMapState();
}

class _OSMFlutterMapState extends State<OSMFlutterMap> {
  final MapController mapController = MapController();

  Position? userPosition;

  @override
  void initState() {
    super.initState();
  }

  late LocationNotifier locationNotifier;
  late DataNotifier dataNotifier;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    locationNotifier = AppState.of(context)!.locationNotifier;
    dataNotifier = AppState.of(context)!.dataNotifier;

    locationNotifier.addListener(update);
    dataNotifier.addListener(update);
  }

  @override
  void dispose() {
    locationNotifier.removeListener(update);
    dataNotifier.removeListener(update);
    mapController.dispose();
    super.dispose();
  }

  void update() {
    if (mounted) setState(() {});
  }

  Marker drawMarker(ParseObject entry, Category cat) {
    ParseGeoPoint point = entry['Coordinates'];
    final double latitude = point.latitude;
    final double longitude = point.longitude;

    return Marker(
      point: LatLng(latitude, longitude),
      builder: (context) => CustomMarker(data: entry, category: cat),
    );
  }

  void onPositionChanged(MapPosition position, bool hasGesture) {
    if (AppState.of(context)!.mode) {
      AppState.of(context)!.locationNotifier.setLocation(
            position.center ?? AppState.of(context)!.center,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        FlutterMap(
          mapController: mapController,
          options: MapOptions(
            center: AppState.of(context)!.center,
            zoom: 14.0,
            minZoom: 8.0,
            maxZoom: 18.0,
            interactiveFlags: InteractiveFlag.all & ~InteractiveFlag.rotate,
            onPositionChanged: onPositionChanged,
          ),
          children: [
            TileLayer(
              urlTemplate:
                  'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}.png',
              subdomains: const ['a', 'b', 'c', 'd'],
            ),
            if (!AppState.of(context)!.mode)
              MarkerClusterLayerWidget(
                options: MarkerClusterLayerOptions(
                  maxClusterRadius: 45,
                  size: const Size(40, 40),
                  markers: AppState.of(context)!.filtered.map((entry) {
                    return drawMarker(entry, AppState.of(context)!.category);
                  }).toList(),
                  builder: (context, markers) {
                    return Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: Theme.of(context).primaryColor),
                      child: Center(
                        child: Text(
                          markers.length.toString(),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
        if (AppState.of(context)!.mode)
          const Positioned(
            top: 50,
            right: 50,
            left: 50,
            bottom: 50,
            child: IconAnimation(
              icon: Icons.my_location,
            ),
          ),
      ],
    );
  }
}

// class UserPositionMarker extends StatelessWidget {
//   const UserPositionMarker({
//     super.key,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Stack(
//       alignment: Alignment.center,
//       children: [
//         // Outer lighter circle with shadow
//         Container(
//           width: 25.0,
//           height: 25.0,
//           decoration: BoxDecoration(
//             shape: BoxShape.circle,
//             color: Colors.blueAccent.withOpacity(0.3),
//             boxShadow: const [
//               BoxShadow(
//                 color: Colors.black26,
//                 blurRadius: 8,
//                 offset: Offset(0, 4),
//               ),
//             ],
//           ),
//         ),
//         // Inner blue dot
//         Container(
//           width: 15.0,
//           height: 15.0,
//           decoration: const BoxDecoration(
//             shape: BoxShape.circle,
//             color: Colors.blue,
//           ),
//         ),
//       ],
//     );
//   }
// }

class CustomMarker extends StatelessWidget {
  final ParseObject data;
  final Category category;

  const CustomMarker({
    super.key,
    required this.data,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.zero,
            ),
            contentPadding: EdgeInsets.zero,
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (category == Category.artist) ArtistProfile(artist: data),
                if (category == Category.event) EventProfile(event: data),
                if (category == Category.station) RadioProfile(radio: data)
              ],
            ),
          );
        },
      ),
      child: CircleAvatar(
        backgroundColor: category == Category.artist
            ? Theme.of(context).cardColor
            : category == Category.event
                ? const Color.fromRGBO(194, 255, 115, 1)
                : const Color.fromRGBO(255, 234, 0, 1),
        child: Text(
          'Y',
          style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 10,
              color: category != Category.artist ? Colors.black : Colors.white),
        ),
      ),
    );
  }
}
