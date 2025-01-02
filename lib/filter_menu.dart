import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'package:ymyr/app_state.dart';
import 'package:ymyr/list_screen.dart';
import 'package:ymyr/main.dart';
import 'package:ymyr/picker.dart';

class NavMenu extends StatefulWidget {
  final AppView appview;

  const NavMenu({
    super.key,
    required this.appview,
  });

  @override
  State<NavMenu> createState() => _NavMenuState();
}

class _NavMenuState extends State<NavMenu> {
  late List<ParseObject> data = [];

  bool filterOn = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final state = AppState.of(context)!;
    state.dataNotifier.addListener(update);
    state.menuNotifier.addListener(update);
  }

  @override
  void dispose() {
    final state = AppState.of(context);
    if (state != null) {
      state.dataNotifier.removeListener(update);
      state.menuNotifier.removeListener(update);
    }
    super.dispose();
  }

  void update() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final state = AppState.of(context)!;

    return Positioned(
      bottom: 20,
      left: 0,
      right: 0,
      child: Column(
        children: [
          if (filterOn)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Picker(
                  defaultText: AppState.of(context)!.dataNotifier.genre == 'All'
                      ? 'Genre'
                      : AppState.of(context)!.dataNotifier.genre,
                  items: ['All'] + genreStringMap.values.toList(),
                  onChanged: (genre) =>
                      AppState.of(context)!.dataNotifier.genre = genre,
                ),
                if (AppState.of(context)!.dataNotifier.category ==
                    Category.artist)
                  const SizedBox(width: 24),
                if (AppState.of(context)!.dataNotifier.category ==
                    Category.artist)
                  Picker(
                    defaultText:
                        AppState.of(context)!.dataNotifier.type == 'All'
                            ? 'Type'
                            : AppState.of(context)!.dataNotifier.type,
                    items: ['All'] + typeStringMap.values.toList(),
                    onChanged: (type) =>
                        AppState.of(context)!.dataNotifier.type = type,
                  ),
                if (AppState.of(context)!.dataNotifier.category ==
                    Category.artist)
                  const SizedBox(width: 24),
                if (AppState.of(context)!.dataNotifier.category ==
                    Category.artist)
                  const FintaActionChip(),
              ],
            ),
          const SizedBox(height: 8),
          Center(
            child: SizedBox(
                width: 240,
                child:
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          filterOn = !filterOn;
                        });
                      },
                      child: Container(
                        height: 40,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: AppState.of(context)!.dataNotifier.type !=
                                      'All' ||
                                  AppState.of(context)!.dataNotifier.genre !=
                                      'All' ||
                                  AppState.of(context)!.dataNotifier.finta !=
                                      false
                              ? const Color.fromRGBO(193, 255, 114, 1)
                              : Colors.white,
                          border: Border.all(),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(15.0),
                            bottomLeft: Radius.circular(15.0),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.filter_alt,
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              "Filter",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(width: 8),
                            if (AppState.of(context)!.dataNotifier.type !=
                                    'All' ||
                                AppState.of(context)!.dataNotifier.genre !=
                                    'All' ||
                                AppState.of(context)!.dataNotifier.finta !=
                                    false)
                              IconButton.outlined(
                                constraints: const BoxConstraints(
                                  minWidth: 18,
                                  minHeight: 18,
                                ),
                                padding: const EdgeInsets.all(0),
                                iconSize: 16,
                                icon: const Icon(
                                  Icons.close,
                                ),
                                onPressed: () {
                                  AppState.of(context)!.dataNotifier.type =
                                      'All';
                                  AppState.of(context)!.dataNotifier.genre =
                                      'All';
                                  AppState.of(context)!.dataNotifier.finta =
                                      false;
                                  setState(() {
                                    filterOn = !filterOn;
                                  });
                                },
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        if (widget.appview != AppView.list) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ListScreen(data: state.current),
                            ),
                          );
                        } else {
                          Navigator.pop(context);
                        }
                      },
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          border: Border(
                            top: BorderSide(color: Colors.black),
                            bottom: BorderSide(color: Colors.black),
                            right: BorderSide(color: Colors.black),
                          ),
                          borderRadius: BorderRadius.only(
                            bottomRight: Radius.circular(15.0),
                            topRight: Radius.circular(15.0),
                          ),
                        ),
                        height: 40,
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              widget.appview != AppView.list
                                  ? Icons.list
                                  : Icons.map,
                              size: 16,
                            ),
                            const SizedBox(
                              width: 8,
                            ),
                            Text(
                              widget.appview != AppView.list ? "List" : "Map",
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ])),
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
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final state = AppState.of(context)!;
    state.dataNotifier.addListener(update);
  }

  @override
  void dispose() {
    final state = AppState.of(context);
    if (state != null) {
      state.dataNotifier.removeListener(update);
    }
    super.dispose();
  }

  void update() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      clipBehavior: Clip.antiAlias,
      labelPadding: EdgeInsets.zero,
      padding: EdgeInsets.zero,
      onPressed: () {
        AppState.of(context)!.dataNotifier.finta =
            !AppState.of(context)!.dataNotifier.finta;
      },
      label: Container(
        width: 76,
        height: 36,
        decoration: BoxDecoration(
            color: !AppState.of(context)!.dataNotifier.finta
                ? Colors.transparent
                : Theme.of(context).primaryColor),
        child: Center(
          child: Text(
            'Finta',
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 14,
              color: !AppState.of(context)!.dataNotifier.finta
                  ? Colors.black
                  : Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
