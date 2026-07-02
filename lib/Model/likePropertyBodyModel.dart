// To parse this JSON data, do
//
//     final getMyPropertyDetailsBodyModel = getMyPropertyDetailsBodyModelFromJson(jsonString);

import 'dart:convert';

LikePropertyBodyModel getMyPropertyDetailsBodyModelFromJson(String str) =>
    LikePropertyBodyModel.fromJson(json.decode(str));

String getMyPropertyDetailsBodyModelToJson(LikePropertyBodyModel data) =>
    json.encode(data.toJson());

class LikePropertyBodyModel {
  String propertyId;

  LikePropertyBodyModel({required this.propertyId});

  factory LikePropertyBodyModel.fromJson(Map<String, dynamic> json) =>
      LikePropertyBodyModel(propertyId: json["propertyId"]);

  Map<String, dynamic> toJson() => {"propertyId": propertyId};
}
