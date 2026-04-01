// To parse this JSON data, do
//
//     final getLikePropertyResModel = getLikePropertyResModelFromJson(jsonString);

import 'dart:convert';

GetLikePropertyResModel getLikePropertyResModelFromJson(String str) => GetLikePropertyResModel.fromJson(json.decode(str));

String getLikePropertyResModelToJson(GetLikePropertyResModel data) => json.encode(data.toJson());

class GetLikePropertyResModel {
    String? message;
    int? code;
    bool? error;
    List<Datum>? data;

    GetLikePropertyResModel({
        this.message,
        this.code,
        this.error,
        this.data,
    });

    factory GetLikePropertyResModel.fromJson(Map<String, dynamic> json) => GetLikePropertyResModel(
        message: json["message"],
        code: json["code"],
        error: json["error"],
        data: json["data"] == null ? [] : List<Datum>.from(json["data"]!.map((x) => Datum.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "message": message,
        "code": code,
        "error": error,
        "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
    };
}

class Datum {
    String? id;
    PropertyId? propertyId;
    String? userId;
    bool? isDisable;
    bool? isDeleted;
    int? date;
    int? month;
    int? year;
    int? createdAt;
    int? updatedAt;

    Datum({
        this.id,
        this.propertyId,
        this.userId,
        this.isDisable,
        this.isDeleted,
        this.date,
        this.month,
        this.year,
        this.createdAt,
        this.updatedAt,
    });

    factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        id: json["_id"],
        propertyId: json["propertyId"] == null ? null : PropertyId.fromJson(json["propertyId"]),
        userId: json["userId"],
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
        "propertyId": propertyId?.toJson(),
        "userId": userId,
        "isDisable": isDisable,
        "isDeleted": isDeleted,
        "date": date,
        "month": month,
        "year": year,
        "createdAt": createdAt,
        "updatedAt": updatedAt,
    };
}

class PropertyId {
    AveneuOverView? aveneuOverView;
    String? id;
    String? property;
    String? propertyType;
    String? listingCategory;
    String? localityArea;
    String? city;
    String? price;
    String? area;
    String? bedRoom;
    List<String>? amenities;
    String? permitNo;
    String? rera;
    String? ded;
    String? brn;
    String? bathrooms;
    String? furnishing;
    String? description;
    List<AroundProject>? aroundProject;
    String? fullName;
    String? email;
    String? phone;
    String? propertyAddress;
    List<String>? uploadedPhotos;
    String? status;
    bool? isDisable;
    bool? isDeleted;
    int? date;
    int? month;
    int? year;
    int? createdAt;
    int? updatedAt;
    String? slug;
    String? uploadBy;
    bool? verifyed;

    PropertyId({
        this.aveneuOverView,
        this.id,
        this.property,
        this.propertyType,
        this.listingCategory,
        this.localityArea,
        this.city,
        this.price,
        this.area,
        this.bedRoom,
        this.amenities,
        this.permitNo,
        this.rera,
        this.ded,
        this.brn,
        this.bathrooms,
        this.furnishing,
        this.description,
        this.aroundProject,
        this.fullName,
        this.email,
        this.phone,
        this.propertyAddress,
        this.uploadedPhotos,
        this.status,
        this.isDisable,
        this.isDeleted,
        this.date,
        this.month,
        this.year,
        this.createdAt,
        this.updatedAt,
        this.slug,
        this.uploadBy,
        this.verifyed,
    });

    factory PropertyId.fromJson(Map<String, dynamic> json) => PropertyId(
        aveneuOverView: json["aveneuOverView"] == null ? null : AveneuOverView.fromJson(json["aveneuOverView"]),
        id: json["_id"],
        property: json["property"],
        propertyType: json["propertyType"],
        listingCategory: json["listingCategory"],
        localityArea: json["localityArea"],
        city: json["city"],
        price: json["price"],
        area: json["area"],
        bedRoom: json["bedRoom"],
        amenities: json["amenities"] == null ? [] : List<String>.from(json["amenities"]!.map((x) => x)),
        permitNo: json["permitNo"],
        rera: json["rera"],
        ded: json["ded"],
        brn: json["brn"],
        bathrooms: json["bathrooms"],
        furnishing: json["furnishing"],
        description: json["description"],
        aroundProject: json["aroundProject"] == null ? [] : List<AroundProject>.from(json["aroundProject"]!.map((x) => AroundProject.fromJson(x))),
        fullName: json["fullName"],
        email: json["email"],
        phone: json["phone"],
        propertyAddress: json["propertyAddress"],
        uploadedPhotos: json["uploadedPhotos"] == null ? [] : List<String>.from(json["uploadedPhotos"]!.map((x) => x)),
        status: json["status"],
        isDisable: json["isDisable"],
        isDeleted: json["isDeleted"],
        date: json["date"],
        month: json["month"],
        year: json["year"],
        createdAt: json["createdAt"],
        updatedAt: json["updatedAt"],
        slug: json["slug"],
        uploadBy: json["uploadBy"],
        verifyed: json["verifyed"],
    );

    Map<String, dynamic> toJson() => {
        "aveneuOverView": aveneuOverView?.toJson(),
        "_id": id,
        "property": property,
        "propertyType": propertyType,
        "listingCategory": listingCategory,
        "localityArea": localityArea,
        "city": city,
        "price": price,
        "area": area,
        "bedRoom": bedRoom,
        "amenities": amenities == null ? [] : List<dynamic>.from(amenities!.map((x) => x)),
        "permitNo": permitNo,
        "rera": rera,
        "ded": ded,
        "brn": brn,
        "bathrooms": bathrooms,
        "furnishing": furnishing,
        "description": description,
        "aroundProject": aroundProject == null ? [] : List<dynamic>.from(aroundProject!.map((x) => x.toJson())),
        "fullName": fullName,
        "email": email,
        "phone": phone,
        "propertyAddress": propertyAddress,
        "uploadedPhotos": uploadedPhotos == null ? [] : List<dynamic>.from(uploadedPhotos!.map((x) => x)),
        "status": status,
        "isDisable": isDisable,
        "isDeleted": isDeleted,
        "date": date,
        "month": month,
        "year": year,
        "createdAt": createdAt,
        "updatedAt": updatedAt,
        "slug": slug,
        "uploadBy": uploadBy,
        "verifyed": verifyed,
    };
}

class AroundProject {
    String? id;
    String? name;
    String? details;

    AroundProject({
        this.id,
        this.name,
        this.details,
    });

    factory AroundProject.fromJson(Map<String, dynamic> json) => AroundProject(
        id: json["_id"],
        name: json["name"],
        details: json["details"],
    );

    Map<String, dynamic> toJson() => {
        "_id": id,
        "name": name,
        "details": details,
    };
}

class AveneuOverView {
    dynamic size;
    double? projectSize;
    double? avgPrice;

    AveneuOverView({
        this.size,
        this.projectSize,
        this.avgPrice,
    });

    factory AveneuOverView.fromJson(Map<String, dynamic> json) => AveneuOverView(
        size: json["size"],
        projectSize: _toDouble(json["projectSize"]),
      avgPrice: _toDouble(json["avgPrice"]),
    );

    Map<String, dynamic> toJson() => {
        "size": size,
        "projectSize": projectSize,
        "avgPrice": avgPrice,
    };
}



double? _toDouble(dynamic value) {
  if (value == null) return null;
  return double.tryParse(value.toString());
}