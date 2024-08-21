import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:latlong2/latlong.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'package:ymyr/animated_icon.dart';
import 'package:ymyr/app_state.dart';

class OSMFlutterMap extends StatelessWidget {
  OSMFlutterMap({super.key});

  final MapController mapController = MapController();

  final LatLng initialCenter = LatLng(48.7758, 9.1829); // Stuttgart

  Marker drawMarker(LatLng geoPoint) {
    return Marker(
      point: geoPoint,
      builder: (context) => const CustomMarker(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = AppState.of(context)!;
    final List<ParseObject> data = state.filtered;

    void onPositionChanged(MapPosition position, bool hasGesture) {
      if (state.mode) {
        state.locationPickerNotifier.setLocation(
          position.center ?? initialCenter,
        );
      }
    }

    return Stack(
      children: [
        FlutterMap(
          options: MapOptions(
              center: initialCenter,
              zoom: 14.0,
              minZoom: 10.0,
              maxZoom: 18.0,
              interactiveFlags: InteractiveFlag.all & ~InteractiveFlag.rotate,
              onPositionChanged: onPositionChanged),
          children: [
            TileLayer(
              urlTemplate:
                  'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}.png',
              subdomains: const ['a', 'b', 'c', 'd'],
            ),
            if (!state.mode)
              MarkerClusterLayerWidget(
                options: MarkerClusterLayerOptions(
                  maxClusterRadius: 45,
                  size: const Size(40, 40),
                  markers: data.map((entry) {
                    ParseGeoPoint point = entry['Coordinates'];
                    final double latitude = point.latitude;
                    final double longitude = point.longitude;
                    return drawMarker(LatLng(latitude, longitude));
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

class CustomMarker extends StatelessWidget {
  const CustomMarker({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => showBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return FractionallySizedBox(
            heightFactor: 0.97,
            child: SizedBox(
              width: 400,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.topRight,
                      child: CloseButton(
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    const Placeholder()
                  ],
                ),
              ),
            ),
          );
        },
      ),
      child: Icon(
        Icons.location_on,
        color: Theme.of(context).primaryColor,
      ),
    );
  }
}
