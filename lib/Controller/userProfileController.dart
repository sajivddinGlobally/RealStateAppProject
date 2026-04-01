import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:realstate/Model/userProfileResModel.dart';
import 'package:realstate/core/network/api.state.dart';
import 'package:realstate/core/utils/preety.dio.dart';

// final userProfileController = FutureProvider.autoDispose<UserProfileResModel>((
//   ref,
// ) async {
//   final service = APIStateNetwork(createDio());
//   return await service.userProfile();
// });

final userProfileController = FutureProvider.autoDispose<UserProfileResModel>((
  ref,
) async {
  final service = APIStateNetwork(createDio());
  final response = await service.userProfile();
  final box = Hive.box('userdata');

  // 🔹 Hive me save karo
  await box.put('name', response.data?.name ?? 'User');
  await box.put('email', response.data?.email ?? 'N/A');
  await box.put('image', response.data?.image ?? '');

  // 🔹 provider ko data return karo
  return response;
});
