// // To parse this JSON data, do
// //
// //     final getMyPropertyDetailsResModel = getMyPropertyDetailsResModelFromJson(jsonString);

// import 'dart:convert';

// GetMyPropertyDetailsResModel getMyPropertyDetailsResModelFromJson(String str) => GetMyPropertyDetailsResModel.fromJson(json.decode(str));

// String getMyPropertyDetailsResModelToJson(GetMyPropertyDetailsResModel data) => json.encode(data.toJson());

// class GetMyPropertyDetailsResModel {
//     String? message;
//     int? code;
//     bool? error;
//     Data? data;

//     GetMyPropertyDetailsResModel({
//         this.message,
//         this.code,
//         this.error,
//         this.data,
//     });

//     factory GetMyPropertyDetailsResModel.fromJson(Map<String, dynamic> json) => GetMyPropertyDetailsResModel(
//         message: json["message"],
//         code: json["code"],
//         error: json["error"],
//         data: json["data"] == null ? null : Data.fromJson(json["data"]),
//     );

//     Map<String, dynamic> toJson() => {
//         "message": message,
//         "code": code,
//         "error": error,
//         "data": data?.toJson(),
//     };
// }

// class Data {
//     String? id;
//     String? property;
//     String? propertyType;
//     String? listingCategory;
//     String? localityArea;
//     String? city;
//     String? price;
//     String? area;
//     String? bedRoom;
//     List<String>? amenities;
//     String? permitNo;
//     String? rera;
//     String? ded;
//     String? brn;
//     String? bathrooms;
//     String? furnishing;
//     String? description;
//     List<AroundProject>? aroundProject;
//     AveneuOverView? aveneuOverView;
//     String? fullName;
//     String? email;
//     String? phone;
//     String? propertyAddress;
//     List<String>? uploadedPhotos;
//     String? status;
//     bool? isDisable;
//     bool? isDeleted;
//     int? date;
//     int? month;
//     int? year;
//     int? createdAt;
//     int? updatedAt;
//     int? v;
//     String? slug;
//     String? uploadBy;

//     Data({
//         this.id,
//         this.property,
//         this.propertyType,
//         this.listingCategory,
//         this.localityArea,
//         this.city,
//         this.price,
//         this.area,
//         this.bedRoom,
//         this.amenities,
//         this.permitNo,
//         this.rera,
//         this.ded,
//         this.brn,
//         this.bathrooms,
//         this.furnishing,
//         this.description,
//         this.aroundProject,
//         this.aveneuOverView,
//         this.fullName,
//         this.email,
//         this.phone,
//         this.propertyAddress,
//         this.uploadedPhotos,
//         this.status,
//         this.isDisable,
//         this.isDeleted,
//         this.date,
//         this.month,
//         this.year,
//         this.createdAt,
//         this.updatedAt,
//         this.v,
//         this.slug,
//         this.uploadBy,
//     });

//     factory Data.fromJson(Map<String, dynamic> json) => Data(
//         id: json["_id"],
//         property: json["property"],
//         propertyType: json["propertyType"],
//         listingCategory: json["listingCategory"],
//         localityArea: json["localityArea"],
//         city: json["city"],
//         price: json["price"],
//         area: json["area"],
//         bedRoom: json["bedRoom"],
//         amenities: json["amenities"] == null ? [] : List<String>.from(json["amenities"]!.map((x) => x)),
//         permitNo: json["permitNo"],
//         rera: json["rera"],
//         ded: json["ded"],
//         brn: json["brn"],
//         bathrooms: json["bathrooms"],
//         furnishing: json["furnishing"],
//         description: json["description"],
//         aroundProject: json["aroundProject"] == null ? [] : List<AroundProject>.from(json["aroundProject"]!.map((x) => AroundProject.fromJson(x))),
//         aveneuOverView: json["aveneuOverView"] == null ? null : AveneuOverView.fromJson(json["aveneuOverView"]),
//         fullName: json["fullName"],
//         email: json["email"],
//         phone: json["phone"],
//         propertyAddress: json["propertyAddress"],
//         uploadedPhotos: json["uploadedPhotos"] == null ? [] : List<String>.from(json["uploadedPhotos"]!.map((x) => x)),
//         status: json["status"],
//         isDisable: json["isDisable"],
//         isDeleted: json["isDeleted"],
//         date: json["date"],
//         month: json["month"],
//         year: json["year"],
//         createdAt: json["createdAt"],
//         updatedAt: json["updatedAt"],
//         v: json["__v"],
//         slug: json["slug"],
//         uploadBy: json["uploadBy"],
//     );

//     Map<String, dynamic> toJson() => {
//         "_id": id,
//         "property": property,
//         "propertyType": propertyType,
//         "listingCategory": listingCategory,
//         "localityArea": localityArea,
//         "city": city,
//         "price": price,
//         "area": area,
//         "bedRoom": bedRoom,
//         "amenities": amenities == null ? [] : List<dynamic>.from(amenities!.map((x) => x)),
//         "permitNo": permitNo,
//         "rera": rera,
//         "ded": ded,
//         "brn": brn,
//         "bathrooms": bathrooms,
//         "furnishing": furnishing,
//         "description": description,
//         "aroundProject": aroundProject == null ? [] : List<dynamic>.from(aroundProject!.map((x) => x.toJson())),
//         "aveneuOverView": aveneuOverView?.toJson(),
//         "fullName": fullName,
//         "email": email,
//         "phone": phone,
//         "propertyAddress": propertyAddress,
//         "uploadedPhotos": uploadedPhotos == null ? [] : List<dynamic>.from(uploadedPhotos!.map((x) => x)),
//         "status": status,
//         "isDisable": isDisable,
//         "isDeleted": isDeleted,
//         "date": date,
//         "month": month,
//         "year": year,
//         "createdAt": createdAt,
//         "updatedAt": updatedAt,
//         "__v": v,
//         "slug": slug,
//         "uploadBy": uploadBy,
//     };
// }

// class AroundProject {
//     String? name;
//     String? details;
//     String? id;

//     AroundProject({
//         this.name,
//         this.details,
//         this.id,
//     });

//     factory AroundProject.fromJson(Map<String, dynamic> json) => AroundProject(
//         name: json["name"],
//         details: json["details"],
//         id: json["_id"],
//     );

//     Map<String, dynamic> toJson() => {
//         "name": name,
//         "details": details,
//         "_id": id,
//     };
// }

// class AveneuOverView {
//     String? size;
//     String? projectSize;
//     String? avgPrice;

//     AveneuOverView({
//         this.size,
//         this.projectSize,
//         this.avgPrice,
//     });

//     factory AveneuOverView.fromJson(Map<String, dynamic> json) => AveneuOverView(
//         size: json["size"],
//         projectSize: json["projectSize"],
//         avgPrice: json["avgPrice"],
//     );

//     Map<String, dynamic> toJson() => {
//         "size": size,
//         "projectSize": projectSize,
//         "avgPrice": avgPrice,
//     };
// }



// To parse this JSON data, do
//
//     final getMyPropertyDetailsResModel = getMyPropertyDetailsResModelFromJson(jsonString);

import 'dart:convert';

GetMyPropertyDetailsResModel getMyPropertyDetailsResModelFromJson(String str) => GetMyPropertyDetailsResModel.fromJson(json.decode(str));

String getMyPropertyDetailsResModelToJson(GetMyPropertyDetailsResModel data) => json.encode(data.toJson());

class GetMyPropertyDetailsResModel {
    String? message;
    int? code;
    bool? error;
    Data? data;

    GetMyPropertyDetailsResModel({
        this.message,
        this.code,
        this.error,
        this.data,
    });

    factory GetMyPropertyDetailsResModel.fromJson(Map<String, dynamic> json) => GetMyPropertyDetailsResModel(
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

    Data({
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
