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
  // ── Filter fields (these must match what backend expects) ────────
  String? minPrice;
  String? maxPrice;
  String? bedrooms;       // comma-separated e.g. "2,3,4"
  String? cities;         // comma-separated e.g. "Jaipur,Gwalior,Delhi"
  // Optional: add more filters later if needed
  String? listingCategory;   // "buy", "rent"
  String? propertyType;      // "apartment", "villa", ...
  String? localityAreas;     // comma-separated localities

  PropertyListBodyModel({
    this.size,
    this.pageNo,
    this.sortBy,
    this.sortOrder,
    this.minPrice,
    this.maxPrice,
    this.bedrooms,
    this.cities,
    this.listingCategory,
    this.propertyType,
    this.localityAreas,
  });

  factory PropertyListBodyModel.fromJson(Map<String, dynamic> json) =>
      PropertyListBodyModel(
        size: json["size"],
        pageNo: json["pageNo"],
        sortBy: json["sortBy"],
        sortOrder: json["sortOrder"],
        minPrice: json["minPrice"],
        maxPrice: json["maxPrice"],
        bedrooms: json["bedrooms"],
        cities: json["cities"],
        listingCategory: json["listingCategory"],
        propertyType: json["propertyType"],
        localityAreas: json["localityAreas"],
      );

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (size != null) data["size"] = size;
    if (pageNo != null) data["pageNo"] = pageNo;
    if (sortBy != null) data["sortBy"] = sortBy;
    if (sortOrder != null) data["sortOrder"] = sortOrder;
    if (minPrice != null) data["minPrice"] = minPrice;
    if (maxPrice != null) data["maxPrice"] = maxPrice;
    if (bedrooms != null) data["bedrooms"] = bedrooms;
    if (cities != null) data["cities"] = cities;
    if (listingCategory != null) data["listingCategory"] = listingCategory;
    if (propertyType != null) data["propertyType"] = propertyType;
    if (localityAreas != null) data["localityAreas"] = localityAreas;
    return data;
  }
}