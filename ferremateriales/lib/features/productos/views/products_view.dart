import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../views/failure_view.dart';
import '../../../views/loading_view.dart';
import '../bloc/product_bloc.dart';
import '../widgets/producto_card.dart';

class ProductsPageView extends StatelessWidget {
  const ProductsPageView({super.key});

  @override
  Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      backgroundColor: Color(0xFFE2714D),
      title: const Text('Productos', style: TextStyle(color: Colors.white),),
      automaticallyImplyLeading: false, // Quita la flechita de regreso
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
          return ProductsList(products: state.productos);
        } else if (state is ProductLoadFailure) {
          return const Center(child: FailureView());
        } else {
          return const SizedBox.shrink(); // por si acaso
        }
      },
    ),
  );
  }
}