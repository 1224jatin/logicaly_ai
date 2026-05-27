class QuizzModel {
  late String quizzId;
  late String quizz;
  late String quizzanswer;

  QuizzModel({
    required this.quizzId,
    required this.quizz,
    required this.quizzanswer,
  });

  Map<String, dynamic> tojson() {
    return {"quizzId": quizzId, "quizz": quizz, "quizzanswer": quizzanswer};
  }

  factory QuizzModel.fromJson(Map<String, dynamic> json) {
    return QuizzModel(
      quizzId: json['quizzId'] as String,
      quizz: json['quizz'] as String,
      quizzanswer: json['quizzanswer'] as String,
    );
  }
}
