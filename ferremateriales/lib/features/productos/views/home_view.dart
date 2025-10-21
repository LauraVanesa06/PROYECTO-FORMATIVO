import 'package:ferremateriales/features/productos/views/category_products_view.dart';
import 'package:ferremateriales/features/productos/views/product_view.dart';
import 'package:ferremateriales/features/productos/widgets/product_list.dart';
import 'package:ferremateriales/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../bloc/product_bloc.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  @override
  void initState() {
    super.initState();
    context.read<ProductBloc>().add(ProductEntrarPressed());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final bannerImages = [
      'assets/images/oferta.jpg',
      'assets/images/oferta2.png',
      'assets/images/oferta3.jpg',
    ];

    final categories = [
      {'icon': Icons.construction, 'label': 'Herramientas', 'display': l10n.tools, 'id': 1},
      {'icon': Icons.handyman, 'label': 'Tornilleria y Fijaciones', 'display': l10n.hardware, 'id': 2},
      {'icon': Icons.plumbing, 'label': 'Plomeria', 'display': l10n.plumbing, 'id': 3},
      {'icon': Icons.flash_on, 'label': 'Electricidad', 'display': l10n.electricity, 'id': 4},
      {'icon': Icons.business, 'label': 'Construccion y Materiales', 'display': l10n.construction, 'id': 5},
      {'icon': Icons.format_paint, 'label': 'Pintura y Acabados', 'display': l10n.paint, 'id': 6},
      {'icon': Icons.home_repair_service, 'label': 'Ferreteria para el hogar', 'display': l10n.homeHardware, 'id': 7},
      {'icon': Icons.cleaning_services, 'label': 'Limpieza y Mantenimiento', 'display': l10n.cleaning, 'id': 8},
      {'icon': Icons.sticky_note_2, 'label': 'Adhesivos y Selladores', 'display': l10n.adhesives, 'id': 9},
      {'icon': Icons.grass, 'label': 'Jardineria', 'display': l10n.gardening, 'id': 10},
    ];

    final categoryItems = categories.map((category) {
      return _HoverCategoryButton(
        icon: category['icon'] as IconData,
        label: category['display'] as String,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BlocProvider.value(
                value: context.read<ProductBloc>(),
                child: CategoryProductsView(
                  categoryName: category['label'] as String,
                  categoryId: category['id'] as int,
                  displayName: category['display'] as String,
                ),
              ),
            ),
          ).then((_) {
            context.read<ProductBloc>().add(ProductEntrarPressed());
          });
        },
      );
    }).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 80),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),

              // Carrusel de imágenes
              CarouselSlider(
                options: CarouselOptions(
                  height: 140,
                  autoPlay: true,
                  enlargeCenterPage: true,
                ),
                items:
                    bannerImages.map((path) {
                      return Builder(
                        builder: (BuildContext context) {
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.asset(
                              path,
                              fit: BoxFit.cover,
                              width: double.infinity,
                            ),
                          );
                        },
                      );
                    }).toList(),
              ),

              const SizedBox(height: 28),

              // Carrusel de categorías
              CarouselSlider(
                options: CarouselOptions(
                  height: 110,
                  viewportFraction: 0.33,
                  enableInfiniteScroll: true,
                  autoPlay: true,
                  autoPlayInterval: const Duration(seconds: 3),
                  enlargeCenterPage: true,
                ),
                items: categoryItems,
              ),

              const SizedBox(height: 24),

              Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: Text(l10n.featuredProducts,
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.brown.shade700,
                    )),
              ),

              // Mostrar productos usando BlocBuilder
              BlocBuilder<ProductBloc, ProductState>(
                builder: (context, state) {
                  if (state is ProductLoadInProgress) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (state is ProductLoadSuccess) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ProductsList(products: state.productos),
                      
                    );
                    // return SizedBox(
                    //   height: 1000,
                    //   child: Padding(
                    //     padding: const EdgeInsets.all(8.0),
                    //     child: ProductsList(products: state.productos),
                    //   ),
                    // );
                  } else if (state is ProductLoadFailure) {
                    return Center(
                      child: Text(l10n.errorLoadingProducts),
                    );
                  } else {
                    return const ProductsPageView(); // Estado inicial
                  }
                },
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

// Widget personalizado con efecto hover
class _HoverCategoryButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _HoverCategoryButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  State<_HoverCategoryButton> createState() => _HoverCategoryButtonState();
}

class _HoverCategoryButtonState extends State<_HoverCategoryButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor:
                  _isHovered ? Colors.brown.shade100 : Colors.grey.shade200,
              child: Icon(
                widget.icon,
                color:
                    _isHovered
                        ? Colors.brown.shade800
                        : const Color.fromARGB(255, 130, 204, 238),
                size: 22,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              widget.label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: _isHovered ? Colors.brown.shade800 : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
