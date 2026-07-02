// To parse this JSON data, do
//
//     final saveAddCustomAreaResModel = saveAddCustomAreaResModelFromJson(jsonString);

import 'dart:convert';

SaveAddCustomAreaResModel saveAddCustomAreaResModelFromJson(String str) => SaveAddCustomAreaResModel.fromJson(json.decode(str));

String saveAddCustomAreaResModelToJson(SaveAddCustomAreaResModel data) => json.encode(data.toJson());

class SaveAddCustomAreaResModel {
    String? message;
    int? code;
    bool? error;
    Data? data;

    SaveAddCustomAreaResModel({
        this.message,
        this.code,
        this.error,
        this.data,
    });

    factory SaveAddCustomAreaResModel.fromJson(Map<String, dynamic> json) => SaveAddCustomAreaResModel(
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
    String? cityName;
    List<String>? areas;
    bool? isDisable;
    bool? isDeleted;
    int? date;
    int? month;
    int? year;
    int? createdAt;
    int? updatedAt;
    int? v;

    Data({
        this.id,
        this.cityName,
        this.areas,
        this.isDisable,
        this.isDeleted,
        this.date,
        this.month,
        this.year,
        this.createdAt,
        this.updatedAt,
        this.v,
    });

    factory Data.fromJson(Map<String, dynamic> json) => Data(
        id: json["_id"],
        cityName: json["cityName"],
        areas: json["areas"] == null ? [] : List<String>.from(json["areas"]!.map((x) => x)),
        isDisable: json["isDisable"],
        isDeleted: json["isDeleted"],
        date: json["date"],
        month: json["month"],
        year: json["year"],
        createdAt: json["createdAt"],
        updatedAt: json["updatedAt"],
        v: json["__v"],
    );

    Map<String, dynamic> toJson() => {
        "_id": id,
        "cityName": cityName,
        "areas": areas == null ? [] : List<dynamic>.from(areas!.map((x) => x)),
        "isDisable": isDisable,
        "isDeleted": isDeleted,
        "date": date,
        "month": month,
        "year": year,
        "createdAt": createdAt,
        "updatedAt": updatedAt,
        "__v": v,
    };
}
