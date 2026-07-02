// To parse this JSON data, do
//
//     final loanQueryBodyModel = loanQueryBodyModelFromJson(jsonString);

import 'dart:convert';

LoanQueryBodyModel loanQueryBodyModelFromJson(String str) => LoanQueryBodyModel.fromJson(json.decode(str));

String loanQueryBodyModelToJson(LoanQueryBodyModel data) => json.encode(data.toJson());

class LoanQueryBodyModel {
    String phone;
    String loanType;
    String name;
    String city;

    LoanQueryBodyModel({
        required this.phone,
        required this.loanType,
        required this.name,
        required this.city,
    });

    factory LoanQueryBodyModel.fromJson(Map<String, dynamic> json) => LoanQueryBodyModel(
        phone: json["phone"],
        loanType: json["loanType"],
        name: json["name"],
        city: json["city"],
    );

    Map<String, dynamic> toJson() => {
        "phone": phone,
        "loanType": loanType,
        "name": name,
        "city": city,
    };
}
