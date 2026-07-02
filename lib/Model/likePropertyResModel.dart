// To parse this JSON data, do
//
//     final likePropertyResModel = likePropertyResModelFromJson(jsonString);

import 'dart:convert';

LikePropertyResModel likePropertyResModelFromJson(String str) => LikePropertyResModel.fromJson(json.decode(str));

String likePropertyResModelToJson(LikePropertyResModel data) => json.encode(data.toJson());

class LikePropertyResModel {
    String? message;
    int? code;
    bool? error;
    Data? data;

    LikePropertyResModel({
        this.message,
        this.code,
        this.error,
        this.data,
    });

    factory LikePropertyResModel.fromJson(Map<String, dynamic> json) => LikePropertyResModel(
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
    String? id;
    String? propertyId;
    String? userId;
    bool? isDisable;
    bool? isDeleted;
    int? date;
    int? month;
    int? year;
    int? createdAt;
    int? updatedAt;

    Data({
        this.id,
        this.propertyId,
        this.userId,
        this.isDisable,
        this.isDeleted,
        this.date,
        this.month,
        this.year,
        this.createdAt,
        this.updatedAt,
    });

    factory Data.fromJson(Map<String, dynamic> json) => Data(
        id: json["_id"],
        propertyId: json["propertyId"],
        userId: json["userId"],
        isDisable: json["isDisable"],
        isDeleted: json["isDeleted"],
        date: json["date"],
        month: json["month"],
        year: json["year"],
        createdAt: json["createdAt"],
        updatedAt: json["updatedAt"],
    );

    Map<String, dynamic> toJson() => {
        "_id": id,
        "propertyId": propertyId,
        "userId": userId,
        "isDisable": isDisable,
        "isDeleted": isDeleted,
        "date": date,
        "month": month,
        "year": year,
        "createdAt": createdAt,
        "updatedAt": updatedAt,
    };
}
