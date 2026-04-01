import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:realstate/Model/contactUsBodyModel.dart';
import 'package:realstate/Model/contactUsResModel.dart';
import 'package:realstate/core/network/api.state.dart';
import 'package:realstate/core/utils/preety.dio.dart';

final contactUsController =
    FutureProvider.family<ContactUsResModel, ContactUsBodyModel>((
      ref,
      body,
    ) async {
      final serivce = APIStateNetwork(createDio());
      return await serivce.contactUs(body);
    });
