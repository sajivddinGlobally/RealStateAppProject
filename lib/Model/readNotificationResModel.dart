// To parse this JSON data, do
//
//     final readNotificationResModel = readNotificationResModelFromJson(jsonString);

import 'dart:convert';

ReadNotificationResModel readNotificationResModelFromJson(String str) => ReadNotificationResModel.fromJson(json.decode(str));

String readNotificationResModelToJson(ReadNotificationResModel data) => json.encode(data.toJson());

class ReadNotificationResModel {
    String? message;
    int? code;
    bool? error;
    dynamic data;

    ReadNotificationResModel({
        this.message,
        this.code,
        this.error,
        this.data,
    });

    factory ReadNotificationResModel.fromJson(Map<String, dynamic> json) => ReadNotificationResModel(
        message: json["message"],
        code: json["code"],
        error: json["error"],
        data: json["data"],
    );

    Map<String, dynamic> toJson() => {
        "message": message,
        "code": code,
        "error": error,
        "data": data,
    };
}
