import 'package:ferremateriales/features/productos/bloc/cart_bloc.dart';
import 'package:ferremateriales/features/productos/bloc/cart_event.dart';
import 'package:ferremateriales/features/productos/bloc/product_bloc.dart';
import 'package:ferremateriales/features/productos/model/product_model.dart';
import 'package:ferremateriales/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../auth/bloc/auth_state.dart';

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
    final l10n = AppLocalizations.of(context)!;
    final product = widget.product;
    final authState = context.watch<AuthBloc>().state;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.all(8),
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Imagen con botón de favorito superpuesto
          Expanded(
            child: Stack(
              children: [
                // Imagen del producto
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                    child: (product.imagenUrl != null && product.imagenUrl!.isNotEmpty)
                        ? Image.network(
                            product.imagenUrl!,
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) =>
                                const Icon(Icons.broken_image, size: 80, color: Colors.grey),
                          )
                        : Image.asset('assets/images/Default_not_img.png', fit: BoxFit.contain),
                  ),
                ),
                
                // Botón de favorito en la esquina superior izquierda
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.orange.shade200, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: Icon(
                        isFavorite ? Icons.star : Icons.star_border,
                        color: Colors.orange,
                        size: 20,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 36,
                        minHeight: 36,
                      ),
                      onPressed: () {
                        if (authState.status == AuthStatus.guest) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                            content: Text('Inicia sesión para agregar favoritos ⭐'),
                            backgroundColor: Colors.orange,
                          ));
                          return;
                        }

                        context
                            .read<ProductBloc>()
                            .add(ToggleFavorite(widget.product.id!));
                        setState(() {
                          isFavorite = !isFavorite;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              isFavorite ? l10n.addedToFavorites : l10n.removedFromFavorites,
                            ),
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Contenido de la tarjeta
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Nombre del producto
                Text(
                  product.nombre ?? '',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color(0xFF2e67a3),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),

                // Descripción
                Text(
                  product.descripcion ?? '',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 12),

                // Fila con precio y botón de carrito
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Precio
                    Text(
                      'COP ${product.precio?.toStringAsFixed(2) ?? '0.00'}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Color(0xFF2e67a3),
                      ),
                    ),

                    // Botón de carrito
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF2e67a3),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF2e67a3).withOpacity(0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.shopping_cart,
                          color: Colors.white,
                          size: 20,
                        ),
                        padding: const EdgeInsets.all(8),
                        constraints: const BoxConstraints(
                          minWidth: 40,
                          minHeight: 40,
                        ),
                        onPressed: () {
                          if (authState.status == AuthStatus.guest) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                              content: Text('Inicia sesión para añadir productos al carrito 🛒'),
                              backgroundColor: Colors.orange,
                            ));
                            return;
                          }
                          
                          context.read<CartBloc>().add(
                            AddToCart({
                              "name": product.nombre ?? '',
                              "price": product.precio ?? 0.0,
                              "quantity": 1,
                              "image": product.imagenUrl ?? '',
                            }),
                          );

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(l10n.addedToCart(product.nombre ?? '')),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
