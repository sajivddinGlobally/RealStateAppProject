import 'package:realstate/Model/getPropertyResponsemodel.dart';
import 'package:realstate/Model/searchPropertyListResponse.dart';

class PropertyDetailsModel {
  String? id;
  String? property;
  String? propertyType;
  String? listingCategory;
  String? localityArea;
  String? city;
  String? price;
  String? area;
  String? bedRoom;
  List<String>? amenities;
  String? bathrooms;
  String? furnishing;
  String? description;
  String? propertyAddress;
  List<String>? uploadedPhotos;
  String? fullName;
  String? email;
  String? phone;
  bool? verifyed;

  PropertyDetailsModel({
    this.id,
    this.property,
    this.propertyType,
    this.listingCategory,
    this.localityArea,
    this.city,
    this.price,
    this.area,
    this.bedRoom,
    this.amenities,
    this.bathrooms,
    this.furnishing,
    this.description,
    this.propertyAddress,
    this.uploadedPhotos,
    this.fullName,
    this.email,
    this.phone,
    this.verifyed,
  });

  factory PropertyDetailsModel.fromProperty(Property p) {
    return PropertyDetailsModel(
      id: p.id,
      property: p.property,
      propertyType: p.propertyType,
      listingCategory: p.listingCategory,
      localityArea: p.localityArea,
      city: p.city,
      price: p.price,
      area: p.area,
      bedRoom: p.bedRoom,
      amenities: p.amenities,
      bathrooms: p.bathrooms,
      furnishing: p.furnishing,
      description: p.description,
      propertyAddress: p.propertyAddress,
      uploadedPhotos: p.uploadedPhotos,
      fullName: p.fullName,
      email: p.email,
      phone: p.phone,
      verifyed: p.verifyed,
    );
  }

  factory PropertyDetailsModel.fromListElement(ListElement p) {
    return PropertyDetailsModel(
      id: p.id,
      property: p.property,
      propertyType: p.propertyType,
      listingCategory: p.listingCategory,
      localityArea: p.localityArea,
      city: p.city,
      price: p.price,
      area: p.area,
      bedRoom: p.bedRoom,
      amenities: p.amenities,
      bathrooms: p.bathrooms,
      furnishing: p.furnishing,
      description: p.description,
      propertyAddress: p.propertyAddress,
      uploadedPhotos: p.uploadedPhotos,
      fullName: p.fullName,
      email: p.email,
      phone: p.phone,
      verifyed: p.verifyed,
    );
  }
}