import 'package:ferremateriales/features/productos/services/favorites_service.dart';
import 'package:ferremateriales/features/productos/services/cart_service.dart';
import 'package:flutter/foundation.dart'; 
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:ferremateriales/l10n/app_localizations.dart';
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

class _HomeViewState extends State<HomeView> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true; // Mantener el estado vivo
  
  bool _isSearching = false;
  bool _dataLoaded = false; // Flag para evitar recargas múltiples
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    print("=== HOME VIEW INIT STATE ===");
    _searchController = TextEditingController();

    // Solo cargar una vez cuando se monta el widget
    if (!_dataLoaded) {
      _dataLoaded = true;
      _initializeData();
    }
  }

  Future<void> _initializeData() async {
    final productBloc = context.read<ProductBloc>();
    
    // 1. Cargar cachés de favoritos y carrito PRIMERO
    await FavoritesService().loadFavoritesCache();
    await CartService().loadCartCache();
    
    // 2. DESPUÉS cargar productos destacados (así ya tenemos los favoritos en cache)
    print("Cargando destacados después de cache de favoritos...");
    productBloc.add(CargarDestacados());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Necesario para AutomaticKeepAliveClientMixin
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
                      child: TextField(
                        controller: _searchController,
                        style: TextStyle(
                          color: isDark ? Colors.white : const Color(0xFF222222),
                        ),
                        onTap: () {
                          if (!_isSearching) {
                            setState(() {
                              _isSearching = true;
                            });
                            context.read<ProductBloc>().add(CargarTodosLosProductos());
                          }
                        },
                        onChanged: (value) {
                          if (_isSearching) {
                            final bloc = context.read<ProductBloc>();
                            if (value.isEmpty) {
                              bloc.add(CargarTodosLosProductos());
                            } else {
                              bloc.add(ProductBuscarPorNombre(value));
                            }
                          }
                        },
                        decoration: InputDecoration(
                          hintText: 'Buscar productos...',
                          hintStyle: TextStyle(
                            color: isDark ? Colors.grey.shade400 : Colors.grey.shade500,
                          ),
                          prefixIcon: Icon(
                            Icons.search,
                            color: isDark ? Colors.grey.shade400 : const Color(0xFF2e67a3),
                          ),
                          suffixIcon: _isSearching
                              ? IconButton(
                                  icon: Icon(
                                    Icons.close,
                                    color: isDark ? Colors.grey.shade400 : const Color(0xFF2e67a3),
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _isSearching = false;
                                      _searchController.clear();
                                    });
                                    context.read<ProductBloc>().add(CargarDestacados());
                                  },
                                )
                              : null,
                          filled: true,
                          fillColor: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide(
                              color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide(
                              color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: const BorderSide(color: Color(0xFF2e67a3), width: 2),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Carrusel banners (solo cuando no está buscando)
              if (!_isSearching) ...[
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
              ],

              // Título dinámico

              // Título dinámico

              Padding(
                padding: const EdgeInsets.only(left: 16),
                child: Text(
                  _isSearching ? 'Resultados de búsqueda' : l10n.featuredProducts,
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

                  // 🔹 Modo búsqueda: mostrar todos los productos o filtrados
                  if (_isSearching && state is ProductLoadSuccess) {
                    if (state.productos.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Text(
                            'No se encontraron productos',
                            style: TextStyle(
                              color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      );
                    }
                    return ProductsList(products: state.productos);
                  }

                  // 🔹 Modo normal: mostrar solo destacados
                  if (!_isSearching && state is ProductDestacadosSuccess) {
                    final destacados = state.destacados.take(8).toList();
                    return Column(
                      children: [
                        ProductsList(products: destacados),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: OutlinedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => BlocProvider.value(
                                      value: context.read<ProductBloc>(),
                                      child: const AllProductsView(),
                                    ),
                                  ),
                                );
                                // ❌ REMOVIDO: No recargar destacados al volver
                                // Ya están en memoria y no necesitan recargarse
                              },
                              style: OutlinedButton.styleFrom(
                                foregroundColor: isDark ? Colors.white : const Color(0xFF2e67a3),
                                side: BorderSide(
                                  color: isDark ? Colors.grey.shade600 : const Color(0xFF2e67a3),
                                  width: 2,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Ver todos los productos',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: isDark ? Colors.white : const Color(0xFF2e67a3),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Icon(
                                    Icons.arrow_forward,
                                    color: isDark ? Colors.white : const Color(0xFF2e67a3),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  }

                  if (state is ProductLoadFailure) {
                    return Center(child: Text(l10n.errorLoadingProducts));
                  }

                  return const ProductShimmer();
                },
              ),
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
