import 'dart:convert';
import 'package:ferremateriales/features/productos/bloc/product_bloc.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/cart_bloc.dart';
import '../bloc/cart_event.dart';
import '../bloc/cart_state.dart';

class FavoritesView extends StatelessWidget {
  const FavoritesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Favoritos ❤️"),
        centerTitle: true,
      ),
      body: BlocBuilder<ProductBloc, ProductState>(
        builder: (context, state) {
          if (state is ProductLoadInProgress) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ProductLoadSuccess) {
            final favoritos = state.productos.where((p) => p.isFavorite).toList();

            if (favoritos.isEmpty) {
              return const Center(child: Text("No tienes productos favoritos"));
            }

            return ListView.builder(
              itemCount: favoritos.length,
              itemBuilder: (context, index) {
                final fav = favoritos[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  child: ListTile(
                    leading: Image.network(
                      fav.imagenUrl ?? '',
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
                    ),
                    title: Text(fav.nombre ?? ''),
                    subtitle: Text('\$${fav.precio?.toStringAsFixed(0)}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // ❤️ Botón de favoritos
                        IconButton(
                          icon: const Icon(Icons.favorite, color: Colors.red),
                          onPressed: () {
                            context.read<ProductBloc>().add(ToggleFavorite(fav.id!));
                          },
                        ),

                        // 🛒 Botón de comprar (copiado de ProductCard)
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.brown[700],
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                            minimumSize: const Size(90, 35),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          icon: const Icon(Icons.shopping_cart, size: 16, color: Colors.white),
                          label: const Text(
                            "Comprar",
                            style: TextStyle(fontSize: 13, color: Colors.white),
                          ),
                          onPressed: () {
                            // Enviar al carrito 🛒
                            context.read<CartBloc>().add(
                              AddToCart({
                                "name": fav.nombre ?? '',
                                "price": fav.precio ?? 0.0,
                                "quantity": 1,
                                "image": fav.imagenUrl ?? '',
                              }),
                            );

                            // Notificación visual
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('${fav.nombre} agregado al carrito 🛒'),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          } else {
            return const Center(child: Text("Error al cargar productos"));
          }
        },
      ),
    );
  }
}
