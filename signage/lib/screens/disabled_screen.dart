import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'dart:async';

class DisabledScreen extends StatefulWidget {
  const DisabledScreen({super.key});

  @override
  State<DisabledScreen> createState() => _DisabledScreenState();
}

class _DisabledScreenState extends State<DisabledScreen> {
  String detectedText = '';
  bool isDetecting = false;
  Timer? mockDetectionTimer;

  CameraController? _cameraController;
  bool _isCameraInitialized = false;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    final cameras = await availableCameras();
    final frontCamera = cameras.firstWhere(
          (camera) => camera.lensDirection == CameraLensDirection.front,
    );

    _cameraController = CameraController(
      frontCamera,
      ResolutionPreset.medium,
      enableAudio: false,
    );

    await _cameraController!.initialize();
    setState(() {
      _isCameraInitialized = true;
    });
  }

  void startMockDetection() {
    setState(() => isDetecting = true);
    mockDetectionTimer = Timer.periodic(Duration(seconds: 2), (timer) {
      setState(() {
        detectedText = _getMockGesture();
      });
    });
  }

  void stopDetection() {
    mockDetectionTimer?.cancel();
    setState(() => isDetecting = false);
  }

  void clearText() {
    setState(() => detectedText = '');
  }

  String _getMockGesture() {
    final mockGestures = ['Hello', 'Yes', 'No', 'Thank you', 'What?'];
    mockGestures.shuffle();
    return mockGestures.first;
  }

  @override
  void dispose() {
    mockDetectionTimer?.cancel();
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Disabled Side')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Camera Preview
            SizedBox(
              height: 300,
              width: double.infinity,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: _isCameraInitialized
                    ? CameraPreview(_cameraController!)
                    : Container(
                  color: Colors.grey[850],
                  alignment: Alignment.center,
                  child: const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.deepPurpleAccent,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Detected Gesture Header
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Detected Gesture:',
                style: theme.textTheme.titleLarge,
              ),
            ),
            const SizedBox(height: 8),

            // Detected Text Container
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                border: Border.all(color: Colors.greenAccent),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  )
                ],
              ),
              child: Text(
                detectedText.isNotEmpty
                    ? '“$detectedText”'
                    : 'Waiting for gesture...',
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.greenAccent,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Start'),
                    onPressed: isDetecting ? null : startMockDetection,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.stop),
                    label: const Text('Stop'),
                    onPressed: isDetecting ? stopDetection : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.clear),
                    label: const Text('Clear'),
                    onPressed: clearText,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}