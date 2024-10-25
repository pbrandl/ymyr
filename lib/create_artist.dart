import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'package:ymyr/app_state.dart';
import 'package:ymyr/main.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'package:ymyr/map.dart';

class CreateArtist extends StatefulWidget {
  const CreateArtist({super.key});

  @override
  State<CreateArtist> createState() => _CreateArtistState();
}

class _CreateArtistState extends State<CreateArtist> {
  late NavigatorState _navigator;

  final PageController _pageController = PageController();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _mailController = TextEditingController();

  final TextEditingController _streamLinkController = TextEditingController();

  List<String> genres = genreStringMap.values.toList();
  List<String> types = typeStringMap.values.toList();
  List<String> cities = cityStringMap.values.toList();
  late int selectedCity;
  int selectedGenre = 0;
  int selectedType = 0;
  late ParseWebFile? webImage;

  bool isUploading = false;

  Future<void> loadImageAsUint8List() async {
    ByteData byteData = await rootBundle.load('assets/images/placeholder.jpeg');

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

      if (_pageController.page?.toInt() == 4) {
        debugPrint(_pageController.page?.toInt().toString());
        if (mounted) AppState.of(context)!.mode = true;
      } else {
        debugPrint(_pageController.page?.toInt().toString());
        if (mounted) AppState.of(context)!.mode = false;
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
          debugPrint(_pageController.page?.toInt().toString());
          AppState.of(context)!.mode = false;
        } else {
          debugPrint(_pageController.page?.toInt().toString());
          AppState.of(context)!.mode = true;
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

    final artist = ParseObject('Artists')
      ..set('Name', _nameController.text)
      ..set('Link', _streamLinkController.text)
      ..set('City', cityStringMap.values.toList()[selectedCity])
      ..set('Description', 'tba')
      ..set('Genre', 'tba')
      ..set('Type', 'tba')
      ..set('Mail', _mailController.text)
      ..set('Coordinates', geoPoint)
      ..set('Image', webImage);

    final response = await artist.save();

    if (response.success) {
      return;
    } else {
      debugPrint(artist.toString());
      return Future.error('${response.error?.message}');
    }
  }

  void _uploadHandler() {
    setState(() => isUploading = true);

    uploadArtistData().then((_) {
      _goToNextPage();
    }).catchError(
      (e) {
        _showErrorDialog(e);
        setState(() => isUploading = false);
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
            headline: "Artist / Band name",
            labelText: "Please let us know what your alias is",
            nameController: _nameController,
            goToNextPage: _goToNextPage,
            goToPreviousPage: _goToPreviousPage,
          ),
          // DescriptionInput(
          //   labelText: "Description",
          //   nameController: _descController,
          //   goToNextPage: _goToNextPage,
          //   goToPreviousPage: _goToPreviousPage,
          // ),
          TextInput(
            headline: "Link to Music",
            labelText: "Please provide a valid link to your music",
            nameController: _streamLinkController,
            goToNextPage: _goToNextPage,
            goToPreviousPage: _goToPreviousPage,
          ),
          // TextInput(
          //   headline: "Pick your music scenes",
          //   labelText: "Where are you based?",
          //   nameController: _cityController,
          //   goToNextPage: _goToNextPage,
          //   goToPreviousPage: _goToPreviousPage,
          // ),
          TextInput(
            headline: "Your e-mail (not public)",
            labelText: "Please provide your mail",
            nameController: _mailController,
            goToNextPage: _goToNextPage,
            goToPreviousPage: _goToPreviousPage,
          ),
          FullscreenPicker(
            headline: "Select your city",
            desc:
                "Please select the music scene that you're from and place yourself on the map in the next step. This doesn't need to be your home address, but maybe it makes sense to place yourself in your neighborhood, or where your studio is. You're free to choose.",
            initalSelection: selectedCity,
            items: cities,
            onChanged: (int value) {
              setState(() => selectedCity = value);
              AppState.of(context)!.city = cityStringMap.keys.toList()[value];
            },
            goToPreviousPage: _goToPreviousPage,
            goToNextPage: _goToNextPage,
          ),
          // FullscreenPicker(
          //   initalSelection: selectedGenre,
          //   items: genres,
          //   onChanged: (int value) => setState(() => selectedGenre = value),
          //   goToPreviousPage: _goToPreviousPage,
          //   goToNextPage: _goToNextPage,
          // ),
          // FullscreenPicker(
          //   initalSelection: selectedType,
          //   items: types,
          //   onChanged: (value) => setState(() => selectedType = value),
          //   goToPreviousPage: () {
          //     _goToPreviousPage();
          //   },
          //   goToNextPage: _goToNextPage,
          // ),
          // ImagePickerWidget(
          //   initalImage: webImage,
          //   onImageChange: (image) => setState(
          //     () => webImage = ParseWebFile(
          //       image,
          //       name: '${_nameController.text}_image.png',
          //     ),
          //   ),
          //   goToNextPage: _goToNextPage,
          //   goToPreviousPage: _goToPreviousPage,
          // ),
          Stack(
            children: [
              const OSMFlutterMap(),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    FilledButton.icon(
                      onPressed: isUploading ? null : () => _goToPreviousPage(),
                      icon: const Icon(Icons.arrow_back),
                      label: const Text("Back"),
                    ),
                  ],
                ),
              ),
              Positioned(
                bottom: 20,
                left: 20,
                right: 20,
                child: FilledButton(
                  onPressed: isUploading ? null : () => _uploadHandler(),
                  iconAlignment: IconAlignment.end,
                  child: isUploading
                      ? CircularProgressIndicator(
                          color: Theme.of(context).primaryColor)
                      : const Text("Submit"),
                ),
              )
            ],
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

  const TextInput({
    super.key,
    required this.headline,
    required this.labelText,
    required this.nameController,
    required this.goToNextPage,
    required this.goToPreviousPage,
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
        ),
      ),
    );
  }
}

class ImagePickerWidget extends StatefulWidget {
  final Function(Uint8List?) onImageChange;
  final VoidCallback goToPreviousPage;
  final VoidCallback goToNextPage;
  final ParseWebFile? initalImage;

  const ImagePickerWidget({
    super.key,
    required this.onImageChange,
    required this.goToPreviousPage,
    required this.goToNextPage,
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
              FilledButton.icon(
                onPressed: webImage == null
                    ? null
                    : () {
                        widget.goToNextPage();
                      },
                icon: const Icon(Icons.arrow_forward),
                label: const Text("Next"),
                iconAlignment: IconAlignment.end,
              ),
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

  final String? desc;

  const FullscreenPicker({
    super.key,
    required this.items,
    required this.onChanged,
    required this.goToPreviousPage,
    required this.goToNextPage,
    required this.initalSelection,
    required this.headline,
    this.desc,
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
            height: 570,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.headline,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 16),
                if (widget.desc != null) Text(widget.desc!),
                const SizedBox(height: 16),
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
  void dispose() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const Home()),
      (Route<dynamic> route) => false,
    );
    super.dispose();
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
                  "Thank You! We’ve received your submission and will be in touch shortly regarding your artist profile. Please check your spam just in case. It might take us 1 day to get back to you."),
              const SizedBox(
                height: 32,
              ),
              Center(
                child: FilledButton(
                    onPressed: () {
                      dispose();
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
                "Get listed on YMYR",
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 16),
              const Text(
                "The YMYR artist map is an open infrastructure to makes artists and local music scenes visible and discoverable. If you are an artists and would like to list your profile on YMYR, please follow these simple steps to submit a profile request.",
              ),
              const SizedBox(height: 8),
              const Text(
                  "We will then contact you via email to complete your profile."),
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
