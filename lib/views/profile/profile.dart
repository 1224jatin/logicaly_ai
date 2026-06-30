import 'package:flutter/material.dart';
import 'package:logicaly_ai_project/models/profile_model.dart';
import 'package:logicaly_ai_project/services/auth_services.dart';
import 'package:logicaly_ai_project/services/supabase_service.dart';
import 'package:logicaly_ai_project/views/auth/auth_gate.dart';
import 'package:logicaly_ai_project/views/auth/login_screen.dart';
import 'package:logicaly_ai_project/views/chat/chat_bot.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<StatefulWidget> createState() => _Profile();
}

class _Profile extends State<Profile> {
  final SupabaseService _supabaseService = SupabaseService();
  Stream<ProfileModel?>? _profileStream;
  Stream<List<Map<String, dynamic>>>? _activityStream;

  @override
  void initState() {
    super.initState();
    // Initialize streams here to ensure they are stable
    _profileStream = _supabaseService.currentProfileStream();
    _activityStream = _supabaseService.activityStream();
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
              StreamBuilder<ProfileModel?>(
                key: const ValueKey('profile_data_block'),
                stream: _profileStream,
                builder: (context, snapshot) {
                  final user = AuthService().currentUser;
                  final profile = snapshot.data;
                  final name = profile?.name.isNotEmpty == true
                      ? profile!.name
                      : user?.userMetadata?["name"] as String? ?? "Student";
                  final email = profile?.email.isNotEmpty == true
                      ? profile!.email
                      : user?.email ?? "";
                  final dailyGoal = profile?.dailyGoalMinutes ?? 30;
                  final completed = profile?.completedMinutes ?? 0;
                  final streak = profile?.streakDays ?? 0;
                  final testsTaken = profile?.testsTaken ?? 0;
                  final studyHours = profile?.studyHours ?? 0;
                  final progress = dailyGoal == 0
                      ? 0.0
                      : (completed / dailyGoal).clamp(0.0, 1.0).toDouble();

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Profile",
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              FocusScope.of(context).unfocus();
                              _logout();
                            },
                            icon: const Icon(Icons.logout),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _buildProfileCard(name, email),
                      const SizedBox(height: 26),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Your Progress",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Row(
                            children: [
                              Text(
                                "$streak Days Streak",
                                style: const TextStyle(
                                  color: Colors.black54,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.local_fire_department,
                                color: Colors.red,
                                size: 20,
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _buildGoalEditor(dailyGoal),
                      const SizedBox(height: 20),
                      _buildDailyGoalCard(progress, completed, dailyGoal),
                      const SizedBox(height: 22),
                      Row(
                        children: [
                          Expanded(
                            child: buildStatCard(
                              icon: Icons.auto_awesome,
                              iconColor: Colors.purple,
                              value: "$testsTaken",
                              label: "Test Taken",
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: buildStatCard(
                              icon: Icons.access_time,
                              iconColor: Colors.blue,
                              value: "${studyHours}h",
                              label: "Time Spent",
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 28),
              const Text(
                "Recent Activity",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 18),
              _buildRecentActivity(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileCard(String name, String email) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 34,
            backgroundImage: NetworkImage("https://i.pravatar.cc/300"),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  email,
                  style: const TextStyle(color: Colors.black54, fontSize: 14),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              FocusScope.of(context).unfocus();
              _editName(name);
            },
            icon: const Icon(Icons.edit_outlined),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalEditor(int dailyGoal) {
    return Row(
      children: [
        const Expanded(
          child: Text(
            "Set your daily study goal",
            style: TextStyle(fontSize: 15),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            "$dailyGoal Min",
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        IconButton(
          onPressed: () {
            FocusScope.of(context).unfocus();
            _editDailyGoal(dailyGoal);
          },
          icon: const Icon(Icons.edit_outlined),
        ),
      ],
    );
  }

  Widget _buildDailyGoalCard(double progress, int completed, int dailyGoal) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Daily Goal",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Icon(Icons.track_changes, color: Colors.blue),
            ],
          ),
          const SizedBox(height: 18),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: Colors.grey.shade300,
              color: Colors.blue,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "$completed/$dailyGoal Minutes Completed",
            style: const TextStyle(color: Colors.black54),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivity() {
    return StreamBuilder<List<Map<String, dynamic>>>(
      key: const ValueKey('profile_activity_stream'),
      stream: _activityStream,
      builder: (context, snapshot) {
        final activities = snapshot.data ?? [];
        if (activities.isEmpty) {
          return buildActivityCard(
            title: "No recent activity",
            subtitle: "Start learning to build your timeline",
          );
        }

        return Column(
          children: activities.map((activity) {
            final title = activity["title"] as String? ?? "Activity";
            final subtitle = activity["subtitle"] as String? ?? "";
            
            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: buildActivityCard(
                title: title,
                subtitle: subtitle,
                onTap: () {
                  FocusScope.of(context).unfocus();
                  String? initialPrompt;
                  if (title == "Asked AI") {
                    initialPrompt = subtitle;
                  } else if (title.contains("generated") || title.contains("created")) {
                    initialPrompt = "Tell me more about the $title regarding: $subtitle";
                  }

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatBot(initialPrompt: initialPrompt),
                    ),
                  );
                },
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Future<void> _editName(String currentName) async {
    final name = await showDialog<String>(
      context: context,
      builder: (context) => _EditNameDialog(currentName: currentName),
    );

    if (name == null || !mounted) {
      return;
    }

    await AuthService().updateDisplayName(name);
    await _supabaseService.updateCurrentProfile({"name": name});
  }

  Future<void> _editDailyGoal(int currentGoal) async {
    final minutes = await showDialog<int>(
      context: context,
      builder: (context) => _EditGoalDialog(currentGoal: currentGoal),
    );

    if (minutes == null || !mounted) {
      return;
    }

    await _supabaseService.updateCurrentProfile({
      "dailyGoalMinutes": minutes,
    });
  }

  Future<void> _logout() async {
    final navigator = Navigator.of(context);
    // Unfocus to prevent highlight manager errors
    FocusScope.of(context).unfocus();
    
    await AuthService().signOut();
    
    if (mounted) {
      // Return to the absolute root. AuthGate will already be showing LoginScreen.
      // We use a post-frame callback to ensure the tree has stabilized.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (navigator.canPop()) {
          navigator.popUntil((route) => route.isFirst);
        }
      });
    }
  }

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
          Icon(icon, color: iconColor),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(color: Colors.black54, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget buildActivityCard({
    required String title,
    required String subtitle,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
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
              child: const Icon(Icons.menu_book_outlined),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
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
                    style: const TextStyle(color: Colors.black54, fontSize: 13),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 18, color: Colors.black54),
          ],
        ),
      ),
    );
  }
}

class _EditNameDialog extends StatefulWidget {
  final String currentName;
  const _EditNameDialog({required this.currentName});

  @override
  State<_EditNameDialog> createState() => _EditNameDialogState();
}

class _EditNameDialogState extends State<_EditNameDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.currentName);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Edit Name"),
      content: TextField(
        controller: _controller,
        autofocus: true,
        decoration: const InputDecoration(labelText: "Name"),
        onSubmitted: (val) {
          final name = val.trim();
          if (name.isNotEmpty) Navigator.pop(context, name);
        },
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: () {
            final name = _controller.text.trim();
            if (name.isNotEmpty) {
              Navigator.pop(context, name);
            }
          },
          child: const Text("Save"),
        ),
      ],
    );
  }
}

class _EditGoalDialog extends StatefulWidget {
  final int currentGoal;
  const _EditGoalDialog({required this.currentGoal});

  @override
  State<_EditGoalDialog> createState() => _EditGoalDialogState();
}

class _EditGoalDialogState extends State<_EditGoalDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.currentGoal.toString());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Daily Goal"),
      content: TextField(
        controller: _controller,
        autofocus: true,
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(labelText: "Minutes"),
        onSubmitted: (val) {
          final minutes = int.tryParse(val.trim());
          if (minutes != null && minutes > 0) Navigator.pop(context, minutes);
        },
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: () {
            final minutes = int.tryParse(_controller.text.trim());
            if (minutes != null && minutes > 0) {
              Navigator.pop(context, minutes);
            }
          },
          child: const Text("Save"),
        ),
      ],
    );
  }
}
