// To parse this JSON data, do
//
//     final myBookingServiceRequestResModel = myBookingServiceRequestResModelFromJson(jsonString);

import 'dart:convert';

MyBookingServiceRequestResModel myBookingServiceRequestResModelFromJson(
  String str,
) => MyBookingServiceRequestResModel.fromJson(json.decode(str));

String myBookingServiceRequestResModelToJson(
  MyBookingServiceRequestResModel data,
) => json.encode(data.toJson());

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

  factory MyBookingServiceRequestResModel.fromJson(Map<String, dynamic> json) =>
      MyBookingServiceRequestResModel(
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

  Data({this.list, this.total});

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    list: json["list"] == null
        ? []
        : List<ListElement>.from(
            json["list"]!.map((x) => ListElement.fromJson(x)),
          ),
    total: json["total"],
  );

  Map<String, dynamic> toJson() => {
    "list": list == null
        ? []
        : List<dynamic>.from(list!.map((x) => x.toJson())),
    "total": total,
  };
}

class ListElement {
  String? id;
  String? address;
  DateTime? serviceDate;
  String? serviceTimeSlot;
  String? problemImgae;
  Service? serviceType;
  String? message;
  String? status;
  int? serviceFee;
  String? paymentStatus;
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
  int? v;
  Service? serviceBoy;
  String? verificationOtp;
  List<Rating>? ratings;
  String? beforeImage;
  String? afterImage;

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
    this.v,
    this.serviceBoy,
    this.verificationOtp,
    this.ratings,
    this.beforeImage,
    this.afterImage,
  });

  factory ListElement.fromJson(Map<String, dynamic> json) => ListElement(
    id: json["_id"],
    address: json["address"],
    serviceDate: json["serviceDate"] == null
        ? null
        : DateTime.parse(json["serviceDate"]),
    serviceTimeSlot: json["serviceTimeSlot"],
    problemImgae: json["problemImgae"],
    serviceType: json["serviceType"] == null
        ? null
        : Service.fromJson(json["serviceType"]),
    message: json["message"],
    status: json["status"],
    serviceFee: json["serviceFee"],
    paymentStatus: json["paymentStatus"],
    isVerified: json["isVerified"],
    items: json["items"] == null
        ? []
        : List<Item>.from(json["items"]!.map((x) => Item.fromJson(x))),
    isDisable: json["isDisable"],
    isDeleted: json["isDeleted"],
    date: json["date"],
    month: json["month"],
    year: json["year"],
    createdAt: json["createdAt"],
    updatedAt: json["updatedAt"],
    bookingId: json["bookingId"],
    v: json["__v"],
    serviceBoy: json["serviceBoy"] == null
        ? null
        : Service.fromJson(json["serviceBoy"]),
    verificationOtp: json["verificationOTP"],
    ratings: json["ratings"] == null
        ? []
        : List<Rating>.from(json["ratings"]!.map((x) => Rating.fromJson(x))),
    beforeImage: json["beforeImage"],
    afterImage: json["afterImage"],
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
    "isVerified": isVerified,
    "items": items == null
        ? []
        : List<dynamic>.from(items!.map((x) => x.toJson())),
    "isDisable": isDisable,
    "isDeleted": isDeleted,
    "date": date,
    "month": month,
    "year": year,
    "createdAt": createdAt,
    "updatedAt": updatedAt,
    "bookingId": bookingId,
    "__v": v,
    "serviceBoy": serviceBoy?.toJson(),
    "verificationOTP": verificationOtp,
    "ratings": ratings == null
        ? []
        : List<dynamic>.from(ratings!.map((x) => x.toJson())),
    "beforeImage": beforeImage,
    "afterImage": afterImage,
  };
}

class Item {
  String? title;
  int? price;
  String? image;
  String? description;
  String? id;
  String? serviceId;
  bool? isExtra;
  int? serviceFee;

  Item({
    this.title,
    this.price,
    this.image,
    this.description,
    this.id,
    this.serviceId,
    this.isExtra,
    this.serviceFee,
  });

  factory Item.fromJson(Map<String, dynamic> json) => Item(
    title: json["title"],
    price: json["price"],
    image: json["image"],
    description: json["description"],
    id: json["_id"],
    serviceId: json["serviceId"],
    isExtra: json["isExtra"],
    serviceFee: json["serviceFee"],
  );

  Map<String, dynamic> toJson() => {
    "title": title,
    "price": price,
    "image": image,
    "description": description,
    "_id": id,
    "serviceId": serviceId,
    "isExtra": isExtra,
    "serviceFee": serviceFee,
  };
}

class Rating {
  String? id;
  String? userId;
  int? rating;
  String? review;
  String? image;

  Rating({this.id, this.userId, this.rating, this.review, this.image});

  factory Rating.fromJson(Map<String, dynamic> json) => Rating(
    id: json["_id"],
    userId: json["userId"],
    rating: json["rating"],
    review: json["review"],
    image: json["image"],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "userId": userId,
    "rating": rating,
    "review": review,
    "image": image,
  };
}

class Service {
  String? id;
  String? name;
  String? phone;
  String? image;
  List<Slot>? slots;

  Service({this.id, this.name, this.phone, this.image, this.slots});

  factory Service.fromJson(Map<String, dynamic> json) => Service(
    id: json["_id"],
    name: json["name"],
    phone: json["phone"],
    image: json["image"],
    slots: json["slots"] == null
        ? []
        : List<Slot>.from(json["slots"]!.map((x) => Slot.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "name": name,
    "phone": phone,
    "image": image,
    "slots": slots == null
        ? []
        : List<dynamic>.from(slots!.map((x) => x.toJson())),
  };
}

class Slot {
  String? timeSlot;
  int? slotCount;
  String? id;

  Slot({this.timeSlot, this.slotCount, this.id});

  factory Slot.fromJson(Map<String, dynamic> json) => Slot(
    timeSlot: json["timeSlot"],
    slotCount: json["slotCount"],
    id: json["_id"],
  );

  Map<String, dynamic> toJson() => {
    "timeSlot": timeSlot,
    "slotCount": slotCount,
    "_id": id,
  };
}
