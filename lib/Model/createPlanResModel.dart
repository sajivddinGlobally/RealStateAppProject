// To parse this JSON data, do
//
//     final createPlanResModel = createPlanResModelFromJson(jsonString);

import 'dart:convert';

CreatePlanResModel createPlanResModelFromJson(String str) => CreatePlanResModel.fromJson(json.decode(str));

String createPlanResModelToJson(CreatePlanResModel data) => json.encode(data.toJson());

class CreatePlanResModel {
    String? message;
    int? code;
    bool? error;
    Data? data;

    CreatePlanResModel({
        this.message,
        this.code,
        this.error,
        this.data,
    });

    factory CreatePlanResModel.fromJson(Map<String, dynamic> json) => CreatePlanResModel(
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
    String? orderId;
    int? amount;
    String? currency;
    String? keyId;
    String? planId;

    Data({
        this.orderId,
        this.amount,
        this.currency,
        this.keyId,
        this.planId,
    });

    factory Data.fromJson(Map<String, dynamic> json) => Data(
        orderId: json["orderId"],
        amount: json["amount"],
        currency: json["currency"],
        keyId: json["keyId"],
        planId: json["planId"],
    );

    Map<String, dynamic> toJson() => {
        "orderId": orderId,
        "amount": amount,
        "currency": currency,
        "keyId": keyId,
        "planId": planId,
    };
}
