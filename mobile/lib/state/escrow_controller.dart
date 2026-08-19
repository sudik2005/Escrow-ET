import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/escrow_api.dart';
import '../models/escrow_contract.dart';
import 'auth_controller.dart';

final escrowApiProvider = Provider<EscrowApi>((ref) {
  return EscrowApi(ref.watch(apiClientProvider));
});

final escrowListProvider = FutureProvider<List<EscrowContract>>((ref) async {
  final token = ref.watch(authControllerProvider).session?.token;
  if (token == null) {
    return const [];
  }
  return ref.read(escrowApiProvider).mine(token);
});
