import 'dart:io';
import 'package:flutter/material.dart';
import 'package:ecosnap_1/services/snap_state_service.dart';
import 'package:ecosnap_1/models/snap_model.dart';
import 'package:ecosnap_1/screens/home_page_screen.dart';

class SendToScreen extends StatefulWidget {
  final String imagePath;
  const SendToScreen({Key? key, required this.imagePath}) : super(key: key);

  @override
  _SendToScreenState createState() => _SendToScreenState();
}

class _SendToScreenState extends State<SendToScreen> {
  final TextEditingController _descriptionController = TextEditingController();
  bool _isLoading = false;

  /// This function handles sending the snap and showing the pop-up.
  Future<void> _onSendPressed() async {
    // Show a loading indicator
    setState(() {
      _isLoading = true;
    });

    final snap = Snap(
      imagePath: widget.imagePath,
      userDescription: _descriptionController.text,
    );
    final users = {'friend1', 'friend2'}; // Example users

    // Call the service and await the result message
    final String resultMessage = await SnapStateService.instance.addSnap(users, snap);

    // Hide the loading indicator
    setState(() {
      _isLoading = false;
    });

    if (!mounted) return;

    // Navigate back to the main camera screen
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) => const HomePageScreen(initialPageIndex: 2),
      ),
      (route) => false,
    );

    // **** THIS IS THE POP-UP LOGIC ****
    // Use the resultMessage to create the pop-up.
    // We check the message content to decide the text and color.
    final bool gotPoints = resultMessage.contains("+1 Point");

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        // The content of the pop-up
        content: Text(
          gotPoints ? "+1 Point Awarded!" : "No points awarded.",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        // The background color of the pop-up
        backgroundColor: gotPoints ? Colors.green : Colors.redAccent,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Send To...', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Expanded(
            child: Image.file(File(widget.imagePath)),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _descriptionController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Add a description...',
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                filled: true,
                fillColor: Colors.grey.shade800,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isLoading ? null : _onSendPressed,
        backgroundColor: Colors.blueAccent,
        icon: _isLoading
            ? Container(
                width: 24,
                height: 24,
                padding: const EdgeInsets.all(2.0),
                child: const CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 3,
                ),
              )
            : const Icon(Icons.send, color: Colors.white),
        label: Text(_isLoading ? 'Sending...' : 'Send',
            style: const TextStyle(color: Colors.white)),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}