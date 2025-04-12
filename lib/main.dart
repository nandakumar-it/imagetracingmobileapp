import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Image Tracer Lock Demo',
      home: const ImageLockScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class ImageLockScreen extends StatefulWidget {
  const ImageLockScreen({super.key});

  @override
  State<ImageLockScreen> createState() => _ImageLockScreenState();
}

class _ImageLockScreenState extends State<ImageLockScreen> {
  File? _selectedImage;
  bool _isLocked = false;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      setState(() {
        _selectedImage = File(picked.path);
        _isLocked = true; // Lock screen after image upload
      });

      // Keep the screen on while tracing
      await WakelockPlus.enable();
    }
  }

  void _unlockScreen() async {
    setState(() {
      _isLocked = false;
    });

    // Optional: Allow screen to sleep after unlocking
    await WakelockPlus.disable();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Papercopy - Tracer'),
      ),
      body: AbsorbPointer(
        absorbing: _isLocked,
        child: Stack(
          children: [
            Center(
              child: _selectedImage != null
                  ? Image.file(_selectedImage!)
                  : const Text('No image selected'),
            ),
            if (_isLocked)
              Container(
                color: Colors.black.withOpacity(0.5), // Visual lock
                alignment: Alignment.center,
                child: const Text(
                  'Screen Locked\nTap + or - to unlock',
                  style: TextStyle(color: Colors.white, fontSize: 24),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            ElevatedButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.image),
              label: const Text("Upload Image"),
            ),
            ElevatedButton.icon(
              onPressed: _unlockScreen,
              icon: const Icon(Icons.add),
              label: const Text("Audio +"),
            ),
            ElevatedButton.icon(
              onPressed: _unlockScreen,
              icon: const Icon(Icons.remove),
              label: const Text("Audio -"),
            ),
          ],
        ),
      ),
    );
  }
}
