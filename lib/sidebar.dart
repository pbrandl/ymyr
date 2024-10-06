import 'dart:async';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:ymyr/create_artist.dart';
import 'package:ymyr/create_event.dart';
import 'package:ymyr/create_station.dart';
import 'package:ymyr/waitlist.dart';

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

  Future<void> _sendEmail() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'stefan@ymyr.world',
      query: 'subject=Waitlist Request&body=Please add me to the waitlist',
    );

    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      throw 'Could not launch $emailUri';
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
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        bottomLeft: Radius.circular(20),
                      ),
                    ),
                    child: Center(
                      child: !isSidebarOpenedAsync.data!
                          ? const Icon(Icons.chevron_left)
                          : const Icon(Icons.chevron_right),
                    )),
              ),
              Expanded(
                child: Container(
                  color: Theme.of(context).cardColor,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FilledButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const CreateArtist()),
                          );
                        },
                        child: const Text("Create Artists"),
                      ),
                      const SizedBox(height: 16),
                      FilledButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const CreateEvent()),
                          );
                        },
                        child: const Text("Create Events"),
                      ),
                      const SizedBox(height: 16),
                      FilledButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const CreateStation()),
                          );
                        },
                        child: const Text("Create Station"),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: 135,
                        child: FilledButton(
                          onPressed: () => {
                            showDialog<void>(
                              context: context,
                              barrierDismissible: false,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Center(
                                      child: Text('YMYR',
                                          style: Theme.of(context)
                                              .textTheme
                                              .headlineLarge)),
                                  content: const SingleChildScrollView(
                                    child: ListBody(
                                      children: <Widget>[
                                        Text(
                                            textAlign: TextAlign.center,
                                            'YMYR is localized music discovery network.'),
                                        SizedBox(height: 8),
                                        Text(
                                            textAlign: TextAlign.center,
                                            'Its mission is to make local music culture visible by giving unique overview of local artists, collectives and events that are shaping your neighborhoods music scene.'),
                                        SizedBox(height: 8),
                                        Text(
                                            textAlign: TextAlign.center,
                                            'In this stage we are focused on representing the Freiburg Music Scene with plans to expand further in BW, Germany and the globe.'),
                                        SizedBox(height: 8),
                                        Text(
                                            textAlign: TextAlign.center,
                                            'By offering an alternative to algorithmic music discovery, we hope to help local emerging artist gain more visibility and livening up local music scenes.'),
                                        SizedBox(height: 8),
                                        Text(
                                            textAlign: TextAlign.center,
                                            'If you are intersted in what is next for YMYR and want to support us by testing new versions of our service, please sign up to the waitlist by leaving your email.'),
                                        SizedBox(height: 8),
                                        Text(
                                            textAlign: TextAlign.center,
                                            'We will contact you as soon as there is a new version to explore.'),
                                        SizedBox(height: 8),
                                        Text(
                                            textAlign: TextAlign.center,
                                            'Cheers!')
                                      ],
                                    ),
                                  ),
                                  actions: <Widget>[
                                    FilledButton(
                                      child: const Text('Contact'),
                                      onPressed: () {
                                        _sendEmail(); // Send an email on click
                                      },
                                    ),
                                    FilledButton(
                                      child: const Text('Join Waitlist'),
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const Waitlist(),
                                          ),
                                        );
                                      },
                                    ),
                                    FilledButton(
                                      child: const Text('Close'),
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                    ),
                                  ],
                                );
                              },
                            )
                          },
                          child: const Text("About"),
                        ),
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
