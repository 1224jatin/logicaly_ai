class AiMessageModel {
  late String messageId;
  late String senderId;
  late String receiverId;
  late String message;
  DateTime? createdAt;

  AiMessageModel({
    required this.messageId,
    required this.senderId,
    required this.receiverId,
    required this.message,
    this.createdAt,
  });

  Map<String, dynamic> tojson() {
    return {
      "messageId": messageId,
      "senderId": senderId,
      "receiverId": receiverId,
      "message": message,
    };
  }

  factory AiMessageModel.fromJson(Map<String, dynamic> json) {
    return AiMessageModel(
      messageId: json['messageId'] as String,
      senderId: json['senderId'] as String,
      receiverId: json['receiverId'] as String,
      message: json['message'] as String,
      createdAt: json['createdAt'] != null 
          ? DateTime.tryParse(json['createdAt'].toString()) 
          : null,
    );
  }
}
