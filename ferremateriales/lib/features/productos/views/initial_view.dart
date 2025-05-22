import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ferremateriales/features/productos/bloc/product_bloc.dart';

class InitialView extends StatelessWidget {
  const InitialView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("FerreMateriales", style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFFB84030),
      ),
      backgroundColor: Color(0xFFE2714D),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Bienvenido', style: TextStyle(color: Colors.white)),
            Text('Henry Guzman', style: TextStyle(color: Colors.white )),
            Text(''),
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