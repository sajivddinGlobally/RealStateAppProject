import 'dart:convert';

CheckSlotResModel checkSlotResModelFromJson(String str) =>
    CheckSlotResModel.fromJson(json.decode(str));

String checkSlotResModelToJson(CheckSlotResModel data) =>
    json.encode(data.toJson());

class CheckSlotResModel {
  String? message;
  int? code;
  bool? error;
  Data? data;

  CheckSlotResModel({
    this.message,
    this.code,
    this.error,
    this.data,
  });

  factory CheckSlotResModel.fromJson(Map<String, dynamic> json) {
    final rawData = json["data"];

    return CheckSlotResModel(
      message: json["message"]?.toString(),
      code: json["code"] is int
          ? json["code"]
          : int.tryParse(json["code"]?.toString() ?? ""),
      error: json["error"] is bool
          ? json["error"]
          : json["error"]?.toString().toLowerCase() == "true",
      data: rawData is Map<String, dynamic>
          ? Data.fromJson(rawData)
          : (rawData is int)
              ? Data(
                  slotAvailable: rawData > 0,
                  remainingSlots: rawData,
                )
              : null,
    );
  }

  Map<String, dynamic> toJson() => {
        "message": message,
        "code": code,
        "error": error,
        "data": data?.toJson(),
      };
}

class Data {
  bool? slotAvailable;
  int? remainingSlots;

  Data({
    this.slotAvailable,
    this.remainingSlots,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        slotAvailable: json["slotAvailable"] is bool
            ? json["slotAvailable"]
            : json["slotAvailable"]?.toString().toLowerCase() == "true",
        remainingSlots: json["remainingSlots"] is int
            ? json["remainingSlots"]
            : int.tryParse(json["remainingSlots"]?.toString() ?? "0"),
      );

  Map<String, dynamic> toJson() => {
        "slotAvailable": slotAvailable,
        "remainingSlots": remainingSlots,
      };
}