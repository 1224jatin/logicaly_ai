class ProfileModel {
  final String uid;
  final String name;
  final String email;
  //final String imageUrl;
  final int streakDays;
  final int dailyGoalMinutes;
  final int completedMinutes;
  final int testsTaken;
  final int studyHours;

  ProfileModel({
    required this.uid,
    required this.name,
    required this.email,
    //required this.imageUrl,
    required this.streakDays,
    required this.dailyGoalMinutes,
    required this.completedMinutes,
    required this.testsTaken,
    required this.studyHours,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      uid: json['uid'] as String? ?? "",
      name: json['name'] as String? ?? "",
      email: json['email'] as String? ?? "",
      //imageUrl: json['imageUrl'] as String,
      streakDays: json['streakDays'] as int? ?? 0,
      dailyGoalMinutes: json['dailyGoalMinutes'] as int? ?? 30,
      completedMinutes: json['completedMinutes'] as int? ?? 0,
      testsTaken: json['testsTaken'] as int? ?? 0,
      studyHours: json['studyHours'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      //'imageUrl': imageUrl,
      'streakDays': streakDays,
      'dailyGoalMinutes': dailyGoalMinutes,
      'completedMinutes': completedMinutes,
      'testsTaken': testsTaken,
      'studyHours': studyHours,
    };
  }
}
