import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:realstate/Model/Body/homeGerServiceCategoryByIdModel.dart';
import 'package:realstate/core/network/api.state.dart';
import 'package:realstate/core/utils/preety.dio.dart';

final homeServiceCategoryByIdController =
    FutureProvider.family<HomeGetServiceCategoryById, String>((ref, id) async {
      final service = APIStateNetwork(createDio());
      return await service.homeServiceCategoryById(id);
    });
