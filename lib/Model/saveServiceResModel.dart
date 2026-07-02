// // To parse this JSON data, do
// //
// //     final saveServiceResModel = saveServiceResModelFromJson(jsonString);

// import 'dart:convert';

// SaveServiceResModel saveServiceResModelFromJson(String str) => SaveServiceResModel.fromJson(json.decode(str));

// String saveServiceResModelToJson(SaveServiceResModel data) => json.encode(data.toJson());

// class SaveServiceResModel {
//     String? message;
//     int? code;
//     bool? error;
//     Data? data;

//     SaveServiceResModel({
//         this.message,
//         this.code,
//         this.error,
//         this.data,
//     });

//     factory SaveServiceResModel.fromJson(Map<String, dynamic> json) => SaveServiceResModel(
//         message: json["message"],
//         code: json["code"],
//         error: json["error"],
//         data: json["data"] == null ? null : Data.fromJson(json["data"]),
//     );

//     Map<String, dynamic> toJson() => {
//         "message": message,
//         "code": code,
//         "error": error,
//         "data": data?.toJson(),
//     };
// }

// class Data {
//     String? name;
//     String? phone;
//     String? email;
//     String? serviceType;
//     String? status;
//     bool? isDisable;
//     bool? isDeleted;
//     String? id;
//     int? date;
//     int? month;
//     int? year;
//     int? createdAt;
//     int? updatedAt;

//     Data({
//         this.name,
//         this.phone,
//         this.email,
//         this.serviceType,
//         this.status,
//         this.isDisable,
//         this.isDeleted,
//         this.id,
//         this.date,
//         this.month,
//         this.year,
//         this.createdAt,
//         this.updatedAt,
//     });

//     factory Data.fromJson(Map<String, dynamic> json) => Data(
//         name: json["name"],
//         phone: json["phone"],
//         email: json["email"],
//         serviceType: json["serviceType"],
//         status: json["status"],
//         isDisable: json["isDisable"],
//         isDeleted: json["isDeleted"],
//         id: json["_id"],
//         date: json["date"],
//         month: json["month"],
//         year: json["year"],
//         createdAt: json["createdAt"],
//         updatedAt: json["updatedAt"],
//     );

//     Map<String, dynamic> toJson() => {
//         "name": name,
//         "phone": phone,
//         "email": email,
//         "serviceType": serviceType,
//         "status": status,
//         "isDisable": isDisable,
//         "isDeleted": isDeleted,
//         "_id": id,
//         "date": date,
//         "month": month,
//         "year": year,
//         "createdAt": createdAt,
//         "updatedAt": updatedAt,
//     };
// }

import 'dart:convert';

SaveServiceResModel saveServiceResModelFromJson(String str) =>
    SaveServiceResModel.fromJson(json.decode(str));

String saveServiceResModelToJson(SaveServiceResModel data) =>
    json.encode(data.toJson());

class SaveServiceResModel {
  String? message;
  int? code;
  bool? error;
  dynamic data;

  SaveServiceResModel({this.message, this.code, this.error, this.data});

  factory SaveServiceResModel.fromJson(Map<String, dynamic> json) {
    return SaveServiceResModel(
      message: json["message"]?.toString(),
      code: json["code"],
      error: json["error"],
      data: json["data"] is Map<String, dynamic>
          ? Data.fromJson(json["data"])
          : json["data"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "message": message,
      "code": code,
      "error": error,
      "data": data is Data ? data.toJson() : data,
    };
  }
}

class Data {
  String? name;
  String? phone;
  String? email;
  String? serviceType;
  String? status;
  bool? isDisable;
  bool? isDeleted;
  String? id;
  int? date;
  int? month;
  int? year;
  int? createdAt;
  int? updatedAt;

  Data({
    this.name,
    this.phone,
    this.email,
    this.serviceType,
    this.status,
    this.isDisable,
    this.isDeleted,
    this.id,
    this.date,
    this.month,
    this.year,
    this.createdAt,
    this.updatedAt,
  });

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      name: json["name"]?.toString(),
      phone: json["phone"]?.toString(),
      email: json["email"]?.toString(),
      serviceType: json["serviceType"]?.toString(),
      status: json["status"]?.toString(),
      isDisable: json["isDisable"],
      isDeleted: json["isDeleted"],
      id: json["_id"]?.toString(),
      date: json["date"],
      month: json["month"],
      year: json["year"],
      createdAt: json["createdAt"],
      updatedAt: json["updatedAt"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "phone": phone,
      "email": email,
      "serviceType": serviceType,
      "status": status,
      "isDisable": isDisable,
      "isDeleted": isDeleted,
      "_id": id,
      "date": date,
      "month": month,
      "year": year,
      "createdAt": createdAt,
      "updatedAt": updatedAt,
    };
  }
}
