// To parse this JSON data, do
//
//     final verifyRazorpayPaymentResModel = verifyRazorpayPaymentResModelFromJson(jsonString);

import 'dart:convert';

VerifyRazorpayPaymentResModel verifyRazorpayPaymentResModelFromJson(String str) => VerifyRazorpayPaymentResModel.fromJson(json.decode(str));

String verifyRazorpayPaymentResModelToJson(VerifyRazorpayPaymentResModel data) => json.encode(data.toJson());

class VerifyRazorpayPaymentResModel {
    String? message;
    int? code;
    bool? error;
    Data? data;

    VerifyRazorpayPaymentResModel({
        this.message,
        this.code,
        this.error,
        this.data,
    });

    factory VerifyRazorpayPaymentResModel.fromJson(Map<String, dynamic> json) => VerifyRazorpayPaymentResModel(
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
    String? problemImgae;
    String? serviceType;
    String? message;
    String? status;
    int? serviceFee;
    String? paymentStatus;
    String? paymentMethod;
    bool? isVerified;
    List<Item>? items;
    bool? isDisable;
    bool? isDeleted;
    int? date;
    int? month;
    int? year;
    int? createdAt;
    int? updatedAt;
    String? bookingId;
    String? serviceBoy;
    String? verificationOtp;
    String? beforeImage;
    String? afterImage;
    String? razorpayOrderId;
    DateTime? paidAt;
    String? razorpayPaymentId;
    String? razorpaySignature;

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
        this.paymentMethod,
        this.isVerified,
        this.items,
        this.isDisable,
        this.isDeleted,
        this.date,
        this.month,
        this.year,
        this.createdAt,
        this.updatedAt,
        this.bookingId,
        this.serviceBoy,
        this.verificationOtp,
        this.beforeImage,
        this.afterImage,
        this.razorpayOrderId,
        this.paidAt,
        this.razorpayPaymentId,
        this.razorpaySignature,
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
        paymentMethod: json["paymentMethod"],
        isVerified: json["isVerified"],
        items: json["items"] == null ? [] : List<Item>.from(json["items"]!.map((x) => Item.fromJson(x))),
        isDisable: json["isDisable"],
        isDeleted: json["isDeleted"],
        date: json["date"],
        month: json["month"],
        year: json["year"],
        createdAt: json["createdAt"],
        updatedAt: json["updatedAt"],
        bookingId: json["bookingId"],
        serviceBoy: json["serviceBoy"],
        verificationOtp: json["verificationOTP"],
        beforeImage: json["beforeImage"],
        afterImage: json["afterImage"],
        razorpayOrderId: json["razorpayOrderId"],
        paidAt: json["paidAt"] == null ? null : DateTime.parse(json["paidAt"]),
        razorpayPaymentId: json["razorpayPaymentId"],
        razorpaySignature: json["razorpaySignature"],
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
        "paymentMethod": paymentMethod,
        "isVerified": isVerified,
        "items": items == null ? [] : List<dynamic>.from(items!.map((x) => x.toJson())),
        "isDisable": isDisable,
        "isDeleted": isDeleted,
        "date": date,
        "month": month,
        "year": year,
        "createdAt": createdAt,
        "updatedAt": updatedAt,
        "bookingId": bookingId,
        "serviceBoy": serviceBoy,
        "verificationOTP": verificationOtp,
        "beforeImage": beforeImage,
        "afterImage": afterImage,
        "razorpayOrderId": razorpayOrderId,
        "paidAt": paidAt?.toIso8601String(),
        "razorpayPaymentId": razorpayPaymentId,
        "razorpaySignature": razorpaySignature,
    };
}

class Item {
    String? title;
    int? price;
    String? image;
    String? description;
    String? id;
    String? serviceId;
    int? serviceFee;

    Item({
        this.title,
        this.price,
        this.image,
        this.description,
        this.id,
        this.serviceId,
        this.serviceFee,
    });

    factory Item.fromJson(Map<String, dynamic> json) => Item(
        title: json["title"],
        price: json["price"],
        image: json["image"],
        description: json["description"],
        id: json["_id"],
        serviceId: json["serviceId"],
        serviceFee: json["serviceFee"],
    );

    Map<String, dynamic> toJson() => {
        "title": title,
        "price": price,
        "image": image,
        "description": description,
        "_id": id,
        "serviceId": serviceId,
        "serviceFee": serviceFee,
    };
}
