import 'package:realstate/Model/homeGetServiceCateogryModel.dart';
import 'package:realstate/core/network/api.state.dart';
import 'package:realstate/core/utils/preety.dio.dart';
import 'package:riverpod/riverpod.dart';

final homeServiceCategoryController =
    FutureProvider.autoDispose<HomeGetServiceCategoryModel>((ref) async {
      final service = APIStateNetwork(createDio());
      return await service.homeServiceCategory();
    });









