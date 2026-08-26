import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:realstate/Model/getMyPropertyResModel.dart';
import 'package:realstate/Model/getPropertyResponsemodel.dart';
import '../Model/Body/PropertyListBodyModel.dart';
import '../core/network/api.state.dart';
import '../core/utils/preety.dio.dart';

final getPropertyController =
    FutureProvider.family<PropertyGetReponseModel, PropertyListBodyModel>((
      ref,
      body,
    ) async {
      final service = APIStateNetwork(createDio());

      return await service.getListProperty(body);
    });
