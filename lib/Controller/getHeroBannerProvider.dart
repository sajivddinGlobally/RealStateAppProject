import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:realstate/Model/getHeroBannerModel.dart';
import 'package:realstate/core/network/api.state.dart';
import 'package:realstate/core/utils/preety.dio.dart';

final getHeroBannerProvider = FutureProvider.autoDispose<GetHeroBannerModel>((
  ref,
) async {
  final service = APIStateNetwork(createDio());
  return await service.getHeroBanner();
});
