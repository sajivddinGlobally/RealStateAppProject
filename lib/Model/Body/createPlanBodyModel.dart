// To parse this JSON data, do
//
//     final createPlanBodyModel = createPlanBodyModelFromJson(jsonString);

import 'dart:convert';

CreatePlanBodyModel createPlanBodyModelFromJson(String str) => CreatePlanBodyModel.fromJson(json.decode(str));

String createPlanBodyModelToJson(CreatePlanBodyModel data) => json.encode(data.toJson());

class CreatePlanBodyModel {
    String? planId;

    CreatePlanBodyModel({
        this.planId,
    });

    factory CreatePlanBodyModel.fromJson(Map<String, dynamic> json) => CreatePlanBodyModel(
        planId: json["planId"],
    );

    Map<String, dynamic> toJson() => {
        "planId": planId,
    };
}
