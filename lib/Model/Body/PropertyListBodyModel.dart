/*
// To parse this JSON data, do
//
//     final propertyListBodyModel = propertyListBodyModelFromJson(jsonString);

import 'dart:convert';

PropertyListBodyModel propertyListBodyModelFromJson(String str) => PropertyListBodyModel.fromJson(json.decode(str));

String propertyListBodyModelToJson(PropertyListBodyModel data) => json.encode(data.toJson());

class PropertyListBodyModel {
  String? sortOrder;
  String? sortBy;
  int? pageNo;
  int? size;

  PropertyListBodyModel({
    this.sortOrder,
    this.sortBy,
    this.pageNo,
    this.size,
  });

  factory PropertyListBodyModel.fromJson(Map<String, dynamic> json) => PropertyListBodyModel(
    sortOrder: json["sortOrder"],
    sortBy: json["sortBy"],
    pageNo: json["pageNo"],
    size: json["size"],
  );

  Map<String, dynamic> toJson() => {
    "sortOrder": sortOrder,
    "sortBy": sortBy,
    "pageNo": pageNo,
    "size": size,
  };
}
*/

// To parse this JSON data, do
//
//     final propertyListBodyModel = propertyListBodyModelFromJson(jsonString);

import 'dart:convert';

PropertyListBodyModel propertyListBodyModelFromJson(String str) =>
    PropertyListBodyModel.fromJson(json.decode(str));

String propertyListBodyModelToJson(PropertyListBodyModel data) =>
    json.encode(data.toJson());

class PropertyListBodyModel {
  int? size;
  int? pageNo;
  String? sortBy;
  String? sortOrder;
  // ── Filter fields (matching exactly what backend expects) ────────
  String? minPrice;
  String? maxPrice;
  List<String>? bedroom; 
  String? city; 
  String? listingCategory;
  String? propertyType;
  String? keyWord;
  List<String>? balcony;
  List<String>? bathrooms;
  List<String>? kitchen;
  List<String>? locality;
  List<String>? parking;

  PropertyListBodyModel({
    this.size,
    this.pageNo,
    this.sortBy,
    this.sortOrder,
    this.minPrice,
    this.maxPrice,
    this.bedroom,
    this.city,
    this.listingCategory,
    this.propertyType,
    this.keyWord,
    this.balcony,
    this.bathrooms,
    this.kitchen,
    this.locality,
    this.parking,
  });

  factory PropertyListBodyModel.fromJson(Map<String, dynamic> json) =>
      PropertyListBodyModel(
        size: json["size"],
        pageNo: json["pageNo"],
        sortBy: json["sortBy"],
        sortOrder: json["sortOrder"],
        minPrice: json["minPrice"],
        maxPrice: json["maxPrice"],
        bedroom: json["bedroom"] == null ? [] : List<String>.from(json["bedroom"]!.map((x) => x)),
        city: json["city"],
        listingCategory: json["listingCategory"],
        propertyType: json["propertyType"],
        keyWord: json["keyWord"],
        balcony: json["balcony"] == null ? [] : List<String>.from(json["balcony"]!.map((x) => x)),
        bathrooms: json["bathrooms"] == null ? [] : List<String>.from(json["bathrooms"]!.map((x) => x)),
        kitchen: json["kitchen"] == null ? [] : List<String>.from(json["kitchen"]!.map((x) => x)),
        locality: json["locality"] == null ? [] : List<String>.from(json["locality"]!.map((x) => x)),
        parking: json["parking"] == null ? [] : List<String>.from(json["parking"]!.map((x) => x)),
      );

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (size != null) data["size"] = size;
    if (pageNo != null) data["pageNo"] = pageNo;
    if (sortBy != null) data["sortBy"] = sortBy;
    if (sortOrder != null) data["sortOrder"] = sortOrder;
    if (minPrice != null) data["minPrice"] = minPrice;
    if (maxPrice != null) data["maxPrice"] = maxPrice;
    if (bedroom != null) data["bedroom"] = bedroom;
    if (city != null) data["city"] = city;
    if (listingCategory != null) data["listingCategory"] = listingCategory;
    if (propertyType != null) data["propertyType"] = propertyType;
    if (keyWord != null) data["keyWord"] = keyWord;
    if (balcony != null) data["balcony"] = balcony;
    if (bathrooms != null) data["bathrooms"] = bathrooms;
    if (kitchen != null) data["kitchen"] = kitchen;
    if (locality != null) data["locality"] = locality;
    if (parking != null) data["parking"] = parking;
    return data;
  }
}
