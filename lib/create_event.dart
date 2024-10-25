import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:ymyr/app_state.dart';
import 'package:ymyr/main.dart';
import 'package:ymyr/map.dart';

class CreateEvent extends StatefulWidget {
  const CreateEvent({super.key});

  @override
  State<CreateEvent> createState() => _CreateEventState();
}

class _CreateEventState extends State<CreateEvent> {
  final PageController _pageController = PageController();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _eventLinkController = TextEditingController();
  final TextEditingController _mailController = TextEditingController();

  List<String> cities = cityStringMap.values.toList();
  late int selectedCity;

  ParseWebFile? webImage;

  bool isUploading = false;

  Future<void> loadImageAsUint8List() async {
    ByteData byteData = await rootBundle.load('images/placeholder.jpeg');

    setState(() {
      webImage =
          ParseWebFile(byteData.buffer.asUint8List(), name: 'placeholder.jpeg');
    });
  }

  @override
  void initState() {
    super.initState();
    loadImageAsUint8List();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    selectedCity =
        cityStringMap.keys.toList().indexOf(AppState.of(context)!.city);
  }

  void _goToNextPage() {
    if (_pageController.hasClients) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeIn,
      );

      if (_pageController.page?.toInt() == 3) {
        AppState.of(context)!.mode = true;
      }
    }
  }

  void _goToPreviousPage() {
    if (_pageController.hasClients) {
      final currentPage = _pageController.page?.toInt() ?? 0;
      if (currentPage == 0) {
        AppState.of(context)!.mode = false;
        Navigator.pop(context);
      } else {
        _pageController.previousPage(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeIn,
        );

        if (_pageController.page?.toInt() != 4) {
          AppState.of(context)!.mode = false;
        }
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> uploadArtistData() async {
    LatLng? coord = AppState.of(context)!.locationNotifier.center;
    ParseGeoPoint geoPoint =
        ParseGeoPoint(latitude: coord.latitude, longitude: coord.longitude);

    DateTime selectedDate = DateTime.parse(_dateController.text);

    final event = ParseObject('Events')
      ..set('Name', _nameController.text)
      ..set('City', cityStringMap.values.toList()[selectedCity])
      ..set('Start', selectedDate)
      ..set('Description',
          _descController.text.isEmpty ? "tba" : _descController.text)
      // ..set('Coordinates', geoPoint)
      ..set('Mail', _mailController.text)
      ..set('Finta', false)
      ..set('Image', webImage);

    final response = await event.save();

    if (response.success) {
      return;
    } else {
      return Future.error('${response.error?.message}');
    }
  }

  void _uploadHandler() {
    setState(() => isUploading = true);

    uploadArtistData().then((_) {
      _goToNextPage();
    }).catchError(
      (e) {
        setState(() => isUploading = false);
        _showErrorDialog(e);
      },
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          Info(
            goToNextPage: _goToNextPage,
            goToPreviousPage: _goToPreviousPage,
          ),
          TextInput(
            headline: "Event Name",
            labelText: "Please let us know what your event will be called",
            nameController: _nameController,
            goToNextPage: _goToNextPage,
            goToPreviousPage: _goToPreviousPage,
          ),
          FullscreenPicker(
            headline: "Select your city",
            initalSelection: selectedCity,
            items: cities,
            onChanged: (int value) {
              setState(() => selectedCity = value);
            },
            goToPreviousPage: _goToPreviousPage,
            goToNextPage: _goToNextPage,
          ),
          CalendarPicker(
            dateController: _dateController,
            goToNextPage: _goToNextPage,
            goToPreviousPage: _goToPreviousPage,
          ),
          DescriptionInput(
            labelText: "Description (optional)",
            nameController: _descController,
            goToNextPage: _goToNextPage,
            goToPreviousPage: _goToPreviousPage,
          ),
          TextInput(
            headline: "Link (optional)",
            labelText: "Is there already a link to your event?",
            nameController: _eventLinkController,
            goToNextPage: _goToNextPage,
            goToPreviousPage: _goToPreviousPage,
            optional: true,
          ),
          TextInput(
            headline: "Your e-mail (not public)",
            labelText: "Please let us know how to contact you",
            nameController: _mailController,
            goToNextPage: _goToNextPage,
            goToPreviousPage: _goToPreviousPage,
          ),
          ImagePickerWidget(
            initalImage: webImage,
            onImageChange: (image) => setState(
              () => webImage = ParseWebFile(
                image,
                name: 'image.png',
              ),
            ),
            goToNextPageButton: FilledButton.icon(
              onPressed: isUploading
                  ? null
                  : () {
                      _uploadHandler();
                    },
              icon: const Icon(Icons.arrow_forward),
              label: isUploading
                  ? const Padding(
                      padding: EdgeInsets.all(4.0),
                      child: SizedBox(
                          height: 8,
                          width: 8,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          )),
                    )
                  : const Text("Submit"),
              iconAlignment: IconAlignment.end,
            ),
            goToPreviousPage: _goToPreviousPage,
          ),
          const SuccessScreen(message: "Success!")
        ],
      ),
    );
  }
}

class TextInput extends StatefulWidget {
  final String headline;
  final String labelText;
  final TextEditingController nameController;
  final VoidCallback goToPreviousPage;
  final VoidCallback goToNextPage;
  final bool optional;

  const TextInput({
    super.key,
    required this.headline,
    required this.labelText,
    required this.nameController,
    required this.goToNextPage,
    required this.goToPreviousPage,
    this.optional = false,
  });

  @override
  State<TextInput> createState() => _TextInputState();
}

class _TextInputState extends State<TextInput> {
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
    return Center(
      child: SizedBox(
        width: 400,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.headline,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 32),
              TextField(
                controller: widget.nameController,
                focusNode: _focusNode,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: widget.labelText,
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
                    onPressed:
                        widget.nameController.text.isNotEmpty || widget.optional
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
        ),
      ),
    );
  }
}

class ImagePickerWidget extends StatefulWidget {
  final Function(Uint8List?) onImageChange;
  final VoidCallback goToPreviousPage;
  final ParseWebFile? initalImage;
  final Widget goToNextPageButton;

  const ImagePickerWidget({
    super.key,
    required this.onImageChange,
    required this.goToPreviousPage,
    required this.goToNextPageButton,
    this.initalImage,
  });

  @override
  ImagePickerWidgetState createState() => ImagePickerWidgetState();
}

class ImagePickerWidgetState extends State<ImagePickerWidget> {
  Uint8List? webImage;

  @override
  void initState() {
    super.initState();
    webImage = widget.initalImage?.file;
  }

  Future<void> _pickImage() async {
    if (kIsWeb) {
      final ImagePicker picker = ImagePicker();
      XFile? image = await picker.pickImage(source: ImageSource.gallery);

      if (image != null) {
        var f = await image.readAsBytes();
        setState(() => webImage = f);
        widget.onImageChange(f);
      }
    } else {
      debugPrint("This platform is not web");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              webImage != null
                  ? Image.memory(
                      webImage!,
                      width: 200,
                      height: 200,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      width: 200,
                      height: 200,
                      color: Colors.grey[200],
                      child: Icon(
                        Icons.image,
                        size: 50,
                        color: Colors.grey[400],
                      ),
                    ),
              const SizedBox(height: 16),
              TextButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.upload_file),
                label: const Text("Upload Image"),
              ),
            ],
          ),
        ),
        Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              FilledButton.icon(
                onPressed: () {
                  widget.goToPreviousPage();
                },
                icon: const Icon(Icons.arrow_back),
                label: const Text("Back"),
              ),
              widget.goToNextPageButton
            ],
          ),
        ),
      ],
    );
  }
}

class FullscreenPicker extends StatefulWidget {
  final int initalSelection;
  final List<String> items;
  final Function(int) onChanged;
  final Function goToPreviousPage;
  final Function goToNextPage;

  final String headline;

  const FullscreenPicker({
    super.key,
    required this.items,
    required this.onChanged,
    required this.goToPreviousPage,
    required this.goToNextPage,
    required this.initalSelection,
    required this.headline,
  });

  @override
  State<FullscreenPicker> createState() => FullscreenPickerState();
}

class FullscreenPickerState extends State<FullscreenPicker> {
  late int _selected;

  @override
  void initState() {
    super.initState();

    _selected = widget.initalSelection;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Center(
          child: SizedBox(
            width: 400,
            height: 450,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.headline,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                SizedBox(
                  height: 400,
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
                      widget.onChanged(_selected);
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
        Center(
          child: SizedBox(
            width: 400,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                FilledButton.icon(
                  onPressed: () {
                    widget.goToPreviousPage();
                  },
                  icon: const Icon(Icons.arrow_back),
                  label: const Text("Back"),
                ),
                FilledButton.icon(
                  onPressed: () {
                    widget.goToNextPage();
                  },
                  icon: const Icon(Icons.arrow_forward),
                  label: const Text("Next"),
                  iconAlignment: IconAlignment.end,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class SuccessScreen extends StatefulWidget {
  final String message;

  const SuccessScreen({super.key, required this.message});

  @override
  SuccessScreenState createState() => SuccessScreenState();
}

class SuccessScreenState extends State<SuccessScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SizedBox(
          width: 400,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.check_circle_outline,
                  size: 44, color: Colors.green),
              const SizedBox(
                height: 16,
              ),
              Text(
                widget.message,
                style: Theme.of(context).textTheme.headlineLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(
                height: 16,
              ),
              const Text(
                  "Thank You! We’ve received your submission and will be in touch shortly regarding your event. Pls check your spam just in case. It might take us 1 day to get back to you."),
              const SizedBox(
                height: 32,
              ),
              Center(
                child: FilledButton(
                    onPressed: () {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (context) => const Home()),
                        (Route<dynamic> route) => false,
                      );
                    },
                    child: const Text("Home")),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class DescriptionInput extends StatefulWidget {
  final String labelText;
  final TextEditingController nameController;
  final VoidCallback goToPreviousPage;
  final VoidCallback goToNextPage;

  const DescriptionInput({
    super.key,
    required this.labelText,
    required this.nameController,
    required this.goToNextPage,
    required this.goToPreviousPage,
  });

  @override
  State<DescriptionInput> createState() => _DescriptionInputState();
}

class _DescriptionInputState extends State<DescriptionInput> {
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
            minLines: 4,
            maxLines: 4,
            maxLength: 140,
            controller: widget.nameController,
            focusNode: _focusNode,
            autofocus: true,
            keyboardType: TextInputType.multiline,
            decoration: InputDecoration(
                labelText: widget.labelText,
                labelStyle: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold),
                floatingLabelBehavior: FloatingLabelBehavior.always,
                border: OutlineInputBorder()),
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
                onPressed: widget.goToNextPage,
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

class CalendarPicker extends StatefulWidget {
  final TextEditingController dateController;

  final VoidCallback goToPreviousPage;
  final VoidCallback goToNextPage;

  const CalendarPicker({
    super.key,
    required this.dateController,
    required this.goToPreviousPage,
    required this.goToNextPage,
  });

  @override
  CalendarPickerState createState() => CalendarPickerState();
}

class CalendarPickerState extends State<CalendarPicker> {
  DateTime _selectedDate = DateTime.now();
  TimeOfDay? selectedTime;

  @override
  void initState() {
    super.initState();
    widget.dateController.text = _selectedDate
        .toString()
        .substring(0, 10); // Initialize with current date
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      hourLabelText: "Hour",
      minuteLabelText: "Minute",
      context: context,
      initialTime: const TimeOfDay(hour: 0, minute: 0),
    );
    if (picked != null && picked != selectedTime) {
      setState(() {
        selectedTime = picked;
        String formattedTime =
            "${selectedTime!.hour.toString().padLeft(2, '0')}:${selectedTime!.minute.toString().padLeft(2, '0')}";

        widget.dateController.text =
            "${_selectedDate.toString().substring(0, 10)} $formattedTime";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 400,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Date & Time",
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 16),
                  TableCalendar(
                    focusedDay: _selectedDate,
                    firstDay: DateTime(2000),
                    lastDay: DateTime(2100),
                    calendarFormat: CalendarFormat.month,
                    selectedDayPredicate: (day) {
                      return isSameDay(_selectedDate, day);
                    },
                    availableCalendarFormats: const {
                      CalendarFormat.month: 'Month',
                    },
                    onDaySelected: (selectedDay, focusedDay) {
                      setState(() {
                        _selectedDate = selectedDay;
                        widget.dateController.text = selectedDay.toString();
                      });
                    },
                  ),
                  FilledButton.icon(
                    icon: const Icon(Icons.timer),
                    onPressed: () => _selectTime(context),
                    label: Text(selectedTime == null
                        ? "Starting Time"
                        : "${selectedTime!.hourOfPeriod == 0 ? 12 : selectedTime!.hourOfPeriod}:${selectedTime!.minute.toString().padLeft(2, '0')} ${selectedTime!.period == DayPeriod.am ? 'AM' : 'PM'}"),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      FilledButton.icon(
                        onPressed: widget.goToPreviousPage,
                        icon: const Icon(Icons.arrow_back),
                        label: const Text("Back"),
                      ),
                      FilledButton.icon(
                        onPressed: widget.dateController.text.isNotEmpty &&
                                selectedTime != null
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
            ),
          ),
        ],
      ),
    );
  }
}

class Info extends StatelessWidget {
  final void Function() goToNextPage;

  final void Function() goToPreviousPage;

  const Info(
      {super.key, required this.goToNextPage, required this.goToPreviousPage});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 400,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Text(
                "Music Events on YMYR",
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 16),
              const Text(
                "The YMYR event map is an open infrastructure that makes music events in your music scene visible. To add your event to the calendar, please follow these simple steps.",
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  FilledButton.icon(
                    onPressed: goToPreviousPage,
                    icon: const Icon(Icons.arrow_back),
                    label: const Text("Back"),
                  ),
                  FilledButton.icon(
                    onPressed: goToNextPage,
                    icon: const Icon(Icons.arrow_forward),
                    label: const Text("Next"),
                    iconAlignment: IconAlignment.end,
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
