import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Dropdown extends StatefulWidget {
  final String hintText;
  final List<String> dropdownOptions;

  const Dropdown(
      {super.key, required this.hintText, required this.dropdownOptions});

  @override
  DropdownState createState() => DropdownState();
}

class DropdownState extends State<Dropdown> {
  String? selectedGenre;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(50.0),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        child: DropdownButton<String>(
          value: null,
          hint: Text(widget.hintText),
          items: widget.dropdownOptions
              .map<DropdownMenuItem<String>>((String genre) {
            return DropdownMenuItem<String>(
              value: genre,
              child: SizedBox(
                  width: 80,
                  child: Text(
                    genre,
                    overflow: TextOverflow.ellipsis,
                  )),
            );
          }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              selectedGenre = newValue;
            });
          },
          underline: SizedBox(), // Removes the default underline
        ),
      ),
    );
  }
}

class Picker extends StatefulWidget {
  final String defaultText;
  final List<String> items;
  final Function onChanged;
  final bool autofocus;
  final bool transparentBackground;
  final bool fullscreen;

  const Picker({
    super.key,
    required this.defaultText,
    required this.items,
    required this.onChanged,
    this.autofocus = false,
    this.transparentBackground = false,
    this.fullscreen = false,
  });

  @override
  State<Picker> createState() => PickerState();
}

class PickerState extends State<Picker> {
  int _selected = 0;

  @override
  void initState() {
    super.initState();

    if (widget.autofocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showDialog();
      });
    }
  }

  // This shows a CupertinoModalPopup with a reasonable fixed height which hosts CupertinoPicker.
  void _showDialog() {
    showCupertinoModalPopup<void>(
      context: context,
      barrierColor:
          widget.transparentBackground ? Colors.transparent : Colors.black12,
      builder: (BuildContext context) => Container(
        height: widget.fullscreen == false ? 275 : null,
        padding: const EdgeInsets.only(top: 6.0),
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        color: CupertinoColors.systemBackground.resolveFrom(context),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Expanded(
                child: CupertinoPicker(
                  magnification: 1,
                  squeeze: 1.3,
                  useMagnifier: true,
                  itemExtent: 30,
                  scrollController: FixedExtentScrollController(
                    initialItem: _selected,
                  ),
                  onSelectedItemChanged: (int selectedItem) {
                    setState(() {
                      _selected = selectedItem;
                    });
                    widget.onChanged(widget.items[_selected]);
                  },
                  children:
                      List<Widget>.generate(widget.items.length, (int index) {
                    return Center(child: Text(widget.items[index]));
                  }),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: () => _showDialog(),
      // This displays the selected name or default if 'All' selected
      child: Text(
        overflow: TextOverflow.ellipsis,
        widget.items[_selected] == 'All'
            ? widget.defaultText
            : widget.items[_selected],
      ),
    );
  }
}

class FullscreenPicker extends StatefulWidget {
  final String defaultText;
  final List<String> items;
  final Function onChanged;
  final VoidCallback goToPreviousPage;
  final VoidCallback goToNextPage;

  const FullscreenPicker({
    super.key,
    required this.defaultText,
    required this.items,
    required this.onChanged,
    required this.goToPreviousPage,
    required this.goToNextPage,
  });

  @override
  State<FullscreenPicker> createState() => FullscreenPickerState();
}

class FullscreenPickerState extends State<FullscreenPicker> {
  int _selected = 0;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showDialog();
    });
  }

  @override
  void dispose() {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
    super.dispose();
  }

  // This shows a CupertinoModalPopup with a reasonable fixed height which hosts CupertinoPicker.
  void _showDialog() {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => Container(
        height: null,
        padding: const EdgeInsets.only(top: 6.0),
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        color: CupertinoColors.systemBackground.resolveFrom(context),
        child: SafeArea(
          top: false,
          child: Stack(
            children: [
              Expanded(
                child: CupertinoPicker(
                  magnification: 1,
                  squeeze: 1.3,
                  useMagnifier: true,
                  itemExtent: 30,
                  scrollController: FixedExtentScrollController(
                    initialItem: _selected,
                  ),
                  onSelectedItemChanged: (int selectedItem) {
                    setState(() {
                      _selected = selectedItem;
                    });
                    widget.onChanged(widget.items[_selected]);
                  },
                  children:
                      List<Widget>.generate(widget.items.length, (int index) {
                    return Center(child: Text(widget.items[index]));
                  }),
                ),
              ),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    FilledButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        widget.goToPreviousPage();
                      },
                      icon: const Icon(Icons.arrow_back),
                      label: const Text("Back"),
                    ),
                    FilledButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        widget.goToNextPage();
                      },
                      icon: const Icon(Icons.arrow_forward),
                      label: const Text("Next"),
                      iconAlignment: IconAlignment.end,
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: () => _showDialog(),
      // This displays the selected name or default if 'All' selected
      child: Text(
        overflow: TextOverflow.ellipsis,
        widget.items[_selected] == 'All'
            ? widget.defaultText
            : widget.items[_selected],
      ),
    );
  }
}
