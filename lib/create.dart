import 'package:flutter/material.dart';
import 'package:ymyr/app_state.dart';
import 'package:ymyr/dropdowns.dart';

class Create extends StatefulWidget {
  const Create({super.key});

  @override
  State<Create> createState() => _CreateState();
}

class _CreateState extends State<Create> {
  final PageController _pageController = PageController();
  final FocusNode _focusNode = FocusNode();

  String name = "";
  String selectedGenre = "";

  void _goToNextPage() {
    if (_pageController.hasClients) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _goToPreviousPage() {
    if (_pageController.hasClients) {
      if (_pageController.page == 0) {
        Navigator.pop(context);
      } else {
        _pageController.previousPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    // Request focus after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_focusNode);
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          _buildNamePage(),
          _buildDropdownPage(),
        ],
      ),
    );
  }

  Widget _buildNamePage() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const SizedBox(height: 32),
          TextField(
            focusNode: _focusNode,
            autofocus: true,
            decoration: InputDecoration(
              labelText: "What's your name?",
              labelStyle: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.bold),
              floatingLabelBehavior:
                  FloatingLabelBehavior.always, // Label hovers all the time
              border: InputBorder.none, // No border around the TextField
            ),
            style: const TextStyle(
              fontSize: 24.0,
            ),
            onChanged: (value) {
              setState(() {
                name = value;
              });
            },
            onSubmitted: (value) {
              if (value.isNotEmpty) {
                _goToNextPage();
              }
            },
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              FilledButton.icon(
                onPressed: _goToPreviousPage,
                icon: const Icon(Icons.arrow_back),
                label: const Text("Back"),
              ),
              FilledButton.icon(
                onPressed: name.isNotEmpty ? _goToNextPage : null,
                icon: const Icon(Icons.arrow_forward),
                label: const Text("Next"),
                iconAlignment: IconAlignment.end,
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildDropdownPage() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("My genre: "),
              Picker(
                defaultText: 'Genre',
                items: genres.sublist(1),
                onChanged: (genre) => selectedGenre = genre,
                autofocus: true,
                transparentBackground: true,
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              FilledButton.icon(
                onPressed: _goToPreviousPage,
                icon: const Icon(Icons.arrow_back),
                label: const Text("Back"),
              ),
              FilledButton.icon(
                onPressed: name.isNotEmpty ? _goToNextPage : null,
                icon: const Icon(Icons.arrow_forward),
                label: const Text("Next"),
                iconAlignment: IconAlignment.end,
              ),
            ],
          )
        ],
      ),
    );
  }
}
