import 'package:flutter/material.dart';
import 'package:logicaly_ai_project/services/ai_services.dart';
import 'package:logicaly_ai_project/services/fire_store_services.dart';
import 'package:logicaly_ai_project/services/study_file_service.dart';
import 'package:logicaly_ai_project/views/chat/chat_bot.dart';

class SmartNotes extends StatefulWidget {
  const SmartNotes({super.key});

  @override
  State<StatefulWidget> createState() => _SmartNotes();
}

class _SmartNotes extends State<SmartNotes> {
  final FirestoreService _firestoreService = FirestoreService();
  final AiService _aiService = AiService();
  final StudyFileService _studyFileService = StudyFileService();
  final TextEditingController _inputController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  StudyFileResult? _uploadedFile;
  bool _isGenerating = false;
  bool _isReadingFile = false;

  @override
  void dispose() {
    _inputController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),

      // ---------------- BODY ----------------
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              // ---------------- TITLE ----------------
              const Text(
                "Smart Notes",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 20),

              // ---------------- INPUT BOX ----------------
              Container(
                padding: const EdgeInsets.all(14),

                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                ),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    // Text Field
                    TextField(
                      controller: _inputController,
                      maxLines: 6,

                      decoration: InputDecoration(
                        hintText:
                            "paste your topic, notes, or upload a file...",

                        border: InputBorder.none,

                        hintStyle: TextStyle(color: Colors.grey.shade500),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Buttons Row
                    Row(
                      children: [
                        // Upload PDF
                        buildSmallButton(
                          icon: Icons.picture_as_pdf,
                          text: _isReadingFile ? "Uploading..." : "Upload",
                          iconColor: Colors.red,
                          onTap: _isReadingFile ? null : _pickStudyFile,
                        ),

                        const SizedBox(width: 12),

                        // Voice Input
                        buildSmallButton(
                          icon: Icons.mic,
                          text: "Voice input",
                          iconColor: Colors.blue,
                          onTap: () => _showSnackBar("Voice input coming soon"),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 22),

              // ---------------- GENERATE BUTTON ----------------
              SizedBox(
                width: double.infinity,
                height: 56,

                child: ElevatedButton.icon(
                  onPressed: _isGenerating ? null : _generateNotes,

                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3563E9),

                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),

                  icon: const Icon(Icons.auto_awesome, color: Colors.white),

                  label: Text(
                    _isGenerating ? "Generating..." : "Generate Notes",
                    style: const TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // ---------------- AI NOTES ----------------
              const Text(
                "AI Notes",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 14),

              // Notes Box
              Container(
                height: 260,
                width: double.infinity,
                padding: const EdgeInsets.all(14),

                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                ),

                child: TextField(
                  controller: _notesController,
                  maxLines: null,

                  decoration: InputDecoration(
                    hintText: "Your notes",
                    border: InputBorder.none,

                    hintStyle: TextStyle(color: Colors.grey.shade500),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ---------------- ACTION BUTTONS ----------------
              Row(
                children: [
                  // Download
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _saveNotes,

                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),

                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),

                      icon: const Icon(Icons.download),

                      label: const Text("Save"),
                    ),
                  ),

                  const SizedBox(width: 14),

                  // Ask AI
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _askAiAboutNotes,

                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3563E9),

                        padding: const EdgeInsets.symmetric(vertical: 16),

                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),

                      icon: const Icon(Icons.auto_awesome, color: Colors.white),

                      label: const Text(
                        "Ask AI",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // ---------------- UPLOADED PDF ----------------
              const Text(
                "Uploaded File",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 16),

              _buildUploadedFileCard(),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------- SMALL BUTTON ----------------

  Widget buildSmallButton({
    required IconData icon,
    required String text,
    required Color iconColor,
    VoidCallback? onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 18),
            const SizedBox(width: 6),
            Text(
              text,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadedFileCard() {
    final uploadedFile = _uploadedFile;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              uploadedFile?.isImage == true
                  ? Icons.image_outlined
                  : Icons.insert_drive_file_outlined,
              color: Colors.red,
              size: 32,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  uploadedFile?.fileName ?? "No file uploaded",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  uploadedFile == null
                      ? "Upload any file except audio/video"
                      : uploadedFile.isImage
                      ? "Image file - Groq vision will read it"
                      : uploadedFile.hasReadableText
                      ? "Readable text added to input"
                      : "Selected, but no readable text found",
                  style: const TextStyle(color: Colors.black54, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _generateNotes() async {
    final input = _inputController.text.trim();
    final uploadedFile = _uploadedFile;
    if (input.isEmpty && uploadedFile?.imageBytes == null) {
      if (uploadedFile == null) {
        _showSnackBar("Please enter a topic, notes, or upload a file first");
      } else {
        _showSnackBar("Selected file has no readable study text");
      }
      return;
    }

    setState(() => _isGenerating = true);
    try {
      final generated = uploadedFile?.imageBytes == null
          ? await _aiService.generateNotes(input)
          : await _aiService.generateNotesFromImage(
              imageBytes: uploadedFile!.imageBytes!,
              imageMimeType: uploadedFile.mimeType,
            );
      _notesController.text = generated;
      await _firestoreService.addNote(
        input: input.isEmpty ? uploadedFile?.fileName ?? "Uploaded file" : input,
        generatedNote: generated,
      );
      await _firestoreService.addActivity(
        title: "Smart notes generated",
        subtitle: input.isEmpty ? uploadedFile?.fileName ?? "Uploaded file" : input,
      );
    } catch (error) {
      _showSnackBar("Could not generate notes: $error");
    } finally {
      if (mounted) {
        setState(() => _isGenerating = false);
      }
    }
  }

  Future<void> _pickStudyFile() async {
    setState(() => _isReadingFile = true);
    try {
      final file = await _studyFileService.pickStudyFile();
      if (file == null) {
        return;
      }

      if (file.hasReadableText) {
        final existingText = _inputController.text.trim();
        _inputController.text = [
          if (existingText.isNotEmpty) existingText,
          "Uploaded file: ${file.fileName}",
          file.text,
        ].join("\n\n");
      }

      setState(() => _uploadedFile = file);
      _showSnackBar(
        file.isImage
            ? "Image uploaded"
            : file.hasReadableText
            ? "File text added"
            : "File selected, but paste notes too",
      );
    } catch (error) {
      _showSnackBar("Could not upload file: $error");
    } finally {
      if (mounted) {
        setState(() => _isReadingFile = false);
      }
    }
  }

  Future<void> _saveNotes() async {
    final input = _inputController.text.trim();
    final notes = _notesController.text.trim();
    if (notes.isEmpty) {
      _showSnackBar("No notes to save yet");
      return;
    }

    final title = input.isEmpty
        ? _uploadedFile?.fileName ?? "Manual note"
        : input;
    await _firestoreService.addNote(input: title, generatedNote: notes);
    await _firestoreService.addActivity(
      title: "Notes saved",
      subtitle: title,
    );
    _showSnackBar("Notes saved");
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _askAiAboutNotes() {
    final notes = _notesController.text.trim();
    if (notes.isEmpty) {
      _showSnackBar("Generate or write notes first");
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatBot(
          initialPrompt: "Help me understand and revise these notes:\n\n$notes",
        ),
      ),
    );
  }
}
