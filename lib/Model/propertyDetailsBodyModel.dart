// To parse this JSON data, do
//
//     final propertyDetailsBodyModel = propertyDetailsBodyModelFromJson(jsonString);

import 'dart:convert';

PropertyDetailsBodyModel propertyDetailsBodyModelFromJson(String str) => PropertyDetailsBodyModel.fromJson(json.decode(str));

String propertyDetailsBodyModelToJson(PropertyDetailsBodyModel data) => json.encode(data.toJson());

class PropertyDetailsBodyModel {
    String? id;

    PropertyDetailsBodyModel({
        this.id,
    });

    factory PropertyDetailsBodyModel.fromJson(Map<String, dynamic> json) => PropertyDetailsBodyModel(
        id: json["id"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
    };
}
