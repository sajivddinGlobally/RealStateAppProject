import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:realstate/Model/getNotificationModel.dart';
import 'package:realstate/core/network/api.state.dart';
import 'package:realstate/core/utils/preety.dio.dart';

final notificationController = FutureProvider.autoDispose<GetNotificationModel>(
  (ref) async {
    final serivce = APIStateNetwork(createDio());
    return await serivce.notification();
  },
);
