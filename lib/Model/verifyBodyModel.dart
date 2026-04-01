// To parse this JSON data, do
//
//     final verifyBodyModel = verifyBodyModelFromJson(jsonString);

import 'dart:convert';

VerifyBodyModel verifyBodyModelFromJson(String str) => VerifyBodyModel.fromJson(json.decode(str));

String verifyBodyModelToJson(VerifyBodyModel data) => json.encode(data.toJson());

class VerifyBodyModel {
    String token;
    String otp;

    VerifyBodyModel({
        required this.token,
        required this.otp,
    });

    factory VerifyBodyModel.fromJson(Map<String, dynamic> json) => VerifyBodyModel(
        token: json["token"],
        otp: json["otp"],
    );

    Map<String, dynamic> toJson() => {
        "token": token,
        "otp": otp,
    };
}
