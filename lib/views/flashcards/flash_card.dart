import 'package:flutter/material.dart';
import 'package:logicaly_ai_project/models/flashcard_model.dart';
import 'package:logicaly_ai_project/services/ai_services.dart';
import 'package:logicaly_ai_project/services/supabase_service.dart';
import 'package:logicaly_ai_project/services/study_file_service.dart';
import 'package:logicaly_ai_project/views/flashcards/manual_flashcards.dart';

class FlashCard extends StatefulWidget {
  const FlashCard({super.key});

  @override
  State<StatefulWidget> createState() => _FlashCard();
}

class _FlashCard extends State<FlashCard> {
  static const String _flashcardsIconAsset =
      "assets/images/icons/flashcards_icon.png";

  final AiService _aiService = AiService();
  final SupabaseService _supabaseService = SupabaseService();
  final StudyFileService _studyFileService = StudyFileService();
  final TextEditingController _aiInputController = TextEditingController();

  Stream<List<FlashcardModel>>? _flashcardsStream;
  StudyFileResult? _uploadedFile;
  bool _isGenerating = false;
  bool _isReadingFile = false;

  @override
  void initState() {
    super.initState();
    _flashcardsStream = _supabaseService.flashcardsStream();
  }

  @override
  void dispose() {
    _aiInputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              const Text(
                "Flashcards",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 5),
              const Text(
                "Revise through quick question-answer cards",
                style: TextStyle(color: Colors.black54, fontSize: 14),
              ),
              const SizedBox(height: 22),
              _buildDeckSummary(),
              const SizedBox(height: 24),
              _buildAiCreator(),
              const SizedBox(height: 24),
              const Text(
                "Create Flashcards",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              InkWell(
                borderRadius: BorderRadius.circular(18),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ManualFlashcards(),
                    ),
                  );
                },
                child: buildFlashcardOption(
                  icon: Icons.edit_outlined,
                  title: "Manual Flashcards",
                  subtitle: "Create, flip, and revise your cards",
                ),
              ),
              const SizedBox(height: 14),
              InkWell(
                borderRadius: BorderRadius.circular(18),
                onTap: _isGenerating ? null : _generateFlashcards,
                child: buildFlashcardOption(
                  icon: Icons.smart_toy,
                  title: "Generate with AI",
                  subtitle: "Use the material above to create cards",
                ),
              ),
              const SizedBox(height: 28),
              _buildRecentCards(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDeckSummary() {
    return StreamBuilder<List<FlashcardModel>>(
      stream: _flashcardsStream,
      builder: (context, snapshot) {
        final cards = snapshot.data ?? [];
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Image.asset(
                    _flashcardsIconAsset,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cards.isEmpty
                          ? "No flashcards yet"
                          : "${cards.length} flashcards ready",
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      "Build a deck from notes, files, or images.",
                      style: TextStyle(color: Colors.black54, fontSize: 13),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: cards.isEmpty
                    ? null
                    : () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ManualFlashcards(),
                          ),
                        );
                      },
                icon: const Icon(Icons.arrow_forward_ios),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAiCreator() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "AI Flashcards",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _aiInputController,
            maxLines: 6,
            decoration: InputDecoration(
              hintText: "Paste a topic, syllabus, notes, or important points...",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _isReadingFile ? null : _pickStudyFile,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: _isReadingFile
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.upload_file),
                  label: Text(_isReadingFile ? "Uploading..." : "Upload File"),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _isGenerating ? null : _generateFlashcards,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3563E9),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: _isGenerating
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.auto_awesome, color: Colors.white),
                  label: Text(
                    _isGenerating ? "Generating..." : "Generate",
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildUploadedFileStatus(),
        ],
      ),
    );
  }

  Widget _buildUploadedFileStatus() {
    final uploadedFile = _uploadedFile;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F9FC),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            uploadedFile?.isImage == true
                ? Icons.image_outlined
                : Icons.insert_drive_file_outlined,
            color: Colors.blue,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              uploadedFile == null
                  ? "Upload any file except audio/video"
                  : uploadedFile.isImage
                  ? "${uploadedFile.fileName} - image"
                  : uploadedFile.hasReadableText
                  ? "${uploadedFile.fileName} - text added"
                  : "${uploadedFile.fileName} - paste notes too",
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.black54, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentCards() {
    return StreamBuilder<List<FlashcardModel>>(
      stream: _flashcardsStream,
      builder: (context, snapshot) {
        final cards = snapshot.data ?? [];
        if (cards.isEmpty) {
          return const SizedBox.shrink();
        }

        final recentCards = cards.take(3).toList();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Recent Cards",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...recentCards.map(
              (card) => Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      card.cardQues,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      card.cardAns,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.black54),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _pickStudyFile() async {
    setState(() => _isReadingFile = true);
    try {
      final file = await _studyFileService.pickStudyFile();
      if (file == null) {
        return;
      }

      if (file.hasReadableText) {
        final existingText = _aiInputController.text.trim();
        _aiInputController.text = [
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

  Future<void> _generateFlashcards() async {
    final input = _aiInputController.text.trim();
    final uploadedFile = _uploadedFile;
    if (input.isEmpty && uploadedFile?.imageBytes == null) {
      if (uploadedFile == null) {
        _showSnackBar("Paste notes or upload a file first");
      } else {
        _showSnackBar("Selected file has no readable study text");
      }
      return;
    }

    setState(() => _isGenerating = true);
    try {
      final cards = uploadedFile?.imageBytes == null
          ? await _aiService.generateFlashcards(input)
          : await _aiService.generateFlashcardsFromImage(
              imageBytes: uploadedFile!.imageBytes!,
              imageMimeType: uploadedFile.mimeType,
            );

      if (cards.isEmpty) {
        _showSnackBar("AI did not return usable flashcards");
        return;
      }

      for (final card in cards) {
        await _supabaseService.addFlashcard(card);
      }
      await _supabaseService.addActivity(
        title: "AI flashcards created",
        subtitle: input.isEmpty
            ? uploadedFile?.fileName ?? "Uploaded file"
            : input,
      );

      _aiInputController.clear();
      if (mounted) {
        setState(() => _uploadedFile = null);
      }
      _showSnackBar("${cards.length} flashcards created");
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ManualFlashcards()),
        );
      }
    } catch (error) {
      _showSnackBar("Could not create flashcards: $error");
    } finally {
      if (mounted) {
        setState(() => _isGenerating = false);
      }
    }
  }

  Widget buildFlashcardOption({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.blue, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.black54, fontSize: 13),
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios, size: 18, color: Colors.black54),
        ],
      ),
    );
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
