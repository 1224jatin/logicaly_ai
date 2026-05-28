import 'dart:convert';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:logicaly_ai_project/services/ai_services.dart';
import 'package:logicaly_ai_project/services/fire_store_services.dart';
import 'package:mime/mime.dart';

import '../../models/quizz_model.dart';

class MockTestScreen extends StatefulWidget {
  const MockTestScreen({super.key});

  @override
  State<StatefulWidget> createState() => _MockTestScreen();
}

class _MockTestScreen extends State<MockTestScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final AiService _aiService = AiService();
  final TextEditingController _syllabusController = TextEditingController();

  String difficulty = "Medium";
  String testType = "MCQ+Coding";
  String duration = "60 Min";
  String questionCount = "15 Questions";

  String? _uploadedFileName;
  String? _uploadedFileMimeType;
  Uint8List? _uploadedImageBytes;
  String? _generatedTest;
  bool focusWeakAreas = true;
  bool _isGeneratedTestSaved = false;
  bool _isGenerating = false;
  bool _isReadingFile = false;

  @override
  void dispose() {
    _syllabusController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              const Text(
                "Mock Test",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              _buildHero(),
              const SizedBox(height: 24),
              _buildSourceSection(),
              const SizedBox(height: 18),
              _buildActionsRow(),
              const SizedBox(height: 24),
              _buildPreferencesSection(),
              const SizedBox(height: 24),
              _buildGenerateButton(),
              const SizedBox(height: 16),
              _buildQuickTest(),
              const SizedBox(height: 24),
              if (_generatedTest != null) _buildGeneratedTest(),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHero() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Expanded(
          child: Text(
            "Create a test from\nnotes, topics, or a file",
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
              height: 1.2,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Container(
          width: 112,
          height: 112,
          decoration: BoxDecoration(
            color: Colors.blue.shade100,
            borderRadius: BorderRadius.circular(18),
          ),
          child: const Icon(
            Icons.assignment_turned_in,
            size: 64,
            color: Colors.blue,
          ),
        ),
      ],
    );
  }

  Widget _buildSourceSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Study Material",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Column(
            children: [
              InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: _isReadingFile ? null : _pickStudyFile,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF7F7),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      _isReadingFile
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.upload_file, color: Colors.blue),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _uploadedFileName ?? "Upload File",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 3),
                            const Text(
                              "Any file except audio/video",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right, color: Colors.black45),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),
              const Row(
                children: [
                  Expanded(child: Divider()),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Text("or"),
                  ),
                  Expanded(child: Divider()),
                ],
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _syllabusController,
                maxLines: 7,
                decoration: InputDecoration(
                  hintText:
                      "Paste syllabus, notes, chapters, weak topics, or important questions...",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionsRow() {
    return Row(
      children: [
        SizedBox(
          height: 48,
          child: ElevatedButton.icon(
            onPressed: _clearTestInput,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3563E9),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text("New", style: TextStyle(color: Colors.white)),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _generatedTest == null || _isGeneratedTestSaved
                ? null
                : _saveGeneratedTest,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            icon: const Icon(Icons.save_outlined),
            label: Text(_isGeneratedTestSaved ? "Saved" : "Save Test"),
          ),
        ),
      ],
    );
  }

  Widget _buildPreferencesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Test Preferences",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            children: [
              buildDropdownRow(
                icon: Icons.bar_chart,
                iconColor: Colors.purple,
                title: "Difficulty Level",
                value: difficulty,
                items: const ["Easy", "Medium", "Hard"],
                onChanged: (value) => setState(() => difficulty = value!),
              ),
              const SizedBox(height: 18),
              buildDropdownRow(
                icon: Icons.description,
                iconColor: Colors.red,
                title: "Test Type",
                value: testType,
                items: const ["MCQ", "Coding", "MCQ+Coding", "Short Answer"],
                onChanged: (value) => setState(() => testType = value!),
              ),
              const SizedBox(height: 18),
              buildDropdownRow(
                icon: Icons.access_time,
                iconColor: Colors.blue,
                title: "Duration",
                value: duration,
                items: const ["30 Min", "60 Min", "90 Min", "120 Min"],
                onChanged: (value) => setState(() => duration = value!),
              ),
              const SizedBox(height: 18),
              buildDropdownRow(
                icon: Icons.format_list_numbered,
                iconColor: Colors.green,
                title: "Questions",
                value: questionCount,
                items: const ["10 Questions", "15 Questions", "20 Questions"],
                onChanged: (value) => setState(() => questionCount = value!),
              ),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F9FC),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.auto_awesome, color: Colors.indigo),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Focus on my weak area",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 4),
                          Text(
                            "AI will prioritize weak topics in the material",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: focusWeakAreas,
                      onChanged: (value) {
                        setState(() {
                          focusWeakAreas = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGenerateButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: _isGenerating ? null : _generateTest,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF3563E9),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        icon: _isGenerating
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Icon(Icons.auto_awesome, color: Colors.white),
        label: Text(
          _isGenerating ? "Generating..." : "Generate My Test",
          style: const TextStyle(color: Colors.white, fontSize: 18),
        ),
      ),
    );
  }

  Widget _buildQuickTest() {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: _isGenerating ? null : _generateQuickTest,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Row(
          children: [
            Icon(Icons.flash_on, color: Colors.orange),
            SizedBox(width: 10),
            Expanded(
              child: Text.rich(
                TextSpan(
                  text: "Quick Test ",
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                  children: [
                    TextSpan(
                      text: "-> generate from common exam topics",
                      style: TextStyle(
                        color: Colors.black54,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.black45),
          ],
        ),
      ),
    );
  }

  Widget _buildGeneratedTest() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Generated Test",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: SelectableText(
            _generatedTest!,
            style: const TextStyle(fontSize: 14, height: 1.45),
          ),
        ),
      ],
    );
  }

  Widget buildDropdownRow({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Row(
      children: [
        Icon(icon, color: iconColor),
        const SizedBox(width: 12),
        Expanded(child: Text(title, style: const TextStyle(fontSize: 16))),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(10),
          ),
          child: DropdownButton<String>(
            value: value,
            underline: const SizedBox(),
            items: items.map((item) {
              return DropdownMenuItem(value: item, child: Text(item));
            }).toList(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Future<void> _pickStudyFile() async {
    setState(() => _isReadingFile = true);
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: false,
        withData: true,
      );
      if (result == null || result.files.isEmpty) {
        return;
      }
      if (!mounted) {
        return;
      }

      final file = result.files.single;
      final extension = _fileExtension(file.name);
      final bytes = file.bytes;
      if (bytes == null || bytes.isEmpty) {
        _showSnackBar("Could not read the selected file");
        return;
      }

      final mimeType =
          lookupMimeType(file.name, headerBytes: bytes.take(16).toList()) ??
          _mimeTypeForExtension(extension);
      if (_isAudioOrVideoFile(extension: extension, mimeType: mimeType)) {
        _showSnackBar("Audio and video files are not supported");
        return;
      }

      if (_isImageFile(extension: extension, mimeType: mimeType)) {
        setState(() {
          _uploadedFileName = file.name;
          _uploadedFileMimeType = mimeType;
          _uploadedImageBytes = bytes;
          _generatedTest = null;
          _isGeneratedTestSaved = false;
        });
        _showSnackBar("Image added to study material");
        return;
      }

      final fileText = _extractReadableText(bytes);
      if (fileText.isEmpty) {
        setState(() {
          _uploadedFileName = file.name;
          _uploadedFileMimeType = mimeType;
          _uploadedImageBytes = null;
          _generatedTest = null;
          _isGeneratedTestSaved = false;
        });
        _showSnackBar(
          "File selected, but no readable text was found. Paste notes too.",
        );
        return;
      }

      final existingText = _syllabusController.text.trim();
      _syllabusController.text = [
        if (existingText.isNotEmpty) existingText,
        "Uploaded file: ${file.name}",
        fileText,
      ].join("\n\n");

      setState(() {
        _uploadedFileName = file.name;
        _uploadedFileMimeType = mimeType;
        _uploadedImageBytes = null;
        _generatedTest = null;
        _isGeneratedTestSaved = false;
      });
      _showSnackBar("File added to study material");
    } catch (error) {
      _showSnackBar("Could not upload file: $error");
    } finally {
      if (mounted) {
        setState(() => _isReadingFile = false);
      }
    }
  }

  void _clearTestInput() {
    _syllabusController.clear();
    setState(() {
      difficulty = "Medium";
      testType = "MCQ+Coding";
      duration = "60 Min";
      questionCount = "15 Questions";
      focusWeakAreas = true;
      _uploadedFileName = null;
      _uploadedFileMimeType = null;
      _uploadedImageBytes = null;
      _generatedTest = null;
      _isGeneratedTestSaved = false;
    });
  }

  Future<void> _generateQuickTest() async {
    _syllabusController.text =
        "Data structures: arrays, linked lists, stacks, queues, trees, graphs, sorting, searching, time complexity, recursion.";
    setState(() {
      difficulty = "Medium";
      testType = "MCQ+Coding";
      duration = "60 Min";
      questionCount = "15 Questions";
      focusWeakAreas = false;
      _uploadedFileName = null;
      _uploadedFileMimeType = null;
      _uploadedImageBytes = null;
      _generatedTest = null;
      _isGeneratedTestSaved = false;
    });
    await _generateTest();
  }

  Future<void> _generateTest() async {
    final syllabus = _syllabusController.text.trim();
    final uploadedImageBytes = _uploadedImageBytes;
    if (syllabus.isEmpty && uploadedImageBytes == null) {
      if (_uploadedFileName == null) {
        _showSnackBar("Please add syllabus, notes, topics, or a file");
      } else {
        _showSnackBar(
          "This file was selected, but no readable study text was found.",
        );
      }
      return;
    }

    setState(() => _isGenerating = true);
    try {
      final generatedTest = uploadedImageBytes == null
          ? await _aiService.generateMockTest(
              syllabus: syllabus,
              difficulty: difficulty,
              testType: testType,
              duration: duration,
              questionCount: questionCount,
              focusWeakAreas: focusWeakAreas,
            )
          : await _aiService.generateMockTestFromImage(
              imageBytes: uploadedImageBytes,
              imageMimeType: _uploadedFileMimeType ?? "image/jpeg",
              difficulty: difficulty,
              testType: testType,
              duration: duration,
              questionCount: questionCount,
              focusWeakAreas: focusWeakAreas,
            );

      await _saveTest(generatedTest);

      if (!mounted) {
        return;
      }
      setState(() {
        _generatedTest = generatedTest;
        _isGeneratedTestSaved = true;
      });
      _showSnackBar("Mock test generated");
    } catch (error) {
      _showSnackBar("Could not generate test: $error");
    } finally {
      if (mounted) {
        setState(() => _isGenerating = false);
      }
    }
  }

  Future<void> _saveGeneratedTest() async {
    final generatedTest = _generatedTest;
    if (generatedTest == null || generatedTest.trim().isEmpty) {
      _showSnackBar("Generate a test first");
      return;
    }

    try {
      await _saveTest(generatedTest);
      if (mounted) {
        setState(() => _isGeneratedTestSaved = true);
      }
      _showSnackBar("Test saved");
    } catch (error) {
      _showSnackBar("Could not save test: $error");
    }
  }

  Future<void> _saveTest(String generatedTest) async {
    final syllabus = _syllabusController.text.trim();
    final title = _uploadedFileName ?? _previewText(syllabus);
    await _firestoreService.addQuizz(
      QuizzModel(
        quizzId: "",
        quizz:
            "$title | $difficulty | $testType | $duration | $questionCount",
        quizzanswer: generatedTest,
      ),
    );
    await _firestoreService.incrementTestsTaken();
    await _firestoreService.addActivity(
      title: "Mock test generated",
      subtitle: title,
    );
  }

  String _previewText(String value) {
    final compact = value.replaceAll(RegExp(r"\s+"), " ").trim();
    if (compact.length <= 80) {
      return compact;
    }
    return "${compact.substring(0, 80)}...";
  }

  String _fileExtension(String fileName) {
    final dotIndex = fileName.lastIndexOf(".");
    if (dotIndex == -1 || dotIndex == fileName.length - 1) {
      return "";
    }
    return fileName.substring(dotIndex + 1).toLowerCase();
  }

  bool _isAudioOrVideoFile({
    required String extension,
    required String mimeType,
  }) {
    if (mimeType.startsWith("audio/") || mimeType.startsWith("video/")) {
      return true;
    }

    const blockedExtensions = {
      "3g2",
      "3gp",
      "aac",
      "aiff",
      "amr",
      "avi",
      "flac",
      "m4a",
      "m4v",
      "mkv",
      "mov",
      "mp3",
      "mp4",
      "mpeg",
      "mpg",
      "ogg",
      "opus",
      "wav",
      "webm",
      "wma",
      "wmv",
    };
    return blockedExtensions.contains(extension);
  }

  bool _isImageFile({required String extension, required String mimeType}) {
    if (mimeType.startsWith("image/")) {
      return true;
    }

    const imageExtensions = {
      "bmp",
      "gif",
      "heic",
      "heif",
      "jpeg",
      "jpg",
      "png",
      "webp",
    };
    return imageExtensions.contains(extension);
  }

  String _mimeTypeForExtension(String extension) {
    switch (extension) {
      case "bmp":
        return "image/bmp";
      case "gif":
        return "image/gif";
      case "heic":
        return "image/heic";
      case "heif":
        return "image/heif";
      case "jpg":
      case "jpeg":
        return "image/jpeg";
      case "png":
        return "image/png";
      case "webp":
        return "image/webp";
      default:
        return "application/octet-stream";
    }
  }

  String _extractReadableText(Uint8List bytes) {
    final text = utf8.decode(bytes, allowMalformed: true).trim();
    if (text.isEmpty) {
      return "";
    }

    final printableCharacters = text.runes.where((rune) {
      return rune == 9 || rune == 10 || rune == 13 || rune >= 32;
    }).length;
    final printableRatio = printableCharacters / text.runes.length;
    if (printableRatio < 0.85) {
      return "";
    }

    return text;
  }

  void _showSnackBar(String message) {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}
