import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:latlong2/latlong.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'package:ymyr/animated_icon.dart';
import 'package:ymyr/app_state.dart';
import 'package:ymyr/artist_profile.dart';
import 'package:geolocator/geolocator.dart';
import 'package:ymyr/event_profile.dart';

class OSMFlutterMap extends StatefulWidget {
  const OSMFlutterMap({super.key});

  @override
  State<OSMFlutterMap> createState() => _OSMFlutterMapState();
}

class _OSMFlutterMapState extends State<OSMFlutterMap> {
  final MapController mapController = MapController();

  late LatLng initialCenter;
  late LatLngBounds bounds;

  Position? userPosition;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final state = AppState.of(context)!;
    state.locationNotifier.addListener(update);
    state.dataNotifier.addListener(update);
  }

  @override
  void dispose() {
    final state = AppState.of(context);
    if (state != null) {
      state.locationNotifier.removeListener(update);
      state.dataNotifier.removeListener(update);
    }
    super.dispose();
  }

  void update() {
    setState(() {});
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

  @override
  Widget build(BuildContext context) {
    final state = AppState.of(context)!;
    final List<ParseObject> data = state.filtered;
    final LatLng initialCenter = state.center;
    final LatLngBounds bounds = state.bounds;

    void onPositionChanged(MapPosition position, bool hasGesture) {
      if (state.mode) {
        state.locationNotifier.setLocation(
          position.center ?? initialCenter,
        );
      }

      if (!bounds.contains(position.center!)) {
        debugPrint(position.center.toString());

        final newCenter = LatLng(
          position.center!.latitude
              .clamp(bounds.southWest.latitude, bounds.northEast.latitude),
          position.center!.longitude
              .clamp(bounds.southWest.longitude, bounds.northEast.longitude),
        );

        WidgetsBinding.instance.addPostFrameCallback((_) {
          mapController.move(newCenter, position.zoom!);
        });
      }
    }

    return Stack(
      children: [
        FlutterMap(
          mapController: mapController,
          options: MapOptions(
            center: initialCenter,
            zoom: 14.0,
            minZoom: 12.0,
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
            // if (userPosition != null)
            //   MarkerLayer(
            //     markers: [
            //       Marker(
            //         width: 60.0,
            //         height: 60.0,
            //         point: LatLng(
            //           userPosition!.latitude,
            //           userPosition!.longitude,
            //         ),
            //         builder: (context) => const UserPositionMarker(),
            //       ),
            //     ],
            //   ),
            if (!state.mode)
              MarkerClusterLayerWidget(
                options: MarkerClusterLayerOptions(
                  maxClusterRadius: 45,
                  size: const Size(40, 40),
                  markers: data.map((entry) {
                    return drawMarker(entry, state.category);
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
        if (state.mode)
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
                if (category == Category.event) EventProfile(event: data)
              ],
            ),
          );
        },
      ),
      child: CircleAvatar(
        backgroundColor: Theme.of(context).cardColor,
        child: const Text(
          'Y',
          style: TextStyle(
              fontWeight: FontWeight.bold, fontSize: 10, color: Colors.white),
        ),
      ),
    );
  }
}
