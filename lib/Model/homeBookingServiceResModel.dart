// To parse this JSON data, do
//
//     final homeBookingServiceResModel = homeBookingServiceResModelFromJson(jsonString);

import 'dart:convert';

HomeBookingServiceResModel homeBookingServiceResModelFromJson(String str) => HomeBookingServiceResModel.fromJson(json.decode(str));

String homeBookingServiceResModelToJson(HomeBookingServiceResModel data) => json.encode(data.toJson());

class HomeBookingServiceResModel {
    String? message;
    int? code;
    bool? error;
    Data? data;

    HomeBookingServiceResModel({
        this.message,
        this.code,
        this.error,
        this.data,
    });

    factory HomeBookingServiceResModel.fromJson(Map<String, dynamic> json) => HomeBookingServiceResModel(
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
    String? address;
    DateTime? serviceDate;
    String? serviceTimeSlot;
    String? problemImgae;
    String? serviceType;
    String? message;
    String? status;
    int? serviceFee;
    String? paymentStatus;
    bool? isDisable;
    bool? isDeleted;
    String? id;
    int? date;
    int? month;
    int? year;
    int? createdAt;
    int? updatedAt;
    String? bookingId;

    Data({
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
        this.isDisable,
        this.isDeleted,
        this.id,
        this.date,
        this.month,
        this.year,
        this.createdAt,
        this.updatedAt,
        this.bookingId,
    });

    factory Data.fromJson(Map<String, dynamic> json) => Data(
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
        isDisable: json["isDisable"],
        isDeleted: json["isDeleted"],
        id: json["_id"],
        date: json["date"],
        month: json["month"],
        year: json["year"],
        createdAt: json["createdAt"],
        updatedAt: json["updatedAt"],
        bookingId: json["bookingId"],
    );

    Map<String, dynamic> toJson() => {
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
        "isDisable": isDisable,
        "isDeleted": isDeleted,
        "_id": id,
        "date": date,
        "month": month,
        "year": year,
        "createdAt": createdAt,
        "updatedAt": updatedAt,
        "bookingId": bookingId,
    };
}
