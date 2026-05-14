import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MockTestScreen extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => _MockTestScreen();

}
class _MockTestScreen extends State<MockTestScreen>{
  String difficulty = "Medium";
  String testType = "MCQ+Coding";
  String duration = "60 Min";

  bool focusWeakAreas = true;
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

              // ================= TITLE =================

              const Text(
                "Mock Test",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 30),

              // ================= TOP SECTION =================

              Row(
                crossAxisAlignment: CrossAxisAlignment.center,

                children: [

                  const Expanded(
                    child: Text(
                      "Lets Create Your\nPersonalized Test",
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),

                  // Illustration
                  Container(
                    width: 120,
                    height: 120,

                    decoration: BoxDecoration(
                      color: Colors.blue.shade100,
                      borderRadius: BorderRadius.circular(20),
                    ),

                    child: const Icon(
                      Icons.assignment_turned_in,
                      size: 70,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // ================= SYLLABUS SECTION =================

              const Text(
                "Add your Syllabus/Notes/Topics",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 14),

              Container(
                padding: const EdgeInsets.all(14),

                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: Colors.grey.shade300,
                  ),
                ),

                child: Column(
                  children: [

                    // Upload PDF
                    Container(
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

                          const Icon(
                            Icons.upload_file,
                            color: Colors.blue,
                          ),

                          const SizedBox(width: 10),

                          Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,

                            children: const [

                              Text(
                                "Upload File",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              SizedBox(height: 3),

                              Text(
                                "PDF,DOC,TXT",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 14),

                    // Divider
                    Row(
                      children: const [

                        Expanded(child: Divider()),

                        Padding(
                          padding:
                          EdgeInsets.symmetric(horizontal: 10),
                          child: Text("or"),
                        ),

                        Expanded(child: Divider()),
                      ],
                    ),

                    const SizedBox(height: 14),

                    // Text Area
                    TextField(
                      maxLines: 5,

                      decoration: InputDecoration(
                        hintText:
                        "e.g. Binary Search, Trees, DBMS Normalization,\nOperating System...",

                        border: OutlineInputBorder(
                          borderRadius:
                          BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 22),

              // ================= NEW BUTTON =================

              SizedBox(
                width: 140,
                height: 50,

                child: ElevatedButton(
                  onPressed: () {},

                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                    const Color(0xFF3563E9),

                    shape: RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.circular(10),
                    ),
                  ),

                  child: const Text(
                    "NEW",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // ================= TEST PREFERENCES =================

              const Text(
                "Test Preferences",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
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

                    // Difficulty
                    buildDropdownRow(
                      icon: Icons.bar_chart,
                      iconColor: Colors.purple,
                      title: "Difficulty Level",
                      value: difficulty,
                      items: [
                        "Easy",
                        "Medium",
                        "Hard",
                      ],
                      onChanged: (value) {
                        setState(() {
                          difficulty = value!;
                        });
                      },
                    ),

                    const SizedBox(height: 18),

                    // Test Type
                    buildDropdownRow(
                      icon: Icons.description,
                      iconColor: Colors.red,
                      title: "Test Type",
                      value: testType,
                      items: [
                        "MCQ",
                        "Coding",
                        "MCQ+Coding",
                      ],
                      onChanged: (value) {
                        setState(() {
                          testType = value!;
                        });
                      },
                    ),

                    const SizedBox(height: 18),

                    // Duration
                    buildDropdownRow(
                      icon: Icons.access_time,
                      iconColor: Colors.blue,
                      title: "Duration",
                      value: duration,
                      items: [
                        "30 Min",
                        "60 Min",
                        "90 Min",
                      ],
                      onChanged: (value) {
                        setState(() {
                          duration = value!;
                        });
                      },
                    ),

                    const SizedBox(height: 18),

                    // Switch
                    Container(
                      padding: const EdgeInsets.all(14),

                      decoration: BoxDecoration(
                        color: const Color(0xFFF7F9FC),
                        borderRadius:
                        BorderRadius.circular(14),
                      ),

                      child: Row(
                        children: [

                          const Icon(
                            Icons.auto_awesome,
                            color: Colors.indigo,
                          ),

                          const SizedBox(width: 12),

                          const Expanded(
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,

                              children: [

                                Text(
                                  "Focus on my weak area",
                                  style: TextStyle(
                                    fontWeight:
                                    FontWeight.bold,
                                  ),
                                ),

                                SizedBox(height: 4),

                                Text(
                                  "AI will prioritize your weak topics",
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

              const SizedBox(height: 24),

              // ================= GENERATE BUTTON =================

              SizedBox(
                width: double.infinity,
                height: 56,

                child: ElevatedButton.icon(
                  onPressed: () {},

                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                    const Color(0xFF3563E9),

                    shape: RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.circular(14),
                    ),
                  ),

                  icon: const Icon(
                    Icons.auto_awesome,
                    color: Colors.white,
                  ),

                  label: const Text(
                    "Generate My Test",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // ================= QUICK TEST =================

              Container(
                padding: const EdgeInsets.all(16),

                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                ),

                child: Row(
                  children: [

                    const Icon(
                      Icons.flash_on,
                      color: Colors.orange,
                    ),

                    const SizedBox(width: 10),

                    RichText(
                      text: const TextSpan(
                        text: "Quick Test ",
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                        children: [
                          TextSpan(
                            text:
                            "→ Generate a random test",
                            style: TextStyle(
                              color: Colors.black54,
                              fontWeight:
                              FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  // ================= DROPDOWN WIDGET =================

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

        Icon(
          icon,
          color: iconColor,
        ),

        const SizedBox(width: 12),

        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
            ),
          ),
        ),

        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
          ),

          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.grey.shade300,
            ),
            borderRadius: BorderRadius.circular(10),
          ),

          child: DropdownButton<String>(
            value: value,
            underline: const SizedBox(),

            items: items.map((item) {
              return DropdownMenuItem(
                value: item,
                child: Text(item),
              );
            }).toList(),

            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

}