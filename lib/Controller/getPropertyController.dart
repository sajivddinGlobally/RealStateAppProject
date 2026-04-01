import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../Model/Body/PropertyListBodyModel.dart';
import '../Model/getPropertyResponsemodel.dart';
import '../Model/loanServiceResModel.dart';
import '../core/network/api.state.dart';
import '../core/utils/preety.dio.dart';

// Correct Family Provider
final getPropertyController =
    FutureProvider.family<PropertyGetReponseModel, PropertyListBodyModel>((
      ref,
      body,
    ) async {
      final service = APIStateNetwork(createDio());

      return await service.getListProperty(body);
    });
