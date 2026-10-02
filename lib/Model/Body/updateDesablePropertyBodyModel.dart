// To parse this JSON data, do
//
//     final updateDesablePropertyBodyModel = updateDesablePropertyBodyModelFromJson(jsonString);

import 'dart:convert';

UpdateDesablePropertyBodyModel updateDesablePropertyBodyModelFromJson(String str) => UpdateDesablePropertyBodyModel.fromJson(json.decode(str));

String updateDesablePropertyBodyModelToJson(UpdateDesablePropertyBodyModel data) => json.encode(data.toJson());

class UpdateDesablePropertyBodyModel {
    String? id;

    UpdateDesablePropertyBodyModel({
        this.id,
    });

    factory UpdateDesablePropertyBodyModel.fromJson(Map<String, dynamic> json) => UpdateDesablePropertyBodyModel(
        id: json["id"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
    };
}
