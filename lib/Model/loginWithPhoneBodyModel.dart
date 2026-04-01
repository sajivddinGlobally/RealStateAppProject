// To parse this JSON data, do
//
//     final loginWithPhoneBodyModel = loginWithPhoneBodyModelFromJson(jsonString);

import 'dart:convert';

LoginWithPhoneBodyModel loginWithPhoneBodyModelFromJson(String str) =>
    LoginWithPhoneBodyModel.fromJson(json.decode(str));

String loginWithPhoneBodyModelToJson(LoginWithPhoneBodyModel data) =>
    json.encode(data.toJson());

class LoginWithPhoneBodyModel {
  String phone;
  String? password;

  LoginWithPhoneBodyModel({required this.phone, this.password});

  factory LoginWithPhoneBodyModel.fromJson(Map<String, dynamic> json) =>
      LoginWithPhoneBodyModel(phone: json["phone"], password: json['password']);

  Map<String, dynamic> toJson() => {"phone": phone, "password": password};
}




// To parse this JSON data, do
//
//     final loginWithPhoneBodyModel = loginWithPhoneBodyModelFromJson(jsonString);


LoginWithPhoneResisterBodyModel loginWithPhoneResisterBodyModelFromJson(String str) =>
    LoginWithPhoneResisterBodyModel.fromJson(json.decode(str));

String loginWithPhoneResisterBodyModelToJson(LoginWithPhoneBodyModel data) =>
    json.encode(data.toJson());

class LoginWithPhoneResisterBodyModel {
  String phone;


  LoginWithPhoneResisterBodyModel({required this.phone, });

  factory LoginWithPhoneResisterBodyModel.fromJson(Map<String, dynamic> json) =>
      LoginWithPhoneResisterBodyModel(phone: json["phone"], );

  Map<String, dynamic> toJson() => {"phone": phone, };
}
