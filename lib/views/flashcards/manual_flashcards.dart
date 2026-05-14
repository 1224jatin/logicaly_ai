import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ManualFlashcards extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => _ManualFlashcards();

}
class _ManualFlashcards extends State<ManualFlashcards>{
  int currentCard = 1;

  final List<String> flashcards = [
    "Glassmorphism is a UI style that looks like frosted glass—using transparent backgrounds, blur effects, and soft borders.",

    "Flutter is an open-source UI toolkit developed by Google.",

    "Provider is used for state management in Flutter apps.",
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),

      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF5B82F7),
        onPressed: () {
          //
        },

        child: const Icon(
          Icons.add,
          color: Colors.white,
          size: 32,
        ),
      ),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [

              const SizedBox(height: 10),

              // ================= TOP BAR =================

              Row(
                children: [

                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },

                    icon: const Icon(
                      Icons.arrow_back_ios,
                    ),
                  ),

                  const SizedBox(width: 4),

                  const Text(
                    "UX/UI",
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
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 14,
                  ),
                ),
              ),

              const SizedBox(height: 26),

              // ================= FLASHCARD =================

              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(22),

                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                    BorderRadius.circular(24),

                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.12),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),

                  child: Column(
                    children: [

                      // Title
                      const Text(
                        "Answer",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      // Content
                      Expanded(
                        child: Center(
                          child: Text(
                            flashcards[currentCard - 1],
                            textAlign: TextAlign.center,

                            style: const TextStyle(
                              fontSize: 20,
                              height: 1.3,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),

                      // Bottom Icons
                      Row(
                        mainAxisAlignment:
                        MainAxisAlignment.center,

                        children: const [

                          Icon(
                            Icons.close,
                            color: Colors.red,
                            size: 42,
                          ),

                          SizedBox(width: 80),

                          Icon(
                            Icons.check,
                            color: Colors.green,
                            size: 42,
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ================= BUTTONS =================

              Row(
                mainAxisAlignment:
                MainAxisAlignment.spaceBetween,

                children: [

                  // Previous Button
                  SizedBox(
                    width: 140,
                    height: 56,

                    child: OutlinedButton.icon(
                      onPressed: () {
                        if (currentCard > 1) {
                          setState(() {
                            currentCard--;
                          });
                        }
                      },

                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.white,

                        shape: RoundedRectangleBorder(
                          borderRadius:
                          BorderRadius.circular(20),
                        ),
                      ),

                      icon: const Icon(
                        Icons.arrow_back,
                        color: Colors.black,
                      ),

                      label: const Text(
                        "Previous",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),

                  // Next Button
                  SizedBox(
                    width: 140,
                    height: 56,

                    child: OutlinedButton(
                      onPressed: () {
                        if (currentCard <
                            flashcards.length) {
                          setState(() {
                            currentCard++;
                          });
                        }
                      },

                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.white,

                        shape: RoundedRectangleBorder(
                          borderRadius:
                          BorderRadius.circular(20),
                        ),
                      ),

                      child: Row(
                        mainAxisAlignment:
                        MainAxisAlignment.center,

                        children: const [

                          Text(
                            "Next",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                            ),
                          ),

                          SizedBox(width: 6),

                          Icon(
                            Icons.arrow_forward,
                            color: Colors.black,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

}