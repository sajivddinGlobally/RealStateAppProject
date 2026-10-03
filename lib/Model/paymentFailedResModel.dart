// To parse this JSON data, do
//
//     final paymentFailedResModel = paymentFailedResModelFromJson(jsonString);

import 'dart:convert';

PaymentFailedResModel paymentFailedResModelFromJson(String str) => PaymentFailedResModel.fromJson(json.decode(str));

String paymentFailedResModelToJson(PaymentFailedResModel data) => json.encode(data.toJson());

class PaymentFailedResModel {
    String? message;
    int? code;
    bool? error;
    dynamic data;

    PaymentFailedResModel({
        this.message,
        this.code,
        this.error,
        this.data,
    });

    factory PaymentFailedResModel.fromJson(Map<String, dynamic> json) => PaymentFailedResModel(
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
