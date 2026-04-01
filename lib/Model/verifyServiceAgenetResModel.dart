// To parse this JSON data, do
//
//     final verifyServiceAgentResModel = verifyServiceAgentResModelFromJson(jsonString);

import 'dart:convert';

VerifyServiceAgentResModel verifyServiceAgentResModelFromJson(String str) => VerifyServiceAgentResModel.fromJson(json.decode(str));

String verifyServiceAgentResModelToJson(VerifyServiceAgentResModel data) => json.encode(data.toJson());

class VerifyServiceAgentResModel {
    String? message;
    int? code;
    bool? error;
    Data? data;

    VerifyServiceAgentResModel({
        this.message,
        this.code,
        this.error,
        this.data,
    });

    factory VerifyServiceAgentResModel.fromJson(Map<String, dynamic> json) => VerifyServiceAgentResModel(
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
    String? id;
    String? userId;
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
    ServiceBoy? serviceBoy;
    String? serviceProviderArrivalTime;

    Data({
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
        this.serviceBoy,
        this.serviceProviderArrivalTime,
    });

    factory Data.fromJson(Map<String, dynamic> json) => Data(
        id: json["_id"],
        userId: json["userId"],
        address: json["address"],
        serviceType: json["serviceType"] == null ? null : ServiceType.fromJson(json["serviceType"]),
        message: json["message"],
        status: json["status"],
        isDisable: json["isDisable"],
        isDeleted: json["isDeleted"],
        date: json["date"],
        month: json["month"],
        year: json["year"],
        createdAt: json["createdAt"],
        updatedAt: json["updatedAt"],
        serviceBoy: json["serviceBoy"] == null ? null : ServiceBoy.fromJson(json["serviceBoy"]),
        serviceProviderArrivalTime: json["serviceProviderArrivalTime"],
    );

    Map<String, dynamic> toJson() => {
        "_id": id,
        "userId": userId,
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
        "serviceBoy": serviceBoy?.toJson(),
        "serviceProviderArrivalTime": serviceProviderArrivalTime,
    };
}

class ServiceBoy {
    String? id;
    String? name;
    String? phone;
    String? image;

    ServiceBoy({
        this.id,
        this.name,
        this.phone,
        this.image,
    });

    factory ServiceBoy.fromJson(Map<String, dynamic> json) => ServiceBoy(
        id: json["_id"],
        name: json["name"],
        phone: json["phone"],
        image: json["image"],
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

    ServiceType({
        this.id,
        this.name,
    });

    factory ServiceType.fromJson(Map<String, dynamic> json) => ServiceType(
        id: json["_id"],
        name: json["name"],
    );

    Map<String, dynamic> toJson() => {
        "_id": id,
        "name": name,
    };
}
