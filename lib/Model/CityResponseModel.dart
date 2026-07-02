// To parse this JSON data, do
//
//     final cityResponseModel = cityResponseModelFromJson(jsonString);

import 'dart:convert';

CityResponseModel cityResponseModelFromJson(String str) => CityResponseModel.fromJson(json.decode(str));

String cityResponseModelToJson(CityResponseModel data) => json.encode(data.toJson());

class CityResponseModel {
  String? message;
  int? code;
  bool? error;
  List<Datum>? data;

  CityResponseModel({
    this.message,
    this.code,
    this.error,
    this.data,
  });

  factory CityResponseModel.fromJson(Map<String, dynamic> json) => CityResponseModel(
    message: json["message"],
    code: json["code"],
    error: json["error"],
    data: json["data"] == null ? [] : List<Datum>.from(json["data"]!.map((x) => Datum.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "message": message,
    "code": code,
    "error": error,
    "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
  };
}

class Datum {
  String? id;
  String? cityName;
  List<String>? areas;

  Datum({
    this.id,
    this.cityName,
    this.areas,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
    id: json["_id"],
    cityName: json["cityName"],
    areas: json["areas"] == null ? [] : List<String>.from(json["areas"]!.map((x) => x)),
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "cityName": cityName,
    "areas": areas == null ? [] : List<dynamic>.from(areas!.map((x) => x)),
  };
}
