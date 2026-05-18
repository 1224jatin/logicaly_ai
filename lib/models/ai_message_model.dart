
class AiMessageModel {
  late String messageId;
  late String senderId;
  late String receiverId;
  late String message;

  AiMessageModel({
    required this.messageId,
    required this.senderId,
    required this.receiverId,
    required this.message
  });

  Map<String,dynamic> tojson(){
    return {
      "messageId" : messageId,
      "senderId" : senderId,
      "receiverId" : receiverId,
      "message" : message,
    };
  }
  factory AiMessageModel.fromJson(Map<String,dynamic> json){
    return AiMessageModel(
      messageId: json['messageId'] as String,
      senderId: json['senderId'] as String,
      receiverId: json['receiverId'] as String,
      message: json['message'] as String,
    );
  }
}