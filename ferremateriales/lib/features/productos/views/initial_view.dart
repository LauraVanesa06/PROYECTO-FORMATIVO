import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ferremateriales/features/productos/bloc/product_bloc.dart';

class InitialView extends StatelessWidget {
  const InitialView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            Text('Bienvenido'),
            Text('Henry Guzman'),
            ElevatedButton(
              onPressed: () {
                context.read<ProductBloc>().add(ProductEntrarPressed());
              },
              child: const Text('ver productos'),
            ),
          ],
        ),
      ),
    );
  }
}