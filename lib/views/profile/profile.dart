import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Profile extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => _Profile();

}
class _Profile extends State<Profile>{
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

              // ================= TITLE =================

              const Text(
                "Profile",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),

              // ================= PROFILE CARD =================

              Container(
                padding: const EdgeInsets.all(16),

                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),

                child: Row(
                  children: [

                    // Profile Image
                    const CircleAvatar(
                      radius: 34,
                      backgroundImage: NetworkImage(
                        "https://i.pravatar.cc/300",
                      ),
                    ),

                    const SizedBox(width: 16),

                    // User Info
                    const Expanded(
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,

                        children: [

                          Text(
                            "Student",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          SizedBox(height: 6),

                          Text(
                            "Student@gmail.com",
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Edit Icon
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.edit_outlined),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 26),

              // ================= PROGRESS TITLE =================

              Row(
                mainAxisAlignment:
                MainAxisAlignment.spaceBetween,

                children: const [

                  Text(
                    "Your Progress",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  Row(
                    children: [

                      Text(
                        "4 Days Streak",
                        style: TextStyle(
                          color: Colors.black54,
                          fontSize: 14,
                        ),
                      ),

                      SizedBox(width: 4),

                      Icon(
                        Icons.local_fire_department,
                        color: Colors.red,
                        size: 20,
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // ================= DAILY GOAL ROW =================

              Row(
                children: [

                  const Expanded(
                    child: Text(
                      "Set your daily study goal",
                      style: TextStyle(
                        fontSize: 15,
                      ),
                    ),
                  ),

                  // Time Box
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),

                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                      BorderRadius.circular(10),
                    ),

                    child: const Text(
                      "30 Min",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.edit_outlined,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // ================= DAILY GOAL CARD =================

              Container(
                padding: const EdgeInsets.all(16),

                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                ),

                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,

                  children: [

                    // Title
                    Row(
                      mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,

                      children: const [

                        Text(
                          "Daily Goal",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        Icon(
                          Icons.track_changes,
                          color: Colors.blue,
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    // Progress Bar
                    ClipRRect(
                      borderRadius:
                      BorderRadius.circular(10),

                      child: LinearProgressIndicator(
                        value: 0.6,
                        minHeight: 8,
                        backgroundColor:
                        Colors.grey.shade300,
                        color: Colors.blue,
                      ),
                    ),

                    const SizedBox(height: 12),

                    const Text(
                      "20/30 Minutes Completed",
                      style: TextStyle(
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 22),

              // ================= STATS =================

              Row(
                children: [

                  // Test Taken
                  Expanded(
                    child: buildStatCard(
                      icon: Icons.auto_awesome,
                      iconColor: Colors.purple,
                      value: "12",
                      label: "Test Taken",
                    ),
                  ),

                  const SizedBox(width: 14),

                  // Time Spent
                  Expanded(
                    child: buildStatCard(
                      icon: Icons.access_time,
                      iconColor: Colors.blue,
                      value: "14h",
                      label: "Time Spent",
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // ================= RECENT ACTIVITY =================

              const Text(
                "Recent Activity",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 18),

              // Activity 1
              buildActivityCard(
                title: "UX/UI Flashcards",
                subtitle: "1 hour ago",
              ),

              const SizedBox(height: 14),

              // Activity 2
              buildActivityCard(
                title: "Mock Test: DSA",
                subtitle: "2 hours ago",
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // ================= STAT CARD =================

  Widget buildStatCard({
    required IconData icon,
    required Color iconColor,
    required String value,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [

          Icon(
            icon,
            color: iconColor,
          ),

          const SizedBox(height: 12),

          Text(
            value,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            label,
            style: const TextStyle(
              color: Colors.black54,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  // ================= ACTIVITY CARD =================

  Widget buildActivityCard({
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),

      child: Row(
        children: [

          Container(
            padding: const EdgeInsets.all(10),

            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(10),
            ),

            child: const Icon(
              Icons.menu_book_outlined,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,

              children: [

                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 4),

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