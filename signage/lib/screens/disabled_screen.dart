import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class DisabledScreen extends StatefulWidget {
  const DisabledScreen({super.key});

  @override
  State<DisabledScreen> createState() => _DisabledScreenState();
}

class _DisabledScreenState extends State<DisabledScreen> {
  String detectedText = '';
  bool isDetecting = false;
  Timer? detectionTimer;

  CameraController? _cameraController;
  bool _isCameraInitialized = false;

  final String backendUrl = 'http://192.168.0.7:5000/predict'; // 🔥 Flask endpoint

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
    setState(() => _isCameraInitialized = true);
  }

  /// 📸 Capture image and send to Flask backend
  Future<void> _sendFrameToServer() async {
    if (!_cameraController!.value.isInitialized) return;

    try {
      // Capture image
      final picture = await _cameraController!.takePicture();

      // Flask can’t read temporary Android paths directly, so we re-save it
      final dir = await getTemporaryDirectory();
      final newPath = '${dir.path}/frame.jpg';
      final File imageFile = await File(picture.path).copy(newPath);

      // Send image to Flask
      var request = http.MultipartRequest('POST', Uri.parse(backendUrl));
      request.files.add(await http.MultipartFile.fromPath('image', imageFile.path));

      var response = await request.send();

      if (response.statusCode == 200) {
        final resBody = await response.stream.bytesToString();
        final json = jsonDecode(resBody);
        setState(() => detectedText = json['prediction'] ?? 'Unknown');
      } else {
        setState(() => detectedText = 'Error: ${response.statusCode}');
      }
    } catch (e) {
      setState(() => detectedText = 'Error: $e');
    }
  }

  void startDetection() {
    setState(() => isDetecting = true);

    detectionTimer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      await _sendFrameToServer();
    });
  }

  void stopDetection() {
    detectionTimer?.cancel();
    setState(() => isDetecting = false);
  }

  void clearText() {
    setState(() => detectedText = '');
  }

  @override
  void dispose() {
    detectionTimer?.cancel();
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

            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Detected Gesture:',
                style: theme.textTheme.titleLarge,
              ),
            ),
            const SizedBox(height: 8),

            // Detected Text Display
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                border: Border.all(color: Colors.greenAccent),
                borderRadius: BorderRadius.circular(12),
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

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Start'),
                    onPressed: isDetecting ? null : startDetection,
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
            ),
          ],
        ),
      ),
    );
  }
}
