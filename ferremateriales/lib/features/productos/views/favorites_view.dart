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
                return ListTile(
                  leading: Image.network(fav.imagenUrl ?? ''),
                  title: Text(fav.nombre ?? ''),
                  subtitle: Text('\$${fav.precio?.toStringAsFixed(0)}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.favorite, color: Colors.red),
                    onPressed: () {
                      context.read<ProductBloc>().add(ToggleFavorite(fav.id!));
                    },
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
