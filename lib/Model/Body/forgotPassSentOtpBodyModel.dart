// To parse this JSON data, do
//
//     final forgotPassSentOtpBodyModel = forgotPassSentOtpBodyModelFromJson(jsonString);

import 'dart:convert';

ForgotPassSentOtpBodyModel forgotPassSentOtpBodyModelFromJson(String str) => ForgotPassSentOtpBodyModel.fromJson(json.decode(str));

String forgotPassSentOtpBodyModelToJson(ForgotPassSentOtpBodyModel data) => json.encode(data.toJson());

class ForgotPassSentOtpBodyModel {
    String? phone;

    ForgotPassSentOtpBodyModel({
        this.phone,
    });

    factory ForgotPassSentOtpBodyModel.fromJson(Map<String, dynamic> json) => ForgotPassSentOtpBodyModel(
        phone: json["phone"],
    );

    Map<String, dynamic> toJson() => {
        "phone": phone,
    };
}
