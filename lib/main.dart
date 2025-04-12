import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:screen_brightness/screen_brightness.dart';

void main() {
  runApp(const TracerApp());
}

class TracerApp extends StatelessWidget {
  const TracerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Papercopy Tracer',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  File? _image;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _image = File(image.path);
      });
      // Keep screen awake and set max brightness
      await WakelockPlus.enable();
      await ScreenBrightness().setScreenBrightness(1.0);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => TracerScreen(imageFile: _image!),
        ),
      );
    }
  }

  @override
  void dispose() {
    WakelockPlus.disable();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Papercopy Tracer')),
      body: Center(
        child: ElevatedButton(
          onPressed: _pickImage,
          child: const Text('Select Image to Trace'),
        ),
      ),
    );
  }
}

class TracerScreen extends StatelessWidget {
  final File imageFile;
  const TracerScreen({super.key, required this.imageFile});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        // Tap anywhere to return
        await WakelockPlus.disable();
        await ScreenBrightness().resetScreenBrightness();
        Navigator.pop(context);
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Image.file(imageFile, fit: BoxFit.contain),
        ),
      ),
    );
  }
}
