import 'package:ferremateriales/features/productos/bloc/cart_bloc.dart';
import 'package:ferremateriales/features/productos/bloc/cart_event.dart';
import 'package:ferremateriales/features/productos/model/product_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProductCard extends StatefulWidget {
  final ProductModel product;

  const ProductCard({Key? key, required this.product}) : super(key: key);

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  bool isFavorite = false;

  @override
  Widget build(BuildContext context) {
    final product = widget.product;

    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Imagen del producto
          Expanded(
            child: AspectRatio(
              aspectRatio: 1, // cuadrada
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: (product.imagenUrl != null && product.imagenUrl!.isNotEmpty)
                    ? Image.network(
                        product.imagenUrl ?? "",
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTracer) => const Icon(Icons.broken_image, size: 100, color: Colors.grey),
                      )
                    : Image.asset(
                        'assets/images/Default_not_img.png',
                        fit: BoxFit.contain,
                      ),
              ),
            ),
          ),

          // Nombre
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Text(
              product.nombre ?? '',
              style: const TextStyle(fontWeight: FontWeight.bold),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // Descripción
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              product.descripcion ?? '',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ),

          // Precio
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Text(
              '\$${product.precio?.toStringAsFixed(2) ?? ''}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
          ),

          // 🛒 Botones de acción
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Botón de comprar
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
                  // 🛒 Enviamos el producto como Map<String, dynamic> al CartBloc
                  context.read<CartBloc>().add(
                    AddToCart({
                      "name": product.nombre ?? '',
                      "price": product.precio ?? 0.0,
                      "quantity": 1,
                      "image": product.imagenUrl ?? '',
                    }),
                  );

                  // ✅ Mostrar notificación breve
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${product.nombre} agregado al carrito 🛒'),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
              ),


                // Botón de favorito ❤️
                IconButton(
                  icon: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: isFavorite ? Colors.red : Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      isFavorite = !isFavorite;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          isFavorite
                              ? 'Agregado a favoritos ❤️'
                              : 'Eliminado de favoritos 💔',
                        ),
                        duration: const Duration(seconds: 1),
                      ),
                    );
                    // TODO: Conectar con tu API (POST /api/v1/favorites)
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
