// To parse this JSON data, do
//
//     final forgotPassSentOtpResModel = forgotPassSentOtpResModelFromJson(jsonString);

import 'dart:convert';

ForgotPassSentOtpResModel forgotPassSentOtpResModelFromJson(String str) => ForgotPassSentOtpResModel.fromJson(json.decode(str));

String forgotPassSentOtpResModelToJson(ForgotPassSentOtpResModel data) => json.encode(data.toJson());

class ForgotPassSentOtpResModel {
    String? message;
    int? code;
    bool? error;
    Data? data;

    ForgotPassSentOtpResModel({
        this.message,
        this.code,
        this.error,
        this.data,
    });

    factory ForgotPassSentOtpResModel.fromJson(Map<String, dynamic> json) => ForgotPassSentOtpResModel(
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
    String? token;
    String? otp;

    Data({
        this.token,
        this.otp,
    });

    factory Data.fromJson(Map<String, dynamic> json) => Data(
        token: json["token"],
        otp: json["otp"],
    );

    Map<String, dynamic> toJson() => {
        "token": token,
        "otp": otp,
    };
}
