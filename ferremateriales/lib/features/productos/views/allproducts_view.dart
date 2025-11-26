import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/product_bloc.dart';
import '../widgets/producto_card.dart';

class AllProductsView extends StatefulWidget {
  const AllProductsView({Key? key}) : super(key: key);

  @override
  State<AllProductsView> createState() => _AllProductsViewState();
}

class _AllProductsViewState extends State<AllProductsView> {
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();

    /// ✅ CARGAR TODOS LOS PRODUCTOS AL ENTRAR
    context.read<ProductBloc>().add(CargarTodosLosProductos());
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? Colors.grey.shade900 : Colors.grey.shade50,
      body: CustomScrollView(
        slivers: [
          // App Bar moderno con búsqueda integrada
          SliverAppBar(
            expandedHeight: 120,
            floating: false,
            pinned: true,
            backgroundColor: isDark ? Colors.grey.shade800 : Colors.white,
            foregroundColor: isDark ? Colors.white : const Color(0xFF222222),
            elevation: 0,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: isDark ? Colors.white : const Color(0xFF222222),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'Todos los Productos',
                style: TextStyle(
                  color: isDark ? Colors.white : const Color(0xFF222222),
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              centerTitle: true,
            ),
          ),
          
          // Campo de búsqueda sticky
          SliverPersistentHeader(
            pinned: true,
            delegate: _SearchBarDelegate(
              isDark: isDark,
              child: Container(
                color: isDark ? Colors.grey.shade900 : Colors.grey.shade50,
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                child: Container(
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey.shade800 : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    style: TextStyle(
                      color: isDark ? Colors.white : const Color(0xFF222222),
                      fontSize: 15,
                    ),
                    onChanged: (value) {
                      debugPrint('AllProductsView - onChanged search: "$value"');

                      final bloc = context.read<ProductBloc>();
                      if (bloc.state is! ProductLoadSuccess) {
                        debugPrint('AllProductsView - cache vacío o carga en progreso, dispatch CargarTodosLosProductos');
                        bloc.add(CargarTodosLosProductos());
                        return;
                      }

                      /// 🔎 Buscar en tiempo real sobre el CACHE
                      bloc.add(ProductBuscarPorNombre(value));
                    },
                    decoration: InputDecoration(
                      hintText: 'Buscar productos...',
                      hintStyle: TextStyle(
                        color: isDark ? Colors.grey.shade400 : Colors.grey.shade500,
                        fontSize: 15,
                      ),
                      prefixIcon: Icon(
                        Icons.search_rounded,
                        color: isDark ? Colors.grey.shade400 : const Color(0xFF2e67a3),
                        size: 22,
                      ),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: Icon(
                                Icons.clear_rounded,
                                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                                size: 20,
                              ),
                              onPressed: () {
                                _searchController.clear();
                                context.read<ProductBloc>().add(CargarTodosLosProductos());
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                  ),
                ),
              ),
            ),
          ),

          /// 🔥 CONTENIDO
          BlocBuilder<ProductBloc, ProductState>(
            buildWhen: (previous, current) {
              debugPrint('BlocBuilder buildWhen - current state: ${current.runtimeType}');
              return current is ProductLoadSuccess || 
                     current is ProductLoadInProgress || 
                     current is ProductLoadFailure;
            },
            builder: (context, state) {
              debugPrint('BlocBuilder builder - state: ${state.runtimeType}');
              
              if (state is ProductLoadInProgress) {
                debugPrint('AllProductsView - showing loading');
                return SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          color: isDark ? Colors.white : const Color(0xFF2e67a3),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Cargando productos...',
                          style: TextStyle(
                            color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              if (state is ProductLoadSuccess) {
                debugPrint('AllProductsView - ProductLoadSuccess with ${state.productos.length} products');
                if (state.productos.isEmpty) {
                  return SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off_rounded,
                            size: 64,
                            color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No se encontraron productos',
                            style: TextStyle(
                              color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Intenta con otra búsqueda',
                            style: TextStyle(
                              color: isDark ? Colors.grey.shade500 : Colors.grey.shade500,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                      childAspectRatio: 0.75,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        return ProductCard(product: state.productos[index]);
                      },
                      childCount: state.productos.length,
                    ),
                  ),
                );
              }

              if (state is ProductLoadFailure) {
                debugPrint('AllProductsView - error: ${state.message}');
                return SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline_rounded,
                          size: 64,
                          color: isDark ? Colors.red.shade300 : Colors.red.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Error al cargar productos',
                          style: TextStyle(
                            color: isDark ? Colors.grey.shade300 : Colors.grey.shade800,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          state.message ?? 'Intenta de nuevo más tarde',
                          style: TextStyle(
                            color: isDark ? Colors.grey.shade500 : Colors.grey.shade600,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: () {
                            context.read<ProductBloc>().add(CargarTodosLosProductos());
                          },
                          icon: const Icon(Icons.refresh_rounded),
                          label: const Text('Reintentar'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2e67a3),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              debugPrint('AllProductsView - other state: ${state.runtimeType}');
              return SliverFillRemaining(
                child: Center(
                  child: Text(
                    'No hay productos disponibles',
                    style: TextStyle(
                      color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                      fontSize: 16,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

/// 📌 Delegate para SliverPersistentHeader con altura fija
class _SearchBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  final bool isDark;

  _SearchBarDelegate({required this.child, required this.isDark});

  @override
  double get minExtent => 68;

  @override
  double get maxExtent => 68;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  bool shouldRebuild(_SearchBarDelegate oldDelegate) {
    return oldDelegate.isDark != isDark;
  }
}
