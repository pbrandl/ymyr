import 'dart:io';

import 'package:flutter/material.dart';
import 'package:ymyr/app_state.dart';
import 'package:ymyr/main.dart';

class LocationSelection extends StatelessWidget {
  const LocationSelection({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    void pushCityMap(City city) {
      AppState.of(context)!.locationNotifier.city = city;

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const MapScreen(),
        ),
      );
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text("Choose your city"),
          const SizedBox(
            height: 16,
          ),
          GestureDetector(
              onTap: () => pushCityMap(City.freiburg),
              child: const CityBox(
                name: 'Freiburg',
                imagePath: 'images/freiburg.webp',
              )),
          const SizedBox(
            height: 16,
          ),
          GestureDetector(
              onTap: () => pushCityMap(City.stuttgart),
              child: const CityBox(
                name: 'Stuttgart',
                imagePath: 'images/stuttgart.jpg',
              ))
        ],
      ),
    );
  }
}

class CityBox extends StatelessWidget {
  final String imagePath;
  final String name;

  const CityBox({
    super.key,
    required this.name,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20.0), //
        child: Stack(
          children: [
            // Display the image
            SizedBox(
              width: 250,
              height: 250,
              child: Image.asset(
                imagePath,
                fit: BoxFit.cover,
              ),
            ),
            // Overlay caption
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                color: Colors.black.withOpacity(0.6),
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  name,
                  style: TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
