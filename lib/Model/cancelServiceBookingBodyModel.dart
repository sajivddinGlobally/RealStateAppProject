// To parse this JSON data, do
//
//     final cancelServiceBookingBodyModel = cancelServiceBookingBodyModelFromJson(jsonString);

import 'dart:convert';

CancelServiceBookingBodyModel cancelServiceBookingBodyModelFromJson(String str) => CancelServiceBookingBodyModel.fromJson(json.decode(str));

String cancelServiceBookingBodyModelToJson(CancelServiceBookingBodyModel data) => json.encode(data.toJson());

class CancelServiceBookingBodyModel {
    String? bookingId;

    CancelServiceBookingBodyModel({
        this.bookingId,
    });

    factory CancelServiceBookingBodyModel.fromJson(Map<String, dynamic> json) => CancelServiceBookingBodyModel(
        bookingId: json["bookingId"],
    );

    Map<String, dynamic> toJson() => {
        "bookingId": bookingId,
    };
}
