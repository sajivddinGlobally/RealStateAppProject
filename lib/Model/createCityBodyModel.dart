class CreateCityBodyModel {
  final String cityName;

  CreateCityBodyModel({required this.cityName});

  Map<String, dynamic> toJson() => {"cityName": cityName};
}