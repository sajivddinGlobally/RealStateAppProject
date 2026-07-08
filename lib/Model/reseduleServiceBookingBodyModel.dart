// To parse this JSON data, do
//
//     final rescheduleServiceBookingBodyModel = rescheduleServiceBookingBodyModelFromJson(jsonString);

import 'dart:convert';

RescheduleServiceBookingBodyModel rescheduleServiceBookingBodyModelFromJson(String str) => RescheduleServiceBookingBodyModel.fromJson(json.decode(str));

String rescheduleServiceBookingBodyModelToJson(RescheduleServiceBookingBodyModel data) => json.encode(data.toJson());

class RescheduleServiceBookingBodyModel {
    DateTime? serviceDate;
    String? serviceTimeSlot;
    String? bookingId;

    RescheduleServiceBookingBodyModel({
        this.serviceDate,
        this.serviceTimeSlot,
        this.bookingId,
    });

    factory RescheduleServiceBookingBodyModel.fromJson(Map<String, dynamic> json) => RescheduleServiceBookingBodyModel(
        serviceDate: json["serviceDate"] == null ? null : DateTime.parse(json["serviceDate"]),
        serviceTimeSlot: json["serviceTimeSlot"],
        bookingId: json["bookingId"],
    );

    Map<String, dynamic> toJson() => {
        "serviceDate": serviceDate?.toIso8601String(),
        "serviceTimeSlot": serviceTimeSlot,
        "bookingId": bookingId,
    };
}
