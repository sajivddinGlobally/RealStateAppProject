// To parse this JSON data, do
//
//     final myBookingServiceRequestResModel = myBookingServiceRequestResModelFromJson(jsonString);

import 'dart:convert';

MyBookingServiceRequestResModel myBookingServiceRequestResModelFromJson(String str) => MyBookingServiceRequestResModel.fromJson(json.decode(str));

String myBookingServiceRequestResModelToJson(MyBookingServiceRequestResModel data) => json.encode(data.toJson());

class MyBookingServiceRequestResModel {
    String message;
    int code;
    bool error;
    Data data;

    MyBookingServiceRequestResModel({
        required this.message,
        required this.code,
        required this.error,
        required this.data,
    });

    factory MyBookingServiceRequestResModel.fromJson(Map<String, dynamic> json) => MyBookingServiceRequestResModel(
        message: json["message"],
        code: json["code"],
        error: json["error"],
        data: Data.fromJson(json["data"]),
    );

    Map<String, dynamic> toJson() => {
        "message": message,
        "code": code,
        "error": error,
        "data": data.toJson(),
    };
}

class Data {
    List<ListElement> list;
    int total;

    Data({
        required this.list,
        required this.total,
    });

    factory Data.fromJson(Map<String, dynamic> json) => Data(
        list: List<ListElement>.from(json["list"].map((x) => ListElement.fromJson(x))),
        total: json["total"],
    );

    Map<String, dynamic> toJson() => {
        "list": List<dynamic>.from(list.map((x) => x.toJson())),
        "total": total,
    };
}

class ListElement {
    String id;
    String address;
    DateTime serviceDate;
    String serviceTimeSlot;
    String problemImgae;
    ServiceType serviceType;
    String message;
    String status;
    int serviceFee;
    PaymentStatus paymentStatus;
    bool? isVerified;
    List<Item> items;
    bool isDisable;
    bool isDeleted;
    int date;
    int month;
    int year;
    int createdAt;
    int updatedAt;
    String bookingId;
    int v;
    ServiceBoy? serviceBoy;
    String? serviceProviderImage;
    String? verificationOtp;
    List<Rating> ratings;
    String? beforeImage;
    String? afterImage;

    ListElement({
        required this.id,
        required this.address,
        required this.serviceDate,
        required this.serviceTimeSlot,
        required this.problemImgae,
        required this.serviceType,
        required this.message,
        required this.status,
        required this.serviceFee,
        required this.paymentStatus,
        required this.isVerified,
        required this.items,
        required this.isDisable,
        required this.isDeleted,
        required this.date,
        required this.month,
        required this.year,
        required this.createdAt,
        required this.updatedAt,
        required this.bookingId,
        required this.v,
        this.serviceBoy,
        this.serviceProviderImage,
        this.verificationOtp,
        required this.ratings,
        this.beforeImage,
        this.afterImage,
    });

    factory ListElement.fromJson(Map<String, dynamic> json) => ListElement(
        id: json["_id"],
        address: json["address"],
        serviceDate: DateTime.parse(json["serviceDate"]),
        serviceTimeSlot: json["serviceTimeSlot"],
        problemImgae: json["problemImgae"],
        serviceType: ServiceType.fromJson(json["serviceType"]),
        message: json["message"],
        status: json["status"],
        serviceFee: json["serviceFee"],
        paymentStatus: paymentStatusValues.map[json["paymentStatus"]]!,
        isVerified: json["isVerified"],
       items: json["items"] == null
    ? []
    : List<Item>.from(
        (json["items"] as List).map((x) => Item.fromJson(x)),
      ),
        isDisable: json["isDisable"],
        isDeleted: json["isDeleted"],
        date: json["date"],
        month: json["month"],
        year: json["year"],
        createdAt: json["createdAt"],
        updatedAt: json["updatedAt"],
        bookingId: json["bookingId"],
        v: json["__v"],
        serviceBoy: json["serviceBoy"] == null ? null : ServiceBoy.fromJson(json["serviceBoy"]),
        serviceProviderImage: json["serviceProviderImage"],
        verificationOtp: json["verificationOTP"],
        ratings: List<Rating>.from(json["ratings"].map((x) => Rating.fromJson(x))),
        beforeImage: json["beforeImage"],
        afterImage: json["afterImage"],
    );

    Map<String, dynamic> toJson() => {
        "_id": id,
        "address": address,
        "serviceDate": serviceDate.toIso8601String(),
        "serviceTimeSlot": serviceTimeSlot,
        "problemImgae": problemImgae,
        "serviceType": serviceType.toJson(),
        "message": message,
        "status": status,
        "serviceFee": serviceFee,
        "paymentStatus": paymentStatusValues.reverse[paymentStatus],
        "isVerified": isVerified,
        "items": List<dynamic>.from(items.map((x) => x.toJson())),
        "isDisable": isDisable,
        "isDeleted": isDeleted,
        "date": date,
        "month": month,
        "year": year,
        "createdAt": createdAt,
        "updatedAt": updatedAt,
        "bookingId": bookingId,
        "__v": v,
        "serviceBoy": serviceBoy?.toJson(),
        "serviceProviderImage": serviceProviderImage,
        "verificationOTP": verificationOtp,
        "ratings": List<dynamic>.from(ratings.map((x) => x.toJson())),
        "beforeImage": beforeImage,
        "afterImage": afterImage,
    };
}

class Item {
    String title;
    int price;
    String image;
    String description;
    String id;
    String serviceId;

    Item({
        required this.title,
        required this.price,
        required this.image,
        required this.description,
        required this.id,
        required this.serviceId,
    });

    factory Item.fromJson(Map<String, dynamic> json) => Item(
        title: json["title"],
        price: json["price"],
        image: json["image"],
        description: json["description"],
        id: json["_id"],
        serviceId: json["serviceId"],
    );

    Map<String, dynamic> toJson() => {
        "title": title,
        "price": price,
        "image": image,
        "description": description,
        "_id": id,
        "serviceId": serviceId,
    };
}

enum PaymentStatus {
    PENDING
}

final paymentStatusValues = EnumValues({
    "pending": PaymentStatus.PENDING
});

class Rating {
    String id;
    String userId;
    int rating;
    String? review;
    dynamic image;

    Rating({
        required this.id,
        required this.userId,
        required this.rating,
        required this.review,
        required this.image,
    });

    factory Rating.fromJson(Map<String, dynamic> json) => Rating(
        id: json["_id"],
        userId: json["userId"],
        rating: json["rating"],
        review: json["review"],
        image: json["image"],
    );

    Map<String, dynamic> toJson() => {
        "_id": id,
        "userId": userId,
        "rating": rating,
        "review": review,
        "image": image,
    };
}

class ServiceBoy {
    String id;
    String name;
    String phone;

    ServiceBoy({
        required this.id,
        required this.name,
        required this.phone,
    });

    factory ServiceBoy.fromJson(Map<String, dynamic> json) => ServiceBoy(
        id: json["_id"],
        name: json["name"],
        phone: json["phone"],
    );

    Map<String, dynamic> toJson() => {
        "_id": id,
        "name": name,
        "phone": phone,
    };
}

class ServiceType {
    String id;
    String name;
    String image;
    List<Slot> slots;

    ServiceType({
        required this.id,
        required this.name,
        required this.image,
        required this.slots,
    });

    factory ServiceType.fromJson(Map<String, dynamic> json) => ServiceType(
        id: json["_id"],
        name: json["name"],
        image: json["image"],
        slots: List<Slot>.from(json["slots"].map((x) => Slot.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "_id": id,
        "name": name,
        "image": image,
        "slots": List<dynamic>.from(slots.map((x) => x.toJson())),
    };
}

class Slot {
    String timeSlot;
    int slotCount;
    String id;

    Slot({
        required this.timeSlot,
        required this.slotCount,
        required this.id,
    });

    factory Slot.fromJson(Map<String, dynamic> json) => Slot(
        timeSlot: json["timeSlot"],
        slotCount: json["slotCount"],
        id: json["_id"],
    );

    Map<String, dynamic> toJson() => {
        "timeSlot": timeSlot,
        "slotCount": slotCount,
        "_id": id,
    };
}

class EnumValues<T> {
    Map<String, T> map;
    late Map<T, String> reverseMap;

    EnumValues(this.map);

    Map<T, String> get reverse {
            reverseMap = map.map((k, v) => MapEntry(v, k));
            return reverseMap;
    }
}
