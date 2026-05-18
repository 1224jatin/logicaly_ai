class UserModel {
  late String uId;
  late String userName ;
  late String email ;
  late String password ;

  UserModel({
    required this.uId,
    required this.userName,
    required this.email,
    required this.password,
});
  Map<String,dynamic> tojson(){
    return {
      "userId" : uId,
      "userName" : userName,
      "userEmail" : email,
      "userPassword": password,
    };
  }
  factory UserModel.fromJson(Map<String,dynamic> json){
    return UserModel(
        userName: json["userName"] as String,
        uId: json['uId'] as String,
        email: json['email'] as String,
        password: json['password'] as String,
    );
  }
}