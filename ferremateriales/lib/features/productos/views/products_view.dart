import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/product_bloc.dart';
import '../widgets/producto_card.dart';

class ProductsView extends StatelessWidget {
  const ProductsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
      child:Column(
      children: [
        ListaWidget(),
        ElevatedButton(
              onPressed: () {
                context.read<ProductBloc>().add(ProductRegresarPressed());
              },
              child: const Text('regresar')
              ),
      ],
      )
      )
    );
  }
}
