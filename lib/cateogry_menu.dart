import 'package:flutter/material.dart';
import 'package:ymyr/app_state.dart';
import 'package:ymyr/picker.dart';
import 'package:intl/intl.dart';

class CateogryMenu extends StatefulWidget {
  const CateogryMenu({super.key});

  @override
  State<CateogryMenu> createState() => _CateogryMenuState();
}

class _CateogryMenuState extends State<CateogryMenu> {
  bool toggle = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    AppState.of(context)!.dataNotifier.addListener(_updateState);
  }

  void _updateState() {
    setState(() {});
  }

  @override
  void dispose() {
    AppState.of(context)!.dataNotifier.removeListener(_updateState);
    super.dispose();
  }

  final DateFormat dateFormatter = DateFormat('dd-MM-yyyy');

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ActionChip(
              clipBehavior: Clip.antiAlias,
              labelPadding: EdgeInsets.zero,
              padding: EdgeInsets.zero,
              onPressed: () {
                AppState.of(context)!.dataNotifier.category = Category.artist;
              },
              label: Container(
                width: 76,
                height: 36,
                decoration: BoxDecoration(
                  color: AppState.of(context)!.dataNotifier.category !=
                          Category.artist
                      ? Colors.transparent
                      : const Color.fromRGBO(193, 255, 114, 1),
                ),
                child: Center(
                  child: Text(
                    'Artist',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      color: !toggle ? Colors.black : Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            ActionChip(
              clipBehavior: Clip.antiAlias,
              labelPadding: EdgeInsets.zero,
              padding: EdgeInsets.zero,
              onPressed: () {
                AppState.of(context)!.dataNotifier.category = Category.event;
              },
              label: Container(
                width: 76,
                height: 36,
                decoration: BoxDecoration(
                  color: AppState.of(context)!.dataNotifier.category !=
                          Category.event
                      ? Colors.transparent
                      : const Color.fromRGBO(193, 255, 114, 1),
                ),
                child: Center(
                  child: Text(
                    'Events',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      color: !toggle ? Colors.black : Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            ActionChip(
              clipBehavior: Clip.antiAlias,
              labelPadding: EdgeInsets.zero,
              padding: EdgeInsets.zero,
              onPressed: () {
                AppState.of(context)!.dataNotifier.category = Category.station;
              },
              label: Container(
                width: 76,
                height: 36,
                decoration: BoxDecoration(
                  color: AppState.of(context)!.dataNotifier.category !=
                          Category.station
                      ? Colors.transparent
                      : const Color.fromRGBO(193, 255, 114, 1),
                ),
                child: Center(
                  child: Text(
                    'Radios',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      color: !toggle ? Colors.black : Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 8,
        ),
        if (AppState.of(context)!.dataNotifier.category == Category.event)
          CupertinoButtonPicker(
              defaultText: 'Dates',
              items: ['All'] +
                  AppState.of(context)!.dataNotifier.events.map((event) {
                    DateTime startDate = event.get('Start') as DateTime;
                    return dateFormatter.format(startDate);
                  }).toList(),
              onChanged: (date) =>
                  {AppState.of(context)!.dataNotifier.filterEventByDate(date)})
      ],
    );
  }
}
