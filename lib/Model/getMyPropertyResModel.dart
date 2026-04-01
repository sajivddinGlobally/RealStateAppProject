// To parse this JSON data, do
//
//     final getMyPropertyResModel = getMyPropertyResModelFromJson(jsonString);

import 'dart:convert';

GetMyPropertyResModel getMyPropertyResModelFromJson(String str) => GetMyPropertyResModel.fromJson(json.decode(str));

String getMyPropertyResModelToJson(GetMyPropertyResModel data) => json.encode(data.toJson());

class GetMyPropertyResModel {
    String? message;
    int? code;
    bool? error;
    Data? data;

    GetMyPropertyResModel({
        this.message,
        this.code,
        this.error,
        this.data,
    });

    factory GetMyPropertyResModel.fromJson(Map<String, dynamic> json) => GetMyPropertyResModel(
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
    List<ListElement>? list;

    Data({
        this.total,
        this.list,
    });

    factory Data.fromJson(Map<String, dynamic> json) => Data(
        total: json["total"],
        list: json["list"] == null ? [] : List<ListElement>.from(json["list"]!.map((x) => ListElement.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "total": total,
        "list": list == null ? [] : List<dynamic>.from(list!.map((x) => x.toJson())),
    };
}

class ListElement {
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
    List<AroundProjectGet>? aroundProject;
    AveneuOverViewGet? aveneuOverView;
    String? propertyAddress;
    List<String>? uploadedPhotos;
    String? status;
    bool? verifyed;
    UploadBy? uploadBy;
    bool? isDisable;
    bool? isDeleted;
    int? date;
    int? month;
    int? year;
    int? createdAt;
    int? updatedAt;
    String? slug;
    int? v;

    ListElement({
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
        this.aveneuOverView,
        this.propertyAddress,
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
        this.v,
    });

    factory ListElement.fromJson(Map<String, dynamic> json) => ListElement(
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
        aroundProject: json["aroundProject"] == null ? [] : List<AroundProjectGet>.from(json["aroundProject"]!.map((x) => AroundProjectGet.fromJson(x))),
        aveneuOverView: json["aveneuOverView"] == null ? null : AveneuOverViewGet.fromJson(json["aveneuOverView"]),
        propertyAddress: json["propertyAddress"],
        uploadedPhotos: json["uploadedPhotos"] == null ? [] : List<String>.from(json["uploadedPhotos"]!.map((x) => x)),
        status: json["status"],
        verifyed: json["verifyed"],
        uploadBy: json["uploadBy"] == null ? null : UploadBy.fromJson(json["uploadBy"]),
        isDisable: json["isDisable"],
        isDeleted: json["isDeleted"],
        date: json["date"],
        month: json["month"],
        year: json["year"],
        createdAt: json["createdAt"],
        updatedAt: json["updatedAt"],
        slug: json["slug"],
        v: json["__v"],
    );

    Map<String, dynamic> toJson() => {
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
        "aveneuOverView": aveneuOverView?.toJson(),
        "propertyAddress": propertyAddress,
        "uploadedPhotos": uploadedPhotos == null ? [] : List<dynamic>.from(uploadedPhotos!.map((x) => x)),
        "status": status,
        "verifyed": verifyed,
        "uploadBy": uploadBy?.toJson(),
        "isDisable": isDisable,
        "isDeleted": isDeleted,
        "date": date,
        "month": month,
        "year": year,
        "createdAt": createdAt,
        "updatedAt": updatedAt,
        "slug": slug,
        "__v": v,
    };
}

class AroundProjectGet {
    String? id;
    String? name;
    String? details;

    AroundProjectGet({
        this.id,
        this.name,
        this.details,
    });

    factory AroundProjectGet.fromJson(Map<String, dynamic> json) => AroundProjectGet(
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

class AveneuOverViewGet {
    String? projectArea;
    String? size;
    String? projectSize;
    String? launchDate;
    String? possessionStart;

    AveneuOverViewGet({
        this.projectArea,
        this.size,
        this.projectSize,
        this.launchDate,
        this.possessionStart,
    });

    factory AveneuOverViewGet.fromJson(Map<String, dynamic> json) => AveneuOverViewGet(
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

class UploadBy {
    String? id;
    String? name;
    String? phone;
    String? email;

    UploadBy({
        this.id,
        this.name,
        this.phone,
        this.email,
    });

    factory UploadBy.fromJson(Map<String, dynamic> json) => UploadBy(
        id: json["_id"],
        name: json["name"],
        phone: json["phone"],
        email: json["email"],
    );

    Map<String, dynamic> toJson() => {
        "_id": id,
        "name": name,
        "phone": phone,
        "email": email,
    };
}
