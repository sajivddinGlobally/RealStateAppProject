class CreateServiceRatingBodyModel {
  final String serviceBooking;
  final int rating;
  final String review;

  CreateServiceRatingBodyModel({
    required this.serviceBooking,
    required this.rating,
    required this.review,
  });

  Map<String, dynamic> toJson() => {
    "serviceBooking": serviceBooking,
    "rating": rating,
    "review": review,
  };
}