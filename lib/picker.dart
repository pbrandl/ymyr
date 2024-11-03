import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ActionChipPicker extends StatefulWidget {
  final String defaultText;
  final List<String> items;
  final Function onChanged;
  final bool autofocus;
  final bool transparentBackground;
  final bool fullscreen;

  const ActionChipPicker({
    super.key,
    required this.defaultText,
    required this.items,
    required this.onChanged,
    this.autofocus = false,
    this.transparentBackground = false,
    this.fullscreen = false,
  });

  @override
  State<ActionChipPicker> createState() => ActionChipPickerState();
}

class ActionChipPickerState extends State<ActionChipPicker> {
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
    return ActionChip(
      labelPadding: EdgeInsets.zero,
      onPressed: () => _showDialog(),
      label: SizedBox(
        width: 60,
        child: Center(
          child: Text(
            overflow: TextOverflow.ellipsis,
            widget.items[_selected] == 'All'
                ? widget.defaultText
                : widget.items[_selected],
            style: const TextStyle(fontSize: 14, color: Colors.black),
          ),
        ),
      ),
    );
  }
}

class CupertinoButtonPicker extends StatefulWidget {
  final String defaultText;
  final List<String> items;
  final Function onChanged;
  final bool autofocus;
  final bool transparentBackground;
  final bool fullscreen;

  const CupertinoButtonPicker({
    super.key,
    required this.defaultText,
    required this.items,
    required this.onChanged,
    this.autofocus = false,
    this.transparentBackground = false,
    this.fullscreen = false,
  });

  @override
  State<CupertinoButtonPicker> createState() => CupertinoButtonPickerState();
}

class CupertinoButtonPickerState extends State<CupertinoButtonPicker> {
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
      child: Center(
        child: Text(
          overflow: TextOverflow.ellipsis,
          widget.items[_selected] == 'All'
              ? widget.defaultText.toUpperCase()
              : widget.items[_selected].toUpperCase(),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
