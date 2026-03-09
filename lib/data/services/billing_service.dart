import 'dart:async';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:connect_date/data/models/premium_subscription.dart';
import 'package:connect_date/core/constants/supabase_constants.dart';

class BillingService {
  final InAppPurchase _iap = InAppPurchase.instance;
  final SupabaseClient _client = Supabase.instance.client;

  StreamSubscription<List<PurchaseDetails>>? _subscription;

  static const String goldMonthlyId = 'heartlink_gold_monthly';
  static const String platinumMonthlyId = 'heartlink_platinum_monthly';
  static const String boostSingleId = 'heartlink_boost_single';
  static const String superLikePackId = 'heartlink_superlike_5pack';

  static const Set<String> _productIds = {
    goldMonthlyId,
    platinumMonthlyId,
    boostSingleId,
    superLikePackId,
  };

  Future<bool> isAvailable() async {
    return await _iap.isAvailable();
  }

  void initialize({
    required void Function(PurchaseDetails) onPurchaseSuccess,
    required void Function(String error) onPurchaseError,
  }) {
    _subscription = _iap.purchaseStream.listen(
      (purchaseDetailsList) {
        for (final purchase in purchaseDetailsList) {
          _handlePurchase(purchase, onPurchaseSuccess, onPurchaseError);
        }
      },
      onDone: () => _subscription?.cancel(),
      onError: (error) => onPurchaseError(error.toString()),
    );
  }

  Future<List<ProductDetails>> getProducts() async {
    final response = await _iap.queryProductDetails(_productIds);
    if (response.error != null) {
      throw Exception('Failed to load products: ${response.error!.message}');
    }
    return response.productDetails;
  }

  Future<void> purchaseSubscription(ProductDetails product) async {
    final purchaseParam = PurchaseParam(productDetails: product);
    await _iap.buyNonConsumable(purchaseParam: purchaseParam);
  }

  Future<void> purchaseConsumable(ProductDetails product) async {
    final purchaseParam = PurchaseParam(productDetails: product);
    await _iap.buyConsumable(purchaseParam: purchaseParam);
  }

  Future<void> restorePurchases() async {
    await _iap.restorePurchases();
  }

  Future<void> _handlePurchase(
    PurchaseDetails purchase,
    void Function(PurchaseDetails) onSuccess,
    void Function(String) onError,
  ) async {
    switch (purchase.status) {
      case PurchaseStatus.purchased:
      case PurchaseStatus.restored:
        final verified = await _verifyPurchase(purchase);
        if (verified) {
          await _activateSubscription(purchase);
          onSuccess(purchase);
        } else {
          onError('Purchase verification failed');
        }
        if (purchase.pendingCompletePurchase) {
          await _iap.completePurchase(purchase);
        }
        break;

      case PurchaseStatus.error:
        onError(purchase.error?.message ?? 'Unknown purchase error');
        if (purchase.pendingCompletePurchase) {
          await _iap.completePurchase(purchase);
        }
        break;

      case PurchaseStatus.pending:
        break;

      case PurchaseStatus.canceled:
        break;
    }
  }

  Future<bool> _verifyPurchase(PurchaseDetails purchase) async {
    // Server-side verification recommended for production
    // For now, verify locally that we have valid purchase data
    return purchase.verificationData.localVerificationData.isNotEmpty;
  }

  Future<void> _activateSubscription(PurchaseDetails purchase) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return;

    String plan;
    Map<String, dynamic> config;

    switch (purchase.productID) {
      case goldMonthlyId:
        plan = 'gold';
        config = {
          'user_id': userId,
          'plan': 'gold',
          'unlimited_likes': false,
          'unlimited_rewinds': false,
          'see_who_likes_you': false,
          'boost_count': 1,
          'super_like_count': 3,
          'expires_at': DateTime.now()
              .add(const Duration(days: 30))
              .toIso8601String(),
        };
        break;

      case platinumMonthlyId:
        plan = 'platinum';
        config = {
          'user_id': userId,
          'plan': 'platinum',
          'unlimited_likes': false,
          'unlimited_rewinds': false,
          'see_who_likes_you': true,
          'boost_count': 3,
          'super_like_count': 10,
          'expires_at': DateTime.now()
              .add(const Duration(days: 30))
              .toIso8601String(),
        };
        break;

      case boostSingleId:
        await _client.from(SupabaseConstants.boostsTable).insert({
          'user_id': userId,
          'expires_at': DateTime.now()
              .add(const Duration(minutes: 30))
              .toIso8601String(),
        });
        return;

      case superLikePackId:
        final existing = await _client
            .from(SupabaseConstants.premiumSubscriptionsTable)
            .select('super_like_count')
            .eq('user_id', userId)
            .maybeSingle();

        final currentCount =
            (existing?['super_like_count'] as int?) ?? 0;

        await _client
            .from(SupabaseConstants.premiumSubscriptionsTable)
            .upsert({
          'user_id': userId,
          'super_like_count': currentCount + 5,
        }, onConflict: 'user_id');
        return;

      default:
        return;
    }

    await _client
        .from(SupabaseConstants.premiumSubscriptionsTable)
        .upsert(config, onConflict: 'user_id');
  }

  /// Log purchase transaction for audit trail
  Future<void> _logTransaction(PurchaseDetails purchase) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return;

    // If you have a payment_transactions table, log here
    // For now, Supabase audit log captures the upsert
  }

  void dispose() {
    _subscription?.cancel();
  }
}
