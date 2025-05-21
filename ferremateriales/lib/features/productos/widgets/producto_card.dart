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
          child: ListTile(
            contentPadding: const EdgeInsets.all(12),
            leading: p.imagenUrl != null
                ? Image.network(
                    p.imagenUrl!,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                  )
                : const Icon(Icons.image_not_supported),
            title: Text(
              p.nombre ?? 'Sin nombre',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(p.descripcion ?? 'Sin descripción'),
            trailing: Text(
              '\$${p.precio?.toStringAsFixed(2) ?? '0.00'}',
              style: const TextStyle(color: Colors.red),
            ),
          ),
        );
      },
    );
  }
}
