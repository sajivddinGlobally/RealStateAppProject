// To parse this JSON data, do
//
//     final getHeroBannerModel = getHeroBannerModelFromJson(jsonString);

import 'dart:convert';

GetHeroBannerModel getHeroBannerModelFromJson(String str) => GetHeroBannerModel.fromJson(json.decode(str));

String getHeroBannerModelToJson(GetHeroBannerModel data) => json.encode(data.toJson());

class GetHeroBannerModel {
    String? message;
    int? code;
    bool? error;
    Data? data;

    GetHeroBannerModel({
        this.message,
        this.code,
        this.error,
        this.data,
    });

    factory GetHeroBannerModel.fromJson(Map<String, dynamic> json) => GetHeroBannerModel(
        message: json["message"],
        code: json["code"],
        error: json["error"],
        data: json["data"] == null ? null : Data.fromJson(json["data"]),
    );

    Map<String, dynamic> toJson() => {
        "message": message,
        "code": code,
        "error": error,
        "data": data?.toJson(),
    };
}

class Data {
    List<ListElement>? list;
    int? total;

    Data({
        this.list,
        this.total,
    });

    factory Data.fromJson(Map<String, dynamic> json) => Data(
        list: json["list"] == null ? [] : List<ListElement>.from(json["list"]!.map((x) => ListElement.fromJson(x))),
        total: json["total"],
    );

    Map<String, dynamic> toJson() => {
        "list": list == null ? [] : List<dynamic>.from(list!.map((x) => x.toJson())),
        "total": total,
    };
}

class ListElement {
    String? id;
    String? title;
    String? highlight;
    String? img;
    String? link;
    String? tabCategory;
    bool? isActive;
    bool? isDisable;
    bool? isDeleted;
    int? date;
    int? month;
    int? year;
    int? createdAt;
    int? updatedAt;

    ListElement({
        this.id,
        this.title,
        this.highlight,
        this.img,
        this.link,
        this.tabCategory,
        this.isActive,
        this.isDisable,
        this.isDeleted,
        this.date,
        this.month,
        this.year,
        this.createdAt,
        this.updatedAt,
    });

    factory ListElement.fromJson(Map<String, dynamic> json) => ListElement(
        id: json["_id"],
        title: json["title"],
        highlight: json["highlight"],
        img: json["img"],
        link: json["link"],
        tabCategory: json["tabCategory"],
        isActive: json["isActive"],
        isDisable: json["isDisable"],
        isDeleted: json["isDeleted"],
        date: json["date"],
        month: json["month"],
        year: json["year"],
        createdAt: json["createdAt"],
        updatedAt: json["updatedAt"],
    );

    Map<String, dynamic> toJson() => {
        "_id": id,
        "title": title,
        "highlight": highlight,
        "img": img,
        "link": link,
        "tabCategory": tabCategory,
        "isActive": isActive,
        "isDisable": isDisable,
        "isDeleted": isDeleted,
        "date": date,
        "month": month,
        "year": year,
        "createdAt": createdAt,
        "updatedAt": updatedAt,
    };
}
