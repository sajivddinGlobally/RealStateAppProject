// To parse this JSON data, do
//
//     final resetPassBodyModel = resetPassBodyModelFromJson(jsonString);

import 'dart:convert';

ResetPassBodyModel resetPassBodyModelFromJson(String str) => ResetPassBodyModel.fromJson(json.decode(str));

String resetPassBodyModelToJson(ResetPassBodyModel data) => json.encode(data.toJson());

class ResetPassBodyModel {
    String? token;
    String? otp;
    String? newPassword;
    String? confirmPassword;

    ResetPassBodyModel({
        this.token,
        this.otp,
        this.newPassword,
        this.confirmPassword,
    });

    factory ResetPassBodyModel.fromJson(Map<String, dynamic> json) => ResetPassBodyModel(
        token: json["token"],
        otp: json["otp"],
        newPassword: json["newPassword"],
        confirmPassword: json["confirmPassword"],
    );

    Map<String, dynamic> toJson() => {
        "token": token,
        "otp": otp,
        "newPassword": newPassword,
        "confirmPassword": confirmPassword,
    };
}
