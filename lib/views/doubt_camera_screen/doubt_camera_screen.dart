import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:logicaly_ai_project/services/ai_services.dart';
import 'package:logicaly_ai_project/services/fire_store_services.dart';

class DoubtCameraScreen extends StatefulWidget {
  const DoubtCameraScreen({super.key});

  @override
  State<StatefulWidget> createState() => _DoubtCameraScreen();
}

class _DoubtCameraScreen extends State<DoubtCameraScreen> {
  final ImagePicker _imagePicker = ImagePicker();
  final AiService _aiService = AiService();
  final FirestoreService _firestoreService = FirestoreService();
  final TextEditingController _questionController = TextEditingController();

  Uint8List? _selectedImageBytes;
  String? _answer;
  bool _isSolving = false;

  @override
  void dispose() {
    _questionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),

              child: Row(
                children: [
                  Text(
                    "Doubt-Scanner",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: _isSolving
                        ? null
                        : () => _pickImage(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library, color: Colors.white),
                  ),
                ],
              ),
            ),

            // Camera Preview Area
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),

                child: Stack(
                  children: [
                    // Camera Image
                    Container(
                      width: double.infinity,

                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),

                        image: DecorationImage(
                          image: _selectedImageBytes == null
                              ? const NetworkImage(
                                  "https://images.unsplash.com/photo-1515879218367-8466d910aaa4",
                                )
                              : MemoryImage(_selectedImageBytes!)
                                  as ImageProvider,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),

                    // Left Camera Icons
                    Positioned(
                      left: 10,
                      top: 20,

                      child: Column(
                        children: [
                          buildCameraIcon(Icons.flash_on),

                          const SizedBox(height: 18),

                          buildCameraIcon(Icons.settings),

                          const SizedBox(height: 18),

                          buildCameraIcon(Icons.grid_on),

                          const SizedBox(height: 18),

                          buildCameraIcon(Icons.rotate_right),

                          const SizedBox(height: 18),

                          buildCameraIcon(Icons.timer),
                        ],
                      ),
                    ),

                    Positioned(
                      left: 14,
                      right: 14,
                      bottom: 120,
                      child: TextField(
                        controller: _questionController,
                        minLines: 1,
                        maxLines: 3,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: "Add a question for the AI...",
                          hintStyle: const TextStyle(color: Colors.white70),
                          filled: true,
                          fillColor: Colors.black.withValues(alpha: 0.55),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),

                    // Capture Button
                    Positioned(
                      bottom: 25,
                      left: 0,
                      right: 0,

                      child: Center(
                        child: GestureDetector(
                          onTap: _isSolving
                              ? null
                              : () => _pickImage(ImageSource.camera),
                          child: Container(
                            width: 80,
                            height: 80,

                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white,
                                width: 6,
                              ),
                            ),

                            child: Center(
                              child: Container(
                                width: 62,
                                height: 62,

                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: _isSolving
                                    ? const Padding(
                                        padding: EdgeInsets.all(18),
                                        child: CircularProgressIndicator(
                                          strokeWidth: 3,
                                        ),
                                      )
                                    : const Icon(
                                        Icons.camera_alt,
                                        color: Colors.black,
                                      ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            if (_selectedImageBytes != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
                child: SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: _isSolving ? null : _solveSelectedImage,
                    icon: const Icon(Icons.auto_awesome),
                    label: Text(_isSolving ? "Solving..." : "Solve Doubt"),
                  ),
                ),
              ),

            if (_answer != null)
              Expanded(
                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.all(12),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: SingleChildScrollView(child: Text(_answer!)),
                ),
              )
            else
              const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedImage = await _imagePicker.pickImage(
        source: source,
        imageQuality: 70,
        maxWidth: 1600,
        maxHeight: 1600,
      );
      if (pickedImage == null) {
        return;
      }

      final imageBytes = await pickedImage.readAsBytes();
      setState(() {
        _selectedImageBytes = imageBytes;
        _answer = null;
      });
    } catch (error) {
      _showSnackBar("Could not pick image: $error");
    }
  }

  Future<void> _solveSelectedImage() async {
    final imageBytes = _selectedImageBytes;
    if (imageBytes == null) {
      _showSnackBar("Capture or select an image first");
      return;
    }

    setState(() => _isSolving = true);
    try {
      final answer = await _aiService.solveDoubtFromImage(
        imageBytes: imageBytes,
        question: _questionController.text.trim().isEmpty
            ? "Solve this doubt from the image."
            : _questionController.text.trim(),
      );
      await _firestoreService.addActivity(
        title: "Doubt solved",
        subtitle: _questionController.text.trim().isEmpty
            ? "Image doubt"
            : _questionController.text.trim(),
      );
      if (mounted) {
        setState(() => _answer = answer);
      }
    } catch (error) {
      _showSnackBar("Could not solve doubt: $error");
    } finally {
      if (mounted) {
        setState(() => _isSolving = false);
      }
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  // ---------------- CAMERA ICON ----------------

  Widget buildCameraIcon(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(6),

      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.4),
        shape: BoxShape.circle,
      ),

      child: Icon(icon, color: Colors.white, size: 20),
    );
  }
}
