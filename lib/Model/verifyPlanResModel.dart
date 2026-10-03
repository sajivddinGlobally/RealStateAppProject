// To parse this JSON data, do
//
//     final verifyPlanResModel = verifyPlanResModelFromJson(jsonString);

import 'dart:convert';

VerifyPlanResModel verifyPlanResModelFromJson(String str) => VerifyPlanResModel.fromJson(json.decode(str));

String verifyPlanResModelToJson(VerifyPlanResModel data) => json.encode(data.toJson());

class VerifyPlanResModel {
    String? message;
    int? code;
    bool? error;
    Data? data;

    VerifyPlanResModel({
        this.message,
        this.code,
        this.error,
        this.data,
    });

    factory VerifyPlanResModel.fromJson(Map<String, dynamic> json) => VerifyPlanResModel(
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
    String? userId;
    String? planId;
    int? price;
    DateTime? startDate;
    DateTime? endDate;
    String? status;
    String? paymentStatus;
    bool? autoRenew;
    String? razorpayOrderId;
    String? razorpayPaymentId;
    List<dynamic>? usageTracking;
    bool? isDisable;
    bool? isDeleted;
    String? id;
    int? date;
    int? month;
    int? year;
    int? createdAt;
    int? updatedAt;

    Data({
        this.userId,
        this.planId,
        this.price,
        this.startDate,
        this.endDate,
        this.status,
        this.paymentStatus,
        this.autoRenew,
        this.razorpayOrderId,
        this.razorpayPaymentId,
        this.usageTracking,
        this.isDisable,
        this.isDeleted,
        this.id,
        this.date,
        this.month,
        this.year,
        this.createdAt,
        this.updatedAt,
    });

    factory Data.fromJson(Map<String, dynamic> json) => Data(
        userId: json["userId"],
        planId: json["planId"],
        price: json["price"],
        startDate: json["startDate"] == null ? null : DateTime.parse(json["startDate"]),
        endDate: json["endDate"] == null ? null : DateTime.parse(json["endDate"]),
        status: json["status"],
        paymentStatus: json["paymentStatus"],
        autoRenew: json["autoRenew"],
        razorpayOrderId: json["razorpayOrderId"],
        razorpayPaymentId: json["razorpayPaymentId"],
        usageTracking: json["usageTracking"] == null ? [] : List<dynamic>.from(json["usageTracking"]!.map((x) => x)),
        isDisable: json["isDisable"],
        isDeleted: json["isDeleted"],
        id: json["_id"],
        date: json["date"],
        month: json["month"],
        year: json["year"],
        createdAt: json["createdAt"],
        updatedAt: json["updatedAt"],
    );

    Map<String, dynamic> toJson() => {
        "userId": userId,
        "planId": planId,
        "price": price,
        "startDate": startDate?.toIso8601String(),
        "endDate": endDate?.toIso8601String(),
        "status": status,
        "paymentStatus": paymentStatus,
        "autoRenew": autoRenew,
        "razorpayOrderId": razorpayOrderId,
        "razorpayPaymentId": razorpayPaymentId,
        "usageTracking": usageTracking == null ? [] : List<dynamic>.from(usageTracking!.map((x) => x)),
        "isDisable": isDisable,
        "isDeleted": isDeleted,
        "_id": id,
        "date": date,
        "month": month,
        "year": year,
        "createdAt": createdAt,
        "updatedAt": updatedAt,
    };
}
