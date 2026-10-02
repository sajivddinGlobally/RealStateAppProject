// To parse this JSON data, do
//
//     final updateDesablePropertyResModel = updateDesablePropertyResModelFromJson(jsonString);

import 'dart:convert';

UpdateDesablePropertyResModel updateDesablePropertyResModelFromJson(String str) => UpdateDesablePropertyResModel.fromJson(json.decode(str));

String updateDesablePropertyResModelToJson(UpdateDesablePropertyResModel data) => json.encode(data.toJson());

class UpdateDesablePropertyResModel {
    String? message;
    int? code;
    bool? error;
    Data? data;

    UpdateDesablePropertyResModel({
        this.message,
        this.code,
        this.error,
        this.data,
    });

    factory UpdateDesablePropertyResModel.fromJson(Map<String, dynamic> json) => UpdateDesablePropertyResModel(
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
    AveneuOverView? aveneuOverView;
    String? id;
    String? property;
    String? propertyType;
    String? listingCategory;
    String? localityArea;
    String? city;
    String? price;
    String? securityDeposit;
    String? area;
    String? bedRoom;
    List<String>? amenities;
    String? rera;
    String? bathrooms;
    String? kitchen;
    String? balcony;
    String? parking;
    String? guestRoom;
    String? room;
    String? furnishing;
    List<String>? furnishingItems;
    String? description;
    List<AroundProject>? aroundProject;
    String? propertyAddress;
    String? isBroker;
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
    String? brn;
    String? ded;
    String? permitNo;

    Data({
        this.aveneuOverView,
        this.id,
        this.property,
        this.propertyType,
        this.listingCategory,
        this.localityArea,
        this.city,
        this.price,
        this.securityDeposit,
        this.area,
        this.bedRoom,
        this.amenities,
        this.rera,
        this.bathrooms,
        this.kitchen,
        this.balcony,
        this.parking,
        this.guestRoom,
        this.room,
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
    });

    factory Data.fromJson(Map<String, dynamic> json) => Data(
        aveneuOverView: json["aveneuOverView"] == null ? null : AveneuOverView.fromJson(json["aveneuOverView"]),
        id: json["_id"],
        property: json["property"],
        propertyType: json["propertyType"],
        listingCategory: json["listingCategory"],
        localityArea: json["localityArea"],
        city: json["city"],
        price: json["price"],
        securityDeposit: json["securityDeposit"],
        area: json["area"],
        bedRoom: json["bedRoom"],
        amenities: json["amenities"] == null ? [] : List<String>.from(json["amenities"]!.map((x) => x)),
        rera: json["rera"],
        bathrooms: json["bathrooms"],
        kitchen: json["kitchen"],
        balcony: json["balcony"],
        parking: json["parking"],
        guestRoom: json["guestRoom"],
        room: json["room"],
        furnishing: json["furnishing"],
        furnishingItems: json["furnishingItems"] == null ? [] : List<String>.from(json["furnishingItems"]!.map((x) => x)),
        description: json["description"],
        aroundProject: json["aroundProject"] == null ? [] : List<AroundProject>.from(json["aroundProject"]!.map((x) => AroundProject.fromJson(x))),
        propertyAddress: json["propertyAddress"],
        isBroker: json["isBroker"],
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
        brn: json["brn"],
        ded: json["ded"],
        permitNo: json["permitNo"],
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
        "securityDeposit": securityDeposit,
        "area": area,
        "bedRoom": bedRoom,
        "amenities": amenities == null ? [] : List<dynamic>.from(amenities!.map((x) => x)),
        "rera": rera,
        "bathrooms": bathrooms,
        "kitchen": kitchen,
        "balcony": balcony,
        "parking": parking,
        "guestRoom": guestRoom,
        "room": room,
        "furnishing": furnishing,
        "furnishingItems": furnishingItems == null ? [] : List<dynamic>.from(furnishingItems!.map((x) => x)),
        "description": description,
        "aroundProject": aroundProject == null ? [] : List<dynamic>.from(aroundProject!.map((x) => x.toJson())),
        "propertyAddress": propertyAddress,
        "isBroker": isBroker,
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
        "brn": brn,
        "ded": ded,
        "permitNo": permitNo,
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
    DateTime? launchDate;
    DateTime? possessionStart;

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
        launchDate: json["launchDate"] == null ? null : DateTime.parse(json["launchDate"]),
        possessionStart: json["possessionStart"] == null ? null : DateTime.parse(json["possessionStart"]),
    );

    Map<String, dynamic> toJson() => {
        "projectArea": projectArea,
        "size": size,
        "projectSize": projectSize,
        "launchDate": launchDate == null ? null : "${launchDate!.year.toString().padLeft(4, '0')}-${launchDate!.month.toString().padLeft(2, '0')}-${launchDate!.day.toString().padLeft(2, '0')}",
        "possessionStart": possessionStart == null ? null : "${possessionStart!.year.toString().padLeft(4, '0')}-${possessionStart!.month.toString().padLeft(2, '0')}-${possessionStart!.day.toString().padLeft(2, '0')}",
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
