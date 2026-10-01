// To parse this JSON data, do
//
//     final getPropertyCategoriyModel = getPropertyCategoriyModelFromJson(jsonString);

import 'dart:convert';

GetPropertyCategoriyModel getPropertyCategoriyModelFromJson(String str) => GetPropertyCategoriyModel.fromJson(json.decode(str));

String getPropertyCategoriyModelToJson(GetPropertyCategoriyModel data) => json.encode(data.toJson());

class GetPropertyCategoriyModel {
    String? message;
    int? code;
    bool? error;
    Data? data;

    GetPropertyCategoriyModel({
        this.message,
        this.code,
        this.error,
        this.data,
    });

    factory GetPropertyCategoriyModel.fromJson(Map<String, dynamic> json) => GetPropertyCategoriyModel(
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
    String? name;
    String? propertyTypeKey;
    PropertySector? propertySector;
    CategoryType? categoryType;
    String? rawCategoryType;
    String? image;
    bool? status;
    bool? isDisable;
    bool? isDeleted;
    int? date;
    int? month;
    int? year;
    int? createdAt;
    int? updatedAt;

    ListElement({
        this.id,
        this.name,
        this.propertyTypeKey,
        this.propertySector,
        this.categoryType,
        this.rawCategoryType,
        this.image,
        this.status,
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
        name: json["name"],
        propertyTypeKey: json["propertyTypeKey"],
        propertySector: propertySectorValues.map[json["propertySector"]?.toString().toLowerCase()],
        categoryType: categoryTypeValues.map[json["categoryType"]?.toString().toLowerCase()],
        rawCategoryType: json["categoryType"]?.toString().toLowerCase(),
        image: json["image"],
        status: json["status"],
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
        "name": name,
        "propertyTypeKey": propertyTypeKey,
        "propertySector": propertySectorValues.reverse[propertySector],
        "categoryType": categoryTypeValues.reverse[categoryType],
        "image": image,
        "status": status,
        "isDisable": isDisable,
        "isDeleted": isDeleted,
        "date": date,
        "month": month,
        "year": year,
        "createdAt": createdAt,
        "updatedAt": updatedAt,
    };
}

enum CategoryType {
    BOTH,
    BUY,
    RENT
}

final categoryTypeValues = EnumValues({
    "both": CategoryType.BOTH,
    "buy": CategoryType.BUY,
    "sell": CategoryType.BUY,
    "rent": CategoryType.RENT,
});

enum PropertySector {
    COMMERCIAL,
    RESIDENTIAL
}

final propertySectorValues = EnumValues({
    "commercial": PropertySector.COMMERCIAL,
    "residential": PropertySector.RESIDENTIAL
});

class EnumValues<T> {
    Map<String, T> map;
    late Map<T, String> reverseMap;

    EnumValues(this.map);

    Map<T, String> get reverse {
            reverseMap = map.map((k, v) => MapEntry(v, k));
            return reverseMap;
    }
}
