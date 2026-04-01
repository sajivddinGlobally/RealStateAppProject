import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:realstate/Model/getMyPropertyBodyModel.dart';
import 'package:realstate/Model/getMyPropertyDetailsResModel.dart';
import 'package:realstate/Model/getMyPropertyResModel.dart';
import 'package:realstate/core/network/api.state.dart';
import 'package:realstate/core/utils/preety.dio.dart';

import '../Model/SavedModel.dart';

final getMyPropertyController =
    FutureProvider.autoDispose<GetMyPropertyResModel>((ref) async {
      final service = APIStateNetwork(createDio());
      return await service.getMyProperty();
    });

final getMyPropertyDetailsController =
    FutureProvider.family<GetMyPropertyDetailsResModel, String>((
      ref,
      body,
    ) async {
      final service = APIStateNetwork(createDio());
      return await service.getMyPropertyDetails(
        GetMyPropertyDetailsBodyModel(id: body),
      );
    });

final getMyPropertyContantListController =
    FutureProvider.autoDispose<SavedListModel>((ref) async {
      final service = APIStateNetwork(createDio());
      return await service.getMyPropertyContantList();
    });
