// To parse this JSON data, do
//
//     final resetPassResModel = resetPassResModelFromJson(jsonString);

import 'dart:convert';

ResetPassResModel resetPassResModelFromJson(String str) => ResetPassResModel.fromJson(json.decode(str));

String resetPassResModelToJson(ResetPassResModel data) => json.encode(data.toJson());

class ResetPassResModel {
    String? message;
    int? code;
    bool? error;
    dynamic data;

    ResetPassResModel({
        this.message,
        this.code,
        this.error,
        this.data,
    });

    factory ResetPassResModel.fromJson(Map<String, dynamic> json) => ResetPassResModel(
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
