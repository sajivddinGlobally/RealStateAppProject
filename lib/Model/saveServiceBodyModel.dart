// To parse this JSON data, do
//
//     final saveServiceBodyModel = saveServiceBodyModelFromJson(jsonString);

import 'dart:convert';

SaveServiceBodyModel saveServiceBodyModelFromJson(String str) =>
    SaveServiceBodyModel.fromJson(json.decode(str));

String saveServiceBodyModelToJson(SaveServiceBodyModel data) =>
    json.encode(data.toJson());

class SaveServiceBodyModel {
  String? email;
  String? phone;
  String? serviceType;
  String? name;

  SaveServiceBodyModel({this.email, this.phone, this.serviceType, this.name});

  factory SaveServiceBodyModel.fromJson(Map<String, dynamic> json) =>
      SaveServiceBodyModel(
        email: json["email"],
        phone: json["phone"],
        serviceType: json["serviceType"],
        name: json["name"],
      );

  Map<String, dynamic> toJson() => {
    "email": email,
    "phone": phone,
    "serviceType": serviceType,
    "name": name,
  };
}
