
import 'dart:convert';

EditProfileResModel editProfileResModelFromJson(String str) => EditProfileResModel.fromJson(json.decode(str));

String editProfileResModelToJson(EditProfileResModel data) => json.encode(data.toJson());

class EditProfileResModel {
    String? message;
    int? code;
    bool? error;
    Data? data;

    EditProfileResModel({
        this.message,
        this.code,
        this.error,
        this.data,
    });

    factory EditProfileResModel.fromJson(Map<String, dynamic> json) => EditProfileResModel(
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
    String? image;

    Data({
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
        this.image,
    });

    factory Data.fromJson(Map<String, dynamic> json) => Data(
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
        image: json["image"],
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
        "image": image,
    };
}



