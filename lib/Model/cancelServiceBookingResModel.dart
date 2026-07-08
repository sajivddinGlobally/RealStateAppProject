// To parse this JSON data, do
//
//     final cancelServiceBookingResModel = cancelServiceBookingResModelFromJson(jsonString);

import 'dart:convert';

CancelServiceBookingResModel cancelServiceBookingResModelFromJson(String str) => CancelServiceBookingResModel.fromJson(json.decode(str));

String cancelServiceBookingResModelToJson(CancelServiceBookingResModel data) => json.encode(data.toJson());

class CancelServiceBookingResModel {
    String? message;
    int? code;
    bool? error;
    Data? data;

    CancelServiceBookingResModel({
        this.message,
        this.code,
        this.error,
        this.data,
    });

    factory CancelServiceBookingResModel.fromJson(Map<String, dynamic> json) => CancelServiceBookingResModel(
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
    String? id;
    String? userId;
    String? address;
    DateTime? serviceDate;
    String? serviceTimeSlot;
    dynamic problemImgae;
    String? serviceType;
    String? message;
    String? status;
    int? serviceFee;
    String? paymentStatus;
    List<dynamic>? items;
    bool? isDisable;
    bool? isDeleted;
    int? date;
    int? month;
    int? year;
    int? createdAt;
    int? updatedAt;
    String? bookingId;

    Data({
        this.id,
        this.userId,
        this.address,
        this.serviceDate,
        this.serviceTimeSlot,
        this.problemImgae,
        this.serviceType,
        this.message,
        this.status,
        this.serviceFee,
        this.paymentStatus,
        this.items,
        this.isDisable,
        this.isDeleted,
        this.date,
        this.month,
        this.year,
        this.createdAt,
        this.updatedAt,
        this.bookingId,
    });

    factory Data.fromJson(Map<String, dynamic> json) => Data(
        id: json["_id"],
        userId: json["userId"],
        address: json["address"],
        serviceDate: json["serviceDate"] == null ? null : DateTime.parse(json["serviceDate"]),
        serviceTimeSlot: json["serviceTimeSlot"],
        problemImgae: json["problemImgae"],
        serviceType: json["serviceType"],
        message: json["message"],
        status: json["status"],
        serviceFee: json["serviceFee"],
        paymentStatus: json["paymentStatus"],
        items: json["items"] == null ? [] : List<dynamic>.from(json["items"]!.map((x) => x)),
        isDisable: json["isDisable"],
        isDeleted: json["isDeleted"],
        date: json["date"],
        month: json["month"],
        year: json["year"],
        createdAt: json["createdAt"],
        updatedAt: json["updatedAt"],
        bookingId: json["bookingId"],
    );

    Map<String, dynamic> toJson() => {
        "_id": id,
        "userId": userId,
        "address": address,
        "serviceDate": serviceDate?.toIso8601String(),
        "serviceTimeSlot": serviceTimeSlot,
        "problemImgae": problemImgae,
        "serviceType": serviceType,
        "message": message,
        "status": status,
        "serviceFee": serviceFee,
        "paymentStatus": paymentStatus,
        "items": items == null ? [] : List<dynamic>.from(items!.map((x) => x)),
        "isDisable": isDisable,
        "isDeleted": isDeleted,
        "date": date,
        "month": month,
        "year": year,
        "createdAt": createdAt,
        "updatedAt": updatedAt,
        "bookingId": bookingId,
    };
}
