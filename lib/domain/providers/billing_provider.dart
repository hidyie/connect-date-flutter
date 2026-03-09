import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:connect_date/data/services/billing_service.dart';

final billingServiceProvider = Provider<BillingService>((ref) {
  final service = BillingService();
  ref.onDispose(() => service.dispose());
  return service;
});

final productsProvider = FutureProvider<List<ProductDetails>>((ref) async {
  final billing = ref.watch(billingServiceProvider);
  final isAvailable = await billing.isAvailable();
  if (!isAvailable) return [];
  return billing.getProducts();
});

final billingAvailableProvider = FutureProvider<bool>((ref) async {
  final billing = ref.watch(billingServiceProvider);
  return billing.isAvailable();
});
