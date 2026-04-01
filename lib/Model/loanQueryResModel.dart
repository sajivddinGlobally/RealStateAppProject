// To parse this JSON data, do
//
//     final loanQueryResModel = loanQueryResModelFromJson(jsonString);

import 'dart:convert';

LoanQueryResModel loanQueryResModelFromJson(String str) => LoanQueryResModel.fromJson(json.decode(str));

String loanQueryResModelToJson(LoanQueryResModel data) => json.encode(data.toJson());

class LoanQueryResModel {
    String? message;
    int? code;
    bool? error;
    Data? data;

    LoanQueryResModel({
        this.message,
        this.code,
        this.error,
        this.data,
    });

    factory LoanQueryResModel.fromJson(Map<String, dynamic> json) => LoanQueryResModel(
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
    int? amount;
    String? phone;
    bool? finalize;
    String? city;
    bool? isDisable;
    bool? isDeleted;
    String? id;
    int? date;
    int? month;
    int? year;
    int? createdAt;
    int? updatedAt;

    Data({
        this.amount,
        this.phone,
        this.finalize,
        this.city,
        this.isDisable,
        this.isDeleted,
        this.id,
        this.date,
        this.month,
        this.year,
        this.createdAt,
        this.updatedAt,
    });

    factory Data.fromJson(Map<String, dynamic> json) => Data(
        amount: json["amount"],
        phone: json["phone"],
        finalize: json["finalize"],
        city: json["city"],
        isDisable: json["isDisable"],
        isDeleted: json["isDeleted"],
        id: json["_id"],
        date: json["date"],
        month: json["month"],
        year: json["year"],
        createdAt: json["createdAt"],
        updatedAt: json["updatedAt"],
    );

    Map<String, dynamic> toJson() => {
        "amount": amount,
        "phone": phone,
        "finalize": finalize,
        "city": city,
        "isDisable": isDisable,
        "isDeleted": isDeleted,
        "_id": id,
        "date": date,
        "month": month,
        "year": year,
        "createdAt": createdAt,
        "updatedAt": updatedAt,
    };
}
