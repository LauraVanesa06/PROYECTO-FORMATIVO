import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../views/failure_view.dart';
import '../../../views/loading_view.dart';
import '../bloc/product_bloc.dart';
import '../widgets/producto_card.dart'; 

class ProductsPageView extends StatefulWidget {
  const ProductsPageView({super.key});

  @override
  State<ProductsPageView> createState() => _ProductsPageViewState();
}

class _ProductsPageViewState extends State<ProductsPageView> {
  String selectedCategory = 'Todos';

  // Ejemplo de categorías:
  final List<String> categories = [
    'Todos',
    'Herramientas',
    'Tornillos',
    'Maderas',
    'Electricidad',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFE2714D),
        title: const Text(
          'Productos',
          style: TextStyle(color: Colors.white),
        ),
        automaticallyImplyLeading: false,
        actions: [
          ElevatedButton(
            onPressed: () {
              context.read<ProductBloc>().add(ProductRegresarPressed());
            },
            child: const Text('Regresar al Inicio'),
          ),
        ],
      ),
      body: BlocBuilder<ProductBloc, ProductState>(
        builder: (context, state) {
          if (state is ProductLoadInProgress) {
            return const Center(child: LoadingView());
          } else if (state is ProductLoadSuccess) {
            // FILTRADO DE PRODUCTOS según categoría seleccionada 
            final productos = state.productos.where((product) {
              if (selectedCategory == 'Todos') return true;
              // Aquí podrías usar product.categoria si existiera:
              // return product.categoria == selectedCategory;
              return true; 
            }).toList();

            return Column(
              children: [
                SizedBox(
                  height: 60,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final category = categories[index];
                      final isSelected = selectedCategory == category;

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedCategory = category;
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.white : const Color(0xFFE2714D),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white),
                          ),
                          child: Center(
                            child: Text(
                              category,
                              style: TextStyle(
                                color: isSelected ? Colors.black : Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Expanded(
                  child: ProductsList(products: productos), // MOSTRAR PRODUCTOS
                ),
              ],
            );
          } else if (state is ProductLoadFailure) {
            return const Center(child: FailureView());
          } else {
            return const SizedBox.shrink();
          }
        },
      ),
    );
  }
}
