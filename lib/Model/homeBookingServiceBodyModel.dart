// To parse this JSON data, do
//
//     final homeBookingServiceBodyModel = homeBookingServiceBodyModelFromJson(jsonString);

import 'dart:convert';

HomeBookingServiceBodyModel homeBookingServiceBodyModelFromJson(String str) =>
    HomeBookingServiceBodyModel.fromJson(json.decode(str));

String homeBookingServiceBodyModelToJson(HomeBookingServiceBodyModel data) =>
    json.encode(data.toJson());

class HomeBookingServiceBodyModel {
  String? address;
  String? message;
  String? serviceType;
  DateTime? serviceDate;
  String? serviceTimeSlot;
  int? serviceFee;
  String? problemImgae;
  List<Item>? items;

  HomeBookingServiceBodyModel({
    this.address,
    this.message,
    this.serviceType,
    this.serviceDate,
    this.serviceTimeSlot,
    this.serviceFee,
    this.problemImgae,
    this.items,
  });

  factory HomeBookingServiceBodyModel.fromJson(Map<String, dynamic> json) =>
      HomeBookingServiceBodyModel(
        address: json["address"],
        message: json["message"],
        serviceType: json["serviceType"],
        serviceDate: json["serviceDate"] == null
            ? null
            : DateTime.parse(json["serviceDate"]),
        serviceTimeSlot: json["serviceTimeSlot"],
        serviceFee: json["serviceFee"],
        problemImgae: json["problemImgae"],
        items: json["items"] == null
            ? []
            : List<Item>.from(json["items"]!.map((x) => Item.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
    "address": address,
    "message": message,
    "serviceType": serviceType,
    "serviceDate": serviceDate == null
        ? null
        : "${serviceDate!.year.toString().padLeft(4, '0')}-${serviceDate!.month.toString().padLeft(2, '0')}-${serviceDate!.day.toString().padLeft(2, '0')}",
    "serviceTimeSlot": serviceTimeSlot,
    "serviceFee": serviceFee,
    "problemImgae": problemImgae,
    "items": items == null
        ? []
        : List<dynamic>.from(items!.map((x) => x.toJson())),
  };
}

class Item {
  String? id;
  String? serviceId;
  String? title;
  int? price;
  String? image;
  String? description;
  int? serviceFee;

  Item({
    this.id,
    this.serviceId,
    this.title,
    this.price,
    this.image,
    this.description,
    this.serviceFee,
  });

  factory Item.fromJson(Map<String, dynamic> json) => Item(
    id: json["_id"],
    serviceId: json["serviceId"],
    title: json["title"],
    price: json["price"],
    image: json["image"],
    description: json["description"],
    serviceFee: json["serviceFee"],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "serviceId": serviceId,
    "title": title,
    "price": price,
    "image": image,
    "description": description,
    "serviceFee": serviceFee,
  };
}
