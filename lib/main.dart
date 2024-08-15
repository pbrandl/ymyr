// import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map/flutter_map.dart';

import 'package:flutter/material.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:latlong2/latlong.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'package:ymyr/animated_icon.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Parse SDK
  const keyApplicationId = 'yUVvb4hLLk2P2RlCdblresCpTPgV69ZxCtMcXb1u';
  const keyClientKey = 'lpblFYsSydJ0qYIRC2fqI7vdoplKmHU79mrsw7so';
  const keyParseServerUrl = 'https://parseapi.back4app.com/';

  await Parse().initialize(
    keyApplicationId,
    keyParseServerUrl,
    clientKey: keyClientKey,
    autoSendSessionId: true,
  );

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _locationPickerMode = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'YMYR',
      home: Scaffold(
        body: Stack(children: [
          OSMFlutterMap(showMarker: !_locationPickerMode),
          if (!_locationPickerMode)
            const Positioned(
              right: 50,
              left: 50,
              bottom: 40,
              child: QuadMenu(),
            ),
          if (!_locationPickerMode)
            Positioned(
              right: 20,
              bottom: 40,
              child: FilledButton.icon(
                icon: const Icon(Icons.add),
                onPressed: () => {
                  setState(() {
                    _locationPickerMode = !_locationPickerMode;
                  })
                },
                label: const Text("Neu"),
              ),
            ),
          if (_locationPickerMode)
            const Positioned(
                top: 50,
                right: 50,
                left: 50,
                bottom: 50,
                child: IconAnimation(icon: Icons.my_location)),
          if (_locationPickerMode)
            const Positioned(
              right: 50,
              left: 50,
              bottom: 40,
              child: AddMenu(),
            ),
          if (_locationPickerMode)
            const Positioned(
              right: 50,
              left: 50,
              top: 90,
              child: Center(child: Text("Wähle deine Location")),
            ),
        ]),
      ),
    );
    ;
  }
}

class QuadMenu extends StatefulWidget {
  const QuadMenu({super.key});

  @override
  State<QuadMenu> createState() => _QuadMenuState();
}

enum MenuOptions { event, list, artist, map }

class _QuadMenuState extends State<QuadMenu> {
  final List<(MenuOptions, String)> shirtSizeOptions = <(MenuOptions, String)>[
    (MenuOptions.event, 'Event'),
    (MenuOptions.list, 'List'),
  ];

  Set<MenuOptions> _segmentedButtonSelection = <MenuOptions>{MenuOptions.event};

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SegmentedButton<MenuOptions>(
            multiSelectionEnabled: true,
            emptySelectionAllowed: true,
            showSelectedIcon: false,
            selected: _segmentedButtonSelection,
            onSelectionChanged: (Set<MenuOptions> newSelection) {
              setState(() {
                _segmentedButtonSelection = newSelection;
              });
            },
            segments: shirtSizeOptions
                .map<ButtonSegment<MenuOptions>>(((MenuOptions, String) shirt) {
              return ButtonSegment<MenuOptions>(
                value: shirt.$1,
                label: Row(
                  children: [
                    const Icon(Icons.map),
                    const SizedBox(width: 8),
                    Text(shirt.$2),
                  ],
                ),
              );
            }).toList(),
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all<Color>(Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

class AddMenu extends StatefulWidget {
  const AddMenu({super.key});

  @override
  State<AddMenu> createState() => _AddMenuState();
}

enum AddMenuOptions { cancel, next }

class _AddMenuState extends State<AddMenu> {
  final List<(AddMenuOptions, String)> shirtSizeOptions =
      <(AddMenuOptions, String)>[
    (AddMenuOptions.cancel, 'Abbrechen'),
    (AddMenuOptions.next, 'Weiter'),
  ];

  Set<AddMenuOptions> _segmentedButtonSelection = <AddMenuOptions>{
    AddMenuOptions.next
  };

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SegmentedButton<AddMenuOptions>(
            multiSelectionEnabled: true,
            emptySelectionAllowed: true,
            showSelectedIcon: false,
            selected: _segmentedButtonSelection,
            onSelectionChanged: (Set<AddMenuOptions> newSelection) {
              setState(() {
                _segmentedButtonSelection = newSelection;
              });
            },
            segments: shirtSizeOptions.map<ButtonSegment<AddMenuOptions>>(
                ((AddMenuOptions, String) option) {
              return ButtonSegment<AddMenuOptions>(
                value: option.$1,
                label: Row(
                  children: [
                    const Icon(Icons.map),
                    const SizedBox(width: 8),
                    Text(option.$2),
                  ],
                ),
              );
            }).toList(),
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all<Color>(Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

class OSMFlutterMap extends StatefulWidget {
  final bool showMarker;

  const OSMFlutterMap({super.key, required this.showMarker});

  @override
  State<OSMFlutterMap> createState() => _OSMFlutterMapState();
}

class _OSMFlutterMapState extends State<OSMFlutterMap> {
  final MapController mapController = MapController();
  List<ParseObject> _geoLocations = [
    ParseObject('GeoLocation')
      ..set('latitude', 48.7758)
      ..set('longitude', 9.1829),
    ParseObject('GeoLocation')
      ..set('latitude', 48.7826)
      ..set('longitude', 9.1770),
    ParseObject('GeoLocation')
      ..set('latitude', 48.7746)
      ..set('longitude', 9.1638),
    ParseObject('GeoLocation')
      ..set('latitude', 48.7837)
      ..set('longitude', 9.1563),
    ParseObject('GeoLocation')
      ..set('latitude', 48.7751)
      ..set('longitude', 9.1900),
    ParseObject('GeoLocation')
      ..set('latitude', 48.7700)
      ..set('longitude', 9.1782),
    ParseObject('GeoLocation')
      ..set('latitude', 48.7805)
      ..set('longitude', 9.1850),
    ParseObject('GeoLocation')
      ..set('latitude', 48.7792)
      ..set('longitude', 9.1683),
    ParseObject('GeoLocation')
      ..set('latitude', 48.7743)
      ..set('longitude', 9.1845),
    ParseObject('GeoLocation')
      ..set('latitude', 48.7780)
      ..set('longitude', 9.1871),
    ParseObject('GeoLocation')
      ..set('latitude', 48.7762)
      ..set('longitude', 9.1814),
    ParseObject('GeoLocation')
      ..set('latitude', 48.7717)
      ..set('longitude', 9.1736),
  ];

  @override
  void initState() {
    super.initState();
  }

  LatLng initialCenter = LatLng(48.7758, 9.1829); // Coordinates for Stuttgart

  @override
  Widget build(BuildContext context) {
    Marker drawMarker(LatLng geoPoint) {
      return Marker(
        point: geoPoint,
        builder: (context) => const CustomMarker(),
      );
    }

    void onPositionChanged(MapPosition position, bool hasGesture) {
      print('Center: ${position.center}');
    }

    return FlutterMap(
      options: MapOptions(
          center: initialCenter,
          zoom: 14.0,
          minZoom: 1.0,
          maxZoom: 20.0,
          onPositionChanged: onPositionChanged),
      children: [
        TileLayer(
          urlTemplate:
              'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}.png',
          subdomains: const ['a', 'b', 'c', 'd'],
          // retinaMode: true,
        ),
        if (widget.showMarker)
          MarkerClusterLayerWidget(
            options: MarkerClusterLayerOptions(
              maxClusterRadius: 45,
              size: const Size(40, 40),
              markers: _geoLocations.map((location) {
                final double latitude = location['latitude'];
                final double longitude = location['longitude'];
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
