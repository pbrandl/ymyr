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

  const Picker(
      {super.key,
      required this.defaultText,
      required this.items,
      required this.onChanged});

  @override
  State<Picker> createState() => PickerState();
}

class PickerState extends State<Picker> {
  int _selected = 0;

  // This shows a CupertinoModalPopup with a reasonable fixed height which hosts CupertinoPicker.
  void _showDialog(Widget child) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => Container(
        height: 216,
        padding: const EdgeInsets.only(top: 6.0),
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        color: CupertinoColors.systemBackground.resolveFrom(context),
        child: SafeArea(
          top: false,
          child: child,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: () => _showDialog(
        CupertinoPicker(
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
          children: List<Widget>.generate(widget.items.length, (int index) {
            return Center(child: Text(widget.items[index]));
          }),
        ),
      ),
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
