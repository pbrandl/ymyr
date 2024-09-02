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
          builder: (context) => MapScreen(),
        ),
      );
    }

    return SingleChildScrollView(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "Choose your city",
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            const SizedBox(
              height: 16,
            ),
            GestureDetector(
                onTap: () => pushCityMap(City.freiburg),
                child: const CityBox(
                  name: 'Freiburg',
                  imagePath: 'assets/images/freiburg.webp',
                )),
            const SizedBox(
              height: 16,
            ),
            GestureDetector(
                onTap: () => pushCityMap(City.stuttgart),
                child: const CityBox(
                  name: 'Stuttgart',
                  imagePath: 'assets/images/stuttgart.jpg',
                )),
            const SizedBox(
              height: 16,
            ),
            const CityBox(
              name: 'Hamburg',
              imagePath: 'assets/images/hamburg.jpg',
              isGrey: true,
            ),
            const SizedBox(
              height: 16,
            ),
            const CityBox(
              name: 'Berlin',
              imagePath: 'assets/images/berlin.jpg',
              isGrey: true,
            ),
            const SizedBox(
              height: 16,
            ),
            const CityBox(
              name: 'München',
              imagePath: 'assets/images/munich.jpg',
              isGrey: true,
            )
          ],
        ),
      ),
    );
  }
}

class CityBox extends StatelessWidget {
  final String imagePath;
  final String name;
  final bool isGrey;

  const CityBox({
    super.key,
    required this.name,
    required this.imagePath,
    this.isGrey = false,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: MouseRegion(
        cursor: isGrey ? SystemMouseCursors.basic : SystemMouseCursors.click,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20.0),
          child: Stack(
            children: [
              // Display the image with an optional color filter
              SizedBox(
                width: 250,
                height: 250,
                child: ColorFiltered(
                  colorFilter: isGrey
                      ? const ColorFilter.mode(
                          Colors.grey,
                          BlendMode.saturation,
                        )
                      : const ColorFilter.mode(
                          Colors.transparent,
                          BlendMode.multiply,
                        ),
                  child: Image.asset(
                    imagePath,
                    fit: BoxFit.cover,
                  ),
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
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
