// To parse this JSON data, do
//
//     final homeBookingServiceBodyModel = homeBookingServiceBodyModelFromJson(jsonString);

import 'dart:convert';

HomeBookingServiceBodyModel homeBookingServiceBodyModelFromJson(String str) => HomeBookingServiceBodyModel.fromJson(json.decode(str));

String homeBookingServiceBodyModelToJson(HomeBookingServiceBodyModel data) => json.encode(data.toJson());

class HomeBookingServiceBodyModel {
    String? serviceType;
    String? address;
    String? message;
    DateTime? serviceDate;
    String? serviceTimeSlot;
    int? serviceFee;
    dynamic problemImgae;

    HomeBookingServiceBodyModel({
        this.serviceType,
        this.address,
        this.message,
        this.serviceDate,
        this.serviceTimeSlot,
        this.serviceFee,
        this.problemImgae,
    });

    factory HomeBookingServiceBodyModel.fromJson(Map<String, dynamic> json) => HomeBookingServiceBodyModel(
        serviceType: json["serviceType"],
        address: json["address"],
        message: json["message"],
        serviceDate: json["serviceDate"] == null ? null : DateTime.parse(json["serviceDate"]),
        serviceTimeSlot: json["serviceTimeSlot"],
        serviceFee: json["serviceFee"],
        problemImgae: json["problemImgae"],
    );

    Map<String, dynamic> toJson() => {
        "serviceType": serviceType,
        "address": address,
        "message": message,
        "serviceDate": "${serviceDate!.year.toString().padLeft(4, '0')}-${serviceDate!.month.toString().padLeft(2, '0')}-${serviceDate!.day.toString().padLeft(2, '0')}",
        "serviceTimeSlot": serviceTimeSlot,
        "serviceFee": serviceFee,
        "problemImgae": problemImgae,
    };
}
