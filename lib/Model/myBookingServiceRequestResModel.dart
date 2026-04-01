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
  UserId? userId;
  String? address;
  ServiceType? serviceType;
  String? message;
  String? status;
  bool? isDisable;
  bool? isDeleted;
  int? date;
  int? month;
  int? year;
  int? createdAt;
  int? updatedAt;
  int? v;
  String? rejectedReason;
  ServiceBoy? serviceBoy;
  String? serviceProviderArrivalTime;

  ListElement({
    this.id,
    this.userId,
    this.address,
    this.serviceType,
    this.message,
    this.status,
    this.isDisable,
    this.isDeleted,
    this.date,
    this.month,
    this.year,
    this.createdAt,
    this.updatedAt,
    this.v,
    this.rejectedReason,
    this.serviceBoy,
    this.serviceProviderArrivalTime,
  });

  factory ListElement.fromJson(Map<String, dynamic> json) => ListElement(
    id: json["_id"],
    userId: json["userId"] == null ? null : UserId.fromJson(json["userId"]),
    address: json["address"],
    serviceType: json["serviceType"] == null
        ? null
        : ServiceType.fromJson(json["serviceType"]),
    message: json["message"],
    status: json["status"],
    isDisable: json["isDisable"],
    isDeleted: json["isDeleted"],
    date: json["date"],
    month: json["month"],
    year: json["year"],
    createdAt: json["createdAt"],
    updatedAt: json["updatedAt"],
    v: json["__v"],
    rejectedReason: json["rejectedReason"],
    serviceBoy: json["serviceBoy"] == null
        ? null
        : ServiceBoy.fromJson(json["serviceBoy"]),
    serviceProviderArrivalTime: json["serviceProviderArrivalTime"],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "userId": userId?.toJson(),
    "address": address,
    "serviceType": serviceType?.toJson(),
    "message": message,
    "status": status,
    "isDisable": isDisable,
    "isDeleted": isDeleted,
    "date": date,
    "month": month,
    "year": year,
    "createdAt": createdAt,
    "updatedAt": updatedAt,
    "__v": v,
    "rejectedReason": rejectedReason,
    "serviceBoy": serviceBoy?.toJson(),
    "serviceProviderArrivalTime": serviceProviderArrivalTime,
  };
}

class ServiceBoy {
  String? id;
  String? name;
  String? phone;
  String? image;

  ServiceBoy({this.id, this.name, this.phone, this.image});

  factory ServiceBoy.fromJson(Map<String, dynamic> json) => ServiceBoy(
    id: json["_id"],
    name: json["name"],
    phone: json["phone"],
    image: json['image'],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "name": name,
    "phone": phone,
    "image": image,
  };
}

class ServiceType {
  String? id;
  String? name;
  String? image;

  ServiceType({this.id, this.name, this.image});

  factory ServiceType.fromJson(Map<String, dynamic> json) =>
      ServiceType(id: json["_id"], name: json["name"], image: json["image"]);

  Map<String, dynamic> toJson() => {"_id": id, "name": name, "image": image};
}

class UserId {
  String? id;
  String? name;
  String? phone;
  String? email;
  String? image;

  UserId({this.id, this.name, this.phone, this.email, this.image});

  factory UserId.fromJson(Map<String, dynamic> json) => UserId(
    id: json["_id"],
    name: json["name"],
    phone: json["phone"],
    email: json["email"],
    image: json["image"],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "name": name,
    "phone": phone,
    "email": email,
    "image": image,
  };
}
