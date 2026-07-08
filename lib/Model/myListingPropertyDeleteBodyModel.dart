// To parse this JSON data, do
//
//     final myListingProperyDeleteBodyModel = myListingProperyDeleteBodyModelFromJson(jsonString);

import 'dart:convert';

MyListingProperyDeleteBodyModel myListingProperyDeleteBodyModelFromJson(String str) => MyListingProperyDeleteBodyModel.fromJson(json.decode(str));

String myListingProperyDeleteBodyModelToJson(MyListingProperyDeleteBodyModel data) => json.encode(data.toJson());

class MyListingProperyDeleteBodyModel {
    String? id;

    MyListingProperyDeleteBodyModel({
        this.id,
    });

    factory MyListingProperyDeleteBodyModel.fromJson(Map<String, dynamic> json) => MyListingProperyDeleteBodyModel(
        id: json["id"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
    };
}
