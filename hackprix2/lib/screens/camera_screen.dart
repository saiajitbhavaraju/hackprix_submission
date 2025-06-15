import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:ecosnap_1/common/colors.dart';
import 'send_to_screen.dart';
import 'profile_screen.dart'; // Import the new profile screen

class CameraScreen extends StatefulWidget {
  const CameraScreen({Key? key}) : super(key: key);

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  List<CameraDescription>? _cameras;
  CameraController? _controller;
  bool _isReady = false;
  int _cameraIndex = 0; // 0 for back camera, 1 for front

  @override
  void initState() {
    super.initState();
    _setupCameras();
  }

  Future<void> _setupCameras() async {
    try {
      _cameras = await availableCameras();
      if (_cameras != null && _cameras!.isNotEmpty) {
        await _initializeCameraController(_cameras![_cameraIndex]);
      }
    } on CameraException catch (e) {
      print('Error setting up camera: $e');
    }
  }

  Future<void> _initializeCameraController(
      CameraDescription cameraDescription) async {
    if (_controller != null) {
      await _controller!.dispose();
    }

    _controller = CameraController(
      cameraDescription,
      ResolutionPreset.high,
      enableAudio: false,
    );

    try {
      await _controller!.initialize();
      if (!mounted) return;
      setState(() {
        _isReady = true;
      });
    } on CameraException catch (e) {
      print('Error initializing camera: $e');
      setState(() {
        _isReady = false;
      });
    }
  }

  void _flipCamera() {
    if (_cameras == null || _cameras!.length < 2) return;
    setState(() {
      _isReady = false;
      _cameraIndex = (_cameraIndex + 1) % _cameras!.length;
    });
    _initializeCameraController(_cameras![_cameraIndex]);
  }

  Future<void> _takePicture() async {
    if (!_controller!.value.isInitialized || _controller!.value.isTakingPicture) {
      return;
    }

    try {
      final XFile imageFile = await _controller!.takePicture();
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SendToScreen(imagePath: imageFile.path),
        ),
      );
    } on CameraException catch (e) {
      print("Error taking picture: $e");
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isReady || _controller == null || !_controller!.value.isInitialized) {
      return Container(
        color: Colors.black,
        child: const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: AspectRatio(
              aspectRatio: _controller!.value.aspectRatio,
              child: CameraPreview(_controller!),
            ),
          ),
          _buildControlsOverlay(),
        ],
      ),
    );
  }

  Widget _buildControlsOverlay() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildTopControls(),
            _buildBottomControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            // ** UPDATED: Added onTap to navigate to ProfileScreen **
            _buildOverlayButton(
              icon: Icons.person_outline,
              color: primary,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfileScreen()),
                );
              },
            ),
            const SizedBox(width: 10),
            _buildOverlayButton(icon: Icons.search),
          ],
        ),
        _buildOverlayButton(icon: Icons.flip_camera_ios_outlined, onTap: _flipCamera),
      ],
    );
  }

  Widget _buildBottomControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _buildOverlayButton(icon: Icons.photo_library_outlined, size: 28),
        _buildShutterButton(),
        _buildOverlayButton(icon: Icons.emoji_emotions_outlined, size: 28),
      ],
    );
  }

  Widget _buildShutterButton() {
    return GestureDetector(
      onTap: _takePicture,
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(width: 6, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildOverlayButton(
      {required IconData icon, VoidCallback? onTap, Color? color, double size = 24}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 45,
        height: 45,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.black.withOpacity(0.3),
        ),
        child: Icon(
          icon,
          color: color ?? Colors.white,
          size: size,
        ),
      ),
    );
  }
}
