
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../Model/Body/userResister.dart';
import '../Model/registerResModel.dart';
import '../core/network/api.state.dart';
import '../core/utils/preety.dio.dart';


final userRegisterController =
    FutureProvider.family<RegisterResModel, UserResisterBodyModel>((
      ref,
      body,
    ) async {
      final registerService = APIStateNetwork(createDio());

      return await registerService.userRegister(body);
    });
