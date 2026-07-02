// To parse this JSON data, do
//
//     final planResModel = planResModelFromJson(jsonString);

import 'dart:convert';

PlanResModel planResModelFromJson(String str) => PlanResModel.fromJson(json.decode(str));

String planResModelToJson(PlanResModel data) => json.encode(data.toJson());

class PlanResModel {
    String? message;
    int? code;
    bool? error;
    List<Datum>? data;

    PlanResModel({
        this.message,
        this.code,
        this.error,
        this.data,
    });

    factory PlanResModel.fromJson(Map<String, dynamic> json) => PlanResModel(
        message: json["message"],
        code: json["code"],
        error: json["error"],
        data: json["data"] == null ? [] : List<Datum>.from(json["data"]!.map((x) => Datum.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "message": message,
        "code": code,
        "error": error,
        "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
    };
}

class Datum {
    String? id;
    String? name;
    int? durationDays;
    int? price;
    int? discountPrice;
    int? gst;
    String? description;
    List<Point>? points;
    bool? isActive;
    DateTime? createdAt;
    DateTime? updatedAt;
    int? v;

    Datum({
        this.id,
        this.name,
        this.durationDays,
        this.price,
        this.discountPrice,
        this.gst,
        this.description,
        this.points,
        this.isActive,
        this.createdAt,
        this.updatedAt,
        this.v,
    });

    factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        id: json["_id"],
        name: json["name"],
        durationDays: json["durationDays"],
        price: json["price"],
        discountPrice: json["discountPrice"],
        gst: json["gst"],
        description: json["description"],
        points: json["points"] == null ? [] : List<Point>.from(json["points"]!.map((x) => Point.fromJson(x))),
        isActive: json["isActive"],
        createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
        updatedAt: json["updatedAt"] == null ? null : DateTime.parse(json["updatedAt"]),
        v: json["__v"],
    );

    Map<String, dynamic> toJson() => {
        "_id": id,
        "name": name,
        "durationDays": durationDays,
        "price": price,
        "discountPrice": discountPrice,
        "gst": gst,
        "description": description,
        "points": points == null ? [] : List<dynamic>.from(points!.map((x) => x.toJson())),
        "isActive": isActive,
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
        "__v": v,
    };
}

class Point {
    String? name;
    String? serviceCategory;
    String? type;
    String? value;
    int? limit;

    Point({
        this.name,
        this.serviceCategory,
        this.type,
        this.value,
        this.limit,
    });

    factory Point.fromJson(Map<String, dynamic> json) => Point(
        name: json["name"],
        serviceCategory: json["serviceCategory"],
        type: json["type"],
        value: json["value"],
        limit: json["limit"],
    );

    Map<String, dynamic> toJson() => {
        "name": name,
        "serviceCategory": serviceCategory,
        "type": type,
        "value": value,
        "limit": limit,
    };
}
