import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'result.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ImagePicker _picker = ImagePicker();

  File? selectedImage;
  String? resultLabel;
  double confidence = 0.0;
  bool isScanning = false;

  Future<void> _pickFromCamera() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 95,
    );

    if (image == null) return;

    setState(() {
      selectedImage = File(image.path);
      resultLabel = null;
    });

    await _fakeAnalyze('ready', 0.93);
  }

  Future<void> _pickFromGallery() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 95,
    );

    if (image == null) return;

    setState(() {
      selectedImage = File(image.path);
      resultLabel = null;
    });

    await _fakeAnalyze('unripe', 0.88);
  }

  Future<void> _fakeAnalyze(String label, double score) async {
    setState(() {
      isScanning = true;
      resultLabel = null;
    });

    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      isScanning = false;
      resultLabel = label;
      confidence = score;
    });
  }

  void _clearImage() {
    setState(() {
      selectedImage = null;
      resultLabel = null;
      confidence = 0.0;
      isScanning = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Avocado Ripeness Detector'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6EC),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFFD6E5D0)),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: selectedImage != null
                          ? Image.file(
                              selectedImage!,
                              width: double.infinity,
                              height: double.infinity,
                              fit: BoxFit.cover,
                            )
                          : const Icon(
                              Icons.image_outlined,
                              size: 90,
                              color: Color(0xFF9FB39A),
                            ),
                    ),
                    if (isScanning)
                      Positioned.fill(
                        child: TweenAnimationBuilder<double>(
                          tween: Tween(begin: -1, end: 1),
                          duration: const Duration(seconds: 2),
                          curve: Curves.easeInOut,
                          builder: (context, value, child) {
                            return Align(
                              alignment: Alignment(0, value),
                              child: Container(
                                height: 4,
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 24),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF69B36D),
                                  borderRadius: BorderRadius.circular(999),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Color(0x8069B36D),
                                      blurRadius: 10,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    if (isScanning)
                      const Positioned(
                        bottom: 24,
                        child: Text(
                          'Analyzing ripeness...',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF4B624B),
                          ),
                        ),
                      ),
                    if (selectedImage != null && !isScanning)
                      Positioned(
                        top: 14,
                        right: 14,
                        child: Material(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(999),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(999),
                            onTap: _clearImage,
                            child: const Padding(
                              padding: EdgeInsets.all(8),
                              child: Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: isScanning ? null : _pickFromCamera,
                    icon: const Icon(Icons.camera_alt_outlined),
                    label: const Text('Camera'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: isScanning ? null : _pickFromGallery,
                    icon: const Icon(Icons.photo_library_outlined),
                    label: const Text('Gallery'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (resultLabel != null)
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                transitionBuilder: (child, animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: ScaleTransition(
                      scale: animation,
                      child: child,
                    ),
                  );
                },
                child: ResultCard(
                  key: ValueKey(resultLabel),
                  label: resultLabel!,
                  confidence: confidence,
                ),
              ),
          ],
        ),
      ),
    );
  }
}