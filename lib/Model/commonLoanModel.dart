import 'loanServiceResModel.dart';
import 'searchPropertyListResponse.dart';

class CommonLoanModel {
  String? id;
  String? name;
  String? bankLogo;
  String? interest;
  String? loanType;
  int? loanAmount;
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

  CommonLoanModel({
    this.id,
    this.name,
    this.bankLogo,
    this.interest,
    this.loanType,
    this.loanAmount,
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

  /// LoanServiceResModel ListElement
  factory CommonLoanModel.fromLoanService(ListElement item) {
    return CommonLoanModel(
      id: item.id,
      name: item.name,
      bankLogo: item.bankLogo,
      interest: item.interest,
      loanAmount: item.loandAmount,
      phone: item.phone,
      tenure: item.tenure,
      monthlyEmi: item.monthlyEmi,
      details: item.details,
      reward: item.reward,
      recommended: item.recommended,
      isDisable: item.isDisable,
      isDeleted: item.isDeleted,
      date: item.date,
      month: item.month,
      year: item.year,
      createdAt: item.createdAt,
      updatedAt: item.updatedAt,
    );
  }

  /// Search API Loan
  factory CommonLoanModel.fromSearchLoan(Loan item) {
    return CommonLoanModel(
      id: item.id,
      name: item.name,
      bankLogo: item.bankLogo,
      interest: item.interest,
      loanType: item.loanType,
      loanAmount: item.loanAmount,
      tenure: item.tenure,
      recommended: item.recommended,
      isDisable: item.isDisable,
      isDeleted: item.isDeleted,
      date: item.date,
      month: item.month,
      year: item.year,
      createdAt: item.createdAt,
      updatedAt: item.updatedAt,
    );
  }
}