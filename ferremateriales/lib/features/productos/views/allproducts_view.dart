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
    return Scaffold(
      backgroundColor: const Color(0xfff5f5f5),
      appBar: AppBar(
        title: const Text('Todos los Productos'),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: TextField(
              controller: _searchController,
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
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.white,
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
              return const Center(child: Text('No se encontraron productos.'));
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
              child: Text(state.message ?? 'Error al cargar productos.'),
            );
          }

          debugPrint('AllProductsView - other state: ${state.runtimeType}');
          return const Center(child: Text('No hay productos disponibles.'));
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
