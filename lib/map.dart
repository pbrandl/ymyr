import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:latlong2/latlong.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'package:ymyr/animated_icon.dart';
import 'package:ymyr/app_state.dart';
import 'package:ymyr/main.dart';
import 'package:geolocator/geolocator.dart';

class OSMFlutterMap extends StatefulWidget {
  const OSMFlutterMap({super.key});

  @override
  State<OSMFlutterMap> createState() => _OSMFlutterMapState();
}

class _OSMFlutterMapState extends State<OSMFlutterMap> {
  final MapController mapController = MapController();

  late List<ParseObject> data;
  late LatLng initialCenter;
  late LatLngBounds bounds;

  Position? userPosition;

  @override
  void initState() {
    super.initState();

    try {
      _determinePosition();
    } catch (e) {
      rethrow;
    }
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

  Marker drawMarker(ParseObject entry) {
    ParseGeoPoint point = entry['Coordinates'];
    final double latitude = point.latitude;
    final double longitude = point.longitude;

    return Marker(
      point: LatLng(latitude, longitude),
      builder: (context) => CustomMarker(data: entry),
    );
  }

  /// Determine the current position of the device.
  ///
  /// When the location services are not enabled or permissions
  /// are denied the `Future` will return an error.
  Future _determinePosition() async {
    bool serviceEnabled;
    LocationPermission? permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    userPosition = await Geolocator.getCurrentPosition();
    update();
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

      // if (!bounds.contains(position.center!)) {
      //   debugPrint(position.center.toString());

      //   final newCenter = LatLng(
      //     position.center!.latitude
      //         .clamp(bounds.southWest.latitude, bounds.northEast.latitude),
      //     position.center!.longitude
      //         .clamp(bounds.southWest.longitude, bounds.northEast.longitude),
      //   );

      //   WidgetsBinding.instance.addPostFrameCallback((_) {
      //     mapController.move(newCenter, position.zoom!);
      //   });
      // }
    }

    return Stack(
      children: [
        FlutterMap(
          mapController: mapController,
          options: MapOptions(
            center: initialCenter,
            zoom: 14.0,
            minZoom: 2.0,
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
            if (userPosition != null)
              MarkerLayer(
                markers: [
                  Marker(
                    width: 60.0,
                    height: 60.0,
                    point: LatLng(
                      userPosition!.latitude,
                      userPosition!.longitude,
                    ),
                    builder: (context) => const UserPositionMarker(),
                  ),
                ],
              ),
            if (!state.mode)
              MarkerClusterLayerWidget(
                options: MarkerClusterLayerOptions(
                  maxClusterRadius: 45,
                  size: const Size(40, 40),
                  markers: data.map((entry) {
                    return drawMarker(entry);
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

class UserPositionMarker extends StatelessWidget {
  const UserPositionMarker({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Outer lighter circle with shadow
        Container(
          width: 25.0,
          height: 25.0,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.blueAccent.withOpacity(0.3),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
        ),
        // Inner blue dot
        Container(
          width: 15.0,
          height: 15.0,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.blue,
          ),
        ),
      ],
    );
  }
}

class CustomMarker extends StatelessWidget {
  final ParseObject data;

  const CustomMarker({
    super.key,
    required this.data,
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
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.topRight,
                    child: CloseButton(
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  ArtistProfile(artist: data)
                ],
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
