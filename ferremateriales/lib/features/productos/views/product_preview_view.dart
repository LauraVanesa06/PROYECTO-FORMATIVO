import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../model/product_model.dart';
import '../bloc/cart_bloc.dart';
import '../bloc/cart_event.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../auth/bloc/auth_state.dart';
import '../../auth/views/login_view.dart';

class ProductPreviewView extends StatefulWidget {
  final ProductModel product;

  const ProductPreviewView({
    super.key,
    required this.product,
  });

  @override
  State<ProductPreviewView> createState() => _ProductPreviewViewState();
}

class _ProductPreviewViewState extends State<ProductPreviewView> {
  int quantity = 1;

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
              const Icon(
                Icons.lock_outline,
                color: Color(0xFF2e67a3),
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
                    const Icon(Icons.info_outline, color: Colors.orange, size: 20),
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
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: isDark ? Colors.grey.shade900 : Colors.white,
      appBar: AppBar(
        backgroundColor: isDark ? Colors.grey.shade800 : const Color(0xFF2e67a3),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Detalle del Producto',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, authState) {
              return IconButton(
                icon: Icon(
                  widget.product.isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: widget.product.isFavorite ? Colors.red : Colors.white,
                ),
                onPressed: () {
                  if (authState.status == AuthStatus.guest) {
                    _showAuthDialog(context, action: 'agregar favoritos');
                    return;
                  }
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        widget.product.isFavorite
                            ? 'Eliminado de favoritos'
                            : 'Agregado a favoritos',
                      ),
                    ),
                  );
                },
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.share, color: Colors.white),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Compartir producto')),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen del producto
            _buildImageSection(size),
            
            // Información del producto
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nombre
                  Text(
                    widget.product.nombre ?? 'Sin nombre',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  // Precio
                  Text(
                    '\$${widget.product.precio?.toStringAsFixed(2) ?? '0.00'}',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2e67a3),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Disponibilidad
                  _buildInfoChip(
                    isDark,
                    Icons.inventory_2,
                    (widget.product.stock ?? 0) > 0
                        ? 'Disponible (${widget.product.stock})'
                        : 'Agotado',
                    (widget.product.stock ?? 0) > 0 ? Colors.green : Colors.red,
                  ),
                  const SizedBox(height: 24),

                  // Descripción
                  Text(
                    'Descripción',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.product.descripcion ?? 'Sin descripción disponible.',
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.5,
                      color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Selector de cantidad
                  Text(
                    'Cantidad',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildQuantitySelector(isDark),
                  
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(context, isDark),
    );
  }

  Widget _buildImageSection(Size size) {
    return Container(
      height: size.height * 0.4,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
      ),
      child: widget.product.imagenUrl != null && widget.product.imagenUrl!.isNotEmpty
          ? Image.network(
              widget.product.imagenUrl!,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return const Center(
                  child: Icon(
                    Icons.image_not_supported,
                    size: 80,
                    color: Colors.grey,
                  ),
                );
              },
            )
          : const Center(
              child: Icon(
                Icons.image_not_supported,
                size: 80,
                color: Colors.grey,
              ),
            ),
    );
  }

  Widget _buildInfoChip(bool isDark, IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuantitySelector(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.remove),
            onPressed: quantity > 1
                ? () => setState(() => quantity--)
                : null,
            color: const Color(0xFF2e67a3),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              '$quantity',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: quantity < (widget.product.stock ?? 0)
                ? () => setState(() => quantity++)
                : null,
            color: const Color(0xFF2e67a3),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context, bool isDark) {
    final totalPrice = (widget.product.precio ?? 0.0) * quantity;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade800 : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Total
            Expanded(
              flex: 2,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Total',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                  Text(
                    '\$${totalPrice.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2e67a3),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            
            // Botón agregar al carrito
            Expanded(
              flex: 3,
              child: ElevatedButton.icon(
                onPressed: (widget.product.stock ?? 0) > 0
                    ? () {
                        // Crear el mapa para el carrito
                        final productMap = {
                          'id': widget.product.id,
                          'name': widget.product.nombre ?? 'Sin nombre',
                          'price': widget.product.precio ?? 0.0,
                          'imageUrl': widget.product.imagenUrl ?? '',
                          'quantity': quantity,
                          'stock': widget.product.stock ?? 0,
                        };
                        
                        context.read<CartBloc>().add(AddToCart(productMap));
                        
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('$quantity x ${widget.product.nombre} agregado al carrito'),
                            duration: const Duration(seconds: 2),
                            backgroundColor: Colors.green,
                            action: SnackBarAction(
                              label: 'Ver carrito',
                              textColor: Colors.white,
                              onPressed: () {
                                Navigator.pop(context);
                              },
                            ),
                          ),
                        );
                      }
                    : null,
                icon: const Icon(Icons.shopping_cart, color: Colors.white),
                label: const Text(
                  'Agregar al carrito',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2e67a3),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                  disabledBackgroundColor: Colors.grey,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
