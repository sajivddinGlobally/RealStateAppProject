// To parse this JSON data, do
//
//     final myListingProperyDeleteResModel = myListingProperyDeleteResModelFromJson(jsonString);

import 'dart:convert';

MyListingProperyDeleteResModel myListingProperyDeleteResModelFromJson(String str) => MyListingProperyDeleteResModel.fromJson(json.decode(str));

String myListingProperyDeleteResModelToJson(MyListingProperyDeleteResModel data) => json.encode(data.toJson());

class MyListingProperyDeleteResModel {
    String? message;
    int? code;
    bool? error;
    dynamic data;

    MyListingProperyDeleteResModel({
        this.message,
        this.code,
        this.error,
        this.data,
    });

    factory MyListingProperyDeleteResModel.fromJson(Map<String, dynamic> json) => MyListingProperyDeleteResModel(
        message: json["message"],
        code: json["code"],
        error: json["error"],
        data: json["data"],
    );

    Map<String, dynamic> toJson() => {
        "message": message,
        "code": code,
        "error": error,
        "data": data,
    };
}
