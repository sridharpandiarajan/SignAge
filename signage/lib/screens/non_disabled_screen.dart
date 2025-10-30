import 'dart:async';
import 'package:flutter/material.dart';

class NonDisabledScreen extends StatefulWidget {
  const NonDisabledScreen({super.key});

  @override
  State<NonDisabledScreen> createState() => _NonDisabledScreenState();
}

class _NonDisabledScreenState extends State<NonDisabledScreen> {
  final TextEditingController _textController = TextEditingController();
  List<String> _letters = [];
  int _currentIndex = 0;
  Timer? _timer;
  bool _isPlaying = false;



  void _startDisplay() {
    FocusScope.of(context).unfocus(); // 🔹 Hide keyboard when Start is pressed

    if (_textController.text.trim().isEmpty) return;

    setState(() {
      _letters = _textController.text
          .toUpperCase()
          .split('')
          .where((ch) => RegExp(r'[A-Z0-9 ]').hasMatch(ch))
          .toList();
      _currentIndex = 0;
      _isPlaying = true;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_currentIndex < _letters.length - 1) {
        setState(() => _currentIndex++);
      } else {
        timer.cancel();
        setState(() => _isPlaying = false);
      }
    });
  }

  void _stopDisplay() {
    _timer?.cancel();
    setState(() => _isPlaying = false);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    String currentChar = _letters.isNotEmpty ? _letters[_currentIndex] : '';

    // Determine image (skip for space)
    String? assetName;
    if (currentChar.trim().isEmpty) {
      assetName = null;
    } else if (RegExp(r'[A-Z0-9]').hasMatch(currentChar)) {
      assetName = '$currentChar.jpeg';
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Non-Disabled Side'),
        centerTitle: true,
        elevation: 2,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // 🔹 Input Field
            TextField(
              controller: _textController,
              textCapitalization: TextCapitalization.characters,
              decoration: InputDecoration(
                labelText: 'Enter Text',
                hintText: 'Type a word or sentence',
                prefixIcon: const Icon(Icons.keyboard_alt_outlined),
                labelStyle: TextStyle(color: theme.colorScheme.secondary),
                enabledBorder: OutlineInputBorder(
                  borderSide:
                  BorderSide(color: theme.colorScheme.secondary, width: 1.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide:
                  BorderSide(color: theme.colorScheme.primary, width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _textController.clear();
                    _stopDisplay();
                    setState(() => _letters = []);
                  },
                ),
              ),
            ),

            const SizedBox(height: 28),

            // 🔹 Word and letter display
            if (_letters.isNotEmpty)
              Column(
                children: [
                  Text(
                    'Word: ${_textController.text.toUpperCase()}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Now showing: ${currentChar == ' ' ? '(space)' : currentChar}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),

            const SizedBox(height: 30),

            // 🔹 Display image
            Expanded(
              child: Center(
                  child:AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    transitionBuilder: (child, animation) =>
                        FadeTransition(opacity: animation, child: child),
                    child: _letters.isEmpty
                        ? Text(
                      'Start typing to see sign representations 👋',
                      key: const ValueKey('empty'),
                      style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey),
                      textAlign: TextAlign.center,
                    )
                        : (assetName == null)
                        ? const SizedBox()
                        : Container(
                      // 👇 Unique key for every frame
                      key: ValueKey('$assetName-$_currentIndex'),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: theme.colorScheme.surfaceContainerHighest
                            .withOpacity(0.2),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.asset(
                          'assets/$assetName',
                          width: 220,
                          height: 220,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => const Icon(
                            Icons.error_outline,
                            color: Colors.redAccent,
                            size: 100,
                          ),
                        ),
                      ),
                    ),
                  )
              ),
            ),

            const SizedBox(height: 16),

            // 🔹 Control Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildActionButton(
                  context,
                  icon: Icons.play_arrow_rounded,
                  label: 'Start',
                  color: Colors.green,
                  onPressed: _isPlaying ? null : _startDisplay,
                ),
                _buildActionButton(
                  context,
                  icon: Icons.stop_rounded,
                  label: 'Stop',
                  color: Colors.redAccent,
                  onPressed: _isPlaying ? _stopDisplay : null,
                ),
              ],
            ),

            const SizedBox(height: 20),

            // 🔹 Progress Indicator
            if (_letters.isNotEmpty)
              Text(
                'Showing ${_currentIndex + 1} of ${_letters.length}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[700],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
      BuildContext context, {
        required IconData icon,
        required String label,
        required Color color,
        required VoidCallback? onPressed,
      }) {
    return SizedBox(
      width: 140,
      child: ElevatedButton.icon(
        icon: Icon(icon, color: Colors.white),
        label: Text(label),
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          elevation: 3,
          padding: const EdgeInsets.symmetric(vertical: 14),
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }
}
