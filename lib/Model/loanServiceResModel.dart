// To parse this JSON data, do
//
//     final loanServiceResModel = loanServiceResModelFromJson(jsonString);

import 'dart:convert';

LoanServiceResModel loanServiceResModelFromJson(String str) =>
    LoanServiceResModel.fromJson(json.decode(str));

String loanServiceResModelToJson(LoanServiceResModel data) =>
    json.encode(data.toJson());

class LoanServiceResModel {
  String? message;
  int? code;
  bool? error;
  Data? data;

  LoanServiceResModel({this.message, this.code, this.error, this.data});

  factory LoanServiceResModel.fromJson(Map<String, dynamic> json) =>
      LoanServiceResModel(
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
  int? total;
  List<ListElement>? list;

  Data({this.total, this.list});

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    total: json["total"],
    list: json["list"] == null
        ? []
        : List<ListElement>.from(
            json["list"]!.map((x) => ListElement.fromJson(x)),
          ),
  );

  Map<String, dynamic> toJson() => {
    "total": total,
    "list": list == null
        ? []
        : List<dynamic>.from(list!.map((x) => x.toJson())),
  };
}

class ListElement {
  String? id;
  String? name;
  String? bankLogo;
  String? interest;
  int? loandAmount;
  int? phone;
  int? tenure;
  int? monthlyEmi;
  String? details;
  String? reward;
  bool? recommended;
  bool? isDisable;
  bool? isDeleted;
  int? date;
  int? month;
  int? year;
  int? createdAt;
  int? updatedAt;

  ListElement({
    this.id,
    this.name,
    this.bankLogo,
    this.interest,
    this.loandAmount,
    this.phone,
    this.tenure,
    this.monthlyEmi,
    this.details,
    this.reward,
    this.recommended,
    this.isDisable,
    this.isDeleted,
    this.date,
    this.month,
    this.year,
    this.createdAt,
    this.updatedAt,
  });

  factory ListElement.fromJson(Map<String, dynamic> json) => ListElement(
    id: json["_id"],
    name: json["name"],
    bankLogo: json["bankLogo"],
    interest: json["interest"],
    loandAmount: json["loandAmount"],
    phone: json["phone"],
    tenure: json["tenure"],
    monthlyEmi: json["monthly_emi"],
    details: json["details"],
    reward: json["reward"],
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
    "bankLogo": bankLogo,
    "interest": interest,
    "loandAmount": loandAmount,
    "phone": phone,
    "tenure": tenure,
    "monthly_emi": monthlyEmi,
    "details": details,
    "reward": reward,
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



// To parse this JSON data, do
//
//     final loanServiceBodyModel = loanServiceBodyModelFromJson(jsonString);

LoanServiceBodyModel loanServiceBodyModelFromJson(String str) =>
    LoanServiceBodyModel.fromJson(json.decode(str));

String loanServiceBodyModelToJson(LoanServiceBodyModel data) =>
    json.encode(data.toJson());

class LoanServiceBodyModel {
  int? pageNo;
  int? size;

  LoanServiceBodyModel({this.pageNo, this.size});

  factory LoanServiceBodyModel.fromJson(Map<String, dynamic> json) =>
      LoanServiceBodyModel(pageNo: json["pageNo"], size: json["size"]);

  Map<String, dynamic> toJson() => {"pageNo": pageNo, "size": size};
}
