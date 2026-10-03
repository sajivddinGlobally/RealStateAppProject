// To parse this JSON data, do
//
//     final verifyRazorpayPaymentBodyModel = verifyRazorpayPaymentBodyModelFromJson(jsonString);

import 'dart:convert';

VerifyRazorpayPaymentBodyModel verifyRazorpayPaymentBodyModelFromJson(String str) => VerifyRazorpayPaymentBodyModel.fromJson(json.decode(str));

String verifyRazorpayPaymentBodyModelToJson(VerifyRazorpayPaymentBodyModel data) => json.encode(data.toJson());

class VerifyRazorpayPaymentBodyModel {
    String? bookingId;
    String? razorpayOrderId;
    String? razorpayPaymentId;
    String? razorpaySignature;

    VerifyRazorpayPaymentBodyModel({
        this.bookingId,
        this.razorpayOrderId,
        this.razorpayPaymentId,
        this.razorpaySignature,
    });

    factory VerifyRazorpayPaymentBodyModel.fromJson(Map<String, dynamic> json) => VerifyRazorpayPaymentBodyModel(
        bookingId: json["bookingId"],
        razorpayOrderId: json["razorpay_order_id"],
        razorpayPaymentId: json["razorpay_payment_id"],
        razorpaySignature: json["razorpay_signature"],
    );

    Map<String, dynamic> toJson() => {
        "bookingId": bookingId,
        "razorpay_order_id": razorpayOrderId,
        "razorpay_payment_id": razorpayPaymentId,
        "razorpay_signature": razorpaySignature,
    };
}
