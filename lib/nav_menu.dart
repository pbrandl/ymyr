import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'package:ymyr/app_state.dart';
import 'package:ymyr/list_screen.dart';

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
    final DataNotifier dataNotifier = state.dataNotifier;

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
                  color: Colors.white,
                  border: Border.all(),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(15.0),
                    bottomLeft: Radius.circular(15.0),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      dataNotifier.category == Category.event
                          ? Icons.supervisor_account
                          : Icons.calendar_month,
                      size: 16,
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    Text(
                      dataNotifier.category != Category.event
                          ? "Events"
                          : "Artists",
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
                      builder: (context) => ListScreen(data: state.current),
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
                height: 30,
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      widget.appview != AppView.list ? Icons.list : Icons.map,
                      size: 16,
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    Text(widget.appview != AppView.list ? "List" : "Map")
                  ],
                ),
              ),
            ),
          ),
        ]));
  }
}
