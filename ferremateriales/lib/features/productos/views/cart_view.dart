import 'package:ferremateriales/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/cart_bloc.dart';
import '../bloc/cart_event.dart';
import '../bloc/cart_state.dart';
import 'payment_view.dart';

class CartView extends StatelessWidget {
  const CartView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocBuilder<CartBloc, CartState>(
      builder: (context, state) {
        final totalItems = state.items.fold<int>(
          0,
          (sum, item) => sum + (item["quantity"] as int),
        );

        return Scaffold(
          appBar: AppBar(
            title: Text("${l10n.myCart} ($totalItems)"),
            centerTitle: true,
          ),
          body: state.items.isEmpty
              ? Center(child: Text(l10n.emptyCart))
              : Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: state.items.length,
                        itemBuilder: (context, index) {
                          final item = state.items[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            child: ListTile(
                              leading: const Icon(Icons.shopping_bag),
                              title: Text(item["name"]),
                              subtitle: Row(
                                children: [
                                  // Botón restar
                                  IconButton(
                                    icon: const Icon(
                                      Icons.remove_circle_outline,
                                      color: Colors.orange,
                                    ),
                                    onPressed: () {
                                      context
                                          .read<CartBloc>()
                                          .add(DecreaseQuantity(item["name"]));
                                    },
                                  ),
                                  // Cantidad
                                  Text(
                                    "${item["quantity"]}",
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                  // Botón sumar
                                  IconButton(
                                    icon: const Icon(
                                      Icons.add_circle_outline,
                                      color: Colors.green,
                                    ),
                                    onPressed: () {
                                      context
                                          .read<CartBloc>()
                                          .add(IncreaseQuantity(item["name"]));
                                    },
                                  ),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    "\$${item["price"] * item["quantity"]}",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  IconButton(
                                    icon: const Icon(Icons.close,
                                        color: Colors.red),
                                    onPressed: () {
                                      context
                                          .read<CartBloc>()
                                          .add(RemoveFromCart(item["name"]));
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    // Footer con el total
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                l10n.total,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                "\$${state.total}",
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          ElevatedButton.icon(
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => PaymentView(total: state.total),
                              ),
                            ),
                            icon: const Icon(Icons.payment),
                            label: Text(l10n.finishPurchase),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2196F3),
                              foregroundColor: Colors.white,
                              minimumSize: const Size(double.infinity, 50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }
}
