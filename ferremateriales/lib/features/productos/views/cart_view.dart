import 'package:ferremateriales/features/productos/models/cart_item_model.dart';
import 'package:ferremateriales/features/productos/services/cart_service.dart';
import 'package:ferremateriales/features/productos/widgets/loading_shimmer.dart';
import 'package:ferremateriales/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/cart_bloc.dart';
import '../bloc/cart_state.dart';
import 'checkout_screen.dart';
import '../services/service_wompi.dart'; 
import 'package:universal_html/html.dart' as html;
import 'package:flutter/foundation.dart';

class CartView extends StatefulWidget {
  const CartView({super.key});

  @override
  _CartViewState createState() => _CartViewState();
}

class _CartViewState extends State<CartView> {
  final CartService _cartService = CartService();
  bool _isLoading = true;
  List<CartItemModel> _cartItems = [];

  @override
  void initState() {
    super.initState();
    _loadCartItems();
  }

  Future<void> _loadCartItems() async {
    try {
      final items = await _cartService.getCartItems();
      setState(() {
        _cartItems = items;
        _isLoading = false;
      });
    } catch (e) {
      print('Error: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final total = _cartItems.fold<double>(
      0,
      (sum, item) => sum + ((item.product.precio ?? 0) * item.quantity),
    );

    return BlocBuilder<CartBloc, CartState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: isDark ? Colors.grey.shade900 : Colors.grey.shade50,
          appBar: AppBar(
            backgroundColor: isDark ? Colors.grey.shade800 : Colors.white,
            elevation: 0,
            title: Text(
              l10n.myCart,
              style: TextStyle(
                color: isDark ? Colors.white : const Color(0xFF222222),
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: isDark ? Colors.white : const Color(0xFF222222),
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),

          body: _isLoading
              ? const LoadingShimmer(isGrid: false)
              : _cartItems.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.shopping_cart_outlined,
                            size: 100,
                            color: isDark ? Colors.grey.shade600 : Colors.grey.shade300,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            l10n.emptyCart,
                            style: TextStyle(
                              fontSize: 18,
                              color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    )
                  : Column(
                      children: [
                        Expanded(
                          child: ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _cartItems.length,
                            itemBuilder: (context, index) {
                              final item = _cartItems[index];
                              final product = item.product;

                              return Container(
                                margin: const EdgeInsets.only(bottom: 16),
                                decoration: BoxDecoration(
                                  color: isDark ? Colors.grey.shade800 : Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: isDark ? Colors.grey.shade700 : Colors.grey.shade200,
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: 80,
                                        height: 80,
                                        decoration: BoxDecoration(
                                          color: isDark ? Colors.grey.shade700 : Colors.grey.shade100,
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(12),
                                          child: (product.imagenUrl != null && product.imagenUrl!.isNotEmpty)
                                              ? Image.network(
                                                  product.imagenUrl!,
                                                  fit: BoxFit.cover,
                                                )
                                              : Icon(
                                                  Icons.shopping_bag_outlined,
                                                  color: Colors.grey.shade400,
                                                  size: 40,
                                                ),
                                        ),
                                      ),

                                      const SizedBox(width: 12),

                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              product.nombre ?? 'Producto sin nombre',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: isDark ? Colors.blue.shade300 : const Color(0xFF2e67a3),
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              "COP ${(product.precio ?? 0) * item.quantity}",
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: isDark ? Colors.blue.shade300 : const Color(0xFF2e67a3),
                                              ),
                                            ),
                                            const SizedBox(height: 12),

                                            Row(
                                              children: [
                                                IconButton(
                                                  icon: const Icon(Icons.remove, size: 18),
                                                  onPressed: () async {
                                                    await _cartService.decreaseQuantity(item.id);
                                                    _loadCartItems();
                                                  },
                                                ),
                                                Text("${item.quantity}",
                                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                                IconButton(
                                                  icon: const Icon(Icons.add, size: 18),
                                                  onPressed: () async {
                                                    await _cartService.increaseQuantity(item.id);
                                                    _loadCartItems();
                                                  },
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),

                                      IconButton(
                                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                                        onPressed: () async {
                                          await _cartService.removeItem(item.id);
                                          _loadCartItems();
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),

                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.grey.shade800 : Colors.white,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(24),
                              topRight: Radius.circular(24),
                            ),
                          ),
                          child: SafeArea(
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Total general:",
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                                      ),
                                    ),
                                    Text(
                                      "COP ${total.toStringAsFixed(0)}",
                                      style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        color: isDark ? Colors.blue.shade300 : const Color(0xFF2e67a3),
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 16),

                                SizedBox(
                                  width: double.infinity,
                                  height: 56,
                                  child: ElevatedButton(
                                    onPressed: () async {
                                      try {
                                        final data = await PaymentService().createPayment(
                                          cartId: 10,
                                          amount: total.toInt(),
                                          userId: 12,
                                        );

                                        final checkoutUrl = data["checkout_url"];

                                        if (kIsWeb) {
                                          // ⭐ Web → abrir en nueva pestaña
                                          html.window.open(checkoutUrl, "_blank");
                                        } else {
                                          // 📱 Móvil → usar WebView
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => CheckoutScreen(checkoutUrl: checkoutUrl),
                                            ),
                                          );
                                        }
                                      } catch (e) {
                                        print("Error al procesar pago: $e");
                                      }
                                    },
                                    child: const Text("Finalizar compra"),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
        );
      },
    );
  }
}
