// To parse this JSON data, do
//
//     final createPropertyBodyModel = createPropertyBodyModelFromJson(jsonString);

import 'dart:convert';

CreatePropertyBodyModel createPropertyBodyModelFromJson(String str) =>
    CreatePropertyBodyModel.fromJson(json.decode(str));

String createPropertyBodyModelToJson(CreatePropertyBodyModel data) =>
    json.encode(data.toJson());

class CreatePropertyBodyModel {
  String? propertyType;
  String? localityArea;
  String? property;
  String? listingCategory;
  String? city;
  String? price;
  String? area;
  String? bedRoom;
  List<String>? amenities;
  List<AroundProject>? aroundProject;
  String? permitNo;
  String? rera;
  String? ded;
  String? brn;
  String? bathrooms;
  String? furnishing;
  String? description;
  AveneuOverView? aveneuOverView;

  String? propertyAddress;

  List<String>? uploadedPhotos;

  CreatePropertyBodyModel({
    this.propertyType,
    this.property,
    this.localityArea,
    this.listingCategory,
    this.city,
    this.price,
    this.area,
    this.bedRoom,
    this.amenities,
    this.aroundProject,
    this.permitNo,
    this.rera,
    this.ded,
    this.brn,
    this.bathrooms,
    this.furnishing,
    this.description,
    this.aveneuOverView,
    this.propertyAddress,
    this.uploadedPhotos,
  });

  factory CreatePropertyBodyModel.fromJson(Map<String, dynamic> json) =>
      CreatePropertyBodyModel(
        propertyType: json["propertyType"],
        property: json["property"],
        localityArea: json["localityArea"],
        listingCategory: json["listingCategory"],
        city: json["city"],
        price: json["price"],
        area: json["area"],
        bedRoom: json["bedRoom"],
        amenities: json["amenities"] == null
            ? []
            : List<String>.from(json["amenities"]!.map((x) => x)),
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
        furnishing: json["furnishing"],
        description: json["description"],
        aveneuOverView: json["aveneuOverView"] == null
            ? null
            : AveneuOverView.fromJson(json["aveneuOverView"]),
        propertyAddress: json["propertyAddress"],
        uploadedPhotos: json["uploadedPhotos"] == null
            ? []
            : List<String>.from(json["uploadedPhotos"]!.map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
    "propertyType": propertyType,
    "property": property,
    "localityArea": localityArea,
    "listingCategory": listingCategory,
    "city": city,
    "price": price,
    "area": area,
    "bedRoom": bedRoom,
    "amenities": amenities == null
        ? []
        : List<dynamic>.from(amenities!.map((x) => x)),
    "aroundProject": aroundProject == null
        ? []
        : List<dynamic>.from(aroundProject!.map((x) => x.toJson())),
    "permitNo": permitNo,
    "rera": rera,
    "ded": ded,
    "brn": brn,
    "bathrooms": bathrooms,
    "furnishing": furnishing,
    "description": description,
    "aveneuOverView": aveneuOverView?.toJson(),
    "propertyAddress": propertyAddress,
    "uploadedPhotos": uploadedPhotos == null
        ? []
        : List<dynamic>.from(uploadedPhotos!.map((x) => x)),
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
