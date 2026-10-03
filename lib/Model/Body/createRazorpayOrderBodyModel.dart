// To parse this JSON data, do
//
//     final createRazorpayOrderBodyModel = createRazorpayOrderBodyModelFromJson(jsonString);

import 'dart:convert';

CreateRazorpayOrderBodyModel createRazorpayOrderBodyModelFromJson(String str) => CreateRazorpayOrderBodyModel.fromJson(json.decode(str));

String createRazorpayOrderBodyModelToJson(CreateRazorpayOrderBodyModel data) => json.encode(data.toJson());

class CreateRazorpayOrderBodyModel {
    String? bookingId;

    CreateRazorpayOrderBodyModel({
        this.bookingId,
    });

    factory CreateRazorpayOrderBodyModel.fromJson(Map<String, dynamic> json) => CreateRazorpayOrderBodyModel(
        bookingId: json["bookingId"],
    );

    Map<String, dynamic> toJson() => {
        "bookingId": bookingId,
    };
}
