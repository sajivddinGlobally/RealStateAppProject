// To parse this JSON data, do
//
//     final createPropertyBodyModel = createPropertyBodyModelFromJson(jsonString);

import 'dart:convert';

UpdatePropertyBodyModel createPropertyBodyModelFromJson(String str) =>
    UpdatePropertyBodyModel.fromJson(json.decode(str));

String createPropertyBodyModelToJson(UpdatePropertyBodyModel data) =>
    json.encode(data.toJson());

class UpdatePropertyBodyModel {
  String? id;
  String? propertyType;
  String? localityArea;
  String? property;
  String? listingCategory;
  String? city;
  String? price;
  String? balcony;
  String? parking;
  String? area;
  String? bedRoom;
  List<String>? amenities;
  List<String>? furnishingItems;
  List<AroundProject>? aroundProject;
  String? permitNo;
  String? rera;
  String? ded;
  String? brn;
  String? bathrooms;
  String? kitchen;
  String? furnishing;
  String? description;
  String? isBroker;
  AveneuOverView? aveneuOverView;

  String? propertyAddress;
  String? pincode;
  String? houseNumber;
  String? availableFrom;
  String? securityDeposit;
  String? customSecurityDeposit;
  String? guestRoom;
  String? room;

  List<String>? uploadedPhotos;

  UpdatePropertyBodyModel({
    this.propertyType,
    this.id,
    this.property,
    this.localityArea,
    this.listingCategory,
    this.city,
    this.price,
    this.balcony,
    this.parking,
    this.area,
    this.bedRoom,
    this.amenities,
    this.furnishingItems,
    this.aroundProject,
    this.permitNo,
    this.rera,
    this.ded,
    this.brn,
    this.bathrooms,
    this.kitchen,
    this.furnishing,
    this.description,
    this.aveneuOverView,
    this.propertyAddress,
    this.uploadedPhotos,
    this.isBroker,
    this.pincode,
    this.houseNumber,
    this.availableFrom,
    this.securityDeposit,
    this.customSecurityDeposit,
    this.guestRoom,
    this.room,
  });

  factory UpdatePropertyBodyModel.fromJson(Map<String, dynamic> json) =>
      UpdatePropertyBodyModel(
        propertyType: json["propertyType"],
        id: json["id"],
        property: json["property"],
        localityArea: json["localityArea"],
        listingCategory: json["listingCategory"],
        city: json["city"],
        price: json["price"],
        balcony: json["balcony"] ?? json["balcny"],
        parking: json["parking"],
        area: json["area"],
        bedRoom: json["bedRoom"],
        amenities: json["amenities"] == null
            ? []
            : List<String>.from(json["amenities"]!.map((x) => x)),
        furnishingItems: json["furnishingItems"] == null
            ? []
            : List<String>.from(json["furnishingItems"]!.map((x) => x)),
        aroundProject: json["aroundProject"] == null
            ? []
            : List<AroundProject>.from(
                json["aroundProject"]!.map((x) => AroundProject.fromJson(x)),
              ),
        permitNo: json["permitNo"],
        rera: json["rera"],
        ded: json["ded"],
        brn: json["brn"],
        bathrooms: json["bathrooms"],
        kitchen: json["kitchen"],
        furnishing: json["furnishing"],
        description: json["description"],
        aveneuOverView: json["aveneuOverView"] == null
            ? null
            : AveneuOverView.fromJson(json["aveneuOverView"]),
        propertyAddress: json["propertyAddress"],
        uploadedPhotos: json["uploadedPhotos"] == null
            ? []
            : List<String>.from(json["uploadedPhotos"]!.map((x) => x)),
        isBroker: json['isBroker'] ?? json['isBroker '],
        pincode: json["pincode"],
        houseNumber: json["houseNumber"],
        availableFrom: json["availableFrom"],
        securityDeposit: json["securityDeposit"],
        customSecurityDeposit: json["customSecurityDeposit"],
        guestRoom: json["guestRoom"],
        room: json["room"],
      );

  Map<String, dynamic> toJson() => {
    "propertyType": propertyType,
    "id": id,
    "property": property,
    "localityArea": localityArea,
    "listingCategory": listingCategory,
    "city": city,
    "balcony": balcony,
    "parking": parking,
    "price": price,
    "area": area,
    "bedRoom": bedRoom,
    "amenities": amenities == null
        ? []
        : List<dynamic>.from(amenities!.map((x) => x)),
    "furnishingItems": furnishingItems == null
        ? []
        : List<dynamic>.from(furnishingItems!.map((x) => x)),
    "aroundProject": aroundProject == null
        ? []
        : List<dynamic>.from(aroundProject!.map((x) => x.toJson())),
    "permitNo": permitNo,
    "rera": rera,
    "ded": ded,
    "brn": brn,
    "bathrooms": bathrooms,
    "kitchen": kitchen,
    "furnishing": furnishing,
    "description": description,
    "aveneuOverView": aveneuOverView?.toJson(),
    "propertyAddress": propertyAddress,
    "uploadedPhotos": uploadedPhotos == null
        ? []
        : List<dynamic>.from(uploadedPhotos!.map((x) => x)),
    "isBroker": isBroker,
    "pincode": pincode,
    "houseNumber": houseNumber,
    "availableFrom": availableFrom,
    "securityDeposit": securityDeposit,
    "customSecurityDeposit": customSecurityDeposit,
    "guestRoom": guestRoom,
    "room": room,
  };
}

class AroundProject {
  String? name;
  String? details;

  AroundProject({this.name, this.details});

  factory AroundProject.fromJson(Map<String, dynamic> json) =>
      AroundProject(name: json["name"], details: json["details"]);

  Map<String, dynamic> toJson() => {"name": name, "details": details};
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
