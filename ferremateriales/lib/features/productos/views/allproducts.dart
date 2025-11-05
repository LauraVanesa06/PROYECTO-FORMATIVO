import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/product_bloc.dart';
import '../widgets/product_list.dart';

class AllProductsView extends StatefulWidget {
  final String? searchQuery;

  const AllProductsView({Key? key, this.searchQuery}) : super(key: key);

  @override
  State<AllProductsView> createState() => _AllProductsViewState();
}

class _AllProductsViewState extends State<AllProductsView> {
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.searchQuery);
    // Cargar productos al iniciar
    context.read<ProductBloc>().add(ProductEntrarPressed());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Todos los Productos'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar productos...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              onChanged: (value) {
                // Búsqueda en tiempo real
                context.read<ProductBloc>().add(
                  ProductSearched(value),
                );
              },
            ),
          ),
        ),
      ),
      body: BlocBuilder<ProductBloc, ProductState>(
        builder: (context, state) {
          if (state is ProductLoadInProgress) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is ProductLoadSuccess) {
            return ProductsList(products: state.productos);
          }
          if (state is ProductLoadFailure) {
            return const Center(child: Text('Error al cargar productos'));
          }
          return const Center(child: Text('No hay productos disponibles'));
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
