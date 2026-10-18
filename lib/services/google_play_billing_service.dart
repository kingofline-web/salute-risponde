
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

class GooglePlayBillingService {
  GooglePlayBillingService._();

  static final GooglePlayBillingService instance =
      GooglePlayBillingService._();

  static const String plusId = 'salute_plus';
  static const String proId = 'salute_pro';

  final InAppPurchase _billing = InAppPurchase.instance;

  StreamSubscription<List<PurchaseDetails>>? _subscription;

  final ValueNotifier<List<ProductDetails>> products =
      ValueNotifier<List<ProductDetails>>([]);

  final ValueNotifier<String> status =
      ValueNotifier<String>('Non inizializzato');

  Future<void> initialize() async {
    _subscription ??= _billing.purchaseStream.listen(
      _handlePurchases,
      onError: (Object error) {
        status.value = 'Errore durante il pagamento';
      },
    );

    final available = await _billing.isAvailable();

    if (!available) {
      status.value = 'Google Play Billing non disponibile';
      return;
    }

    final response = await _billing.queryProductDetails({
      plusId,
      proId,
    });

    products.value = response.productDetails;

    if (response.error != null) {
      status.value = 'Errore nel caricamento degli abbonamenti';
    } else if (response.notFoundIDs.isNotEmpty) {
      status.value = 'Abbonamenti non ancora disponibili';
    } else {
      status.value = 'Abbonamenti disponibili';
    }
  }

  Future<void> purchase(String productId) async {
    final matches = products.value.where(
      (product) => product.id == productId,
    );

    if (matches.isEmpty) {
      status.value = 'Piano non disponibile';
      return;
    }

    final param = PurchaseParam(
      productDetails: matches.first,
    );

    await _billing.buyNonConsumable(
      purchaseParam: param,
    );
  }

  Future<void> restorePurchases() async {
    await _billing.restorePurchases();
  }

  Future<void> _handlePurchases(
    List<PurchaseDetails> purchases,
  ) async {
    for (final purchase in purchases) {
      switch (purchase.status) {
        case PurchaseStatus.pending:
          status.value = 'Pagamento in corso';
          break;

        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          status.value =
              'Acquisto ricevuto: verifica necessaria';
          // L'accesso PLUS/PRO non viene attivato qui.
          // La verifica dovra essere eseguita dal backend.
          break;

        case PurchaseStatus.error:
          status.value = 'Pagamento non riuscito';
          break;

        case PurchaseStatus.canceled:
          status.value = 'Pagamento annullato';
          break;
      }

      // La finalizzazione dell'acquisto verra gestita
      // dopo l'integrazione della verifica sicura.
    }
  }

  void dispose() {
    _subscription?.cancel();
    _subscription = null;
  }
}
