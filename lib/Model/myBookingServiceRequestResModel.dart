// To parse this JSON data, do
//
//     final myBookingServiceRequestResModel = myBookingServiceRequestResModelFromJson(jsonString);

import 'dart:convert';

MyBookingServiceRequestResModel myBookingServiceRequestResModelFromJson(String str) => MyBookingServiceRequestResModel.fromJson(json.decode(str));

String myBookingServiceRequestResModelToJson(MyBookingServiceRequestResModel data) => json.encode(data.toJson());

class MyBookingServiceRequestResModel {
  String? message;
  int? code;
  bool? error;
  Data? data;

  MyBookingServiceRequestResModel({
    this.message,
    this.code,
    this.error,
    this.data,
  });

  factory MyBookingServiceRequestResModel.fromJson(Map<String, dynamic> json) => MyBookingServiceRequestResModel(
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
  List<ListElement>? list;
  int? total;

  Data({
    this.list,
    this.total,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    list: json["list"] == null ? [] : List<ListElement>.from(json["list"]!.map((x) => ListElement.fromJson(x))),
    total: json["total"],
  );

  Map<String, dynamic> toJson() => {
    "list": list == null ? [] : List<dynamic>.from(list!.map((x) => x.toJson())),
    "total": total,
  };
}

class ListElement {
  String? id;
  String? address;
  DateTime? serviceDate;
  String? serviceTimeSlot;
  String? problemImgae;
  ServiceType? serviceType;
  String? message;
  String? status;
  int? serviceFee;
  String? paymentStatus;
  bool? isDisable;
  bool? isDeleted;
  int? date;
  int? month;
  int? year;
  int? createdAt;
  int? updatedAt;
  String? bookingId;
  int? v;
  List<Rating>? ratings;
  ServiceBoy? serviceBoy;
  String? serviceProviderImage;

  ListElement({
    this.id,
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
    this.date,
    this.month,
    this.year,
    this.createdAt,
    this.updatedAt,
    this.bookingId,
    this.v,
    this.ratings,
    this.serviceBoy,
    this.serviceProviderImage,
  });

  factory ListElement.fromJson(Map<String, dynamic> json) => ListElement(
    id: json["_id"],
    address: json["address"],
    serviceDate: json["serviceDate"] == null ? null : DateTime.parse(json["serviceDate"]),
    serviceTimeSlot: json["serviceTimeSlot"],
    problemImgae: json["problemImgae"],
    serviceType: json["serviceType"] == null ? null : ServiceType.fromJson(json["serviceType"]),
    message: json["message"],
    status: json["status"],
    serviceFee: json["serviceFee"],
    paymentStatus: json["paymentStatus"],
    isDisable: json["isDisable"],
    isDeleted: json["isDeleted"],
    date: json["date"],
    month: json["month"],
    year: json["year"],
    createdAt: json["createdAt"],
    updatedAt: json["updatedAt"],
    bookingId: json["bookingId"],
    v: json["__v"],
    ratings: json["ratings"] == null ? [] : List<Rating>.from(json["ratings"]!.map((x) => Rating.fromJson(x))),
    serviceBoy: json["serviceBoy"] == null ? null : ServiceBoy.fromJson(json["serviceBoy"]),
    serviceProviderImage: json["serviceProviderImage"],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "address": address,
    "serviceDate": serviceDate?.toIso8601String(),
    "serviceTimeSlot": serviceTimeSlot,
    "problemImgae": problemImgae,
    "serviceType": serviceType?.toJson(),
    "message": message,
    "status": status,
    "serviceFee": serviceFee,
    "paymentStatus": paymentStatus,
    "isDisable": isDisable,
    "isDeleted": isDeleted,
    "date": date,
    "month": month,
    "year": year,
    "createdAt": createdAt,
    "updatedAt": updatedAt,
    "bookingId": bookingId,
    "__v": v,
    "ratings": ratings == null ? [] : List<dynamic>.from(ratings!.map((x) => x.toJson())),
    "serviceBoy": serviceBoy?.toJson(),
    "serviceProviderImage": serviceProviderImage,
  };
}

class Rating {
  String? id;
  String? userId;
  int? rating;
  dynamic review;

  Rating({
    this.id,
    this.userId,
    this.rating,
    this.review,
  });

  factory Rating.fromJson(Map<String, dynamic> json) => Rating(
    id: json["_id"],
    userId: json["userId"],
    rating: json["rating"],
    review: json["review"],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "userId": userId,
    "rating": rating,
    "review": review,
  };
}

class ServiceBoy {
  String? id;
  String? name;
  String? phone;

  ServiceBoy({
    this.id,
    this.name,
    this.phone,
  });

  factory ServiceBoy.fromJson(Map<String, dynamic> json) => ServiceBoy(
    id: json["_id"],
    name: json["name"],
    phone: json["phone"],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "name": name,
    "phone": phone,
  };
}

class ServiceType {
  String? id;
  String? name;
  String? image;

  ServiceType({
    this.id,
    this.name,
    this.image,
  });

  factory ServiceType.fromJson(Map<String, dynamic> json) => ServiceType(
    id: json["_id"],
    name: json["name"],
    image: json["image"],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "name": name,
    "image": image,
  };
}
