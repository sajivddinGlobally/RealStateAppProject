// To parse this JSON data, do
//
//     final contactUsResModel = contactUsResModelFromJson(jsonString);

import 'dart:convert';

ContactUsResModel contactUsResModelFromJson(String str) => ContactUsResModel.fromJson(json.decode(str));

String contactUsResModelToJson(ContactUsResModel data) => json.encode(data.toJson());

class ContactUsResModel {
    String message;
    int code;
    bool error;
    Data data;

    ContactUsResModel({
        required this.message,
        required this.code,
        required this.error,
        required this.data,
    });

    factory ContactUsResModel.fromJson(Map<String, dynamic> json) => ContactUsResModel(
        message: json["message"],
        code: json["code"],
        error: json["error"],
        data: Data.fromJson(json["data"]),
    );

    Map<String, dynamic> toJson() => {
        "message": message,
        "code": code,
        "error": error,
        "data": data.toJson(),
    };
}

class Data {
    String name;
    String phone;
    String email;
    String subject;
    String message;
    String location;
    String status;
    bool isDisable;
    bool isDeleted;
    String id;
    int date;
    int month;
    int year;
    int createdAt;
    int updatedAt;

    Data({
        required this.name,
        required this.phone,
        required this.email,
        required this.subject,
        required this.message,
        required this.location,
        required this.status,
        required this.isDisable,
        required this.isDeleted,
        required this.id,
        required this.date,
        required this.month,
        required this.year,
        required this.createdAt,
        required this.updatedAt,
    });

    factory Data.fromJson(Map<String, dynamic> json) => Data(
        name: json["name"],
        phone: json["phone"],
        email: json["email"],
        subject: json["subject"],
        message: json["message"],
        location: json["location"],
        status: json["status"],
        isDisable: json["isDisable"],
        isDeleted: json["isDeleted"],
        id: json["_id"],
        date: json["date"],
        month: json["month"],
        year: json["year"],
        createdAt: json["createdAt"],
        updatedAt: json["updatedAt"],
    );

    Map<String, dynamic> toJson() => {
        "name": name,
        "phone": phone,
        "email": email,
        "subject": subject,
        "message": message,
        "location": location,
        "status": status,
        "isDisable": isDisable,
        "isDeleted": isDeleted,
        "_id": id,
        "date": date,
        "month": month,
        "year": year,
        "createdAt": createdAt,
        "updatedAt": updatedAt,
    };
}
