import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:realstate/core/network/api.state.dart';
import 'package:realstate/core/utils/preety.dio.dart';

final readNotificationController = FutureProvider.autoDispose((ref) async {
  final servie = APIStateNetwork(createDio());
  return await servie.readNotificattion();
});
