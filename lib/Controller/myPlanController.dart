import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:realstate/Model/mySubscriptionResModel.dart';
import 'package:realstate/Model/subscriptionHistoryResModel.dart';
import 'package:realstate/core/network/api.state.dart';
import 'package:realstate/core/utils/preety.dio.dart';

final mySubscriptionController =
    FutureProvider.autoDispose<MySubscriptionResModel>((ref) async {
  final service = APIStateNetwork(createDio());
  return await service.getMySubscription();
});

final subscriptionHistoryController =
    FutureProvider.autoDispose<SubscriptionHistoryResModel>((ref) async {
  final service = APIStateNetwork(createDio());
  return await service.getSubscriptionHistory();
});
