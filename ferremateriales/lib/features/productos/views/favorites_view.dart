import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/cart_bloc.dart';
import '../bloc/cart_event.dart';
import '../bloc/cart_state.dart';

class FavoritesView extends StatefulWidget {
  const FavoritesView({super.key});

  @override
  State<FavoritesView> createState() => _FavoritesViewState();
}

class _FavoritesViewState extends State<FavoritesView> {
  List favoritos = [];
  bool isLoading = true;

  Future<void> cargarFavoritos() async {
    try {
      // 👇 Cambia la URL por la de tu backend
      final url = Uri.parse("http://localhost:3000/api/v1/products");
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        setState(() {
          // 🔥 Filtramos solo los favoritos desde la API
          favoritos = data.where((p) => p["favorito"] == true).toList();
          isLoading = false;
        });
      } else {
        throw Exception("Error al obtener los productos: ${response.statusCode}");
      }
    } catch (e) {
      print("❌ Error cargando favoritos: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    cargarFavoritos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Favoritos ❤️"),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : favoritos.isEmpty
              ? const _EstadoVacio()
              : ListView.builder(
                  itemCount: favoritos.length,
                  itemBuilder: (context, index) {
                    final fav = favoritos[index];
                    return Card(
                      margin: const EdgeInsets.all(8),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: Image.network(
                                fav['imagen_url'],
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    width: 50,
                                    height: 50,
                                    color: Colors.grey.shade200,
                                    child: const Icon(Icons.broken_image, color: Colors.grey),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    fav['nombre'] ?? '',
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  Text(fav['descripcion'] ?? ''),
                                  Text(
                                    "\$${(fav['precio'] as num?)?.toStringAsFixed(0) ?? '0'}",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            BlocBuilder<CartBloc, CartState>(
                              builder: (context, state) {
                                final indexInCart = state.items.indexWhere(
                                  (item) => item["name"] == fav['nombre'],
                                );

                                if (indexInCart >= 0) {
                                  final item = state.items[indexInCart];
                                  return Row(
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.remove, color: Colors.orange),
                                        onPressed: () {
                                          context.read<CartBloc>().add(
                                                DecreaseQuantity(item["name"]),
                                              );
                                        },
                                      ),
                                      Text("${item["quantity"]}"),
                                      IconButton(
                                        icon: const Icon(Icons.add, color: Colors.green),
                                        onPressed: () {
                                          context.read<CartBloc>().add(
                                                IncreaseQuantity(item["name"]),
                                              );
                                        },
                                      ),
                                    ],
                                  );
                                } else {
                                  return ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue,
                                      foregroundColor: Colors.white,
                                    ),
                                    onPressed: () {
                                      context.read<CartBloc>().add(
                                            AddToCart({
                                              "name": fav['nombre'],
                                              "price": fav['precio'],
                                              "descripcion": fav['descripcion'],
                                              "imagenUrl": fav['imagen_url'],
                                              "quantity": 1,
                                            }),
                                          );
                                    },
                                    child: const Text("Comprar"),
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}

class _EstadoVacio extends StatelessWidget {
  const _EstadoVacio({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.star_border, size: 80, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            "No tienes productos favoritos",
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
