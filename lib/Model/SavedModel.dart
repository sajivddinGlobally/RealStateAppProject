// To parse this JSON data, do
//
//     final savedListModel = savedListModelFromJson(jsonString);

import 'dart:convert';

SavedListModel savedListModelFromJson(String str) =>
    SavedListModel.fromJson(json.decode(str));

String savedListModelToJson(SavedListModel data) => json.encode(data.toJson());

class SavedListModel {
  String? message;
  int? code;
  bool? error;
  Data? data;

  SavedListModel({this.message, this.code, this.error, this.data});

  factory SavedListModel.fromJson(Map<String, dynamic> json) => SavedListModel(
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
  int? total;
  List<ListElementSavedProperty>? list;

  Data({this.total, this.list});

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    total: json["total"],
    list: json["list"] == null
        ? []
        : List<ListElementSavedProperty>.from(
            json["list"]!.map((x) => ListElementSavedProperty.fromJson(x)),
          ),
  );

  Map<String, dynamic> toJson() => {
    "total": total,
    "list": list == null
        ? []
        : List<dynamic>.from(list!.map((x) => x.toJson())),
  };
}

class ListElementSavedProperty {
  String? id;
  PropertyId? propertyId;
  String? name;
  String? phone;
  String? email;
  String? status;
  bool? isDisable;
  bool? isDeleted;
  int? date;
  int? month;
  int? year;
  int? createdAt;
  int? updatedAt;
  String? userId;

  ListElementSavedProperty({
    this.id,
    this.propertyId,
    this.name,
    this.phone,
    this.email,
    this.status,
    this.isDisable,
    this.isDeleted,
    this.date,
    this.month,
    this.year,
    this.createdAt,
    this.updatedAt,
    this.userId,
  });

  factory ListElementSavedProperty.fromJson(Map<String, dynamic> json) =>
      ListElementSavedProperty(
        id: json["_id"],
        propertyId: json["propertyId"] == null
            ? null
            : PropertyId.fromJson(json["propertyId"]),
        name: json["name"],
        phone: json["phone"],
        email: json["email"],
        status: json["status"],
        isDisable: json["isDisable"],
        isDeleted: json["isDeleted"],
        date: json["date"],
        month: json["month"],
        year: json["year"],
        createdAt: json["createdAt"],
        updatedAt: json["updatedAt"],
        userId: json["userId"],
      );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "propertyId": propertyId?.toJson(),
    "name": name,
    "phone": phone,
    "email": email,
    "status": status,
    "isDisable": isDisable,
    "isDeleted": isDeleted,
    "date": date,
    "month": month,
    "year": year,
    "createdAt": createdAt,
    "updatedAt": updatedAt,
    "userId": userId,
  };
}

class PropertyId {
  String? id;
  String? property;
  String? propertyType;
  String? listingCategory;
  String? city;
  String? price;
  String? area;
  String? bathrooms;
  String? furnishing;
  String? description;
  String? fullName;
  String? email;
  String? phone;
  String? propertyAddress;
  List<String>? uploadedPhotos;
  String? status;
  int? createdAt;
  int? updatedAt;

  PropertyId({
    this.id,
    this.property,
    this.propertyType,
    this.listingCategory,
    this.city,
    this.price,
    this.area,
    this.bathrooms,
    this.furnishing,
    this.description,
    this.fullName,
    this.email,
    this.phone,
    this.propertyAddress,
    this.uploadedPhotos,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory PropertyId.fromJson(Map<String, dynamic> json) => PropertyId(
    id: json["_id"],
    property: json["property"],
    propertyType: json["propertyType"],
    listingCategory: json["listingCategory"],
    city: json["city"],
    price: json["price"],
    area: json["area"],
    bathrooms: json["bathrooms"],
    furnishing: json["furnishing"],
    description: json["description"],
    fullName: json["fullName"],
    email: json["email"],
    phone: json["phone"],
    propertyAddress: json["propertyAddress"],
    uploadedPhotos: json["uploadedPhotos"] == null
        ? []
        : List<String>.from(json["uploadedPhotos"]!.map((x) => x)),
    status: json["status"],
    createdAt: json["createdAt"],
    updatedAt: json["updatedAt"],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "property": property,
    "propertyType": propertyType,
    "listingCategory": listingCategory,
    "city": city,
    "price": price,
    "area": area,
    "bathrooms": bathrooms,
    "furnishing": furnishing,
    "description": description,
    "fullName": fullName,
    "email": email,
    "phone": phone,
    "propertyAddress": propertyAddress,
    "uploadedPhotos": uploadedPhotos == null
        ? []
        : List<dynamic>.from(uploadedPhotos!.map((x) => x)),
    "status": status,
    "createdAt": createdAt,
    "updatedAt": updatedAt,
  };
}
