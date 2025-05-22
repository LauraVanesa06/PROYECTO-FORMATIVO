import 'package:flutter/material.dart';

import '../model/product_model.dart';

class ProductsList extends StatelessWidget {
  final List<ProductModel> products;

  const ProductsList({super.key, required this.products});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: products.length,
      itemBuilder: (context, index) {
        final p = products[index];

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          
          elevation: 3,
          shape: RoundedRectangleBorder(borderRadius: BorderRadiusGeometry.circular(12)),
          child: Container(
            padding: const EdgeInsets.all(12),
            constraints: const BoxConstraints(minHeight: 150),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Imagen a la izquierda
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: SizedBox(
                    width: 100,
                    height: 150,
                    child:
                        (p.imagenUrl != null && p.imagenUrl!.isNotEmpty)
                            ? Image.network(
                              p.imagenUrl!,
                              fit: BoxFit.none,
                              alignment: Alignment.center,
                              errorBuilder: (context, error, stackTrace) {
                                return Image.asset('assets/images/Default_not_img.png',);
                              },
                            )
                            : Image.asset(
                              'assets/images/Default_not_img.png',
                              fit: BoxFit.cover,
                            ),
                  ),
                ),
                const SizedBox(width: 16),

                // Texto a la derecha
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        p.nombre ?? 'Sin nombre',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        p.descripcion ?? 'Sin descripción',
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '\$${p.precio?.toStringAsFixed(2) ?? '0.00'}',
                        style: const TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
