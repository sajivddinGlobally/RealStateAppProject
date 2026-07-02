// To parse this JSON data, do
//
//     final homeGetServiceCategoryById = homeGetServiceCategoryByIdFromJson(jsonString);

import 'dart:convert';

HomeGetServiceCategoryById homeGetServiceCategoryByIdFromJson(String str) =>
    HomeGetServiceCategoryById.fromJson(json.decode(str));

String homeGetServiceCategoryByIdToJson(HomeGetServiceCategoryById data) =>
    json.encode(data.toJson());

class HomeGetServiceCategoryById {
  String? message;
  int? code;
  bool? error;
  Data? data;

  HomeGetServiceCategoryById({this.message, this.code, this.error, this.data});

  factory HomeGetServiceCategoryById.fromJson(Map<String, dynamic> json) =>
      HomeGetServiceCategoryById(
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
  String? id;
  String? name;
  String? image;
  bool? isDisable;
  bool? isDeleted;
  List<Slot>? slots;
  int? date;
  int? month;
  int? year;
  int? createdAt;
  int? updatedAt;
  int? serviceFee;
  List<PricingOption>? pricingOptions;
  num? averageRating;
  int? totalReviews;
  List<ReviewsList>? reviewsList;

  Data({
    this.id,
    this.name,
    this.image,
    this.isDisable,
    this.isDeleted,
    this.slots,
    this.date,
    this.month,
    this.year,
    this.createdAt,
    this.updatedAt,
    this.serviceFee,
    this.pricingOptions,
    this.averageRating,
    this.totalReviews,
    this.reviewsList,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    id: json["_id"],
    name: json["name"],
    image: json["image"],
    isDisable: json["isDisable"],
    isDeleted: json["isDeleted"],
    slots: json["slots"] == null
        ? []
        : List<Slot>.from(json["slots"]!.map((x) => Slot.fromJson(x))),
    date: json["date"],
    month: json["month"],
    year: json["year"],
    createdAt: json["createdAt"],
    updatedAt: json["updatedAt"],
    serviceFee: json['serviceFee'],
    pricingOptions: json["pricingOptions"] == null
        ? []
        : List<PricingOption>.from(
            json["pricingOptions"]!.map((x) => PricingOption.fromJson(x)),
          ),
    averageRating: json["averageRating"],
    totalReviews: json["totalReviews"],
    reviewsList: json["reviewsList"] == null
        ? []
        : List<ReviewsList>.from(
            json["reviewsList"]!.map((x) => ReviewsList.fromJson(x)),
          ),
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "name": name,
    "image": image,
    "isDisable": isDisable,
    "isDeleted": isDeleted,
    "slots": slots == null
        ? []
        : List<dynamic>.from(slots!.map((x) => x.toJson())),
    "date": date,
    "month": month,
    "year": year,
    "createdAt": createdAt,
    "updatedAt": updatedAt,
    "serviceFee":serviceFee,
    "pricingOptions": pricingOptions == null
        ? []
        : List<dynamic>.from(pricingOptions!.map((x) => x.toJson())),
    "averageRating": averageRating,
    "totalReviews": totalReviews,
    "reviewsList": reviewsList == null
        ? []
        : List<dynamic>.from(reviewsList!.map((x) => x.toJson())),
  };
}

class PricingOption {
  String? title;
  int? price;
  String? image;
  String? description;
  String? id;

  PricingOption({
    this.title,
    this.price,
    this.image,
    this.description,
    this.id,
  });

  factory PricingOption.fromJson(Map<String, dynamic> json) => PricingOption(
    title: json["title"],
    price: json["price"],
    image: json["image"],
    description: json["description"],
    id: json["_id"],
  );

  Map<String, dynamic> toJson() => {
    "title": title,
    "price": price,
    "image": image,
    "description": description,
    "_id": id,
  };
}

class ReviewsList {
  int? rating;
  String? review;
  int? createdAt;
  User? user;
  dynamic image;

  ReviewsList({
    this.rating,
    this.review,
    this.createdAt,
    this.user,
    this.image,
  });

  factory ReviewsList.fromJson(Map<String, dynamic> json) => ReviewsList(
    rating: json["rating"],
    review: json["review"],
    createdAt: json["createdAt"],
    user: json["user"] == null ? null : User.fromJson(json["user"]),
    image: json["image"],
  );

  Map<String, dynamic> toJson() => {
    "rating": rating,
    "review": review,
    "createdAt": createdAt,
    "user": user?.toJson(),
    "image": image,
  };
}

class User {
  String? name;
  String? image;

  User({this.name, this.image});

  factory User.fromJson(Map<String, dynamic> json) =>
      User(name: json["name"], image: json["image"]);

  Map<String, dynamic> toJson() => {"name": name, "image": image};
}

class Slot {
  String? timeSlot;
  int? slotCount;
  String? id;

  Slot({this.timeSlot, this.slotCount, this.id});

  factory Slot.fromJson(Map<String, dynamic> json) => Slot(
    timeSlot: json["timeSlot"],
    slotCount: json["slotCount"],
    id: json["_id"],
  );

  String? get image => null;

  Map<String, dynamic> toJson() => {
    "timeSlot": timeSlot,
    "slotCount": slotCount,
    "_id": id,
  };
}
