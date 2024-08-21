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
  final TextEditingController _nameController = TextEditingController();

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
  }

  @override
  void dispose() {
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
          NameInput(
            nameController: _nameController,
            goToNextPage: _goToNextPage,
            goToPreviousPage: _goToPreviousPage,
          ),
          _buildDropdownPage(),
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
                onPressed: _goToNextPage,
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

class NameInput extends StatefulWidget {
  final TextEditingController nameController;
  final VoidCallback goToPreviousPage;
  final VoidCallback goToNextPage;

  const NameInput({
    super.key,
    required this.nameController,
    required this.goToNextPage,
    required this.goToPreviousPage,
  });

  @override
  State<NameInput> createState() => _NameInputState();
}

class _NameInputState extends State<NameInput> {
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();

    _focusNode = FocusNode();

    widget.nameController.addListener(_updateState);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_focusNode);
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    widget.nameController.removeListener(_updateState);
    super.dispose();
  }

  void _updateState() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const SizedBox(height: 32),
          TextField(
            controller: widget.nameController,
            focusNode: _focusNode,
            autofocus: true,
            decoration: InputDecoration(
              labelText: "What's your name?",
              labelStyle: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.bold),
              floatingLabelBehavior: FloatingLabelBehavior.always,
              border: InputBorder.none,
            ),
            style: const TextStyle(
              fontSize: 24.0,
            ),
            onSubmitted: (value) {
              if (value.isNotEmpty) {
                widget.goToNextPage();
              }
            },
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              FilledButton.icon(
                onPressed: widget.goToPreviousPage,
                icon: const Icon(Icons.arrow_back),
                label: const Text("Back"),
              ),
              FilledButton.icon(
                onPressed: widget.nameController.text.isNotEmpty
                    ? widget.goToNextPage
                    : null,
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
