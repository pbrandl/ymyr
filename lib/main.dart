// import 'package:flutter_map/flutter_map.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'package:ymyr/animated_icon.dart';
import 'package:ymyr/dropdowns.dart';
import 'package:ymyr/app_state.dart';
import 'package:ymyr/map.dart';
import 'package:ymyr/sidebar.dart';

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

class _HomeState extends State<Home> {
  late LocationPickerNotifier _pickerNotifier;
  late DataNotifier _dataNotifier;
  late MenuNotifier _menuNotifier;

  @override
  void initState() {
    super.initState();
    _pickerNotifier = LocationPickerNotifier();
    _pickerNotifier.addListener(_update);
    _dataNotifier = DataNotifier();
    _dataNotifier.addListener(_update);
    _menuNotifier = MenuNotifier();
    _menuNotifier.addListener(_update);
  }

  @override
  void dispose() {
    _pickerNotifier.removeListener(_update);
    _pickerNotifier.dispose();
    _dataNotifier.removeListener(_update);
    _dataNotifier.dispose();
    _menuNotifier.removeListener(_update);
    _menuNotifier.dispose();
    super.dispose();
  }

  void _update() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return AppState(
      locationPickerNotifier: _pickerNotifier,
      dataNotifier: _dataNotifier,
      menuNotifier: _menuNotifier,
      child: MaterialApp(
        title: 'YMYR',
        home: Scaffold(
          body: Stack(clipBehavior: Clip.none, children: [
            OSMFlutterMap(),
            Positioned(
              top: 20,
              right: 50,
              left: 50,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                      color: Theme.of(context).primaryColorLight,
                      width: 60,
                      child: Picker(
                        defaultText: 'Genre',
                        items: genres,
                        onChanged: (genre) => _dataNotifier.genre = genre,
                      )),
                  const SizedBox(width: 32),
                  Container(
                      color: Theme.of(context).primaryColorLight,
                      width: 60,
                      child: Picker(
                        defaultText: 'Type',
                        items: types,
                        onChanged: (type) => _dataNotifier.type = type,
                      )),
                  const SizedBox(width: 32),
                  const FintaActionChip(),
                ],
              ),
            ),
            if (_pickerNotifier.mode)
              const Positioned(
                  top: 50,
                  right: 50,
                  left: 50,
                  bottom: 50,
                  child: IconAnimation(icon: Icons.my_location)),
            if (_pickerNotifier.mode)
              const Positioned(
                right: 50,
                left: 50,
                bottom: 40,
                child: AddMenu(),
              ),
            if (_pickerNotifier.mode)
              const Positioned(
                right: 50,
                left: 50,
                top: 90,
                child: Center(child: Text("Wähle deine Location")),
              ),
            SideBarNotch(),
          ]),
          floatingActionButton: !_pickerNotifier.mode
              ? QuadMenu(
                  menuState: _menuNotifier,
                  categoryData: _dataNotifier,
                )
              : null,
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
        ),
      ),
    );
  }
}

class QuadMenu extends StatefulWidget {
  final MenuNotifier menuState;
  final DataNotifier categoryData;

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
    final state = AppState.of(context)!;
    final DataNotifier dataNotifier = state.dataNotifier;
    final view = AppState.of(context)?.menuNotifier.view;

    return SizedBox(
        width: 200,
        child: Row(children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                if (state.dataNotifier.category == Category.event) {
                  state.dataNotifier.category = Category.artist;
                } else {
                  state.dataNotifier.category = Category.event;
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
                  dataNotifier.category.toString(),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                widget.menuState.toggleView();
                if (view == AppView.map) {
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
                child: Text(view.toString()),
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
        AppState.of(context)!.dataNotifier.finta = toggle;
      },
    );
  }
}
