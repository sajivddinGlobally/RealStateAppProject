// To parse this JSON data, do
//
//     final uploadImageBodyModel = uploadImageBodyModelFromJson(jsonString);

import 'dart:convert';

UploadImageBodyModel uploadImageBodyModelFromJson(String str) => UploadImageBodyModel.fromJson(json.decode(str));

String uploadImageBodyModelToJson(UploadImageBodyModel data) => json.encode(data.toJson());

class UploadImageBodyModel {
    String image;

    UploadImageBodyModel({
        required this.image,
    });

    factory UploadImageBodyModel.fromJson(Map<String, dynamic> json) => UploadImageBodyModel(
        image: json["image"],
    );

    Map<String, dynamic> toJson() => {
        "image": image,
    };
}
