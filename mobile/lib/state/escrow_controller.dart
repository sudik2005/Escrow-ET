import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/escrow_api.dart';
import '../models/escrow_contract.dart';
import 'auth_controller.dart';

final escrowApiProvider = Provider<EscrowApi>((ref) {
  return EscrowApi(ref.watch(apiClientProvider));
});

final escrowListProvider = FutureProvider<List<EscrowContract>>((ref) async {
  final session = ref.watch(authControllerProvider).session;
  if (session == null) return const [];
  // Depend on account + role so a login or buyer↔seller switch never
  // reuses the previous person's list.
  session.user.id;
  session.user.role;
  return ref.read(escrowApiProvider).mine(session.token);
});
