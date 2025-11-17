import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../model/product_model.dart';
import 'producto_card.dart';

class ProductsList extends StatefulWidget {
  final List<ProductModel> products;
  final bool enableScroll; // 👈 NUEVO parámetro

  const ProductsList({
    Key? key,
    required this.products,
    this.enableScroll = false, // Por defecto sin scroll
  }) : super(key: key);

  @override
  State<ProductsList> createState() => _ProductsListState();
}

class _ProductsListState extends State<ProductsList> {
  bool _imagesCached = false; // Evita recargar varias veces

  @override
  void didUpdateWidget(covariant ProductsList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.products != widget.products) {
      _precacheProductImages();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_imagesCached) {
      _precacheProductImages();
      _imagesCached = true;
    }
  }

  Future<void> _precacheProductImages() async {
    for (final product in widget.products.take(20)) {
      if (product.imagenUrl != null && product.imagenUrl!.isNotEmpty) {
        // Verifica que el widget siga montado antes de usar context
        if (!mounted) return;

        try {
          await precacheImage(
            CachedNetworkImageProvider(product.imagenUrl!),
            context,
          );
        } catch (e) {
          debugPrint("Error precargando imagen: $e");
        }
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      // Si enableScroll es true, permitimos scroll; si no, usamos shrinkWrap
      shrinkWrap: !widget.enableScroll,
      physics: widget.enableScroll
          ? const AlwaysScrollableScrollPhysics()
          : const NeverScrollableScrollPhysics(),
      itemCount: widget.products.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.75,
      ),
      itemBuilder: (context, index) {
        final product = widget.products[index];
        return ProductCard(product: product);
      },
    );
  }
}
