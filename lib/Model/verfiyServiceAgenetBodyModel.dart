// To parse this JSON data, do
//
//     final verifyServiceAgentBodyModel = verifyServiceAgentBodyModelFromJson(jsonString);

import 'dart:convert';

VerifyServiceAgentBodyModel verifyServiceAgentBodyModelFromJson(String str) => VerifyServiceAgentBodyModel.fromJson(json.decode(str));

String verifyServiceAgentBodyModelToJson(VerifyServiceAgentBodyModel data) => json.encode(data.toJson());

class VerifyServiceAgentBodyModel {
    String id;

    VerifyServiceAgentBodyModel({
        required this.id,
    });

    factory VerifyServiceAgentBodyModel.fromJson(Map<String, dynamic> json) => VerifyServiceAgentBodyModel(
        id: json["id"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
    };
}
