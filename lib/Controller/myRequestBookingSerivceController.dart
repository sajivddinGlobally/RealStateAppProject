import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:realstate/Model/myBookingServiceRequestResModel.dart';
import 'package:realstate/core/network/api.state.dart';
import 'package:realstate/core/utils/preety.dio.dart';

import '../Model/GetLoanQueryModel.dart';
import '../Model/SavedModel.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:realstate/core/network/api.state.dart';
import 'package:realstate/core/utils/preety.dio.dart';

final myRequestBookingServiceContorller =
    FutureProvider.autoDispose<MyBookingServiceRequestResModel>((ref) async {
      final service = APIStateNetwork(createDio());
      return await service.MyRequestBookingService();
    });


final myLoanServiceContorller =
FutureProvider.autoDispose<GetLoanQueryModel>((ref) async {
  final service = APIStateNetwork(createDio());
  return await service.myLoanQuery();
});



final createServiceRatingController =
FutureProvider.family.autoDispose<dynamic, Map<String, dynamic>>(
        (ref, body) async {
      final service = APIStateNetwork(createDio());

      final response = await service.createServiceRating(body);

      return response;
    });
