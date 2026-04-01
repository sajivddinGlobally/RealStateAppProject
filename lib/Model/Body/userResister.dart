import 'dart:convert';

UserResisterBodyModel UserResisterBodyModelFromJson(String str) => UserResisterBodyModel.fromJson(json.decode(str));

String UserResisterBodyModelToJson(UserResisterBodyModel data) => json.encode(data.toJson());

class UserResisterBodyModel {

  String name;
  String email;
  String phone;
  String password;
  UserResisterBodyModel({
    required this.name,
    required this.email,
    required this.phone,
    required this.password,
  });
  factory UserResisterBodyModel.fromJson(Map<String, dynamic> json) => UserResisterBodyModel(

    name: json["name"],
    email: json["email"],
    phone: json["phone"],
    password: json["password"],
  );
  Map<String, dynamic> toJson() => {

    "name": name,
    "email": email,
    "phone": phone,
    "password": password,

  };
}