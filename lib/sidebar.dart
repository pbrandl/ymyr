import 'dart:async';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

class SideBarNotch extends StatefulWidget {
  const SideBarNotch({super.key});

  @override
  State<SideBarNotch> createState() => _SideBarNotchState();
}

class _SideBarNotchState extends State<SideBarNotch>
    with SingleTickerProviderStateMixin {
  late StreamController<bool> isSideBarOpenedStreamController;
  late AnimationController _animationController;
  late Stream<bool> isSideBarOpenedStream;
  late StreamSink<bool> isSideBarOpenedSink;
  final _animationDuration = const Duration(milliseconds: 300);

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: _animationDuration,
    );
    isSideBarOpenedStreamController = PublishSubject<bool>();
    isSideBarOpenedStream = isSideBarOpenedStreamController.stream;
    isSideBarOpenedSink = isSideBarOpenedStreamController.sink;
  }

  @override
  void dispose() {
    isSideBarOpenedSink.close();
    isSideBarOpenedStreamController.close();
    _animationController.dispose();
    super.dispose();
  }

  void onNotchTapped() {
    final animationStatus = _animationController.status;
    final isAnimationCompleted = animationStatus == AnimationStatus.completed;

    if (isAnimationCompleted) {
      isSideBarOpenedSink.add(false);
      _animationController.reverse();
    } else {
      isSideBarOpenedSink.add(true);
      _animationController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return StreamBuilder<bool>(
      initialData: false,
      stream: isSideBarOpenedStream,
      builder: (context, isSidebarOpenedAsync) {
        return AnimatedPositioned(
          duration: _animationDuration,
          top: 0,
          bottom: 0,
          left: isSidebarOpenedAsync.data! ? 0 : screenWidth - 40,
          right: isSidebarOpenedAsync.data! ? 0 : -screenWidth,
          child: Row(
            children: [
              GestureDetector(
                onTap: onNotchTapped,
                child: Container(
                  width: 40,
                  height: 110,
                  color: Theme.of(context).primaryColorLight,
                  child: Center(
                    child: AnimatedIcon(
                      icon: AnimatedIcons.menu_close,
                      progress: _animationController.view,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  color: Theme.of(context).canvasColor,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FilledButton(
                        onPressed: () => {},
                        child: Text("Create Artists"),
                      ),
                      const SizedBox(height: 16),
                      FilledButton(
                        onPressed: () => {},
                        child: Text("Create Events"),
                      ),
                      const SizedBox(height: 16),
                      FilledButton(
                        onPressed: () => {
                          showAboutDialog(
                              applicationIcon: Icon(Icons.yard),
                              applicationName: "YMYR",
                              applicationVersion: "0.1",
                              children: [
                                Text(
                                    "YMYR TextLorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet. Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet.")
                              ],
                              context: context)
                        },
                        child: Text("About"),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
