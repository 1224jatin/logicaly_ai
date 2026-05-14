import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SmartNotes extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _SmartNotes();

}
class _SmartNotes extends State<SmartNotes>{
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
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
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
                      maxLines: 6,

                      decoration: InputDecoration(
                        hintText:
                        "paste your topic, notes, or upload a file...",

                        border: InputBorder.none,

                        hintStyle: TextStyle(
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Buttons Row
                    Row(
                      children: [

                        // Upload PDF
                        buildSmallButton(
                          icon: Icons.picture_as_pdf,
                          text: "Upload PDF",
                          iconColor: Colors.red,
                        ),

                        const SizedBox(width: 12),

                        // Voice Input
                        buildSmallButton(
                          icon: Icons.mic,
                          text: "Voice input",
                          iconColor: Colors.blue,
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
                  onPressed: () {},

                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3563E9),

                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),

                  icon: const Icon(
                    Icons.auto_awesome,
                    color: Colors.white,
                  ),

                  label: const Text(
                    "Generate Notes",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // ---------------- AI NOTES ----------------
              const Text(
                "AI Notes",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
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
                  maxLines: null,

                  decoration: InputDecoration(
                    hintText: "Your notes",
                    border: InputBorder.none,

                    hintStyle: TextStyle(
                      color: Colors.grey.shade500,
                    ),
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
                      onPressed: () {},

                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),

                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),

                      icon: const Icon(Icons.download),

                      label: const Text("Download"),
                    ),
                  ),

                  const SizedBox(width: 14),

                  // Ask AI
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {},

                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3563E9),

                        padding: const EdgeInsets.symmetric(vertical: 16),

                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),

                      icon: const Icon(
                        Icons.auto_awesome,
                        color: Colors.white,
                      ),

                      label: const Text(
                        "Ask AI",
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // ---------------- UPLOADED PDF ----------------
              const Text(
                "Uploaded PDF's",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 16),

              // PDF Card
              Container(
                padding: const EdgeInsets.all(14),

                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                ),

                child: Row(
                  children: [

                    // PDF Icon
                    Container(
                      padding: const EdgeInsets.all(12),

                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),

                      child: const Icon(
                        Icons.picture_as_pdf,
                        color: Colors.red,
                        size: 32,
                      ),
                    ),

                    const SizedBox(width: 14),

                    // File Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,

                        children: const [

                          Text(
                            "Cryptography Notes.pdf",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          SizedBox(height: 4),

                          Text(
                            "82 pages - 1.9 MB - PDF",
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

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
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 10,
      ),

      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(12),
      ),

      child: Row(
        children: [

          Icon(
            icon,
            color: iconColor,
            size: 18,
          ),

          const SizedBox(width: 6),

          Text(
            text,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );

  }

}