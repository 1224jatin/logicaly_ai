import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:logicaly_ai_project/models/flashcard_model.dart';
import 'package:logicaly_ai_project/services/supabase_service.dart';

class ManualFlashcards extends StatefulWidget {
  const ManualFlashcards({super.key});

  @override
  State<StatefulWidget> createState() => _ManualFlashcards();
}

class _ManualFlashcards extends State<ManualFlashcards> {
  final SupabaseService _supabaseService = SupabaseService();
  final TextEditingController addQuestion = TextEditingController();
  final TextEditingController addAnswer = TextEditingController();

  Stream<List<FlashcardModel>>? _flashcardsStream;

  int currentCard = 0;
  bool showAnswer = false;

  @override
  void initState() {
    super.initState();
    _flashcardsStream = _supabaseService.flashcardsStream();
  }

  @override
  void dispose() {
    addQuestion.dispose();
    addAnswer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF5B82F7),
        onPressed: showDialoge,
        child: const Icon(Icons.add, color: Colors.white, size: 32),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: StreamBuilder<List<FlashcardModel>>(
            stream: _flashcardsStream,
            builder: (context, snapshot) {
              final cards = snapshot.data ?? [];
              if (currentCard >= cards.length && cards.isNotEmpty) {
                currentCard = cards.length - 1;
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.arrow_back_ios),
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        "Flashcards",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Padding(
                    padding: EdgeInsets.only(left: 14),
                    child: Text(
                      "Revise through Flashcards",
                      style: TextStyle(color: Colors.black54, fontSize: 14),
                    ),
                  ),
                  const SizedBox(height: 26),
                  Expanded(
                    child: _buildFlashcardBody(cards, snapshot.connectionState),
                  ),
                  const SizedBox(height: 20),
                  _buildNavigation(cards),
                  const SizedBox(height: 20),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildFlashcardBody(
    List<FlashcardModel> cards,
    ConnectionState connectionState,
  ) {
    if (connectionState == ConnectionState.waiting && cards.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (cards.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: const Center(
          child: Text(
            "Tap + to add your first flashcard.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black54, fontSize: 18),
          ),
        ),
      );
    }

    final card = cards[currentCard];
    return InkWell(
      onTap: () => setState(() => showAnswer = !showAnswer),
      borderRadius: BorderRadius.circular(24),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 420),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        transitionBuilder: (child, animation) {
          final rotateAnimation = Tween<double>(
            begin: math.pi,
            end: 0,
          ).animate(animation);

          return AnimatedBuilder(
            animation: rotateAnimation,
            child: child,
            builder: (context, child) {
              final isUnder = ValueKey(showAnswer) != child?.key;
              var rotationY = rotateAnimation.value;
              if (isUnder) {
                rotationY -= math.pi;
              }

              return Transform(
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.001)
                  ..rotateY(rotationY),
                alignment: Alignment.center,
                child: child,
              );
            },
          );
        },
        layoutBuilder: (currentChild, previousChildren) {
          return Stack(
            fit: StackFit.expand,
            children: [
              ...previousChildren,
              if (currentChild != null) currentChild,
            ],
          );
        },
        child: _buildCardFace(
          key: ValueKey(showAnswer),
          title: showAnswer ? "Answer" : "Question",
          text: showAnswer ? card.cardAns : card.cardQues,
        ),
      ),
    );
  }

  Widget _buildCardFace({
    required Key key,
    required String title,
    required String text,
  }) {
    return Container(
      key: key,
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
          ),
          Expanded(
            child: Center(
              child: Text(
                text,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20,
                  height: 1.3,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          const Text(
            "Tap card to flip",
            style: TextStyle(color: Colors.black45),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildNavigation(List<FlashcardModel> cards) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SizedBox(
          width: 140,
          height: 56,
          child: OutlinedButton.icon(
            onPressed: cards.isEmpty || currentCard == 0
                ? null
                : () {
                    setState(() {
                      currentCard--;
                      showAnswer = false;
                    });
                  },
            style: OutlinedButton.styleFrom(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            label: const Text(
              "Previous",
              style: TextStyle(color: Colors.black, fontSize: 18),
            ),
          ),
        ),
        SizedBox(
          width: 140,
          height: 56,
          child: OutlinedButton(
            onPressed: cards.isEmpty || currentCard >= cards.length - 1
                ? null
                : () {
                    setState(() {
                      currentCard++;
                      showAnswer = false;
                    });
                  },
            style: OutlinedButton.styleFrom(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Next",
                  style: TextStyle(color: Colors.black, fontSize: 18),
                ),
                SizedBox(width: 6),
                Icon(Icons.arrow_forward, color: Colors.black),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> showDialoge() async {
    addQuestion.clear();
    addAnswer.clear();

    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Add Flashcard"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: addQuestion,
                decoration: const InputDecoration(label: Text("Question")),
              ),
              TextField(
                controller: addAnswer,
                decoration: const InputDecoration(label: Text("Answer")),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                if (addQuestion.text.trim().isEmpty ||
                    addAnswer.text.trim().isEmpty) {
                  return;
                }

                final navigator = Navigator.of(context);
                FocusScope.of(context).unfocus();

                await _supabaseService.addFlashcard(
                  FlashcardModel(
                    cardId: "",
                    cardQues: addQuestion.text.trim(),
                    cardAns: addAnswer.text.trim(),
                  ),
                );
                await _supabaseService.addActivity(
                  title: "Flashcard created",
                  subtitle: addQuestion.text.trim(),
                );

                if (mounted) {
                  navigator.pop();
                }
              },
              child: const Text("Add"),
            ),
          ],
        );
      },
    );
  }
}
