// To parse this JSON data, do
//
//     final getNotificationModel = getNotificationModelFromJson(jsonString);

import 'dart:convert';

GetNotificationModel getNotificationModelFromJson(String str) => GetNotificationModel.fromJson(json.decode(str));

String getNotificationModelToJson(GetNotificationModel data) => json.encode(data.toJson());

class GetNotificationModel {
    String? message;
    int? code;
    bool? error;
    List<Datum>? data;

    GetNotificationModel({
        this.message,
        this.code,
        this.error,
        this.data,
    });

    factory GetNotificationModel.fromJson(Map<String, dynamic> json) => GetNotificationModel(
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
    String? userId;
    String? userModel;
    String? title;
    String? message;
    String? type;
    String? targetId;
    bool? isRead;
    DateTime? createdAt;
    int? v;

    Datum({
        this.id,
        this.userId,
        this.userModel,
        this.title,
        this.message,
        this.type,
        this.targetId,
        this.isRead,
        this.createdAt,
        this.v,
    });

    factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        id: json["_id"],
        userId: json["userId"],
        userModel: json["userModel"],
        title: json["title"],
        message: json["message"],
        type: json["type"],
        targetId: json["targetId"],
        isRead: json["isRead"],
        createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
        v: json["__v"],
    );

    Map<String, dynamic> toJson() => {
        "_id": id,
        "userId": userId,
        "userModel": userModel,
        "title": title,
        "message": message,
        "type": type,
        "targetId": targetId,
        "isRead": isRead,
        "createdAt": createdAt?.toIso8601String(),
        "__v": v,
    };
}
