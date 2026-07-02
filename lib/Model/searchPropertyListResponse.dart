// To parse this JSON data, do
//
//     final searchPropertyListResponse = searchPropertyListResponseFromJson(jsonString);

import 'dart:convert';

SearchPropertyListResponse searchPropertyListResponseFromJson(String str) => SearchPropertyListResponse.fromJson(json.decode(str));

String searchPropertyListResponseToJson(SearchPropertyListResponse data) => json.encode(data.toJson());

class SearchPropertyListResponse {
  bool? error;
  DataSearch? data;

  SearchPropertyListResponse({
    this.error,
    this.data,
  });

  factory SearchPropertyListResponse.fromJson(Map<String, dynamic> json) => SearchPropertyListResponse(
    error: json["error"],
    data: json["data"] == null ? null : DataSearch.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {
    "error": error,
    "data": data?.toJson(),
  };
}

class DataSearch {
  List<Property>? properties;
  List<Service>? services;
  List<Loan>? loans;

  DataSearch({
    this.properties,
    this.services,
    this.loans,
  });

  factory DataSearch.fromJson(Map<String, dynamic> json) => DataSearch(
    properties: json["properties"] == null ? [] : List<Property>.from(json["properties"]!.map((x) => Property.fromJson(x))),
    services: json["services"] == null ? [] : List<Service>.from(json["services"]!.map((x) => Service.fromJson(x))),
    loans: json["loans"] == null ? [] : List<Loan>.from(json["loans"]!.map((x) => Loan.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "properties": properties == null ? [] : List<dynamic>.from(properties!.map((x) => x.toJson())),
    "services": services == null ? [] : List<dynamic>.from(services!.map((x) => x.toJson())),
    "loans": loans == null ? [] : List<dynamic>.from(loans!.map((x) => x.toJson())),
  };
}

class Loan {
  String? id;
  String? name;
  String? interest;
  String? bankLogo;
  String? loanType;
  int? loanAmount;
  int? tenure;
  bool? recommended;
  bool? isDisable;
  bool? isDeleted;
  int? date;
  int? month;
  int? year;
  int? createdAt;
  int? updatedAt;

  Loan({
    this.id,
    this.name,
    this.interest,
    this.bankLogo,
    this.loanType,
    this.loanAmount,
    this.tenure,
    this.recommended,
    this.isDisable,
    this.isDeleted,
    this.date,
    this.month,
    this.year,
    this.createdAt,
    this.updatedAt,
  });

  factory Loan.fromJson(Map<String, dynamic> json) => Loan(
    id: json["_id"],
    name: json["name"],
    bankLogo: json["bankLogo"],
    interest: json["interest"],
    loanType: json["loanType"],
    loanAmount: json["loanAmount"],
    tenure: json["tenure"],
    recommended: json["recommended"],
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
    "name": name,
    "interest": interest,
    "bankLogo": bankLogo,
    "loanType": loanType,
    "loanAmount": loanAmount,
    "tenure": tenure,
    "recommended": recommended,
    "isDisable": isDisable,
    "isDeleted": isDeleted,
    "date": date,
    "month": month,
    "year": year,
    "createdAt": createdAt,
    "updatedAt": updatedAt,
  };
}

class Property {
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
  String? isBroker;

  Property({
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
    this.isBroker,
  });

  factory Property.fromJson(Map<String, dynamic> json) => Property(
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
    isBroker: json["isBroker"],
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
    "isBroker": isBroker,
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
  String? size;
  String? projectSize;
  String? avgPrice;
  String? projectArea;
  String? launchDate;
  String? possessionStart;

  AveneuOverView({
    this.size,
    this.projectSize,
    this.avgPrice,
    this.projectArea,
    this.launchDate,
    this.possessionStart,
  });

  factory AveneuOverView.fromJson(Map<String, dynamic> json) => AveneuOverView(
    size: json["size"],
    projectSize: json["projectSize"],
    avgPrice: json["avgPrice"],
    projectArea: json["projectArea"],
    launchDate: json["launchDate"],
    possessionStart: json["possessionStart"],
  );

  Map<String, dynamic> toJson() => {
    "size": size,
    "projectSize": projectSize,
    "avgPrice": avgPrice,
    "projectArea": projectArea,
    "launchDate": launchDate,
    "possessionStart": possessionStart,
  };
}

class Service {
  String? id;
  String? name;
  String? image;
  bool? isDisable;
  bool? isDeleted;
  List<dynamic>? slots;
  List<dynamic>? pricingOptions;
  int? serviceFee;
  int? date;
  int? month;
  int? year;
  int? createdAt;
  int? updatedAt;

  Service({
    this.id,
    this.name,
    this.image,
    this.isDisable,
    this.isDeleted,
    this.slots,
    this.pricingOptions,
    this.date,
    this.serviceFee,
    this.month,
    this.year,
    this.createdAt,
    this.updatedAt,
  });

  factory Service.fromJson(Map<String, dynamic> json) => Service(
    id: json["_id"],
    name: json["name"],
    image: json["image"],
    isDisable: json["isDisable"],
    isDeleted: json["isDeleted"],
    slots: json["slots"] == null ? [] : List<dynamic>.from(json["slots"]!.map((x) => x)),
    pricingOptions: json["pricingOptions"] == null ? [] : List<dynamic>.from(json["pricingOptions"]!.map((x) => x)),
    date: json["date"],
    serviceFee: json["serviceFee"],
    month: json["month"],
    year: json["year"],
    createdAt: json["createdAt"],
    updatedAt: json["updatedAt"],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "name": name,
    "image": image,
    "isDisable": isDisable,
    "isDeleted": isDeleted,
    "slots": slots == null ? [] : List<dynamic>.from(slots!.map((x) => x)),
    "pricingOptions": pricingOptions == null ? [] : List<dynamic>.from(pricingOptions!.map((x) => x)),
    "date": date,
    "serviceFee": serviceFee,
    "month": month,
    "year": year,
    "createdAt": createdAt,
    "updatedAt": updatedAt,
  };
}