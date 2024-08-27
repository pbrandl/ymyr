import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

enum Genre {
  rock,
  pop,
  jazz,
  classical,
  hipHop,
}

enum Type {
  band,
  dj,
}

final Map<Genre, String> genreStringMap = {
  Genre.rock: 'Rock',
  Genre.pop: 'Pop',
  Genre.jazz: 'Jazz',
  Genre.classical: 'Classical',
  Genre.hipHop: 'Hip-Hop',
};

final Map<Type, String> typeStringMap = {
  Type.band: 'Band',
  Type.dj: 'DJ',
};

enum Category { event, artist }

enum AppView { list, map }

class AppState extends InheritedWidget {
  final LocationNotifier locationPickerNotifier;
  final DataNotifier dataNotifier;
  final MenuNotifier menuNotifier;

  List<ParseObject> get filtered => dataNotifier.current;
  Category get category => dataNotifier.category;
  AppView get view => menuNotifier.view;

  List<ParseObject> get current => dataNotifier.current;

  bool get mode => locationPickerNotifier.mode;
  set mode(bool b) => locationPickerNotifier.mode = b;

  LatLng get center => locationPickerNotifier.center;
  LatLngBounds get bounds => locationPickerNotifier.bounds;

  const AppState({
    super.key,
    required super.child,
    required this.locationPickerNotifier,
    required this.dataNotifier,
    required this.menuNotifier,
  });

  static AppState? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<AppState>();
  }

  @override
  bool updateShouldNotify(AppState oldWidget) {
    return locationPickerNotifier != oldWidget.locationPickerNotifier ||
        dataNotifier != oldWidget.dataNotifier;
  }
}

enum City { freiburg, stuttgart }

final Map<City, (LatLng, LatLngBounds)> cityToCoord = {
  City.stuttgart: (
    LatLng(48.7758, 9.1829),
    LatLngBounds(LatLng(48.75, 9.15), LatLng(48.8, 9.25)),
  ),
  City.freiburg: (
    LatLng(47.9990, 7.8421),
    LatLngBounds(LatLng(47.9740, 7.8121), LatLng(48.0240, 7.8721))
  ),
};

class LocationNotifier extends ChangeNotifier {
  City _city = City.stuttgart;

  bool mode = false;
  LatLng _center;
  LatLngBounds _bounds;

  LocationNotifier()
      : _center = cityToCoord[City.stuttgart]!.$1,
        _bounds = cityToCoord[City.stuttgart]!.$2;

  City get city => _city;
  LatLng get center => _center;
  LatLngBounds get bounds => _bounds;

  set city(City newCity) {
    _city = newCity;
    final (center, bounds) = cityToCoord[_city]!;
    _center = center;
    _bounds = bounds;
    notifyListeners();
  }

  void toggleLocationPickerMode() {
    mode = !mode;
    notifyListeners();
  }

  void setLocation(LatLng center) {
    _center = center;
    debugPrint(_center.toString());
    notifyListeners();
  }
}

class DataNotifier extends ChangeNotifier {
  Category _category = Category.artist;
  List<ParseObject> _events = [];
  List<ParseObject> _artists = [];
  String _genre = 'All';
  String _type = 'All';
  bool _finta = false;

  String get genre => _genre;
  String get type => _type;
  bool get finta => _finta;

  Category get category => _category;
  List<ParseObject> get events => _events;
  List<ParseObject> get artists => _artists;
  List<ParseObject> get current => _filtered;

  List<ParseObject> _filtered = [];

  set category(Category cat) {
    _category = cat;
    filterSelection(_category, genre, type, finta);
  }

  set genre(String genre) {
    _genre = genre;
    filterSelection(_category, genre, type, finta);
  }

  set type(String type) {
    _type = type;
    filterSelection(_category, genre, type, finta);
  }

  set finta(bool finta) {
    _finta = finta;
    filterSelection(_category, genre, type, finta);
  }

  void filterSelection(
    Category category,
    String genre,
    String type,
    bool finta,
  ) {
    _filtered = (category == Category.event ? events : artists).where((item) {
      final itemGenre = item.get<String>('Genre');
      final itemType = item.get<String>('Type');
      final itemFinta = item.get<bool>('Finta');

      return (genre == 'All' || itemGenre == genre) &&
          (type == 'All' || itemType == type) &&
          ((finta == true && itemFinta == true) || finta == false);
    }).toList();
    notifyListeners();
  }

  DataNotifier() {
    _initialize();
  }

  Future<void> _initialize() async {
    // await Future.delayed(const Duration(seconds: 3));
    await Future.wait([
      fetchArtists(),
      fetchEvents(),
    ]);
    notifyListeners();
  }

  Future<void> fetchArtists() async {
    final QueryBuilder<ParseObject> queryArtists =
        QueryBuilder<ParseObject>(ParseObject('Artists'));

    final ParseResponse response = await queryArtists.query();

    if (response.success && response.results != null) {
      _artists = response.results as List<ParseObject>;
      _filtered = _artists;
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
    } else {
      // Handle error
      print('Failed to fetch events: ${response.error?.message}');
    }
  }
}

class MenuNotifier extends ChangeNotifier {
  AppView _view = AppView.map;

  AppView get view => _view;

  void toggleView() {
    _view = _view == AppView.list ? AppView.map : AppView.list;
    notifyListeners();
  }
}
