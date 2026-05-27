class UserModel {
  final String uId;
  final String userName;
  final String email;

  UserModel({required this.uId, required this.userName, required this.email});

  Map<String, dynamic> tojson() {
    return {"uId": uId, "userName": userName, "email": email};
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userName: json["userName"] as String? ?? "",
      uId: json['uId'] as String? ?? json['userId'] as String? ?? "",
      email: json['email'] as String? ?? json['userEmail'] as String? ?? "",
    );
  }
}
