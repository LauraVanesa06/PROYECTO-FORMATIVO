import 'package:ferremateriales/features/productos/views/category_products_view.dart';
import 'package:ferremateriales/features/productos/widgets/product_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../../auth/views/login_view.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../auth/bloc/auth_state.dart';
import '../bloc/product_bloc.dart';
import 'product_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<ProductBloc>().add(ProductEntrarPressed());
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;

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
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BlocProvider.value(
                value: context.read<ProductBloc>(),
                child: CategoryProductsView(
                  categoryName: category['label'] as String,
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
              // 🔸 Barra superior con buscador y botón condicional
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.brown.shade700,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.brown.shade200.withOpacity(0.5),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: TextField(
                          controller: _searchController,
                          onChanged: (value) {
                            if (value.isEmpty) {
                              context
                                  .read<ProductBloc>()
                                  .add(ProductEntrarPressed());
                            } else {
                              context
                                  .read<ProductBloc>()
                                  .add(ProductBuscarPorNombre(value));
                            }
                          },
                          decoration: InputDecoration(
                            hintText: "Buscar productos...",
                            prefixIcon:
                                const Icon(Icons.search, color: Colors.brown),
                            suffixIcon: _searchController.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.close,
                                        color: Colors.brown),
                                    onPressed: () {
                                      _searchController.clear();
                                      context
                                          .read<ProductBloc>()
                                          .add(ProductEntrarPressed());
                                      setState(() {}); // refresca el icono
                                    },
                                  )
                                : null,
                            border: InputBorder.none,
                            contentPadding:
                                const EdgeInsets.symmetric(vertical: 10),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // 👇 Solo se muestra el botón si es invitado
                    if (authState.status == AuthStatus.guest)
                      TextButton.icon(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const LoginView()),
                          );
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.brown.shade900,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        icon: const Icon(Icons.login,
                            size: 18, color: Colors.white),
                        label: const Text(
                          "Iniciar sesión",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                  ],
                ),
              ),

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

              Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: Text(
                  "Productos Destacados",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.brown.shade700,
                  ),
                ),
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
                  } else if (state is ProductLoadFailure) {
                    return const Center(
                      child: Text('Error al cargar productos'),
                    );
                  } else {
                    return const ProductsPageView();
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

// 🔸 Botón de categoría con hover
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
