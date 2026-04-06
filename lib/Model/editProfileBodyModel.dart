
import 'dart:convert';

EditProfileBodyModel editProfileBodyModelFromJson(String str) =>
    EditProfileBodyModel.fromJson(json.decode(str));

String editProfileBodyModelToJson(EditProfileBodyModel data) =>
    json.encode(data.toJson());

class EditProfileBodyModel {
  String? name;
  String? image;
  String? email;
  String? pincode;
  String? state;
  String? city;
  String? address;

  EditProfileBodyModel({
     this.name,
     this.image,
     this.email,
     this.pincode,
     this.state,
     this.city,
     this.address,
  });

  factory EditProfileBodyModel.fromJson(Map<String, dynamic> json) =>
      EditProfileBodyModel(
        name: json["name"],
        image: json["image"],
        address: json["address"],
        city: json["city"],
        state: json["state"],
        pincode: json["pincode"],
        email: json['email'],
      );

  Map<String, dynamic> toJson() => {
    "name": name,
    "image": image,
    "pincode": pincode,
    "state": state,
    "city": city,
    "address": address,
    "email": email,
  };
}
