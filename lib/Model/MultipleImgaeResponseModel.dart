// To parse this JSON data, do
//
//     final multipleImageUploadResponse = multipleImageUploadResponseFromJson(jsonString);

import 'dart:convert';

MultipleImageUploadResponse multipleImageUploadResponseFromJson(String str) => MultipleImageUploadResponse.fromJson(json.decode(str));

String multipleImageUploadResponseToJson(MultipleImageUploadResponse data) => json.encode(data.toJson());

class MultipleImageUploadResponse {
  String? message;
  int? code;
  bool? error;
  List<Datum>? data;

  MultipleImageUploadResponse({
    this.message,
    this.code,
    this.error,
    this.data,
  });

  factory MultipleImageUploadResponse.fromJson(Map<String, dynamic> json) => MultipleImageUploadResponse(
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
  String? imageName;
  String? imageUrl;

  Datum({
    this.imageName,
    this.imageUrl,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
    imageName: json["imageName"],
    imageUrl: json["imageUrl"],
  );

  Map<String, dynamic> toJson() => {
    "imageName": imageName,
    "imageUrl": imageUrl,
  };
}
