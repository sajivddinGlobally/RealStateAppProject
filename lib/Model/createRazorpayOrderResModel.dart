// To parse this JSON data, do
//
//     final createRazorpayOrderResModel = createRazorpayOrderResModelFromJson(jsonString);

import 'dart:convert';

CreateRazorpayOrderResModel createRazorpayOrderResModelFromJson(String str) => CreateRazorpayOrderResModel.fromJson(json.decode(str));

String createRazorpayOrderResModelToJson(CreateRazorpayOrderResModel data) => json.encode(data.toJson());

class CreateRazorpayOrderResModel {
    String? message;
    int? code;
    bool? error;
    Data? data;

    CreateRazorpayOrderResModel({
        this.message,
        this.code,
        this.error,
        this.data,
    });

    factory CreateRazorpayOrderResModel.fromJson(Map<String, dynamic> json) => CreateRazorpayOrderResModel(
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
    String? bookingId;

    Data({
        this.orderId,
        this.amount,
        this.currency,
        this.keyId,
        this.bookingId,
    });

    factory Data.fromJson(Map<String, dynamic> json) => Data(
        orderId: json["orderId"],
        amount: json["amount"],
        currency: json["currency"],
        keyId: json["keyId"],
        bookingId: json["bookingId"],
    );

    Map<String, dynamic> toJson() => {
        "orderId": orderId,
        "amount": amount,
        "currency": currency,
        "keyId": keyId,
        "bookingId": bookingId,
    };
}
