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

    // 🚀 Al abrir la vista, solicita todos los productos desde el backend.
    // Usamos ProductBuscarPorNombre('') porque en el bloc esa acción carga /all_products
    context.read<ProductBloc>().add(const ProductBuscarPorNombre(''));
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
                // Filtrar en tiempo real usando el bloc (ya tiene la lista completa)
                context.read<ProductBloc>().add(ProductBuscarPorNombre(value));
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
      body: BlocBuilder<ProductBloc, ProductState>(
        builder: (context, state) {
          if (state is ProductLoadInProgress) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ProductLoadSuccess) {
            if (state.productos.isEmpty) {
              return const Center(child: Text('No se encontraron productos.'));
            }
            return RefreshIndicator(
              onRefresh: () async {
                // Forzar recarga completa (vuelve a llamar a la API)
                context.read<ProductBloc>().add(const ProductBuscarPorNombre(''));
              },
              child: ProductsList(products: state.productos),
            );
          } else if (state is ProductLoadFailure) {
            return Center(
              child: Text(state.message ?? 'Error al cargar productos.'),
            );
          } else {
            return const Center(child: Text('No hay productos disponibles.'));
          }
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
