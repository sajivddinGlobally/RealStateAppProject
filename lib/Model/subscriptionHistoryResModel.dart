import 'dart:convert';
import 'package:realstate/Model/mySubscriptionResModel.dart';

SubscriptionHistoryResModel subscriptionHistoryResModelFromJson(String str) =>
    SubscriptionHistoryResModel.fromJson(json.decode(str));

String subscriptionHistoryResModelToJson(SubscriptionHistoryResModel data) =>
    json.encode(data.toJson());

class SubscriptionHistoryResModel {
  String? message;
  int? code;
  bool? error;
  List<SubscriptionHistoryItem>? data;

  SubscriptionHistoryResModel({
    this.message,
    this.code,
    this.error,
    this.data,
  });

  factory SubscriptionHistoryResModel.fromJson(Map<String, dynamic> json) =>
      SubscriptionHistoryResModel(
        message: json["message"],
        code: json["code"],
        error: json["error"],
        data: json["data"] == null
            ? []
            : List<SubscriptionHistoryItem>.from(
                json["data"]!.map((x) => SubscriptionHistoryItem.fromJson(x)),
              ),
      );

  Map<String, dynamic> toJson() => {
        "message": message,
        "code": code,
        "error": error,
        "data": data == null
            ? []
            : List<dynamic>.from(data!.map((x) => x.toJson())),
      };
}

class SubscriptionHistoryItem {
  String? id;
  PlanInfo? planId;
  int? price;
  DateTime? startDate;
  DateTime? endDate;
  String? status;
  String? paymentStatus;

  SubscriptionHistoryItem({
    this.id,
    this.planId,
    this.price,
    this.startDate,
    this.endDate,
    this.status,
    this.paymentStatus,
  });

  factory SubscriptionHistoryItem.fromJson(Map<String, dynamic> json) =>
      SubscriptionHistoryItem(
        id: json["_id"],
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
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "planId": planId?.toJson(),
        "price": price,
        "startDate": startDate?.toIso8601String(),
        "endDate": endDate?.toIso8601String(),
        "status": status,
        "paymentStatus": paymentStatus,
      };
}
