// To parse this JSON data, do
//
//     final serviceRatingBodyModel = serviceRatingBodyModelFromJson(jsonString);

import 'dart:convert';
import 'dart:io';

ServiceRatingBodyModel serviceRatingBodyModelFromJson(String str) =>
    ServiceRatingBodyModel.fromJson(json.decode(str));

String serviceRatingBodyModelToJson(ServiceRatingBodyModel data) =>
    json.encode(data.toJson());

class ServiceRatingBodyModel {
  String? serviceBooking;
  int? rating;
  String? review;
  String? image;

  ServiceRatingBodyModel({this.serviceBooking, this.rating, this.review,this.image});

  factory ServiceRatingBodyModel.fromJson(Map<String, dynamic> json) =>
      ServiceRatingBodyModel(
        serviceBooking: json["serviceBooking"],
        rating: json["rating"],
        review: json["review"],
        image: json["image"],
      );

  Map<String, dynamic> toJson() => {
    "serviceBooking": serviceBooking,
    "rating": rating,
    "review": review,
    "image": image,
  };
}
