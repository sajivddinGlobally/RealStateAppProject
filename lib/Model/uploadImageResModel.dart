// To parse this JSON data, do
//
//     final uploadImageResModel = uploadImageResModelFromJson(jsonString);

import 'dart:convert';

UploadImageResModel uploadImageResModelFromJson(String str) => UploadImageResModel.fromJson(json.decode(str));

String uploadImageResModelToJson(UploadImageResModel data) => json.encode(data.toJson());

class UploadImageResModel {
    String? message;
    int? code;
    bool? error;
    Data? data;

    UploadImageResModel({
        this.message,
        this.code,
        this.error,
        this.data,
    });

    factory UploadImageResModel.fromJson(Map<String, dynamic> json) => UploadImageResModel(
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
    String? imageName;
    String? imageUrl;

    Data({
        this.imageName,
        this.imageUrl,
    });

    factory Data.fromJson(Map<String, dynamic> json) => Data(
        imageName: json["imageName"],
        imageUrl: json["imageUrl"],
    );

    Map<String, dynamic> toJson() => {
        "imageName": imageName,
        "imageUrl": imageUrl,
    };
}
