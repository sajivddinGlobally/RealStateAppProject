// To parse this JSON data, do
//
//     final serviceRatingResModel = serviceRatingResModelFromJson(jsonString);

import 'dart:convert';

ServiceRatingResModel serviceRatingResModelFromJson(String str) => ServiceRatingResModel.fromJson(json.decode(str));

String serviceRatingResModelToJson(ServiceRatingResModel data) => json.encode(data.toJson());

class ServiceRatingResModel {
    String? message;
    int? code;
    bool? error;
    Data? data;

    ServiceRatingResModel({
        this.message,
        this.code,
        this.error,
        this.data,
    });

    factory ServiceRatingResModel.fromJson(Map<String, dynamic> json) => ServiceRatingResModel(
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
    String? userId;
    String? serviceBooking;
    String? categoryId;
    int? rating;
    String? review;
    bool? isDisable;
    bool? isDeleted;
    String? id;
    int? date;
    int? month;
    int? year;
    int? createdAt;
    int? updatedAt;
    int? v;

    Data({
        this.userId,
        this.serviceBooking,
        this.categoryId,
        this.rating,
        this.review,
        this.isDisable,
        this.isDeleted,
        this.id,
        this.date,
        this.month,
        this.year,
        this.createdAt,
        this.updatedAt,
        this.v,
    });

    factory Data.fromJson(Map<String, dynamic> json) => Data(
        userId: json["userId"],
        serviceBooking: json["serviceBooking"],
        categoryId: json["categoryId"],
        rating: json["rating"],
        review: json["review"],
        isDisable: json["isDisable"],
        isDeleted: json["isDeleted"],
        id: json["_id"],
        date: json["date"],
        month: json["month"],
        year: json["year"],
        createdAt: json["createdAt"],
        updatedAt: json["updatedAt"],
        v: json["__v"],
    );

    Map<String, dynamic> toJson() => {
        "userId": userId,
        "serviceBooking": serviceBooking,
        "categoryId": categoryId,
        "rating": rating,
        "review": review,
        "isDisable": isDisable,
        "isDeleted": isDeleted,
        "_id": id,
        "date": date,
        "month": month,
        "year": year,
        "createdAt": createdAt,
        "updatedAt": updatedAt,
        "__v": v,
    };
}
