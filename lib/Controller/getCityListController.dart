import 'package:realstate/core/network/api.state.dart';
import 'package:realstate/core/utils/preety.dio.dart';
import 'package:riverpod/riverpod.dart';

import '../Model/CityResponseModel.dart';

final getCityController =
FutureProvider.autoDispose<CityResponseModel>((ref) async {
  final service = APIStateNetwork(createDio());
  return await service.getCityList();
});

