import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:realstate/Model/getLikeProperyResModel.dart';
import 'package:realstate/core/network/api.state.dart';
import 'package:realstate/core/utils/preety.dio.dart';

final likePropertyController = FutureProvider<GetLikePropertyResModel>((
  ref,
) async {
  final service = APIStateNetwork(createDio());
  return await service.getLikeProperty();
});
