import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'package:ymyr/app_state.dart';
import 'package:ymyr/main.dart';

class Waitlist extends StatefulWidget {
  const Waitlist({super.key});

  @override
  State<Waitlist> createState() => _WaitlistState();
}

class _WaitlistState extends State<Waitlist> {
  final PageController _pageController = PageController();

  final TextEditingController _mailController = TextEditingController();

  bool isUploading = false;

  void _goToNextPage() {
    if (_pageController.hasClients) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeIn,
      );
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
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> uploadWaitlistData() async {
    final bool emailValid = RegExp(
            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(_mailController.text);

    if (!emailValid) {
      return Future.error('Mail not valid!');
    }

    final waitlist = ParseObject('Waitlist')..set('Mail', _mailController.text);

    final response = await waitlist.save();

    if (response.success) {
      return;
    } else {
      debugPrint(waitlist.toString());
      return Future.error('${response.error?.message}');
    }
  }

  void _uploadHandler() {
    setState(() => isUploading = true);

    uploadWaitlistData().then((_) {
      _goToNextPage();
    }).catchError(
      (e) => _showErrorDialog(e),
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
          MailInput(
            mailController: _mailController,
            goToNextPage: _uploadHandler,
            goToPreviousPage: _goToPreviousPage,
          ),
          const SuccessScreen(message: "Success")
        ],
      ),
    );
  }
}

class MailInput extends StatefulWidget {
  final TextEditingController mailController;
  final VoidCallback goToPreviousPage;
  final VoidCallback goToNextPage;

  const MailInput({
    super.key,
    required this.mailController,
    required this.goToNextPage,
    required this.goToPreviousPage,
  });

  @override
  State<MailInput> createState() => _MailInputState();
}

class _MailInputState extends State<MailInput> {
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();

    _focusNode = FocusNode();

    widget.mailController.addListener(_updateState);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_focusNode);
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    widget.mailController.removeListener(_updateState);
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
          const Text(
              "Happy to see you're interested in supporting YMYR. Please leave your mail and we'll be in touch shortly!"),
          const SizedBox(height: 32),
          TextField(
            controller: widget.mailController,
            focusNode: _focusNode,
            autofocus: true,
            decoration: InputDecoration(
              labelText: "What's your mail?",
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
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              FilledButton.icon(
                onPressed: widget.goToPreviousPage,
                icon: const Icon(Icons.arrow_back),
                label: const Text("Back"),
              ),
              FilledButton.icon(
                onPressed: widget.mailController.text.isNotEmpty
                    ? widget.goToNextPage
                    : null,
                icon: const Icon(Icons.arrow_forward),
                label: const Text("Submit"),
                iconAlignment: IconAlignment.end,
              ),
            ],
          )
        ],
      ),
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

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const Home()),
          (Route<dynamic> route) => false,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green,
      body: Center(
        child: Text(
          widget.message,
          style: const TextStyle(fontSize: 24.0, color: Colors.white),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
