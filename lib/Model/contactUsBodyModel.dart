// To parse this JSON data, do
//
//     final contactUsBodyModel = contactUsBodyModelFromJson(jsonString);

import 'dart:convert';

ContactUsBodyModel contactUsBodyModelFromJson(String str) => ContactUsBodyModel.fromJson(json.decode(str));

String contactUsBodyModelToJson(ContactUsBodyModel data) => json.encode(data.toJson());

class ContactUsBodyModel {
    String email;
    String name;
    String phone;
    String subject;
    String message;
    String location;

    ContactUsBodyModel({
        required this.email,
        required this.name,
        required this.phone,
        required this.subject,
        required this.message,
        required this.location,
    });

    factory ContactUsBodyModel.fromJson(Map<String, dynamic> json) => ContactUsBodyModel(
        email: json["email"],
        name: json["name"],
        phone: json["phone"],
        subject: json["subject"],
        message: json["message"],
        location: json["location"],
    );

    Map<String, dynamic> toJson() => {
        "email": email,
        "name": name,
        "phone": phone,
        "subject": subject,
        "message": message,
        "location": location,
    };
}
