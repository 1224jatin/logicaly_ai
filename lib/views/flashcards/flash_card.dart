import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class FlashCard extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _FlashCard();

}
class _FlashCard extends State<FlashCard>{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [

                  const SizedBox(height: 40),

                  // Title
                  const Text(
                    "Flashcards",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 5),

                  // Subtitle
                  const Text(
                    "Revise through Flashcards",
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 14,
                    ),
                  ),

                  const SizedBox(height: 25),

                  // Empty Flashcard Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(22),

                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                    ),

                    child: Column(
                      children: [

                        // Image
                        Image.network(
                          "https://cdn-icons-png.flaticon.com/512/6134/6134065.png",
                          height: 140,
                        ),

                        const SizedBox(height: 15),

                        // Title
                        const Text(
                          "No Flashcards Yet!",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 10),

                        // Description
                        const Text(
                          "Create your first flashcard set and\nstart learning smarter.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.black54,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Create Flashcards Text
                  const Text(
                    "Create Flashcards",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Manual Flashcards
                  InkWell(child:
                  buildFlashcardOption(
                    icon: Icons.edit_outlined,
                    title: "Manual Flashcards",
                    subtitle: "Create your own flashcards",
                  ),onTap: (){
                    //DIALOGUE BOX HERE


                  },),

                  const SizedBox(height: 16),

                  // AI Flashcards
                 InkWell(
                   child: buildFlashcardOption(
                     icon: Icons.smart_toy,
                     title: "AI Flashcards",
                     subtitle: "Create flashcards using AI",
                   ), onTap: (){
                     //DIALOGUE BOX HERE
                 },
                 )
                ],
              ),
        )
        ),
      ),
    );
  }

  // ---------------- OPTION CARD ----------------

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
        border: Border.all(
          color: Colors.grey.shade300,
        ),
      ),

      child: Row(
        children: [

          // Icon
          Container(
            padding: const EdgeInsets.all(10),

            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),

            child: Icon(
              icon,
              color: Colors.blue,
              size: 24,
            ),
          ),

          const SizedBox(width: 14),

          // Texts
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
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),

          // Arrow
          const Icon(
            Icons.arrow_forward_ios,
            size: 18,
            color: Colors.black54,
          ),
        ],
      ),
    );
  }

}