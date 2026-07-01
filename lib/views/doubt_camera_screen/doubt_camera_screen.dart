import 'dart:async';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:logicaly_ai_project/services/ai_services.dart';
import 'package:logicaly_ai_project/services/supabase_service.dart';

class DoubtCameraScreen extends StatefulWidget {
  const DoubtCameraScreen({super.key});

  @override
  State<StatefulWidget> createState() => _DoubtCameraScreen();
}

class _DoubtCameraScreen extends State<DoubtCameraScreen>
    with WidgetsBindingObserver {
  final ImagePicker _imagePicker = ImagePicker();
  final AiService _aiService = AiService();
  final SupabaseService _supabaseService = SupabaseService();
  final TextEditingController _questionController = TextEditingController();

  List<CameraDescription> _cameras = const [];
  CameraController? _cameraController;
  FlashMode _flashMode = FlashMode.off;
  Uint8List? _selectedImageBytes;
  String? _answer;
  bool _isSolving = false;
  bool _isCameraLoading = true;
  bool _showGrid = false;
  bool _isCapturing = false;
  int _captureDelaySeconds = 0;
  int? _countdown;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    unawaited(_cameraController?.dispose());
    _questionController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final controller = _cameraController;

    if (state == AppLifecycleState.inactive) {
      if (controller == null) {
        return;
      }
      _cameraController = null;
      unawaited(controller.dispose());
    } else if (state == AppLifecycleState.resumed) {
      unawaited(_initializeCamera(camera: controller?.description));
    }
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
                    ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: SizedBox.expand(child: _buildCameraSurface()),
                    ),

                    if (_showGrid)
                      Positioned.fill(
                        child: IgnorePointer(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(18),
                            child: CustomPaint(painter: _GridPainter()),
                          ),
                        ),
                      ),

                    if (_countdown != null)
                      Positioned.fill(
                        child: Center(
                          child: Text(
                            "$_countdown",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 84,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                    // Left Camera Icons
                    Positioned(
                      left: 10,
                      top: 20,

                      child: Column(
                        children: [
                          buildCameraIcon(
                            _flashMode == FlashMode.off
                                ? Icons.flash_off
                                : Icons.flash_on,
                            onTap: _toggleFlash,
                            isActive: _flashMode != FlashMode.off,
                          ),

                          const SizedBox(height: 18),

                          buildCameraIcon(
                            Icons.settings,
                            onTap: _showCameraSettings,
                          ),

                          const SizedBox(height: 18),

                          buildCameraIcon(
                            Icons.grid_on,
                            onTap: () {
                              setState(() => _showGrid = !_showGrid);
                            },
                            isActive: _showGrid,
                          ),

                          const SizedBox(height: 18),

                          buildCameraIcon(
                            Icons.cameraswitch,
                            onTap: _switchCamera,
                          ),

                          const SizedBox(height: 18),

                          buildCameraIcon(
                            Icons.timer,
                            onTap: _cycleTimer,
                            isActive: _captureDelaySeconds > 0,
                          ),
                        ],
                      ),
                    ),

                    if (_captureDelaySeconds > 0)
                      Positioned(
                        right: 18,
                        top: 18,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.45),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            "${_captureDelaySeconds}s",
                            style: const TextStyle(color: Colors.white),
                          ),
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
                              : _selectedImageBytes == null
                              ? _captureWithAppCamera
                              : _clearSelectedImage,
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
                                    || _isCapturing
                                    ? const Padding(
                                        padding: EdgeInsets.all(18),
                                        child: CircularProgressIndicator(
                                          strokeWidth: 3,
                                        ),
                                      )
                                    : Icon(
                                        _selectedImageBytes == null
                                            ? Icons.camera_alt
                                            : Icons.refresh,
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

  Widget _buildCameraSurface() {
    final selectedImageBytes = _selectedImageBytes;
    if (selectedImageBytes != null) {
      return Image.memory(selectedImageBytes, fit: BoxFit.cover);
    }

    final controller = _cameraController;
    if (_isCameraLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (controller == null || !controller.value.isInitialized) {
      return Container(
        color: const Color(0xFF111111),
        alignment: Alignment.center,
        padding: const EdgeInsets.all(24),
        child: const Text(
          "Camera is unavailable. Use gallery to upload a doubt image.",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white70),
        ),
      );
    }

    return FittedBox(
      fit: BoxFit.cover,
      child: SizedBox(
        width: controller.value.previewSize?.height ?? 1,
        height: controller.value.previewSize?.width ?? 1,
        child: CameraPreview(controller),
      ),
    );
  }

  Future<void> _initializeCamera({CameraDescription? camera}) async {
    if (!mounted) {
      return;
    }
    setState(() => _isCameraLoading = true);
    try {
      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        if (mounted) {
          setState(() => _isCameraLoading = false);
        }
        return;
      }

      final selectedCamera = camera ?? _cameras.first;
      final oldController = _cameraController;
      _cameraController = null;
      await oldController?.dispose();

      final controller = CameraController(
        selectedCamera,
        ResolutionPreset.medium,
        enableAudio: false,
      );
      _cameraController = controller;
      await controller.initialize();
      await _applyFlashMode();

      if (mounted) {
        setState(() => _isCameraLoading = false);
      }
    } catch (error) {
      if (mounted) {
        setState(() => _isCameraLoading = false);
        _showSnackBar(_friendlyCameraError(error));
      }
    }
  }

  Future<void> _captureWithAppCamera() async {
    final controller = _cameraController;
    if (controller == null || !controller.value.isInitialized) {
      _showSnackBar("Camera is still starting");
      return;
    }
    if (_isCapturing) {
      return;
    }

    setState(() {
      _isCapturing = true;
      _answer = null;
    });

    try {
      if (_captureDelaySeconds > 0) {
        for (var second = _captureDelaySeconds; second > 0; second--) {
          if (!mounted) {
            return;
          }
          setState(() => _countdown = second);
          await Future<void>.delayed(const Duration(seconds: 1));
        }
        if (mounted) {
          setState(() => _countdown = null);
        }
      }

      final picture = await controller.takePicture();
      final imageBytes = await picture.readAsBytes();
      if (!mounted) {
        return;
      }
      setState(() {
        _selectedImageBytes = imageBytes;
        _answer = null;
      });
    } catch (error) {
      _showSnackBar("Could not capture image. Please try again.");
    } finally {
      if (mounted) {
        setState(() {
          _isCapturing = false;
          _countdown = null;
        });
      }
    }
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
      if (!mounted) {
        return;
      }
      setState(() {
        _selectedImageBytes = imageBytes;
        _answer = null;
      });
    } catch (error) {
      _showSnackBar("Could not pick image. Please try again.");
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
      await _supabaseService.addActivity(
        title: "Doubt solved",
        subtitle: _questionController.text.trim().isEmpty
            ? "Image doubt"
            : _questionController.text.trim(),
      );
      if (mounted) {
        setState(() => _answer = answer);
      }
    } catch (error) {
      _showSnackBar(_friendlyError("Could not solve doubt", error));
    } finally {
      if (mounted) {
        setState(() => _isSolving = false);
      }
    }
  }

  void _clearSelectedImage() {
    setState(() {
      _selectedImageBytes = null;
      _answer = null;
    });
  }

  Future<void> _toggleFlash() async {
    final controller = _cameraController;
    if (controller == null || !controller.value.isInitialized) {
      _showSnackBar("Camera is still starting");
      return;
    }

    setState(() {
      _flashMode =
          _flashMode == FlashMode.off ? FlashMode.auto : FlashMode.off;
    });
    await _applyFlashMode();
  }

  Future<void> _applyFlashMode() async {
    final controller = _cameraController;
    if (controller == null || !controller.value.isInitialized) {
      return;
    }

    try {
      await controller.setFlashMode(_flashMode);
    } catch (_) {
      if (mounted) {
        setState(() => _flashMode = FlashMode.off);
      }
    }
  }

  Future<void> _switchCamera() async {
    if (_cameras.length < 2) {
      _showSnackBar("No second camera found");
      return;
    }

    final current = _cameraController?.description;
    final currentIndex = current == null ? 0 : _cameras.indexOf(current);
    final nextIndex = currentIndex == -1
        ? 0
        : (currentIndex + 1) % _cameras.length;
    setState(() {
      _selectedImageBytes = null;
      _answer = null;
      _flashMode = FlashMode.off;
    });
    await _initializeCamera(camera: _cameras[nextIndex]);
  }

  void _cycleTimer() {
    setState(() {
      _captureDelaySeconds = switch (_captureDelaySeconds) {
        0 => 3,
        3 => 5,
        _ => 0,
      };
    });
    _showSnackBar(
      _captureDelaySeconds == 0
          ? "Timer off"
          : "Timer set to $_captureDelaySeconds seconds",
    );
  }

  void _showCameraSettings() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF1B1B1B),
      showDragHandle: true,
      builder: (context) {
        final cameraName = _cameraController?.description.lensDirection.name;
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 0, 18, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Camera",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.camera_alt, color: Colors.white),
                  title: Text(
                    cameraName == null
                        ? "No active camera"
                        : "Using ${cameraName.toUpperCase()} camera",
                    style: const TextStyle(color: Colors.white),
                  ),
                  subtitle: Text(
                    "${_cameras.length} camera${_cameras.length == 1 ? "" : "s"} found",
                    style: const TextStyle(color: Colors.white60),
                  ),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: _showGrid,
                  onChanged: (value) {
                    setState(() => _showGrid = value);
                    Navigator.pop(context);
                  },
                  title: const Text(
                    "Grid",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showSnackBar(String message) {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
        ),
      );
  }

  String _friendlyCameraError(Object error) {
    final message = error.toString().toLowerCase();
    if (message.contains("surface") ||
        message.contains("camera") ||
        message.contains("use case")) {
      return "Could not start camera. Close other camera apps or use gallery upload.";
    }
    return "Could not start camera. Use gallery upload or try again.";
  }

  String _friendlyError(String prefix, Object error) {
    final message = error.toString().replaceFirst("Exception: ", "").trim();
    if (message.isEmpty) {
      return "$prefix. Please try again.";
    }
    if (message.length > 120) {
      return "$prefix. Please try again with a clearer or smaller image.";
    }
    return "$prefix: $message";
  }

  // ---------------- CAMERA ICON ----------------

  Widget buildCameraIcon(
    IconData icon, {
    required VoidCallback onTap,
    bool isActive = false,
  }) {
    return InkWell(
      customBorder: const CircleBorder(),
      onTap: _isSolving || _isCapturing ? null : onTap,
      child: Container(
        padding: const EdgeInsets.all(8),

        decoration: BoxDecoration(
          color: isActive
              ? Colors.blue.withValues(alpha: 0.85)
              : Colors.black.withValues(alpha: 0.4),
          shape: BoxShape.circle,
        ),

        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.35)
      ..strokeWidth = 1;

    canvas.drawLine(
      Offset(size.width / 3, 0),
      Offset(size.width / 3, size.height),
      paint,
    );
    canvas.drawLine(
      Offset(size.width * 2 / 3, 0),
      Offset(size.width * 2 / 3, size.height),
      paint,
    );
    canvas.drawLine(
      Offset(0, size.height / 3),
      Offset(size.width, size.height / 3),
      paint,
    );
    canvas.drawLine(
      Offset(0, size.height * 2 / 3),
      Offset(size.width, size.height * 2 / 3),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
