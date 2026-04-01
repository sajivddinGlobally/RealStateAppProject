// To parse this JSON data, do
//
//     final userProfileResModel = userProfileResModelFromJson(jsonString);

import 'dart:convert';

UserProfileResModel userProfileResModelFromJson(String str) =>
    UserProfileResModel.fromJson(json.decode(str));

String userProfileResModelToJson(UserProfileResModel data) =>
    json.encode(data.toJson());

class UserProfileResModel {
  String? message;
  int? code;
  bool? error;
  Data? data;

  UserProfileResModel({this.message, this.code, this.error, this.data});

  factory UserProfileResModel.fromJson(Map<String, dynamic> json) =>
      UserProfileResModel(
        message: json["message"],
        code: json["code"],
        error: json["error"],
        data: json["data"] == null ? null : Data.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
    "message": message,
    "code": code,
    "error": error,
    "data": data?.toJson(),
  };
}

class Data {
  String? image;
  String? id;
  String? name;
  String? password;
  String? phone;
  String? email;
  String? pincode;
  String? state;
  String? city;
  String? address;
  bool? isDisable;
  bool? isDeleted;
  int? date;
  int? month;
  int? year;
  int? createdAt;
  int? updatedAt;

  Data({
    this.image,
    this.id,
    this.name,
    this.password,
    this.phone,
    this.email,
    this.city,
    this.address,
    this.pincode,
    this.state,
    this.isDisable,
    this.isDeleted,
    this.date,
    this.month,
    this.year,
    this.createdAt,
    this.updatedAt,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    image: json['image'],
    id: json["_id"],
    name: json["name"],
    password: json["password"],
    phone: json["phone"],
    pincode: json["pincode"],
    city: json["city"],
    address: json["address"],
    state: json["state"],
    email: json["email"],
    isDisable: json["isDisable"],
    isDeleted: json["isDeleted"],
    date: json["date"],
    month: json["month"],
    year: json["year"],
    createdAt: json["createdAt"],
    updatedAt: json["updatedAt"],
  );

  Map<String, dynamic> toJson() => {
    "image": image,
    "_id": id,
    "name": name,
    "password": password,
    "phone": phone,
    "email": email,


    "city":city,
    "address":address,
    "pincode":pincode,
 "state":state,
    "isDisable": isDisable,
    "isDeleted": isDeleted,
    "date": date,
    "month": month,
    "year": year,
    "createdAt": createdAt,
    "updatedAt": updatedAt,
  };
}
