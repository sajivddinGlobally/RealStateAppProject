import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:realstate/Model/planResModel.dart';
import 'package:realstate/core/network/api.state.dart';
import 'package:realstate/core/utils/preety.dio.dart';

final pricingPlanController = FutureProvider.autoDispose<PlanResModel>((
  ref,
) async {
  final service = APIStateNetwork(createDio());
  return await service.pricingPlan();
});
