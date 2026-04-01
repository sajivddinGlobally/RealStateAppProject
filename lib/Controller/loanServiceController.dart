import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:realstate/Model/loanQueryBodyModel.dart';
import 'package:realstate/Model/loanQueryResModel.dart';
import 'package:realstate/Model/loanServiceResModel.dart';
import 'package:realstate/core/network/api.state.dart';
import 'package:realstate/core/utils/preety.dio.dart';

final loanServiceController = FutureProvider<LoanServiceResModel>((ref) async {
  final loanService = APIStateNetwork(createDio());
  return await loanService.fetchAllLoanService(
    LoanServiceBodyModel(pageNo: 1, size: 20),
  );
});

final loanQueryProvider =
    FutureProvider.family<LoanQueryResModel, LoanQueryBodyModel>((
      ref,
      body,
    ) async {
      final service = APIStateNetwork(createDio());
      return await service.loanQuery(body);
    });
