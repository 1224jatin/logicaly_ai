import 'package:logicaly_ai_project/views/flashcards/flash_card.dart';

class FlashcardModel {
  late String cardId;
  late String cardQues;
  late String cardAns;

  FlashcardModel({
    required this.cardId,
    required this.cardQues,
    required this.cardAns
});

  Map<String,dynamic> tojson(){
    return {
      "cardId" : cardId,
      "cardAns" : cardAns,
      "cardQues": cardQues,
    };
  }
  factory FlashcardModel.fromJson(Map<String,dynamic> json){
    return FlashcardModel(
      cardId: json['cardId'] as String,
      cardQues: json['cardQues'] as String,
      cardAns: json['cardAns'] as String,

    );
  }
}