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
  String? customServiceType;
  List<String>? serviceTypeArray;

  SaveServiceBodyModel({
    this.email,
    this.phone,
    this.serviceType,
    this.name,
    this.customServiceType,
    this.serviceTypeArray,
  });

  factory SaveServiceBodyModel.fromJson(Map<String, dynamic> json) =>
      SaveServiceBodyModel(
        email: json["email"],
        phone: json["phone"],
        serviceType: json["serviceType"],
        name: json["name"],
        customServiceType: json["customServiceType"],
        serviceTypeArray: json["serviceTypeArray"] == null
            ? []
            : List<String>.from(json["serviceTypeArray"].map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
    "email": email,
    "phone": phone,
    "serviceType": serviceType,
    "name": name,
    "customServiceType": customServiceType,
    "serviceTypeArray": serviceTypeArray,
  };
}
