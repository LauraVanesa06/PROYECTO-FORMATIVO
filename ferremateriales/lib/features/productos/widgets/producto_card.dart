import 'package:cached_network_image/cached_network_image.dart';
import 'package:ferremateriales/core/utils/custom_cache_manager.dart';
import 'package:ferremateriales/features/productos/model/product_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../auth/bloc/auth_state.dart';
import '../../auth/views/login_view.dart';
import '../services/favorites_service.dart';
import '../services/cart_service.dart';
import '../views/product_preview_view.dart';

class ProductCard extends StatefulWidget {
  final ProductModel product;

  const ProductCard({Key? key, required this.product}) : super(key: key);

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  bool isFavorite = false;
  final favoritesService = FavoritesService();
  final cartService = CartService();

  @override
  void initState() {
    super.initState();
    _checkIfFavorite();
  }

  Future<void> _checkIfFavorite() async {
    try {
      final result = await favoritesService.isFavorite(widget.product.id!);
      if (mounted) {
        setState(() => isFavorite = result);
      }
    } catch (e) {
      print('Error checking favorite: $e');
    }
  }

  Future<void> _toggleFavorite(BuildContext context) async {
    try {
      await favoritesService.toggleFavorite(widget.product.id!);
      setState(() => isFavorite = !isFavorite);
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              isFavorite
                  ? 'Agregado a favoritos ⭐'
                  : 'Eliminado de favoritos ❌',
            ),
            duration: const Duration(seconds: 1),
          ),
        );
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al actualizar favorito'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _addToCart(BuildContext context) async {
    try {
      await cartService.addToCart(widget.product.id!);
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text('Agregado al carrito 🛒'),
            duration: const Duration(seconds: 2),
          ),
        );
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al agregar al carrito'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _showAuthDialog(BuildContext context, {required String action}) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: isDark ? Colors.grey.shade800 : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Icon(
                Icons.lock_outline,
                color: const Color(0xFF2e67a3),
                size: 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Autenticación requerida',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Para $action necesitas iniciar sesión o puedes continuar como invitado con funcionalidades limitadas.',
                style: TextStyle(
                  fontSize: 15,
                  height: 1.4,
                  color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.orange.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.orange, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Como invitado no podrás guardar favoritos ni realizar compras',
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? Colors.orange.shade200 : Colors.orange.shade800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Continuar como invitado - no hace nada especial
              },
              child: Text(
                'Continuar como invitado',
                style: TextStyle(
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                  fontSize: 14,
                ),
              ),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
                // Navegar a la vista de login
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginView()),
                );
              },
              icon: const Icon(Icons.login, size: 18, color: Colors.white),
              label: const Text(
                'Iniciar sesión',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2e67a3),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final product = widget.product;
    final authState = context.watch<AuthBloc>().state;

    return Card(
      elevation: isDark ? 0 : 2,
      margin: const EdgeInsets.all(8),
      color: isDark ? Colors.grey.shade800 : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isDark ? Colors.grey.shade700 : Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProductPreviewView(product: product),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          // Imagen con botón de favorito superpuesto
          Expanded(
            child: Stack(
              children: [
                // Imagen del producto con fondo adaptable
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey.shade700 : Colors.white,
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(12)),
                  ),
                  child: Center(
                    child: (product.imagenUrl != null && product.imagenUrl!.isNotEmpty)
                        ? CachedNetworkImage(
                            imageUrl: product.imagenUrl!,
                            cacheManager: CustomCacheManager.instance, // <-- caché personalizada
                            fit: BoxFit.contain,
                            fadeInDuration: const Duration(milliseconds: 200), // animación rápida
                            fadeOutDuration: const Duration(milliseconds: 100),
                            placeholder: (context, url) => const SizedBox(
                              height: 60,
                              width: 60,
                              child: Center(
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            ),
                            errorWidget: (context, url, error) => Icon(
                              Icons.broken_image,
                              size: 80,
                              color: isDark ? Colors.grey.shade500 : Colors.grey,
                            ),
                          )
                        : Image.asset(
                            'assets/images/Default_not_img.png',
                            fit: BoxFit.contain,
                          ),
                  ),
                ),

                // Botón de favorito en la esquina superior izquierda
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey.shade800 : Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.orange.shade200,
                        width: 2,
                      ),
                      boxShadow: isDark
                          ? []
                          : [
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
                          _showAuthDialog(context, action: 'agregar favoritos');
                          return;
                        }
                        _toggleFavorite(context);
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
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: isDark
                        ? Colors.blue.shade300
                        : const Color(0xFF2e67a3),
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
                    color: isDark
                        ? Colors.grey.shade400
                        : Colors.grey.shade600,
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
                      'COP ${double.tryParse(product.precio.toString())?.toStringAsFixed(2) ?? '0.00'}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: isDark
                            ? Colors.blue.shade300
                            : const Color(0xFF2e67a3),
                      ),
                    ),

                    // Botón de carrito
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF2e67a3),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color:
                                const Color(0xFF2e67a3).withOpacity(0.3),
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
                            _showAuthDialog(context, action: 'agregar productos al carrito');
                            return;
                          }
                          _addToCart(context);
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
      ),
    );
  }
}
