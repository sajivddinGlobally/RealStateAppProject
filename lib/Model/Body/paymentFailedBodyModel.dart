// To parse this JSON data, do
//
//     final paymentFailedBodyModel = paymentFailedBodyModelFromJson(jsonString);

import 'dart:convert';

PaymentFailedBodyModel paymentFailedBodyModelFromJson(String str) => PaymentFailedBodyModel.fromJson(json.decode(str));

String paymentFailedBodyModelToJson(PaymentFailedBodyModel data) => json.encode(data.toJson());

class PaymentFailedBodyModel {
    String? razorpayOrderId;
    String? razorpayPaymentId;

    PaymentFailedBodyModel({
        this.razorpayOrderId,
        this.razorpayPaymentId,
    });

    factory PaymentFailedBodyModel.fromJson(Map<String, dynamic> json) => PaymentFailedBodyModel(
        razorpayOrderId: json["razorpay_order_id"],
        razorpayPaymentId: json["razorpay_payment_id"],
    );

    Map<String, dynamic> toJson() => {
        "razorpay_order_id": razorpayOrderId,
        "razorpay_payment_id": razorpayPaymentId,
    };
}
