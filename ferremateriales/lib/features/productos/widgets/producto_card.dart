import 'package:flutter/material.dart';
import '../model/product_model.dart';

class ProductsList extends StatelessWidget {
  final List<ProductModel> products;

  const ProductsList({super.key, required this.products});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, 
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 0.7,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final p = products[index];

        return Card(
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: (p.imagenUrl != null && p.imagenUrl!.isNotEmpty)
                        ? Image.network(
                            p.imagenUrl!,
                            fit: BoxFit.contain, 
                            errorBuilder: (context, error, stackTrace) {
                              return Image.asset(
                                'assets/images/Default_not_img.png',
                                fit: BoxFit.contain, 
                              );
                            },
                          )
                        : Image.asset(
                            'assets/images/Default_not_img.png',
                            fit: BoxFit.contain, 
                          ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  p.nombre ?? 'Sin nombre',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  p.descripcion ?? 'Sin descripción',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
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
        );
      },
    );
  }
}


