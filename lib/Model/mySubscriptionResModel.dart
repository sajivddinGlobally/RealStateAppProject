import 'dart:convert';

MySubscriptionResModel mySubscriptionResModelFromJson(String str) =>
    MySubscriptionResModel.fromJson(json.decode(str));

String mySubscriptionResModelToJson(MySubscriptionResModel data) =>
    json.encode(data.toJson());

class MySubscriptionResModel {
  String? message;
  int? code;
  bool? error;
  MySubscriptionData? data;

  MySubscriptionResModel({
    this.message,
    this.code,
    this.error,
    this.data,
  });

  factory MySubscriptionResModel.fromJson(Map<String, dynamic> json) =>
      MySubscriptionResModel(
        message: json["message"],
        code: json["code"],
        error: json["error"],
        data: json["data"] == null
            ? null
            : MySubscriptionData.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "message": message,
        "code": code,
        "error": error,
        "data": data?.toJson(),
      };
}

class MySubscriptionData {
  String? id;
  String? userId;
  PlanInfo? planId;
  int? price;
  DateTime? startDate;
  DateTime? endDate;
  String? status;
  String? paymentStatus;
  bool? autoRenew;
  String? razorpayOrderId;
  String? razorpayPaymentId;
  List<UsageTracking>? usageTracking;

  MySubscriptionData({
    this.id,
    this.userId,
    this.planId,
    this.price,
    this.startDate,
    this.endDate,
    this.status,
    this.paymentStatus,
    this.autoRenew,
    this.razorpayOrderId,
    this.razorpayPaymentId,
    this.usageTracking,
  });

  factory MySubscriptionData.fromJson(Map<String, dynamic> json) =>
      MySubscriptionData(
        id: json["_id"],
        userId: json["userId"],
        planId: json["planId"] != null
            ? (json["planId"] is Map<String, dynamic>
                ? PlanInfo.fromJson(json["planId"])
                : PlanInfo(id: json["planId"].toString()))
            : null,
        price: json["price"],
        startDate: json["startDate"] == null
            ? null
            : DateTime.tryParse(json["startDate"]),
        endDate: json["endDate"] == null
            ? null
            : DateTime.tryParse(json["endDate"]),
        status: json["status"],
        paymentStatus: json["paymentStatus"],
        autoRenew: json["autoRenew"],
        razorpayOrderId: json["razorpayOrderId"],
        razorpayPaymentId: json["razorpayPaymentId"],
        usageTracking: json["usageTracking"] == null
            ? []
            : List<UsageTracking>.from(
                json["usageTracking"]!.map((x) => UsageTracking.fromJson(x)),
              ),
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "userId": userId,
        "planId": planId?.toJson(),
        "price": price,
        "startDate": startDate?.toIso8601String(),
        "endDate": endDate?.toIso8601String(),
        "status": status,
        "paymentStatus": paymentStatus,
        "autoRenew": autoRenew,
        "razorpayOrderId": razorpayOrderId,
        "razorpayPaymentId": razorpayPaymentId,
        "usageTracking": usageTracking == null
            ? []
            : List<dynamic>.from(usageTracking!.map((x) => x.toJson())),
      };
}

class PlanInfo {
  String? id;
  String? name;
  String? description;
  int? durationDays;
  int? price;
  int? discountPrice;
  List<PlanBenefitPoint>? points;

  PlanInfo({
    this.id,
    this.name,
    this.description,
    this.durationDays,
    this.price,
    this.discountPrice,
    this.points,
  });

  factory PlanInfo.fromJson(Map<String, dynamic> json) => PlanInfo(
        id: json["_id"],
        name: json["name"],
        description: json["description"],
        durationDays: json["durationDays"],
        price: json["price"],
        discountPrice: json["discountPrice"],
        points: json["points"] == null
            ? []
            : List<PlanBenefitPoint>.from(
                json["points"]!.map((x) => PlanBenefitPoint.fromJson(x)),
              ),
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "name": name,
        "description": description,
        "durationDays": durationDays,
        "price": price,
        "discountPrice": discountPrice,
        "points": points == null
            ? []
            : List<dynamic>.from(points!.map((x) => x.toJson())),
      };
}

class PlanBenefitPoint {
  String? name;
  String? serviceCategory;
  String? type;
  String? value;
  int? limit;

  PlanBenefitPoint({
    this.name,
    this.serviceCategory,
    this.type,
    this.value,
    this.limit,
  });

  factory PlanBenefitPoint.fromJson(Map<String, dynamic> json) =>
      PlanBenefitPoint(
        name: json["name"],
        serviceCategory: json["serviceCategory"],
        type: json["type"],
        value: json["value"]?.toString(),
        limit: json["limit"],
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "serviceCategory": serviceCategory,
        "type": type,
        "value": value,
        "limit": limit,
      };
}

class UsageTracking {
  String? pointName;
  int? usedCount;
  int? totalLimit;

  UsageTracking({
    this.pointName,
    this.usedCount,
    this.totalLimit,
  });

  factory UsageTracking.fromJson(Map<String, dynamic> json) => UsageTracking(
        pointName: json["pointName"],
        usedCount: json["usedCount"] ?? 0,
        totalLimit: json["totalLimit"] ?? 0,
      );

  Map<String, dynamic> toJson() => {
        "pointName": pointName,
        "usedCount": usedCount,
        "totalLimit": totalLimit,
      };
}
