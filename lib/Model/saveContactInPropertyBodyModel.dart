// To parse this JSON data, do
//
//     final saveContactInPropertyBodyModel = saveContactInPropertyBodyModelFromJson(jsonString);

import 'dart:convert';

SaveContactInPropertyBodyModel saveContactInPropertyBodyModelFromJson(String str) => SaveContactInPropertyBodyModel.fromJson(json.decode(str));

String saveContactInPropertyBodyModelToJson(SaveContactInPropertyBodyModel data) => json.encode(data.toJson());

class SaveContactInPropertyBodyModel {
    String email;
    String name;
    String phone;
    String propertyId;

    SaveContactInPropertyBodyModel({
        required this.email,
        required this.name,
        required this.phone,
        required this.propertyId,
    });

    factory SaveContactInPropertyBodyModel.fromJson(Map<String, dynamic> json) => SaveContactInPropertyBodyModel(
        email: json["email"],
        name: json["name"],
        phone: json["phone"],
        propertyId: json["propertyId"],
    );

    Map<String, dynamic> toJson() => {
        "email": email,
        "name": name,
        "phone": phone,
        "propertyId": propertyId,
    };
}
