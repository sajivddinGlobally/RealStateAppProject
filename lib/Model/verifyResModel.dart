// To parse this JSON data, do
//
//     final verifyResModel = verifyResModelFromJson(jsonString);

import 'dart:convert';

VerifyResModel verifyResModelFromJson(String str) => VerifyResModel.fromJson(json.decode(str));

String verifyResModelToJson(VerifyResModel data) => json.encode(data.toJson());

class VerifyResModel {
    String? message;
    int? code;
    bool? error;
    Data? data;

    VerifyResModel({
        this.message,
        this.code,
        this.error,
        this.data,
    });

    factory VerifyResModel.fromJson(Map<String, dynamic> json) => VerifyResModel(
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
    User? user;
    String? token;
    bool? register;

    Data({
        this.user,
        this.token,
        this.register,
    });

    factory Data.fromJson(Map<String, dynamic> json) => Data(
        user: json["user"] == null ? null : User.fromJson(json["user"]),
        token: json["token"],
        register: json["register"],
    );

    Map<String, dynamic> toJson() => {
        "user": user?.toJson(),
        "token": token,
        "register": register,
    };
}

class User {
    String? id;
    String? name;
    String? password;
    String? phone;

    String? email;
    bool? isDisable;
    bool? isDeleted;
    int? date;
    int? month;
    int? year;
    int? createdAt;
    int? updatedAt;

    User({
        this.id,
        this.name,
        this.password,
        this.phone,

        this.email,
        this.isDisable,
        this.isDeleted,
        this.date,
        this.month,
        this.year,
        this.createdAt,
        this.updatedAt,
    });

    factory User.fromJson(Map<String, dynamic> json) => User(
        id: json["_id"],
        name: json["name"],
        password: json["password"],
        phone: json["phone"],

        email: json["email"],
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
        "password": password,
        "phone": phone,

        "email": email,
        "isDisable": isDisable,
        "isDeleted": isDeleted,
        "date": date,
        "month": month,
        "year": year,
        "createdAt": createdAt,
        "updatedAt": updatedAt,
    };
}
