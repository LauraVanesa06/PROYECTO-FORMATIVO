import 'package:ferremateriales/features/productos/services/favorites_service.dart';
import 'package:flutter/foundation.dart'; 
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:ferremateriales/l10n/app_localizations.dart';
import '../../auth/views/login_view.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../auth/bloc/auth_state.dart';
import '../bloc/product_bloc.dart';
import '../widgets/product_list.dart';
import '../widgets/product_shimmer.dart';
import 'allproducts_view.dart';
import 'category_products_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {

  @override
  void initState() {
    super.initState();

    // 🔥 ERROR corregido → antes llamabas ProductEntrarPressed (no existe)
    context.read<ProductBloc>().add(CargarDestacados());

    // Cargar favoritos locales
    FavoritesService().loadFavoritesCache();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 🔄 Recargar destacados cuando vuelves a HomeView desde AllProductsView
    context.read<ProductBloc>().add(CargarDestacados());
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
            context.read<ProductBloc>().add(CargarDestacados());
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

              // 🔹 Barra de búsqueda
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
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => BlocProvider.value(
                                value: context.read<ProductBloc>(),
                                child: const AllProductsView(),
                              ),
                            ),
                          ).then((_) {
                            // Al volver a Home, recargamos los destacados
                            context.read<ProductBloc>().add(CargarDestacados());
                          });
                        },
                        child: Container(
                          height: 48,
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.search, color: Color(0xFF2e67a3)),
                              const SizedBox(width: 8),
                              Text("Buscar productos...",
                                  style: TextStyle(color: Colors.grey.shade500)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Botón de login
                    if (authState.status == AuthStatus.guest)
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (_) => const LoginView()),
                          );
                        },
                        icon: const Icon(Icons.login, size: 18),
                        label: const Text("Iniciar sesión"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2e67a3),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24)),
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Carrusel banners
              CarouselSlider(
                options: CarouselOptions(height: 140, autoPlay: true, enlargeCenterPage: true),
                items: bannerImages.map((path) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(path, fit: BoxFit.cover, width: double.infinity),
                  );
                }).toList(),
              ),

              const SizedBox(height: 28),

              // Carrusel categorías
              CarouselSlider(
                options: CarouselOptions(
                  height: 110,
                  viewportFraction: 0.33,
                  autoPlay: true,
                  enlargeCenterPage: true,
                ),
                items: categoryItems,
              ),

              const SizedBox(height: 32),

              Padding(
                padding: const EdgeInsets.only(left: 16),
                child: Text(
                  l10n.featuredProducts,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF222222),
                  ),
                ),
              ),

              const SizedBox(height: 6),
              BlocBuilder<ProductBloc, ProductState>(
                builder: (context, state) {
                  if (state is ProductLoadInProgress) {
                    return const ProductShimmer();
                  }

                  // 🔹 MOSTRAR SOLO DESTACADOS EN HOME
                  if (state is ProductDestacadosSuccess) {
                    final destacados = state.destacados.take(8).toList();
                    return ProductsList(products: destacados);
                  }

                  // 🔹 MOSTRAR TODOS LOS PRODUCTOS (solo en búsqueda)
                  if (state is ProductLoadSuccess) {
                    return ProductsList(products: state.productos);
                  }

                  if (state is ProductLoadFailure) {
                    return Center(child: Text(l10n.errorLoadingProducts));
                  }

                  return const ProductShimmer();
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

/// BOTÓN DE CATEGORÍA
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
      onEnter: kIsWeb ? (_) => setState(() => _isHovered = true) : null,
      onExit: kIsWeb ? (_) => setState(() => _isHovered = false) : null,
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
