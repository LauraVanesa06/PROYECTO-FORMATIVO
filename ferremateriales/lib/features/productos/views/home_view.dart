import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:ferremateriales/l10n/app_localizations.dart';

import '../../auth/views/login_view.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../auth/bloc/auth_state.dart';
import '../bloc/product_bloc.dart';
import '../widgets/product_list.dart';
import 'category_products_view.dart';

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
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authState = context.watch<AuthBloc>().state;

    final bannerImages = [
      'assets/images/oferta.jpg',
      'assets/images/oferta2.png',
      'assets/images/oferta3.jpg',
    ];

    // 🔧 Lista de categorías con IDs únicos
    final categories = [
      {'icon': Icons.construction, 'label': 'Herramientas', 'display': l10n.tools, 'id': 1},
      {'icon': Icons.handyman, 'label': 'Tornillería y Fijaciones', 'display': l10n.hardware, 'id': 2},
      {'icon': Icons.plumbing, 'label': 'Plomería', 'display': l10n.plumbing, 'id': 3},
      {'icon': Icons.flash_on, 'label': 'Electricidad', 'display': l10n.electricity, 'id': 4},
      {'icon': Icons.business, 'label': 'Construcción y Materiales', 'display': l10n.construction, 'id': 5},
      {'icon': Icons.format_paint, 'label': 'Pintura y Acabados', 'display': l10n.paint, 'id': 6},
      {'icon': Icons.home_repair_service, 'label': 'Ferretería para el hogar', 'display': l10n.homeHardware, 'id': 7},
      {'icon': Icons.cleaning_services, 'label': 'Limpieza y Mantenimiento', 'display': l10n.cleaning, 'id': 8},
      {'icon': Icons.sticky_note_2, 'label': 'Adhesivos y Selladores', 'display': l10n.adhesives, 'id': 9},
      {'icon': Icons.grass, 'label': 'Jardinería', 'display': l10n.gardening, 'id': 10},
    ];

    // 🔁 Construcción dinámica de botones de categoría
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
      backgroundColor: isDark ? Colors.grey.shade900 : Colors.grey.shade50,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 80),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🔸 Barra superior con buscador moderna
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey.shade800 : Colors.white,
                  boxShadow: isDark
                      ? []
                      : [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: Colors.grey.shade300, width: 1),
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
                            hintStyle: TextStyle(color: Colors.grey.shade500),
                            prefixIcon: const Icon(Icons.search, color: Color(0xFF2e67a3)),
                            suffixIcon: _searchController.text.isNotEmpty
                                ? IconButton(
                                    icon: Icon(Icons.close, color: Colors.grey.shade600),
                                    onPressed: () {
                                      _searchController.clear();
                                      context
                                          .read<ProductBloc>()
                                          .add(ProductEntrarPressed());
                                      setState(() {});
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
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const LoginView()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: const Color(0xFF2e67a3),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          elevation: 0,
                        ),
                        icon: const Icon(Icons.login, size: 18),
                        label: const Text(
                          "Iniciar sesión",
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // 🖼️ Carrusel de imágenes
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

              // 🧩 Carrusel de categorías
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

              const SizedBox(height: 32),

              Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: Text(
                  l10n.featuredProducts,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF222222),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.only(left: 16.0, right: 16.0),
                child: Container(
                  height: 3,
                  width: 50,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2e67a3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // 🛒 Productos destacados
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
                    return Center(
                      child: Text(l10n.errorLoadingProducts),
                    );
                  } else {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
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

// 🎨 Widget personalizado con efecto hover
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
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
              backgroundColor: _isHovered 
                  ? const Color(0xFF2e67a3).withOpacity(0.2)
                  : (isDark ? Colors.grey.shade800 : Colors.grey.shade200),
              child: Icon(
                widget.icon,
                color: _isHovered
                    ? const Color(0xFF2e67a3)
                    : (isDark ? Colors.blue.shade300 : const Color(0xFF2e67a3)),
                size: 22,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              widget.label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: _isHovered 
                    ? const Color(0xFF2e67a3)
                    : (isDark ? Colors.grey.shade300 : Colors.black87),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
