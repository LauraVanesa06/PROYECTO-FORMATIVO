import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../bloc/product_bloc.dart';
import '../widgets/producto_card.dart'; // ProductsList

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    // Lanzar el evento para cargar productos
    context.read<ProductBloc>().add(ProductEntrarPressed());

    final bannerImages = [
      'assets/images/oferta.jpg',
      'assets/images/oferta2.png',
      'assets/images/oferta3.jpg',
    ];

    final categories = [
      {'icon': Icons.construction, 'label': 'Herramientas'},
      {'icon': Icons.handyman, 'label': 'Tornillería y Fijaciones'},
      {'icon': Icons.plumbing, 'label': 'Plomería'},
      {'icon': Icons.flash_on, 'label': 'Electricidad'},
      {'icon': Icons.business, 'label': 'Construcción y Materiales'},
      {'icon': Icons.format_paint, 'label': 'Pintura y Acabados'},
      {'icon': Icons.home_repair_service, 'label': 'Ferretería para el hogar'},
      {'icon': Icons.cleaning_services, 'label': 'Limpieza y Mantenimiento'},
      {'icon': Icons.sticky_note_2, 'label': 'Adhesivos y Selladores'},
      {'icon': Icons.grass, 'label': 'Jardinería'},
    ];

    final categoryItems = categories.map((category) {
      return _HoverCategoryButton(
        icon: category['icon'] as IconData,
        label: category['label'] as String,
        onTap: () {
          print('Clic en: ${category['label']}');
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
                items: bannerImages.map((path) {
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

              // Sección de productos
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Productos destacados',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),

              const SizedBox(height: 12),

              BlocBuilder<ProductBloc, ProductState>(
                builder: (context, state) {
                  if (state is ProductLoadInProgress) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is ProductLoadSuccess) {
                    return ProductsList(products: state.productos);
                  } else if (state is ProductLoadFailure) {
                    return const Center(child: Text('Error al cargar productos'));
                  } else {
                    return const SizedBox.shrink();
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
                color: _isHovered
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
