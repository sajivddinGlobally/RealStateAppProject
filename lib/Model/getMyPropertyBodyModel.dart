// To parse this JSON data, do
//
//     final getMyPropertyDetailsBodyModel = getMyPropertyDetailsBodyModelFromJson(jsonString);

import 'dart:convert';

GetMyPropertyDetailsBodyModel getMyPropertyDetailsBodyModelFromJson(String str) => GetMyPropertyDetailsBodyModel.fromJson(json.decode(str));

String getMyPropertyDetailsBodyModelToJson(GetMyPropertyDetailsBodyModel data) => json.encode(data.toJson());

class GetMyPropertyDetailsBodyModel {
    String id;

    GetMyPropertyDetailsBodyModel({
        required this.id,
    });

    factory GetMyPropertyDetailsBodyModel.fromJson(Map<String, dynamic> json) => GetMyPropertyDetailsBodyModel(
        id: json["id"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
    };
}
