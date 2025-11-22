import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/product_bloc.dart';
import '../widgets/product_list.dart';

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
      backgroundColor: isDark ? Colors.grey.shade900 : const Color(0xfff5f5f5),
      appBar: AppBar(
        backgroundColor: isDark ? Colors.grey.shade800 : Colors.white,
        foregroundColor: isDark ? Colors.white : const Color(0xFF222222),
        elevation: 0,
        title: Text(
          'Todos los Productos',
          style: TextStyle(
            color: isDark ? Colors.white : const Color(0xFF222222),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(
          color: isDark ? Colors.white : const Color(0xFF222222),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: TextField(
              controller: _searchController,
              style: TextStyle(
                color: isDark ? Colors.white : const Color(0xFF222222),
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
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFF2e67a3),
                    width: 2,
                  ),
                ),
                filled: true,
                fillColor: isDark ? Colors.grey.shade800 : Colors.white,
              ),
            ),
          ),
        ),
      ),

      /// 🔥 CONTENIDO
      body: BlocBuilder<ProductBloc, ProductState>(
        buildWhen: (previous, current) {
          // Solo reconstruye si es ProductLoadSuccess o ProductLoadInProgress o ProductLoadFailure
          // Ignora ProductDestacadosSuccess (de Home)
          debugPrint('BlocBuilder buildWhen - current state: ${current.runtimeType}');
          return current is ProductLoadSuccess || 
                 current is ProductLoadInProgress || 
                 current is ProductLoadFailure;
        },
        builder: (context, state) {
          debugPrint('BlocBuilder builder - state: ${state.runtimeType}');
          
          if (state is ProductLoadInProgress) {
            debugPrint('AllProductsView - showing loading');
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ProductLoadSuccess) {
            debugPrint('AllProductsView - ProductLoadSuccess with ${state.productos.length} products');
            if (state.productos.isEmpty) {
              return Center(
                child: Text(
                  'No se encontraron productos.',
                  style: TextStyle(
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                    fontSize: 16,
                  ),
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                /// 🔄 VOLVER A CARGAR TODO DESDE API
                context.read<ProductBloc>().add(CargarTodosLosProductos());
              },
              child: ProductsList(
                products: state.productos,
                enableScroll: true, // 👈 HABILITAR SCROLL
              ),
            );
          }

          if (state is ProductLoadFailure) {
            debugPrint('AllProductsView - error: ${state.message}');
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: isDark ? Colors.red.shade300 : Colors.red,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    state.message ?? 'Error al cargar productos.',
                    style: TextStyle(
                      color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            );
          }

          debugPrint('AllProductsView - other state: ${state.runtimeType}');
          return Center(
            child: Text(
              'No hay productos disponibles.',
              style: TextStyle(
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                fontSize: 16,
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
