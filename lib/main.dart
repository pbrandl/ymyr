// import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map/flutter_map.dart';

import 'package:flutter/material.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:latlong2/latlong.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'package:ymyr/animated_icon.dart';
import 'package:ymyr/dropdowns.dart';

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

  runApp(const Home());
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class LocationPickerNotifier extends ChangeNotifier {
  bool _mode = false;
  LatLng? _center;

  bool get mode => _mode;

  LatLng? get center => _center;

  void toggleLocationPickerMode() {
    _mode = !_mode;
    notifyListeners();
  }

  void setLocation(LatLng? center) {
    _center = center;
    debugPrint(_center.toString());
    notifyListeners();
  }
}

class CategoryDataNotifier extends ChangeNotifier {
  List<ParseObject> _events = [];
  List<ParseObject> _artists = [];

  List<ParseObject> get events => _events;
  List<ParseObject> get artists => _artists;
  List<ParseObject> get current => _currentSelection;

  List<ParseObject> _currentSelection = [];

  void setSelectionToEvent() {
    _currentSelection = _events;
    notifyListeners();
  }

  void setSelectionToArtist() {
    _currentSelection = _artists;
    notifyListeners();
  }

  void filterSelection(genre, type, finta) {}

  CategoryDataNotifier() {
    Future.wait([
      fetchArtists(),
      fetchEvents(),
    ]);
  }

  Future<void> fetchArtists() async {
    final QueryBuilder<ParseObject> queryArtists =
        QueryBuilder<ParseObject>(ParseObject('Artists'));

    final ParseResponse response = await queryArtists.query();

    if (response.success && response.results != null) {
      _artists = response.results as List<ParseObject>;
      _currentSelection = _artists;
      notifyListeners();
    } else {
      print('Failed to fetch artists: ${response.error?.message}');
    }
  }

  // Fetch all data from the 'Events' table
  Future<void> fetchEvents() async {
    final QueryBuilder<ParseObject> queryEvents =
        QueryBuilder<ParseObject>(ParseObject('Events'));

    final ParseResponse response = await queryEvents.query();

    if (response.success && response.results != null) {
      _events = response.results as List<ParseObject>;
      notifyListeners();
    } else {
      // Handle error
      print('Failed to fetch events: ${response.error?.message}');
    }
  }
}

enum Category { event, artist }

enum View { list, map }

class MenuStateNotifier extends ChangeNotifier {
  Category _category = Category.artist;
  View _view = View.map;

  Category get category => _category;
  View get view => _view;

  void toggleView() {
    _view = _view == View.list ? View.map : View.list;
    notifyListeners();
  }

  void toggleCategory() {
    _category = _category == Category.event ? Category.artist : Category.event;
    notifyListeners();
  }

  void setCategoryEvents() {
    _category = Category.event;
    notifyListeners();
  }

  void setCategoryArtists() {
    _category = Category.artist;
    notifyListeners();
  }

  String categoryString() {
    return _category != Category.event ? "Event" : "Artist";
  }

  String viewString() {
    return _view != View.map ? "Map" : "List";
  }

  bool isEvent() => _category == Category.event;
}

class _HomeState extends State<Home> {
  late LocationPickerNotifier _picker;
  late CategoryDataNotifier _categoryData;
  late MenuStateNotifier _menuState;

  @override
  void initState() {
    super.initState();
    _picker = LocationPickerNotifier();
    _picker.addListener(_update);
    _categoryData = CategoryDataNotifier();
    _categoryData.addListener(_update);
    _menuState = MenuStateNotifier();
    _menuState.addListener(_update);
  }

  @override
  void dispose() {
    _picker.removeListener(_update);
    _picker.dispose();
    _categoryData.removeListener(_update);
    _categoryData.dispose();
    _menuState.removeListener(_update);
    _menuState.dispose();
    super.dispose();
  }

  void _update() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'YMYR',
      home: Scaffold(
        body: Stack(children: [
          OSMFlutterMap(
            pickerNotifier: _picker,
            menuState: _menuState,
            locationData: _categoryData,
          ),
          Positioned(
            top: 20,
            right: 50,
            left: 50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                    color: Colors.white,
                    width: 60,
                    child: Picker(defaultText: 'Genre', items: genres)),
                const SizedBox(width: 32),
                Container(
                    color: Colors.white,
                    width: 60,
                    child: Picker(defaultText: 'Type', items: types)),
                const SizedBox(width: 32),
                const FintaActionChip(),
              ],
            ),
          ),
          if (_picker.mode)
            const Positioned(
                top: 50,
                right: 50,
                left: 50,
                bottom: 50,
                child: IconAnimation(icon: Icons.my_location)),
          if (_picker.mode)
            const Positioned(
              right: 50,
              left: 50,
              bottom: 40,
              child: AddMenu(),
            ),
          if (_picker.mode)
            const Positioned(
              right: 50,
              left: 50,
              top: 90,
              child: Center(child: Text("Wähle deine Location")),
            ),
        ]),
        floatingActionButton: !_picker.mode
            ? QuadMenu(
                menuState: _menuState,
                categoryData: _categoryData,
              )
            : null,
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }
}

class QuadMenu extends StatefulWidget {
  final MenuStateNotifier menuState;
  final CategoryDataNotifier categoryData;

  const QuadMenu({
    super.key,
    required this.menuState,
    required this.categoryData,
  });

  @override
  State<QuadMenu> createState() => _QuadMenuState();
}

class _QuadMenuState extends State<QuadMenu> {
  late List<ParseObject> data = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: 200,
        child: Row(children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                if (widget.menuState._category == Category.event) {
                  widget.menuState.setCategoryArtists();
                  widget.categoryData.setSelectionToArtist();
                } else {
                  widget.menuState.setCategoryEvents();
                  widget.categoryData.setSelectionToEvent();
                }
              },
              child: Container(
                height: 30,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  border: Border.all(),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(15.0),
                    bottomLeft: Radius.circular(15.0),
                  ),
                ),
                child: Text(
                  widget.menuState.categoryString(),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                widget.menuState.toggleView();
                if (widget.menuState._view == View.list) {
                  showBottomSheet(
                    context: context,
                    builder: (BuildContext context) {
                      return FractionallySizedBox(
                        heightFactor: 0.97,
                        child: SizedBox(
                          width: 400,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: AnimatedBuilder(
                              animation: widget.menuState,
                              builder: (context, child) {
                                final data = widget.categoryData.current;
                                return ArtistListView(data: data);
                              },
                            ),
                          ),
                        ),
                      );
                    },
                  ).closed.then((value) => widget.menuState.toggleView());
                  ;
                } else {
                  Navigator.pop(context);
                  widget.menuState.toggleView();
                }
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  border: const Border(
                    top: BorderSide(color: Colors.black),
                    bottom: BorderSide(color: Colors.black),
                    right: BorderSide(color: Colors.black),
                  ),
                  borderRadius: const BorderRadius.only(
                    bottomRight: Radius.circular(15.0),
                    topRight: Radius.circular(15.0),
                  ),
                ),
                height: 30,
                alignment: Alignment.center,
                child: Text(widget.menuState.viewString()),
              ),
            ),
          ),
        ]));
  }
}

class ArtistListView extends StatelessWidget {
  ArtistListView({
    super.key,
    required this.data,
  });

  final List<ParseObject> data;

  final List<Map<String, dynamic>> items = [
    {
      'image': 'assets/sample_image.png',
      'headline': 'Exciting News!',
      'description': 'This is a brief description of the news item.',
      'genre': 'Rock',
      'type': 'Band',
    },
    {
      'image': 'assets/sample_image.png',
      'headline': 'DJ Sorry',
      'description': 'This is a brief description of the news item.',
      'genre': 'Techno',
      'type': 'DJ',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.asset(
                item['image'],
                fit: BoxFit.cover,
                width: double.infinity,
                height: 200,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  item['headline'],
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  item['description'],
                  style: const TextStyle(fontSize: 16),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Chip(
                      label: Text(item['genre']),
                      backgroundColor: Colors.blueAccent,
                    ),
                    const SizedBox(width: 8),
                    Chip(
                      label: Text(item['type']),
                      backgroundColor: Colors.greenAccent,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
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
  final LocationPickerNotifier pickerNotifier;
  final MenuStateNotifier menuState;
  final CategoryDataNotifier locationData;

  const OSMFlutterMap({
    super.key,
    required this.pickerNotifier,
    required this.menuState,
    required this.locationData,
  });

  @override
  State<OSMFlutterMap> createState() => _OSMFlutterMapState();
}

class _OSMFlutterMapState extends State<OSMFlutterMap> {
  final MapController mapController = MapController();

  @override
  void dispose() {
    mapController.dispose();
    super.dispose();
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
      if (widget.pickerNotifier.mode) {
        widget.pickerNotifier.setLocation(position.center);
      }
    }

    return FlutterMap(
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
        if (!widget.pickerNotifier.mode)
          MarkerClusterLayerWidget(
            options: MarkerClusterLayerOptions(
              maxClusterRadius: 45,
              size: const Size(40, 40),
              markers: (widget.menuState.category == Category.event
                      ? widget.locationData.events
                      : widget.locationData.artists)
                  .map((entry) {
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

class FintaActionChip extends StatefulWidget {
  const FintaActionChip({super.key});

  @override
  State<FintaActionChip> createState() => _FintaActionChipState();
}

class _FintaActionChipState extends State<FintaActionChip> {
  bool toggle = false;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      avatar: Icon(toggle ? Icons.check : Icons.radio_button_unchecked),
      label: const Text('Finta'),
      onPressed: () {
        setState(() {
          toggle = !toggle;
        });
      },
    );
  }
}
