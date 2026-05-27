class FlashcardModel {
  final String cardId;
  final String cardQues;
  final String cardAns;

  FlashcardModel({
    required this.cardId,
    required this.cardQues,
    required this.cardAns,
  });

  Map<String, dynamic> tojson() {
    return {"cardId": cardId, "cardAns": cardAns, "cardQues": cardQues};
  }

  factory FlashcardModel.fromJson(Map<String, dynamic> json) {
    return FlashcardModel(
      cardId: json['cardId'] as String? ?? "",
      cardQues: json['cardQues'] as String? ?? "",
      cardAns: json['cardAns'] as String? ?? "",
    );
  }
}
