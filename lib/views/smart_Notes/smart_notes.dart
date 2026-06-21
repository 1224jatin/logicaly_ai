import 'package:flutter/material.dart';
import 'package:logicaly_ai_project/services/ai_services.dart';
import 'package:logicaly_ai_project/services/supabase_service.dart';
import 'package:logicaly_ai_project/services/pdf_service.dart';
import 'package:logicaly_ai_project/services/study_file_service.dart';
import 'package:logicaly_ai_project/services/voice_service.dart';
import 'package:logicaly_ai_project/views/chat/chat_bot.dart';

class SmartNotes extends StatefulWidget {
  const SmartNotes({super.key});

  @override
  State<StatefulWidget> createState() => _SmartNotes();
}

class _SmartNotes extends State<SmartNotes> {
  final SupabaseService _supabaseService = SupabaseService();
  final AiService _aiService = AiService();
  final StudyFileService _studyFileService = StudyFileService();
  final PdfService _pdfService = PdfService();
  final VoiceService _voiceService = VoiceService();

  final TextEditingController _inputController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  StudyFileResult? _uploadedFile;
  bool _isGenerating = false;
  bool _isReadingFile = false;
  bool _isSpeechInitialized = false;

  @override
  void initState() {
    super.initState();
    _initVoice();
  }

  Future<void> _initVoice() async {
    final available = await _voiceService.initialize();
    if (mounted) {
      setState(() => _isSpeechInitialized = available);
    }
  }

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
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 20),

              // ---------------- INPUT BOX ----------------
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Text Field
                    TextField(
                      controller: _inputController,
                      maxLines: 5,
                      decoration: InputDecoration(
                        hintText: "paste your topic, notes, or upload a file...",
                        border: InputBorder.none,
                        hintStyle: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 14,
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Buttons Row
                    Row(
                      children: [
                        // Upload PDF
                        _buildInputOption(
                          icon: Icons.picture_as_pdf,
                          text: _isReadingFile ? "Uploading..." : "Upload PDF",
                          iconColor: Colors.red,
                          onTap: _isReadingFile ? null : _pickStudyFile,
                        ),

                        const SizedBox(width: 12),

                        // Voice Input
                        _buildInputOption(
                          icon: _voiceService.isListening
                              ? Icons.stop_circle_rounded
                              : Icons.mic_none_rounded,
                          text: _voiceService.isListening
                              ? "Listening..."
                              : "Voice input",
                          iconColor:
                              _voiceService.isListening ? Colors.red : Colors.blue,
                          onTap: _toggleListening,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ---------------- GENERATE BUTTON ----------------
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _isGenerating ? null : _generateNotes,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3563E9),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.auto_awesome_outlined, color: Colors.white, size: 20),
                  label: Text(
                    _isGenerating ? "Generating..." : "Generate Notes",
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // ---------------- AI NOTES ----------------
              const Text(
                "AI Notes",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 16),

              // Notes Box
              Container(
                height: 300,
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: TextField(
                  controller: _notesController,
                  maxLines: null,
                  style: const TextStyle(fontSize: 14, height: 1.5),
                  decoration: InputDecoration(
                    hintText: "Your notes",
                    border: InputBorder.none,
                    hintStyle: TextStyle(color: Colors.grey.shade400),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // ---------------- ACTION BUTTONS ----------------
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Download
                  InkWell(
                    onTap: _downloadPdf,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.download_rounded, color: Colors.blue.shade700, size: 22),
                        const SizedBox(width: 8),
                        const Text(
                          "Download",
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Ask AI
                  ElevatedButton.icon(
                    onPressed: _askAiAboutNotes,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3563E9),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    icon: const Icon(Icons.smart_toy_outlined, color: Colors.white, size: 20),
                    label: const Text(
                      "ASK AI",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40),

              // ---------------- UPLOADED PDF ----------------
              const Text(
                "Uploaded PDF's",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 16),

              StreamBuilder<List<Map<String, dynamic>>>(
                stream: _supabaseService.notesStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final notes = snapshot.data ?? [];
                  if (notes.isEmpty) {
                    return _buildUploadedFileCard(); // Fallback if no history
                  }

                  return Column(
                    children: notes.map((note) => _buildNoteItem(note)).toList(),
                  );
                },
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNoteItem(Map<String, dynamic> note) {
    return GestureDetector(
      onLongPress: () => _confirmDelete(note["noteId"] as String),
      onTap: () {
        setState(() {
          _inputController.text = note["input"] as String;
          _notesController.text = note["generatedNote"] as String;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.picture_as_pdf, color: Colors.red, size: 28),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    note["input"] as String,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    "Generated AI Note - Tap to view",
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _toggleListening() {
    if (!_isSpeechInitialized) {
      _showSnackBar("Speech recognition not available");
      return;
    }

    if (_voiceService.isListening) {
      _voiceService.stopListening();
      setState(() {});
    } else {
      _voiceService.startListening(
        onResult: (text) {
          setState(() {
            _inputController.text = text;
          });
        },
      );
      setState(() {});
    }
  }

  Future<void> _downloadPdf() async {
    final title = _inputController.text.trim().isEmpty
        ? "Logicaly AI Notes"
        : _inputController.text.trim();
    final content = _notesController.text.trim();

    if (content.isEmpty) {
      _showSnackBar("Generate notes first before downloading");
      return;
    }

    try {
      await _pdfService.generateAndSavePdf(title: title, content: content);
    } catch (e) {
      _showSnackBar("Failed to download PDF: $e");
    }
  }

  Future<void> _confirmDelete(String noteId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Note"),
        content: const Text("Are you sure you want to delete this note?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _supabaseService.deleteNote(noteId);
      _showSnackBar("Note deleted");
    }
  }

  // ---------------- UI COMPONENTS ----------------

  Widget _buildInputOption({
    required IconData icon,
    required String text,
    required Color iconColor,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.blue.shade50.withOpacity(0.5)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: iconColor, size: 16),
            const SizedBox(width: 6),
            Text(
              text,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.blue.shade900.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadedFileCard() {
    final uploadedFile = _uploadedFile;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.picture_as_pdf,
              color: Colors.red,
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  uploadedFile?.fileName ?? "Cryptography Notes.pdf",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  uploadedFile == null
                      ? "82 pages - 1.9 MB - PDF"
                      : "${uploadedFile.isImage ? "Image" : "PDF"} - ${uploadedFile.fileName.split('.').last.toUpperCase()}",
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
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
      await _supabaseService.addNote(
        input: input.isEmpty ? uploadedFile?.fileName ?? "Uploaded file" : input,
        generatedNote: generated,
      );
      await _supabaseService.addActivity(
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
    await _supabaseService.addNote(input: title, generatedNote: notes);
    await _supabaseService.addActivity(
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
