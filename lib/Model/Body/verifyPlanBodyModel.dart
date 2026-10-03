// To parse this JSON data, do
//
//     final verifyPlanBodyModel = verifyPlanBodyModelFromJson(jsonString);

import 'dart:convert';

VerifyPlanBodyModel verifyPlanBodyModelFromJson(String str) => VerifyPlanBodyModel.fromJson(json.decode(str));

String verifyPlanBodyModelToJson(VerifyPlanBodyModel data) => json.encode(data.toJson());

class VerifyPlanBodyModel {
    String? planId;
    String? razorpayOrderId;
    String? razorpayPaymentId;
    String? razorpaySignature;

    VerifyPlanBodyModel({
        this.planId,
        this.razorpayOrderId,
        this.razorpayPaymentId,
        this.razorpaySignature,
    });

    factory VerifyPlanBodyModel.fromJson(Map<String, dynamic> json) => VerifyPlanBodyModel(
        planId: json["planId"],
        razorpayOrderId: json["razorpay_order_id"],
        razorpayPaymentId: json["razorpay_payment_id"],
        razorpaySignature: json["razorpay_signature"],
    );

    Map<String, dynamic> toJson() => {
        "planId": planId,
        "razorpay_order_id": razorpayOrderId,
        "razorpay_payment_id": razorpayPaymentId,
        "razorpay_signature": razorpaySignature,
    };
}
