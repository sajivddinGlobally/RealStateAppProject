// To parse this JSON data, do
//
//     final checkSlotBodyModel = checkSlotBodyModelFromJson(jsonString);

import 'dart:convert';

CheckSlotBodyModel checkSlotBodyModelFromJson(String str) => CheckSlotBodyModel.fromJson(json.decode(str));

String checkSlotBodyModelToJson(CheckSlotBodyModel data) => json.encode(data.toJson());

class CheckSlotBodyModel {
    String? serviceType;
    String? serviceTimeSlot;
    DateTime? serviceDate;

    CheckSlotBodyModel({
        this.serviceType,
        this.serviceTimeSlot,
        this.serviceDate,
    });

    factory CheckSlotBodyModel.fromJson(Map<String, dynamic> json) => CheckSlotBodyModel(
        serviceType: json["serviceType"],
        serviceTimeSlot: json["serviceTimeSlot"],
        serviceDate: json["serviceDate"] == null ? null : DateTime.parse(json["serviceDate"]),
    );

    Map<String, dynamic> toJson() => {
        "serviceType": serviceType,
        "serviceTimeSlot": serviceTimeSlot,
        "serviceDate": "${serviceDate!.year.toString().padLeft(4, '0')}-${serviceDate!.month.toString().padLeft(2, '0')}-${serviceDate!.day.toString().padLeft(2, '0')}",
    };
}
