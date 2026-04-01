// To parse this JSON data, do
//
//     final saveContactInPropertyResModel = saveContactInPropertyResModelFromJson(jsonString);

import 'dart:convert';

SaveContactInPropertyResModel saveContactInPropertyResModelFromJson(String str) => SaveContactInPropertyResModel.fromJson(json.decode(str));

String saveContactInPropertyResModelToJson(SaveContactInPropertyResModel data) => json.encode(data.toJson());

class SaveContactInPropertyResModel {
    String? message;
    int? code;
    bool? error;
    Data? data;

    SaveContactInPropertyResModel({
        this.message,
        this.code,
        this.error,
        this.data,
    });

    factory SaveContactInPropertyResModel.fromJson(Map<String, dynamic> json) => SaveContactInPropertyResModel(
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
    String? propertyId;
    String? name;
    String? phone;
    String? email;
    String? status;
    bool? isDisable;
    bool? isDeleted;
    String? id;
    int? date;
    int? month;
    int? year;
    int? createdAt;
    int? updatedAt;

    Data({
        this.propertyId,
        this.name,
        this.phone,
        this.email,
        this.status,
        this.isDisable,
        this.isDeleted,
        this.id,
        this.date,
        this.month,
        this.year,
        this.createdAt,
        this.updatedAt,
    });

    factory Data.fromJson(Map<String, dynamic> json) => Data(
        propertyId: json["propertyId"],
        name: json["name"],
        phone: json["phone"],
        email: json["email"],
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
        "propertyId": propertyId,
        "name": name,
        "phone": phone,
        "email": email,
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
