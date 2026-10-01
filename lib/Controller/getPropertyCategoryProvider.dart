import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:realstate/Model/getPropertyCategoryModel.dart';
import 'package:realstate/core/network/api.state.dart';
import 'package:realstate/core/utils/preety.dio.dart';

final getPropertyCategoryProvider =
    FutureProvider.autoDispose<GetPropertyCategoriyModel>((ref) async {
      final service = APIStateNetwork(createDio());
      return await service.getPropertyCategorie();
    });
