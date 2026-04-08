// To parse this JSON data, do
//
//     final serviceRatingBodyModel = serviceRatingBodyModelFromJson(jsonString);

import 'dart:convert';

ServiceRatingBodyModel serviceRatingBodyModelFromJson(String str) => ServiceRatingBodyModel.fromJson(json.decode(str));

String serviceRatingBodyModelToJson(ServiceRatingBodyModel data) => json.encode(data.toJson());

class ServiceRatingBodyModel {
    String? serviceBooking;
    int? rating;
    String? review;

    ServiceRatingBodyModel({
        this.serviceBooking,
        this.rating,
        this.review,
    });

    factory ServiceRatingBodyModel.fromJson(Map<String, dynamic> json) => ServiceRatingBodyModel(
        serviceBooking: json["serviceBooking"],
        rating: json["rating"],
        review: json["review"],
    );

    Map<String, dynamic> toJson() => {
        "serviceBooking": serviceBooking,
        "rating": rating,
        "review": review,
    };
}
