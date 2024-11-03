import 'package:audio_session/audio_session.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:intl/intl.dart';
import 'package:just_audio/just_audio.dart';
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

enum Category { event, artist, station }

enum AppView { list, map }

class AppState extends InheritedWidget {
  final LocationNotifier locationNotifier;
  final DataNotifier dataNotifier;
  final MenuNotifier menuNotifier;
  final AudioNotifier audioNotifier;

  List<ParseObject> get filtered => dataNotifier.current;
  Category get category => dataNotifier.category;
  AppView get view => menuNotifier.view;

  List<ParseObject> get current => dataNotifier.current;

  bool get mode => locationNotifier.mode;
  set mode(bool b) => locationNotifier.mode = b;

  LatLng get center => locationNotifier.center;
  LatLngBounds get bounds => locationNotifier.bounds;

  City get city => locationNotifier.city;
  set city(City c) => locationNotifier.city = c;

  const AppState({
    super.key,
    required super.child,
    required this.locationNotifier,
    required this.dataNotifier,
    required this.menuNotifier,
    required this.audioNotifier,
  });

  static AppState? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<AppState>();
  }

  @override
  bool updateShouldNotify(AppState oldWidget) {
    return locationNotifier != oldWidget.locationNotifier ||
        dataNotifier != oldWidget.dataNotifier;
  }
}

enum City { freiburg, stuttgart, hamburg, berlin, munich }

final Map<City, (LatLng, LatLngBounds)> cityToCoord = {
  City.stuttgart: (
    LatLng(48.7758, 9.1829),
    LatLngBounds(LatLng(48.75, 9.15), LatLng(48.8, 9.25)),
  ),
  City.freiburg: (
    LatLng(47.9990, 7.8421),
    LatLngBounds(
      LatLng(47.9604, 7.6786), // Bottom-left corner (southwest)
      LatLng(48.1004, 7.9802), // Top-right corner (northeast)
    ),
  ),
};

final Map<City, String> cityStringMap = {
  City.stuttgart: "Stuttgart",
  City.freiburg: "Freiburg",
};

final Map<String, City> stringCityMap = {
  "Stuttgart": City.stuttgart,
  "Freiburg": City.freiburg
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
  List<ParseObject> _stations = [];
  List<ParseObject> _artists = [];
  List<ParseObject> _artistWorlds = [];

  String _genre = 'All';
  String _type = 'All';
  bool _finta = false;

  String get genre => _genre;
  String get type => _type;
  bool get finta => _finta;

  Category get category => _category;
  List<ParseObject> get events => _events;
  List<ParseObject> get artists => _artists;
  List<ParseObject> get station => _stations;
  List<ParseObject> get current => _filtered;
  List<ParseObject> get worlds => _artistWorlds;

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
    _filtered = (category == Category.event
            ? events
            : category == Category.artist
                ? artists
                : station)
        .where((item) {
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
    initialize();
  }

  Future<void> initialize() async {
    await Future.wait([
      fetchArtists(),
      fetchEvents(),
      fetchStations(),
      fetchArtistWorlds(),
    ]);
    notifyListeners();
  }

  Future<void> fetchArtistWorlds() async {
    final QueryBuilder<ParseObject> queryArtists =
        QueryBuilder<ParseObject>(ParseObject('ArtistWorld'));
    final ParseResponse response = await queryArtists.query();

    if (response.success && response.results != null) {
      _artistWorlds = response.results as List<ParseObject>;
    } else {
      print('Failed to fetch artists: ${response.error?.message}');
    }
  }

  Future<void> getArtistWorld(String worldID) async {
    final QueryBuilder<ParseObject> queryBuilderArtist =
        QueryBuilder<ParseObject>(ParseObject('Artists'))
          ..whereRelatedTo('FavArtists', 'ArtistWorld', worldID);

    final ParseResponse responseArtist = await queryBuilderArtist.query();

    final QueryBuilder<ParseObject> queryBuilderEvents =
        QueryBuilder<ParseObject>(ParseObject('Artists'))
          ..whereRelatedTo('FavArtists', 'ArtistWorld', worldID);

    final ParseResponse responseEvents = await queryBuilderArtist.query();

    final QueryBuilder<ParseObject> queryBuilderRadios =
        QueryBuilder<ParseObject>(ParseObject('Artists'))
          ..whereRelatedTo('FavArtists', 'ArtistWorld', worldID);

    final ParseResponse responseRadios = await queryBuilderArtist.query();

    debugPrint(responseArtist.results.toString());
    if (responseArtist.success &&
        responseEvents.success &&
        responseRadios.success) {
      _artists = responseArtist.results as List<ParseObject>;
      filterSelection(category, genre, type, finta);
    } else {
      return Future.error(responseArtist.error!.message);
    }
  }

  Future<void> fetchArtists() async {
    final QueryBuilder<ParseObject> queryArtists =
        QueryBuilder<ParseObject>(ParseObject('Artists'))
          ..whereEqualTo('Approved', true);

    final ParseResponse response = await queryArtists.query();

    if (response.success && response.results != null) {
      _artists = response.results as List<ParseObject>;

      _filtered = _artists;
    } else {
      print('Failed to fetch artists: ${response.error?.message}');
    }
  }

  Future<void> fetchStations() async {
    final QueryBuilder<ParseObject> queryArtists =
        QueryBuilder<ParseObject>(ParseObject('Radios'))
          ..whereEqualTo('Approved', true);

    final ParseResponse response = await queryArtists.query();

    if (response.success && response.results != null) {
      _stations = response.results as List<ParseObject>;
    } else {
      print('Failed to fetch stations: ${response.error?.message}');
    }
  }

  // Fetch all data from the 'Events' table
  Future<void> fetchEvents() async {
    final QueryBuilder<ParseObject> queryEvents =
        QueryBuilder<ParseObject>(ParseObject('Events'))
          ..whereEqualTo('Approved', true);

    final ParseResponse response = await queryEvents.query();

    if (response.success && response.results != null) {
      _events = response.results as List<ParseObject>;
    } else {
      // Handle error
      print('Failed to fetch events: ${response.error?.message}');
    }
  }

  filterEventByDate(date) {
    _filtered = (category == Category.event
            ? events
            : category == Category.artist
                ? artists
                : station)
        .where((item) {
      final itemGenre = item.get<String>('Genre');
      final itemType = item.get<String>('Type');
      final itemFinta = item.get<bool>('Finta');
      final DateFormat dateFormatter = DateFormat('dd-MM-yyyy');
      final itemDate = dateFormatter.format(item.get('Start'));

      return (genre == 'All' || itemGenre == genre) &&
          (type == 'All' || itemType == type) &&
          ((finta == true && itemFinta == true) || finta == false) &&
          (date == 'All' || itemDate == date);
    }).toList();

    notifyListeners();
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

class AudioNotifier extends ChangeNotifier with WidgetsBindingObserver {
  final AudioPlayer _player = AudioPlayer();
  String _radioName = "Radio Paradise UK"; // Default values
  String _radioStream = "https://stream-uk1.radioparadise.com/aac-320";

  AudioPlayer get player => _player;
  String get radioName => _radioName;

  setRadio(radioName, radioStream) async {
    _radioName = radioName;
    _radioStream = radioStream;

    try {
      await _player.setAudioSource(AudioSource.uri(Uri.parse(_radioStream)));
    } on PlayerException catch (e) {
      print("Error loading audio source: $e");
    }
    player.play();
    notifyListeners();
  }

  Future<void> _initPlayer() async {
    // Inform the operating system of our app's audio attributes etc.
    // We pick a reasonable default for an app that plays speech.
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.speech());
    // Listen to errors during playback.
    _player.playbackEventStream.listen((event) {},
        onError: (Object e, StackTrace stackTrace) {
      print('A stream error occurred: $e');
    });
    // Try to load audio from a source and catch any errors.
    try {
      await _player.setAudioSource(AudioSource.uri(Uri.parse(_radioStream)));
    } on PlayerException catch (e) {
      print("Error loading audio source: $e");
    }
    notifyListeners();
  }

  AudioNotifier() {
    ambiguate(WidgetsBinding.instance)!.addObserver(this);
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.black,
    ));
    _initPlayer();
  }

  @override
  void dispose() {
    ambiguate(WidgetsBinding.instance)!.removeObserver(this);
    // Release decoders and buffers back to the operating system making them
    // available for other apps to use.
    _player.dispose();
    super.dispose();
  }
}

T? ambiguate<T>(T? value) => value;
