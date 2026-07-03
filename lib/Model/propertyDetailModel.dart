import 'package:realstate/Model/getPropertyResponsemodel.dart';
import 'package:realstate/Model/searchPropertyListResponse.dart'
    hide AveneuOverView, AroundProject;

class PropertyDetailsModel {
  String? id;
  String? property;
  String? propertyType;
  String? listingCategory;
  String? localityArea;
  String? slug;
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
  List<AroundProject>? aroundProject;
  AveneuOverView? aveneuOverView;

  PropertyDetailsModel({
    this.id,
    this.property,
    this.propertyType,
    this.listingCategory,
    this.slug,
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
    this.aroundProject,
    this.aveneuOverView,
  });

  factory PropertyDetailsModel.fromProperty(Property p) {
    return PropertyDetailsModel(
      id: p.id,
      property: p.property,
      propertyType: p.propertyType,
      slug: p.slug,
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
      aroundProject: p.aroundProject
          ?.map(
            (e) => AroundProject(name: e.name, details: e.details, id: e.id),
          )
          .toList(),

      aveneuOverView: p.aveneuOverView == null
          ? null
          : AveneuOverView(
              projectArea: p.aveneuOverView!.projectArea,
              size: p.aveneuOverView!.size,
              projectSize: p.aveneuOverView!.projectSize,
              launchDate: p.aveneuOverView!.launchDate,
              possessionStart: p.aveneuOverView!.possessionStart,
            ),
    );
  }

  factory PropertyDetailsModel.fromListElement(ListElement p) {
    return PropertyDetailsModel(
      id: p.id,
      property: p.property,
      slug: p.slug,
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
      aroundProject: p.aroundProject,
      aveneuOverView: p.aveneuOverView,
    );
  }
}



//
// class AroundProject {
//   String? name;
//   String? details;
//   String? id;
//
//   AroundProject({this.name, this.details, this.id});
//
//   factory AroundProject.fromJson(Map<String, dynamic> json) =>
//       AroundProject(
//         name: json["name"]?.toString(),
//         details: json["details"]?.toString(),
//         id: json["_id"]?.toString(),
//       );
//
//   Map<String, dynamic> toJson() => {
//     "name": name,
//     "details": details,
//     "_id": id,
//   };
// }
//
// class AveneuOverView {
//   String? projectArea;
//   String? size;
//   String? projectSize;
//   String? launchDate;
//   String? possessionStart;
//
//   AveneuOverView({
//     this.projectArea,
//     this.size,
//     this.projectSize,
//     this.launchDate,
//     this.possessionStart,
//   });
//
//   factory AveneuOverView.fromJson(Map<String, dynamic> json) =>
//       AveneuOverView(
//         projectArea: json["projectArea"]?.toString(),
//         size: json["size"]?.toString(),
//         projectSize: json["projectSize"]?.toString(),
//         launchDate: json["launchDate"]?.toString(),
//         possessionStart: json["possessionStart"]?.toString(),
//       );
//
//   Map<String, dynamic> toJson() => {
//     "projectArea": projectArea,
//     "size": size,
//     "projectSize": projectSize,
//     "launchDate": launchDate,
//     "possessionStart": possessionStart,
//   };
// }