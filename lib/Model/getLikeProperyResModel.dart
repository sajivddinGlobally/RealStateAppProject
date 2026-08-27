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
    String? bathrooms;
    String? kitchen;
    String? balcony;
    String? parking;
    String? furnishing;
    List<String>? furnishingItems;
    String? description;
    List<AroundProject>? aroundProject;
    String? propertyAddress;
    String? isBroker;
    List<String>? uploadedPhotos;
    String? status;
    bool? verifyed;
    String? uploadBy;
    bool? isDisable;
    bool? isDeleted;
    int? date;
    int? month;
    int? year;
    int? createdAt;
    int? updatedAt;
    String? slug;
    String? brn;
    String? ded;
    String? permitNo;
    String? rera;

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
        this.bathrooms,
        this.kitchen,
        this.balcony,
        this.parking,
        this.furnishing,
        this.furnishingItems,
        this.description,
        this.aroundProject,
        this.propertyAddress,
        this.isBroker,
        this.uploadedPhotos,
        this.status,
        this.verifyed,
        this.uploadBy,
        this.isDisable,
        this.isDeleted,
        this.date,
        this.month,
        this.year,
        this.createdAt,
        this.updatedAt,
        this.slug,
        this.brn,
        this.ded,
        this.permitNo,
        this.rera,
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
        bathrooms: json["bathrooms"],
        kitchen: json["kitchen"],
        balcony: json["balcony"],
        parking: json["parking"],
        furnishing: json["furnishing"],
        furnishingItems: json["furnishingItems"] == null ? [] : List<String>.from(json["furnishingItems"]!.map((x) => x)),
        description: json["description"],
        aroundProject: json["aroundProject"] == null ? [] : List<AroundProject>.from(json["aroundProject"]!.map((x) => AroundProject.fromJson(x))),
        propertyAddress: json["propertyAddress"],
        isBroker: json["isBroker"],
        uploadedPhotos: json["uploadedPhotos"] == null ? [] : List<String>.from(json["uploadedPhotos"]!.map((x) => x)),
        status: json["status"],
        verifyed: json["verifyed"],
        uploadBy: json["uploadBy"],
        isDisable: json["isDisable"],
        isDeleted: json["isDeleted"],
        date: json["date"],
        month: json["month"],
        year: json["year"],
        createdAt: json["createdAt"],
        updatedAt: json["updatedAt"],
        slug: json["slug"],
        brn: json["brn"],
        ded: json["ded"],
        permitNo: json["permitNo"],
        rera: json["rera"],
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
        "bathrooms": bathrooms,
        "kitchen": kitchen,
        "balcony": balcony,
        "parking": parking,
        "furnishing": furnishing,
        "furnishingItems": furnishingItems == null ? [] : List<dynamic>.from(furnishingItems!.map((x) => x)),
        "description": description,
        "aroundProject": aroundProject == null ? [] : List<dynamic>.from(aroundProject!.map((x) => x.toJson())),
        "propertyAddress": propertyAddress,
        "isBroker": isBroker,
        "uploadedPhotos": uploadedPhotos == null ? [] : List<dynamic>.from(uploadedPhotos!.map((x) => x)),
        "status": status,
        "verifyed": verifyed,
        "uploadBy": uploadBy,
        "isDisable": isDisable,
        "isDeleted": isDeleted,
        "date": date,
        "month": month,
        "year": year,
        "createdAt": createdAt,
        "updatedAt": updatedAt,
        "slug": slug,
        "brn": brn,
        "ded": ded,
        "permitNo": permitNo,
        "rera": rera,
    };
}

class AroundProject {
    String? name;
    String? details;
    String? id;

    AroundProject({
        this.name,
        this.details,
        this.id,
    });

    factory AroundProject.fromJson(Map<String, dynamic> json) => AroundProject(
        name: json["name"],
        details: json["details"],
        id: json["_id"],
    );

    Map<String, dynamic> toJson() => {
        "name": name,
        "details": details,
        "_id": id,
    };
}

class AveneuOverView {
    String? projectArea;
    String? size;
    String? projectSize;
    String? launchDate;
    String? possessionStart;

    AveneuOverView({
        this.projectArea,
        this.size,
        this.projectSize,
        this.launchDate,
        this.possessionStart,
    });

    factory AveneuOverView.fromJson(Map<String, dynamic> json) => AveneuOverView(
        projectArea: json["projectArea"],
        size: json["size"],
        projectSize: json["projectSize"],
        launchDate: json["launchDate"],
        possessionStart: json["possessionStart"],
    );

    Map<String, dynamic> toJson() => {
        "projectArea": projectArea,
        "size": size,
        "projectSize": projectSize,
        "launchDate": launchDate,
        "possessionStart": possessionStart,
    };
}
