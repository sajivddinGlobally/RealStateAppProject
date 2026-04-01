// loan_query_model.dart
class GetLoanQueryModel {
  String? message;
  int? code;
  bool? error;
  LoanResponseData? data;

  GetLoanQueryModel({this.message, this.code, this.error, this.data});

  factory GetLoanQueryModel.fromJson(Map<String, dynamic> json) {
    return GetLoanQueryModel(
      message: json['message'],
      code: json['code'],
      error: json['error'],
      data: json['data'] != null ? LoanResponseData.fromJson(json['data']) : null,
    );
  }
}

class LoanResponseData {
  int? total;
  List<LoanItem>? list;

  LoanResponseData({this.total, this.list});

  factory LoanResponseData.fromJson(Map<String, dynamic> json) {
    return LoanResponseData(
      total: json['total'],
      list: json['list'] != null
          ? (json['list'] as List).map((e) => LoanItem.fromJson(e)).toList()
          : null,
    );
  }
}

class LoanItem {
  String? id;
  String? name;
  String? phone;
  String? userId;
  String? loanType;
  String? city;
  String? status;
  bool? isDisable;
  bool? isDeleted;
  int? date;
  int? month;
  int? year;
  int? createdAt;
  int? updatedAt;

  LoanItem({
    this.id,
    this.name,
    this.phone,
    this.userId,
    this.loanType,
    this.city,
    this.status,
    this.isDisable,
    this.isDeleted,
    this.date,
    this.month,
    this.year,
    this.createdAt,
    this.updatedAt,
  });

  factory LoanItem.fromJson(Map<String, dynamic> json) {
    return LoanItem(
      id: json['_id'],
      name: json['name'],
      phone: json['phone'],
      userId: json['userId'],
      loanType: json['loanType'],
      city: json['city'],
      status: json['status'],
      isDisable: json['isDisable'],
      isDeleted: json['isDeleted'],
      date: json['date'],
      month: json['month'],
      year: json['year'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }
}