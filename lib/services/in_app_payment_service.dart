import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import '../providers/app_state_provider.dart';

class InAppPaymentService {
  static final InAppPaymentService _instance = InAppPaymentService._internal();
  factory InAppPaymentService() => _instance;
  InAppPaymentService._internal();

  static const String proProductId = 'speedmath_pro_lifetime_49';
  static const String legacyProProductId = 'speedmath_pro_lifetime_29';
  static const Set<String> _productIds = {proProductId, legacyProProductId};

  final InAppPurchase _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;
  AppStateProvider? _appStateProvider;

  bool _isAvailable = false;
  List<ProductDetails> _products = [];
  bool _isLoading = false;

  bool get isAvailable => _isAvailable;
  List<ProductDetails> get products => _products;
  bool get isLoading => _isLoading;

  Future<bool> checkAvailability() async {
    try {
      _isAvailable = await _iap.isAvailable();
    } catch (_) {
      _isAvailable = false;
    }
    return _isAvailable;
  }

  void initialize(AppStateProvider provider) {
    _appStateProvider = provider;
    _subscription?.cancel();
    _subscription = _iap.purchaseStream.listen(
      _handlePurchaseUpdates,
      onDone: () => _subscription?.cancel(),
      onError: (error) => debugPrint('InAppPurchase stream error: $error'),
    );
    loadProducts();
  }

  void dispose() {
    _subscription?.cancel();
  }

  Future<void> loadProducts() async {
    _isLoading = true;
    try {
      _isAvailable = await _iap.isAvailable();
      if (!_isAvailable) {
        debugPrint('In-app purchase not available on this device/platform.');
        _isLoading = false;
        return;
      }

      final ProductDetailsResponse response = await _iap.queryProductDetails(_productIds);
      if (response.error != null) {
        debugPrint('Query product details error: ${response.error!.message}');
      }
      _products = response.productDetails;
    } catch (e) {
      debugPrint('Error loading in-app purchase products: $e');
    } finally {
      _isLoading = false;
    }
  }

  // Initiate Google Play Store 1-Tap Purchase
  Future<bool> buyProProduct() async {
    try {
      if (!_isAvailable || _products.isEmpty) {
        // Refresh products
        await loadProducts();
      }

      ProductDetails? product;
      if (_products.isNotEmpty) {
        product = _products.firstWhere(
          (p) => p.id == proProductId,
          orElse: () => _products.first,
        );
      }

      if (product != null) {
        final PurchaseParam purchaseParam = PurchaseParam(productDetails: product);
        return await _iap.buyNonConsumable(purchaseParam: purchaseParam);
      } else {
        debugPrint('Product $proProductId not found in store.');
        return false;
      }
    } catch (e) {
      debugPrint('Google Play purchase trigger error: $e');
      return false;
    }
  }

  // Restore previous purchases for user (Required by Google Play & Apple policies)
  Future<void> restorePurchases() async {
    try {
      await _iap.restorePurchases();
    } catch (e) {
      debugPrint('Restore purchases error: $e');
    }
  }

  Future<void> _handlePurchaseUpdates(List<PurchaseDetails> purchaseDetailsList) async {
    for (var purchase in purchaseDetailsList) {
      if (purchase.status == PurchaseStatus.pending) {
        debugPrint('Payment pending in Google Play...');
      } else {
        if (purchase.status == PurchaseStatus.error) {
          debugPrint('Purchase error: ${purchase.error?.message}');
        } else if (purchase.status == PurchaseStatus.purchased ||
            purchase.status == PurchaseStatus.restored) {
          // Verify and activate premium in app state
          if (_appStateProvider != null) {
            await _appStateProvider!.processPurchase(
              userName: _appStateProvider!.userName,
              paymentMethod: 'Google Play In-App Billing',
            );
          }
        }
        if (purchase.pendingCompletePurchase) {
          await _iap.completePurchase(purchase);
        }
      }
    }
  }
}
