// To parse this JSON data, do
//
//     final saveAddCustomAreaBodyModel = saveAddCustomAreaBodyModelFromJson(jsonString);

import 'dart:convert';

SaveAddCustomAreaBodyModel saveAddCustomAreaBodyModelFromJson(String str) => SaveAddCustomAreaBodyModel.fromJson(json.decode(str));

String saveAddCustomAreaBodyModelToJson(SaveAddCustomAreaBodyModel data) => json.encode(data.toJson());

class SaveAddCustomAreaBodyModel {
    String? cityId;
    String? areaName;

    SaveAddCustomAreaBodyModel({
        this.cityId,
        this.areaName,
    });

    factory SaveAddCustomAreaBodyModel.fromJson(Map<String, dynamic> json) => SaveAddCustomAreaBodyModel(
        cityId: json["cityId"],
        areaName: json["areaName"],
    );

    Map<String, dynamic> toJson() => {
        "cityId": cityId,
        "areaName": areaName,
    };
}
