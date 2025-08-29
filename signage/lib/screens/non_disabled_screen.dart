/*import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class NonDisabledScreen extends StatefulWidget {
  const NonDisabledScreen({super.key});

  @override
  State<NonDisabledScreen> createState() => _NonDisabledScreenState();
}

class _NonDisabledScreenState extends State<NonDisabledScreen> {
  final TextEditingController _controller = TextEditingController();
  String _textToConvert = '';
  bool _showVideo = false;
  late VideoPlayerController _videoController;

  @override
  void initState() {
    super.initState();
    _videoController = VideoPlayerController.network(
      'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4', // Placeholder
    )..initialize().then((_) {
      setState(() {});
    });
  }

  void _convertToSign() {
    setState(() {
      _textToConvert = _controller.text;
      _showVideo = true;
      _videoController.play();
    });
  }

  @override
  void dispose() {
    _videoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Non-Disabled Side')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Text Input
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'Enter text or speech',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 12),

            // Convert Button
            ElevatedButton.icon(
              icon: Icon(Icons.translate),
              label: Text('Convert to Sign'),
              onPressed: _convertToSign,
            ),
            SizedBox(height: 12),

            // Result
            if (_showVideo) ...[
              Text(
                'Playing sign for: "$_textToConvert"',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 10),
              AspectRatio(
                aspectRatio: _videoController.value.aspectRatio,
                child: VideoPlayer(_videoController),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Icon(Icons.play_arrow),
                    onPressed: () => _videoController.play(),
                  ),
                  IconButton(
                    icon: Icon(Icons.pause),
                    onPressed: () => _videoController.pause(),
                  ),
                ],
              )
            ],
          ],
        ),
      ),
    );
  }
}
*/